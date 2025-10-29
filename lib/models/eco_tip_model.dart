/// Eco tip model
class EcoTipModel {
  final String id;
  final String title;
  final String description;
  final String category;
  final String? imageUrl;
  final DateTime createdAt;

  EcoTipModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    this.imageUrl,
    required this.createdAt,
  });

  /// Create from JSON
  factory EcoTipModel.fromJson(Map<String, dynamic> json, String docId) {
    return EcoTipModel(
      id: docId,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? '',
      imageUrl: json['imageUrl'] ?? json['image_url'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'].toString())
          : (json['created_at'] != null
              ? DateTime.parse(json['created_at'].toString())
              : DateTime.now()),
    );
  }

  /// Convert to Firebase JSON
  Map<String, dynamic> toFirebaseJson() {
    return {
      'title': title,
      'description': description,
      'category': category,
      'imageUrl': imageUrl,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Convert to Supabase JSON
  Map<String, dynamic> toSupabaseJson() {
    return {
      'title': title,
      'description': description,
      'category': category,
      'image_url': imageUrl,
      'created_at': createdAt.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'EcoTipModel(id: $id, title: $title, category: $category)';
  }
}
