import 'package:flutter/material.dart';
import '../../services/supabase_service.dart';
import '../../config/admin_config.dart';

class VideoFormScreen extends StatefulWidget {
  final Map<String, dynamic>? video;

  const VideoFormScreen({super.key, this.video});

  @override
  State<VideoFormScreen> createState() => _VideoFormScreenState();
}

class _VideoFormScreenState extends State<VideoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _service = AdminSupabaseService();
  
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _youtubeIdController;
  late TextEditingController _durationController;
  late TextEditingController _authorController;
  late TextEditingController _tagsController;
  
  String _selectedCategory = 'smartphone';
  bool _isFeatured = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    
    // Helper to safely convert any value to string
    String safeString(dynamic value) => value?.toString() ?? '';
    
    // Initialize controllers with existing data if editing
    _titleController = TextEditingController(text: safeString(widget.video?['title']));
    _descriptionController = TextEditingController(text: safeString(widget.video?['description']));
    _youtubeIdController = TextEditingController(text: safeString(widget.video?['youtube_video_id']));
    _durationController = TextEditingController(text: safeString(widget.video?['duration']));
    _authorController = TextEditingController(text: safeString(widget.video?['author']));
    
    // Convert tags array to comma-separated string
    final tags = widget.video?['tags'];
    if (tags is List) {
      _tagsController = TextEditingController(text: tags.join(', '));
    } else {
      _tagsController = TextEditingController();
    }
    
    if (widget.video != null) {
      _selectedCategory = safeString(widget.video!['category']).isNotEmpty 
          ? safeString(widget.video!['category']) 
          : 'smartphone';
      _isFeatured = widget.video!['is_featured'] == true;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _youtubeIdController.dispose();
    _durationController.dispose();
    _authorController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  String _extractYoutubeId(String input) {
    // Extract YouTube ID from various URL formats
    final regexps = [
      RegExp(r'youtube\.com/watch\?v=([a-zA-Z0-9_-]+)'),
      RegExp(r'youtu\.be/([a-zA-Z0-9_-]+)'),
      RegExp(r'youtube\.com/embed/([a-zA-Z0-9_-]+)'),
    ];

    for (var regexp in regexps) {
      final match = regexp.firstMatch(input);
      if (match != null) {
        return match.group(1)!;
      }
    }

    // If no URL pattern matches, assume it's already a video ID
    return input.trim();
  }

  Future<void> _saveVideo() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final videoId = _extractYoutubeId(_youtubeIdController.text);
      
      // Convert comma-separated tags to array
      final tagsString = _tagsController.text.trim();
      final tags = tagsString.isEmpty 
          ? <String>[] 
          : tagsString.split(',').map((t) => t.trim()).where((t) => t.isNotEmpty).toList();

      if (widget.video == null) {
        // Add new video
        await _service.addVideo(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          youtubeVideoId: videoId,
          category: _selectedCategory,
          duration: _durationController.text.trim(),
          author: _authorController.text.trim(),
          tags: tags,
          isFeatured: _isFeatured,
        );
      } else {
        // Update existing video
        final updateData = {
          'title': _titleController.text.trim(),
          'description': _descriptionController.text.trim(),
          'youtube_video_id': videoId,
          'category': _selectedCategory,
          'duration': _durationController.text.trim(),
          'author': _authorController.text.trim(),
          'tags': tags,
          'is_featured': _isFeatured,
        };
        await _service.updateVideo(widget.video!['id'].toString(), updateData);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.video == null ? 'Video added successfully' : 'Video updated successfully'),
            backgroundColor: const Color(0xFF2ECC71),
          ),
        );
        Navigator.pop(context, true); // Return true to indicate success
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
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
    final isEditing = widget.video != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Video' : 'Add Video'),
        backgroundColor: const Color(0xFF2ECC71),
        foregroundColor: Colors.white,
      ),
      body: Container(
        color: const Color(0xFFF5F7FA),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 800),
            padding: const EdgeInsets.all(32),
            child: Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(32),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // YouTube Video ID/URL
                      const Text(
                        'YouTube Video',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _youtubeIdController,
                        decoration: const InputDecoration(
                          labelText: 'YouTube URL or Video ID',
                          hintText: 'https://www.youtube.com/watch?v=... or dQw4w9WgXcQ',
                          prefixIcon: Icon(Icons.video_library),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a YouTube URL or video ID';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          // Show preview when ID is entered
                          setState(() {});
                        },
                      ),
                      
                      // YouTube preview
                      if (_youtubeIdController.text.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            'https://img.youtube.com/vi/${_extractYoutubeId(_youtubeIdController.text)}/mqdefault.jpg',
                            height: 180,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              height: 180,
                              color: Colors.grey[300],
                              child: const Center(
                                child: Text('Invalid YouTube ID'),
                              ),
                            ),
                          ),
                        ),
                      ],
                      
                      const SizedBox(height: 24),

                      // Title
                      TextFormField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          labelText: 'Title',
                          hintText: 'E-waste disposal guide',
                          prefixIcon: Icon(Icons.title),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a title';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Description
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          hintText: 'Learn how to properly dispose of electronic waste...',
                          prefixIcon: Icon(Icons.description),
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 4,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a description';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Category
                      DropdownButtonFormField<String>(
                        value: _selectedCategory,
                        decoration: const InputDecoration(
                          labelText: 'Category',
                          prefixIcon: Icon(Icons.category),
                          border: OutlineInputBorder(),
                        ),
                        items: AdminConfig.categories.map((cat) {
                          return DropdownMenuItem(
                            value: cat,
                            child: Text(AdminConfig.getCategoryDisplayName(cat)),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedCategory = value!;
                          });
                        },
                      ),
                      const SizedBox(height: 16),

                      // Duration and Author row
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _durationController,
                              decoration: const InputDecoration(
                                labelText: 'Duration',
                                hintText: '10:24',
                                prefixIcon: Icon(Icons.access_time),
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Required';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _authorController,
                              decoration: const InputDecoration(
                                labelText: 'Author',
                                hintText: 'John Doe',
                                prefixIcon: Icon(Icons.person),
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Required';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Tags
                      TextFormField(
                        controller: _tagsController,
                        decoration: const InputDecoration(
                          labelText: 'Tags (comma-separated)',
                          hintText: 'e-waste, recycling, disposal',
                          prefixIcon: Icon(Icons.tag),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Featured toggle
                      SwitchListTile(
                        title: const Text('Featured Video'),
                        subtitle: const Text('Show this video prominently in the app'),
                        value: _isFeatured,
                        onChanged: (value) {
                          setState(() {
                            _isFeatured = value;
                          });
                        },
                        activeColor: const Color(0xFF2ECC71),
                      ),
                      const SizedBox(height: 32),

                      // Save button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isSaving ? null : _saveVideo,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2ECC71),
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
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  isEditing ? 'Update Video' : 'Add Video',
                                  style: const TextStyle(fontSize: 16),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
