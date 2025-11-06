/// Community Post model for social sharing of disposal submissions
class CommunityPostModel {
  final String id;
  final String userId;
  final String userName;
  final String? userProfileImage;
  final String description;
  final String itemType;
  final String? brandModel;
  final int quantity;
  final String dropOffLocation;
  final String action; // 'disposed' or 'repurposed'
  final List<String> photoUrls;
  final int likesCount;
  final int commentsCount;
  final DateTime createdAt;
  final bool isLikedByCurrentUser;

  CommunityPostModel({
    required this.id,
    required this.userId,
    required this.userName,
    this.userProfileImage,
    required this.description,
    required this.itemType,
    this.brandModel,
    required this.quantity,
    required this.dropOffLocation,
    required this.action,
    this.photoUrls = const [],
    this.likesCount = 0,
    this.commentsCount = 0,
    required this.createdAt,
    this.isLikedByCurrentUser = false,
  });

  /// Create CommunityPostModel from JSON with user data
  factory CommunityPostModel.fromJson(
    Map<String, dynamic> json,
    String postId, {
    Map<String, dynamic>? userData,
    bool isLikedByCurrentUser = false,
  }) {
    return CommunityPostModel(
      id: postId,
      userId: json['user_id'] ?? '',
      userName: userData?['name'] ?? 'Anonymous User',
      userProfileImage: userData?['profile_image_url'],
      description: json['description'] ?? '',
      itemType: json['item_type'] ?? '',
      brandModel: json['brand_model'],
      quantity: json['quantity'] ?? 0,
      dropOffLocation: json['drop_off_location'] ?? '',
      action: json['action'] ?? 'disposed',
      photoUrls: json['photo_urls'] != null
          ? List<String>.from(json['photo_urls'])
          : [],
      likesCount: json['likes_count'] ?? 0,
      commentsCount: json['comments_count'] ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'].toString())
          : DateTime.now(),
      isLikedByCurrentUser: isLikedByCurrentUser,
    );
  }

  /// Convert to JSON for Supabase
  Map<String, dynamic> toSupabaseJson() {
    return {
      'user_id': userId,
      'description': description,
      'item_type': itemType,
      'brand_model': brandModel,
      'quantity': quantity,
      'drop_off_location': dropOffLocation,
      'action': action,
      'photo_urls': photoUrls,
      'likes_count': likesCount,
      'comments_count': commentsCount,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Create a copy with updated fields
  CommunityPostModel copyWith({
    String? id,
    String? userId,
    String? userName,
    String? userProfileImage,
    String? description,
    String? itemType,
    String? brandModel,
    int? quantity,
    String? dropOffLocation,
    String? action,
    List<String>? photoUrls,
    int? likesCount,
    int? commentsCount,
    DateTime? createdAt,
    bool? isLikedByCurrentUser,
  }) {
    return CommunityPostModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userProfileImage: userProfileImage ?? this.userProfileImage,
      description: description ?? this.description,
      itemType: itemType ?? this.itemType,
      brandModel: brandModel ?? this.brandModel,
      quantity: quantity ?? this.quantity,
      dropOffLocation: dropOffLocation ?? this.dropOffLocation,
      action: action ?? this.action,
      photoUrls: photoUrls ?? this.photoUrls,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      createdAt: createdAt ?? this.createdAt,
      isLikedByCurrentUser: isLikedByCurrentUser ?? this.isLikedByCurrentUser,
    );
  }

  /// Get action display text
  String get actionDisplay {
    return action == 'repurposed' ? 'Repurposed' : 'Disposed';
  }

  /// Get time ago string
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
    } else {
      return 'Just now';
    }
  }

  @override
  String toString() {
    return 'CommunityPostModel(id: $id, user: $userName, itemType: $itemType, action: $action)';
  }
}
