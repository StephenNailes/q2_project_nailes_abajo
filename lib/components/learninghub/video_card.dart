import 'package:flutter/material.dart';
import '../../models/learning_content_model.dart';

/// Video card component for displaying video content
class VideoCard extends StatefulWidget {
  final LearningContent video;
  final VoidCallback onTap;
  final bool isBookmarked;
  final VoidCallback? onBookmark;

  const VideoCard({
    super.key,
    required this.video,
    required this.onTap,
    this.isBookmarked = false,
    this.onBookmark,
  });

  @override
  State<VideoCard> createState() => _VideoCardState();
}

class _VideoCardState extends State<VideoCard> {
  int _thumbnailAttempt = 0;
  
  // YouTube thumbnail quality fallback order
  List<String> _getThumbnailUrls() {
    final url = widget.video.thumbnailUrl ?? '';
    
    // If it's already a YouTube thumbnail URL, extract the video ID
    String? videoId;
    
    // Try to extract from various YouTube URL formats
    final patterns = [
      RegExp(r'img\.youtube\.com/vi/([^/]+)/'),
      RegExp(r'youtube\.com/watch\?v=([^&]+)'),
      RegExp(r'youtu\.be/([^?]+)'),
      RegExp(r'/vi/([^/]+)'),
    ];
    
    for (final pattern in patterns) {
      final match = pattern.firstMatch(url);
      if (match != null) {
        videoId = match.group(1);
        break;
      }
    }
    
    if (videoId == null || videoId.isEmpty) {
      return [url]; // Return original URL if no video ID found
    }
    
    // Return multiple quality options as fallback
    return [
      'https://img.youtube.com/vi/$videoId/maxresdefault.jpg', // Highest quality
      'https://img.youtube.com/vi/$videoId/sddefault.jpg',     // Standard quality
      'https://img.youtube.com/vi/$videoId/hqdefault.jpg',     // High quality
      'https://img.youtube.com/vi/$videoId/mqdefault.jpg',     // Medium quality
      'https://img.youtube.com/vi/$videoId/default.jpg',       // Default quality
    ];
  }

  @override
  Widget build(BuildContext context) {
    final thumbnailUrls = _getThumbnailUrls();
    final currentUrl = _thumbnailAttempt < thumbnailUrls.length 
        ? thumbnailUrls[_thumbnailAttempt] 
        : null;

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Video thumbnail with play button and duration
            Stack(
              children: [
                // Thumbnail with aspect ratio
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                      color: Colors.grey[300],
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                      child: currentUrl != null
                          ? Image.network(
                              currentUrl,
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Center(
                                  child: CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes != null
                                        ? loadingProgress.cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                        : null,
                                    color: const Color(0xFF2ECC71),
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                // Try next quality if available
                                if (_thumbnailAttempt < thumbnailUrls.length - 1) {
                                  WidgetsBinding.instance.addPostFrameCallback((_) {
                                    if (mounted) {
                                      setState(() {
                                        _thumbnailAttempt++;
                                      });
                                    }
                                  });
                                }
                                // Show fallback icon
                                return Center(
                                  child: Icon(
                                    widget.video.categoryIcon,
                                    size: 64,
                                    color: Colors.grey[400],
                                  ),
                                );
                              },
                            )
                          : Center(
                              child: Icon(
                                widget.video.categoryIcon,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                            ),
                    ),
                  ),
                ),
                
                // Play button overlay
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.3),
                        ],
                      ),
                    ),
                    child: Center(
                      child: Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: const Color(0xFF2ECC71).withValues(alpha: 0.95),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.play_arrow,
                          color: Colors.white,
                          size: 36,
                        ),
                      ),
                    ),
                  ),
                ),
                
                // Duration badge
                if (widget.video.duration != null)
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.75),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        widget.video.formattedDuration,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  
                // Category badge
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2ECC71),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          widget.video.categoryIcon,
                          size: 14,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          widget.video.categoryName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            
            // Video info
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    widget.video.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  
                  // Description
                  Text(
                    widget.video.description,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  
                  // Metadata row
                  Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      // Author
                      if (widget.video.author != null)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.person_outline, size: 14, color: Colors.grey[500]),
                            const SizedBox(width: 4),
                            Text(
                              widget.video.author!,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      
                      // Views
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.visibility_outlined, size: 14, color: Colors.grey[500]),
                          const SizedBox(width: 4),
                          Text(
                            '${widget.video.formattedViews} views',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      
                      // Time
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.schedule, size: 14, color: Colors.grey[500]),
                          const SizedBox(width: 4),
                          Text(
                            widget.video.relativeTime,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  
                  // Bookmark button (separate row)
                  if (widget.onBookmark != null)
                    Align(
                      alignment: Alignment.centerRight,
                      child: IconButton(
                        icon: Icon(
                          widget.isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                          color: widget.isBookmarked ? const Color(0xFF2ECC71) : Colors.grey[400],
                        ),
                        onPressed: widget.onBookmark,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
