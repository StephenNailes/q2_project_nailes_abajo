import 'package:flutter/material.dart';
import '../../services/supabase_service.dart';
import '../../config/admin_config.dart';

class ArticleFormScreen extends StatefulWidget {
  final Map<String, dynamic>? article;

  const ArticleFormScreen({super.key, this.article});

  @override
  State<ArticleFormScreen> createState() => _ArticleFormScreenState();
}

class _ArticleFormScreenState extends State<ArticleFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _service = AdminSupabaseService();
  
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _heroImageController;
  late TextEditingController _authorController;
  late TextEditingController _tagsController;
  late TextEditingController _readingTimeController;
  late TextEditingController _markdownController;
  
  String _selectedCategory = 'smartphone';
  bool _isFeatured = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    
    // Helper to safely convert any value to string
    String safeString(dynamic value) => value?.toString() ?? '';
    
    _titleController = TextEditingController(text: safeString(widget.article?['title']));
    _descriptionController = TextEditingController(text: safeString(widget.article?['description']));
    _heroImageController = TextEditingController(text: safeString(widget.article?['hero_image_url']));
    _authorController = TextEditingController(text: safeString(widget.article?['author']));
    _readingTimeController = TextEditingController(
      text: safeString(widget.article?['reading_time_minutes'])
    );
    _markdownController = TextEditingController(text: safeString(widget.article?['content']));
    
    final tags = widget.article?['tags'];
    if (tags is List) {
      _tagsController = TextEditingController(text: tags.join(', '));
    } else {
      _tagsController = TextEditingController();
    }
    
    if (widget.article != null) {
      _selectedCategory = safeString(widget.article!['category']).isNotEmpty 
          ? safeString(widget.article!['category']) 
          : 'smartphone';
      _isFeatured = widget.article!['is_featured'] == true;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _heroImageController.dispose();
    _authorController.dispose();
    _tagsController.dispose();
    _readingTimeController.dispose();
    _markdownController.dispose();
    super.dispose();
  }

  int _calculateReadingTime(String content) {
    final wordCount = content.split(RegExp(r'\s+')).length;
    final minutes = (wordCount / 200).ceil(); // Average reading speed
    return minutes > 0 ? minutes : 1;
  }

  Future<void> _saveArticle() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final tagsString = _tagsController.text.trim();
      final tags = tagsString.isEmpty 
          ? <String>[] 
          : tagsString.split(',').map((t) => t.trim()).where((t) => t.isNotEmpty).toList();

      // Auto-calculate reading time if not provided
      int readingTime;
      if (_readingTimeController.text.isEmpty) {
        readingTime = _calculateReadingTime(_markdownController.text);
      } else {
        readingTime = int.tryParse(_readingTimeController.text) ?? 
                     _calculateReadingTime(_markdownController.text);
      }

      if (widget.article == null) {
        // Add new article
        await _service.addArticle(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          content: _markdownController.text.trim(),
          category: _selectedCategory,
          author: _authorController.text.trim(),
          heroImageUrl: _heroImageController.text.trim().isEmpty 
              ? null 
              : _heroImageController.text.trim(),
          tags: tags,
          readingTimeMinutes: readingTime,
          isFeatured: _isFeatured,
        );
      } else {
        // Update existing article
        final updateData = {
          'title': _titleController.text.trim(),
          'description': _descriptionController.text.trim(),
          'content': _markdownController.text.trim(),
          'category': _selectedCategory,
          'author': _authorController.text.trim(),
          'hero_image_url': _heroImageController.text.trim().isEmpty 
              ? null 
              : _heroImageController.text.trim(),
          'tags': tags,
          'reading_time_minutes': readingTime,
          'is_featured': _isFeatured,
        };
        await _service.updateArticle(widget.article!['id'].toString(), updateData);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.article == null ? 'Article added successfully' : 'Article updated successfully'),
            backgroundColor: const Color(0xFF2ECC71),
          ),
        );
        Navigator.pop(context, true);
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
    final isEditing = widget.article != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Article' : 'Add Article'),
        backgroundColor: const Color(0xFF2ECC71),
        foregroundColor: Colors.white,
      ),
      body: Container(
        color: const Color(0xFFF5F7FA),
        child: Row(
          children: [
            // Form side
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(32),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Article Details',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Title
                      TextFormField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          labelText: 'Title',
                          hintText: 'Understanding E-waste Impact',
                          prefixIcon: Icon(Icons.title),
                          border: OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.white,
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
                          hintText: 'A brief overview of the article...',
                          prefixIcon: Icon(Icons.description),
                          border: OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        maxLines: 3,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a description';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Hero Image URL
                      TextFormField(
                        controller: _heroImageController,
                        decoration: const InputDecoration(
                          labelText: 'Hero Image URL (optional)',
                          hintText: 'https://example.com/image.jpg',
                          prefixIcon: Icon(Icons.image),
                          border: OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Category
                      DropdownButtonFormField<String>(
                        value: _selectedCategory,
                        decoration: const InputDecoration(
                          labelText: 'Category',
                          prefixIcon: Icon(Icons.category),
                          border: OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.white,
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

                      // Author and Reading Time row
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _authorController,
                              decoration: const InputDecoration(
                                labelText: 'Author',
                                hintText: 'Jane Smith',
                                prefixIcon: Icon(Icons.person),
                                border: OutlineInputBorder(),
                                filled: true,
                                fillColor: Colors.white,
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
                              controller: _readingTimeController,
                              decoration: const InputDecoration(
                                labelText: 'Reading Time (min)',
                                hintText: 'Auto-calculated',
                                prefixIcon: Icon(Icons.access_time),
                                border: OutlineInputBorder(),
                                filled: true,
                                fillColor: Colors.white,
                              ),
                              keyboardType: TextInputType.number,
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
                          hintText: 'environment, sustainability, recycling',
                          prefixIcon: Icon(Icons.tag),
                          border: OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Featured toggle
                      SwitchListTile(
                        title: const Text('Featured Article'),
                        subtitle: const Text('Show this article prominently in the app'),
                        value: _isFeatured,
                        onChanged: (value) {
                          setState(() {
                            _isFeatured = value;
                          });
                        },
                        activeColor: const Color(0xFF2ECC71),
                        tileColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: const BorderSide(color: Colors.black12),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Markdown Content Editor
                      const Text(
                        'Article Content (Markdown)',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.black26),
                        ),
                        child: TextFormField(
                          controller: _markdownController,
                          decoration: const InputDecoration(
                            hintText: 'Write your article content in Markdown...\n\n# Heading 1\n## Heading 2\n\n**Bold text**\n*Italic text*\n\n- List item 1\n- List item 2',
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.all(16),
                          ),
                          maxLines: 20,
                          style: const TextStyle(fontFamily: 'monospace'),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter article content';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Save button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isSaving ? null : _saveArticle,
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
                                  isEditing ? 'Update Article' : 'Add Article',
                                  style: const TextStyle(fontSize: 16),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Preview side
            Container(
              width: 400,
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Colors.grey[300]!),
                      ),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.preview, color: Color(0xFF2ECC71)),
                        SizedBox(width: 8),
                        Text(
                          'Preview',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (_heroImageController.text.isNotEmpty) ...[
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                _heroImageController.text,
                                width: double.infinity,
                                height: 200,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Container(
                                  height: 200,
                                  color: Colors.grey[300],
                                  child: const Center(child: Text('Invalid URL')),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                          Text(
                            _titleController.text.isEmpty 
                                ? 'Article Title' 
                                : _titleController.text,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _descriptionController.text.isEmpty 
                                ? 'Article description will appear here...' 
                                : _descriptionController.text,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _markdownController.text.isEmpty 
                                ? 'Article content will be rendered here...' 
                                : _markdownController.text,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
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
