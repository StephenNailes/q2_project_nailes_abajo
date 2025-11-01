/// User model for EcoSustain app
class UserModel {
  final String id;
  final String name;
  final String email;
  final String? profileImageUrl;
  final int totalDisposed;
  final DateTime createdAt;
  final DateTime? updatedAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.profileImageUrl,
    this.totalDisposed = 0,
    required this.createdAt,
    this.updatedAt,
  });

  /// Create UserModel from JSON (Firebase/Supabase)
  factory UserModel.fromJson(Map<String, dynamic> json, String userId) {
    return UserModel(
      id: userId,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      profileImageUrl: json['profileImageUrl'] ?? json['profile_image_url'],
      totalDisposed: json['totalDisposed'] ?? json['total_disposed'] ?? 0,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'].toString())
          : (json['created_at'] != null
              ? DateTime.parse(json['created_at'].toString())
              : DateTime.now()),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'].toString())
          : (json['updated_at'] != null
              ? DateTime.parse(json['updated_at'].toString())
              : null),
    );
  }

  /// Convert UserModel to JSON for Firebase
  Map<String, dynamic> toFirebaseJson() {
    return {
      'name': name,
      'email': email,
      'profileImageUrl': profileImageUrl,
      'totalDisposed': totalDisposed,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// Convert UserModel to JSON for Supabase
  Map<String, dynamic> toSupabaseJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'profile_image_url': profileImageUrl,
      'total_disposed': totalDisposed,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// Create a copy with updated fields
  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? profileImageUrl,
    int? totalDisposed,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      totalDisposed: totalDisposed ?? this.totalDisposed,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'UserModel(id: $id, name: $name, email: $email, totalDisposed: $totalDisposed)';
  }
}
