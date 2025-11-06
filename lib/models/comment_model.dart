/// Comment model for community post comments
class CommentModel {
  final String id;
  final String postId;
  final String userId;
  final String userName;
  final String? userProfileImage;
  final String comment;
  final DateTime createdAt;

  CommentModel({
    required this.id,
    required this.postId,
    required this.userId,
    required this.userName,
    this.userProfileImage,
    required this.comment,
    required this.createdAt,
  });

  /// Create CommentModel from JSON with user data
  factory CommentModel.fromJson(
    Map<String, dynamic> json,
    String commentId, {
    Map<String, dynamic>? userData,
  }) {
    return CommentModel(
      id: commentId,
      postId: json['post_id'] ?? '',
      userId: json['user_id'] ?? '',
      userName: userData?['name'] ?? 'Anonymous User',
      userProfileImage: userData?['profile_image_url'],
      comment: json['comment'] ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'].toString())
          : DateTime.now(),
    );
  }

  /// Convert to JSON for Supabase
  Map<String, dynamic> toSupabaseJson() {
    return {
      'post_id': postId,
      'user_id': userId,
      'comment': comment,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Get time ago string
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '${months}mo ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
