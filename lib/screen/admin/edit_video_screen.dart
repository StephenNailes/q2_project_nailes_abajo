import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/supabase_service.dart';
import '../../services/youtube_service.dart';

class EditVideoScreen extends StatefulWidget {
  final String videoId;
  
  const EditVideoScreen({
    super.key,
    required this.videoId,
  });

  @override
  State<EditVideoScreen> createState() => _EditVideoScreenState();
}

class _EditVideoScreenState extends State<EditVideoScreen> {
  final SupabaseService _supabaseService = SupabaseService();
  final _formKey = GlobalKey<FormState>();
  
  final _urlController = TextEditingController();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _authorController = TextEditingController();
  final _thumbnailController = TextEditingController();
  
  String _selectedCategory = 'General';
  int _duration = 0;
  bool _isFeatured = false;
  bool _isLoading = true;
  bool _isSaving = false;
  bool _isAutoFetching = false;

  final List<String> _categories = [
    'General',
    'Smartphones',
    'Laptops',
    'Tablets',
    'Chargers',
    'Batteries',
    'Cables',
  ];

  @override
  void initState() {
    super.initState();
    _loadVideoData();
  }

  @override
  void dispose() {
    _urlController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _authorController.dispose();
    _thumbnailController.dispose();
    super.dispose();
  }

  Future<void> _loadVideoData() async {
    try {
      final videos = await _supabaseService.getAllVideos();
      final video = videos.firstWhere(
        (v) => v['id'] == widget.videoId,
        orElse: () => <String, dynamic>{},
      );

      if (video.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Video not found'),
              backgroundColor: Colors.red,
            ),
          );
          context.go('/admin/videos');
        }
        return;
      }

      if (mounted) {
        setState(() {
          // Construct full YouTube URL from video ID
          final youtubeVideoId = video['youtube_video_id'] ?? '';
          _urlController.text = youtubeVideoId.isNotEmpty 
              ? 'https://www.youtube.com/watch?v=$youtubeVideoId'
              : '';
          
          _titleController.text = video['title'] ?? '';
          _descriptionController.text = video['description'] ?? '';
          _authorController.text = video['author'] ?? '';
          _thumbnailController.text = video['thumbnail_url'] ?? '';
          
          // Normalize category to match dropdown values
          String categoryFromDb = video['category'] ?? 'General';
          if (_categories.contains(categoryFromDb)) {
            _selectedCategory = categoryFromDb;
          } else {
            // Try to find a matching category (case-insensitive)
            final matchingCategory = _categories.firstWhere(
              (cat) => cat.toLowerCase() == categoryFromDb.toLowerCase(),
              orElse: () => 'General',
            );
            _selectedCategory = matchingCategory;
          }
          
          _duration = video['duration'] ?? 0;
          _isFeatured = video['is_featured'] ?? false;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('❌ Error loading video: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading video: $e'),
            backgroundColor: Colors.red,
          ),
        );
        context.go('/admin/videos');
      }
    }
  }

  Future<void> _autoFetch() async {
    if (_urlController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a YouTube URL first')),
      );
      return;
    }

    setState(() => _isAutoFetching = true);

    try {
      final metadata = await YouTubeService.fetchVideoMetadata(_urlController.text);
      
      if (metadata != null && mounted) {
        setState(() {
          _titleController.text = metadata['title'] ?? '';
          _descriptionController.text = metadata['description'] ?? '';
          _authorController.text = metadata['author'] ?? '';
          _thumbnailController.text = metadata['thumbnailUrl'] ?? '';
          _duration = metadata['duration'] ?? 0;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Video metadata fetched successfully!'),
            backgroundColor: Color(0xFF2ECC71),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isAutoFetching = false);
      }
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final videoId = YouTubeService.extractVideoId(_urlController.text);
    if (videoId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid YouTube URL')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      await _supabaseService.updateVideo(widget.videoId, {
        'youtube_video_id': videoId,
        'title': _titleController.text,
        'description': _descriptionController.text,
        'author': _authorController.text,
        'category': _selectedCategory,
        'duration': _duration,
        'thumbnail_url': _thumbnailController.text,
        'is_featured': _isFeatured,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Video updated successfully!'),
            backgroundColor: Color(0xFF2ECC71),
          ),
        );
        context.go('/admin/videos');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Edit Video',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: const Color(0xFFE74C3C),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        body: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE74C3C)),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Edit Video',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFFE74C3C),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE9FBEF), Color(0xFFD6F5E0)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // YouTube URL
              TextFormField(
                controller: _urlController,
                decoration: InputDecoration(
                  labelText: 'YouTube URL *',
                  hintText: 'https://www.youtube.com/watch?v=...',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  suffixIcon: _isAutoFetching
                      ? const Padding(
                          padding: EdgeInsets.all(12),
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      : IconButton(
                          icon: const Icon(Icons.cloud_download),
                          onPressed: _autoFetch,
                          tooltip: 'Auto-fetch metadata',
                        ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter YouTube URL';
                  }
                  if (!value.contains('youtube.com') && !value.contains('youtu.be')) {
                    return 'Please enter a valid YouTube URL';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Title
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Title *',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Description
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Description',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Author
              TextFormField(
                controller: _authorController,
                decoration: InputDecoration(
                  labelText: 'Author',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Category
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: InputDecoration(
                  labelText: 'Category *',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: _categories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => _selectedCategory = value!);
                },
              ),
              const SizedBox(height: 16),

              // Duration
              TextFormField(
                initialValue: _duration.toString(),
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Duration (seconds)',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onChanged: (value) {
                  setState(() => _duration = int.tryParse(value) ?? 0);
                },
              ),
              const SizedBox(height: 16),

              // Thumbnail URL
              TextFormField(
                controller: _thumbnailController,
                decoration: InputDecoration(
                  labelText: 'Thumbnail URL',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Featured toggle
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.star, color: Color(0xFFF39C12)),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Featured Video',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Show in featured section',
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: _isFeatured,
                      onChanged: (value) {
                        setState(() => _isFeatured = value);
                      },
                      activeColor: const Color(0xFF2ECC71),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Submit Button
              ElevatedButton(
                onPressed: _isSaving ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE74C3C),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Update Video',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
