/// Notification model for in-app notifications
class NotificationModel {
  final String id;
  final String userId;
  final String type; // 'like', 'comment', 'follow', 'post_approved', 'system'
  final String title;
  final String message;
  final String? actorId; // User who triggered the notification
  final String? actorName;
  final String? actorProfileImage;
  final String? relatedPostId; // For likes/comments
  final String? relatedCommentId;
  final bool isRead;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.message,
    this.actorId,
    this.actorName,
    this.actorProfileImage,
    this.relatedPostId,
    this.relatedCommentId,
    this.isRead = false,
    required this.createdAt,
  });

  /// Create NotificationModel from JSON
  factory NotificationModel.fromJson(Map<String, dynamic> json, String notificationId) {
    return NotificationModel(
      id: notificationId,
      userId: json['user_id'] ?? '',
      type: json['type'] ?? 'system',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      actorId: json['actor_id'],
      actorName: json['actor_name'],
      actorProfileImage: json['actor_profile_image'],
      relatedPostId: json['related_post_id'],
      relatedCommentId: json['related_comment_id'],
      isRead: json['is_read'] ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'].toString())
          : DateTime.now(),
    );
  }

  /// Convert to JSON for Supabase
  Map<String, dynamic> toSupabaseJson() {
    return {
      'user_id': userId,
      'type': type,
      'title': title,
      'message': message,
      'actor_id': actorId,
      'actor_name': actorName,
      'actor_profile_image': actorProfileImage,
      'related_post_id': relatedPostId,
      'related_comment_id': relatedCommentId,
      'is_read': isRead,
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

  /// Create a copy with updated fields
  NotificationModel copyWith({
    String? id,
    String? userId,
    String? type,
    String? title,
    String? message,
    String? actorId,
    String? actorName,
    String? actorProfileImage,
    String? relatedPostId,
    String? relatedCommentId,
    bool? isRead,
    DateTime? createdAt,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      title: title ?? this.title,
      message: message ?? this.message,
      actorId: actorId ?? this.actorId,
      actorName: actorName ?? this.actorName,
      actorProfileImage: actorProfileImage ?? this.actorProfileImage,
      relatedPostId: relatedPostId ?? this.relatedPostId,
      relatedCommentId: relatedCommentId ?? this.relatedCommentId,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
