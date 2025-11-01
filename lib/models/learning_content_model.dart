import 'package:flutter/material.dart';

/// Content type for learning materials
enum ContentType {
  video,
  article,
  guide,
  tutorial,
}

/// Category for organizing content
enum ContentCategory {
  smartphone,
  laptop,
  tablet,
  chargers,
  batteries,
  cables,
  general,
}

/// Learning content model for videos and articles
class LearningContent {
  final String id;
  final String title;
  final String description;
  final ContentType type;
  final ContentCategory category;
  final String? thumbnailUrl;
  final String? videoUrl; // YouTube URL or video file path
  final String? articleContent; // Rich text content for articles
  final Duration? duration; // For videos
  final String? author;
  final DateTime publishedDate;
  final List<String> tags;
  final int views;
  final bool isFeatured;

  LearningContent({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.category,
    this.thumbnailUrl,
    this.videoUrl,
    this.articleContent,
    this.duration,
    this.author,
    required this.publishedDate,
    this.tags = const [],
    this.views = 0,
    this.isFeatured = false,
  });

  /// Format duration for display (e.g., "5:30")
  String get formattedDuration {
    if (duration == null) return '';
    final minutes = duration!.inMinutes;
    final seconds = duration!.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  /// Get category display name
  String get categoryName {
    switch (category) {
      case ContentCategory.smartphone:
        return 'Smartphones';
      case ContentCategory.laptop:
        return 'Laptops';
      case ContentCategory.tablet:
        return 'Tablets';
      case ContentCategory.chargers:
        return 'Chargers';
      case ContentCategory.batteries:
        return 'Batteries';
      case ContentCategory.cables:
        return 'Cables';
      case ContentCategory.general:
        return 'General';
    }
  }

  /// Get icon for category
  IconData get categoryIcon {
    switch (category) {
      case ContentCategory.smartphone:
        return Icons.smartphone;
      case ContentCategory.laptop:
        return Icons.laptop;
      case ContentCategory.tablet:
        return Icons.tablet;
      case ContentCategory.chargers:
        return Icons.power;
      case ContentCategory.batteries:
        return Icons.battery_full;
      case ContentCategory.cables:
        return Icons.cable;
      case ContentCategory.general:
        return Icons.eco;
    }
  }

  /// Format views count (e.g., "1.2K", "5M")
  String get formattedViews {
    if (views < 1000) return views.toString();
    if (views < 1000000) return '${(views / 1000).toStringAsFixed(1)}K';
    return '${(views / 1000000).toStringAsFixed(1)}M';
  }

  /// Get relative time (e.g., "2 days ago")
  String get relativeTime {
    final now = DateTime.now();
    final difference = now.difference(publishedDate);

    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return '$years ${years == 1 ? 'year' : 'years'} ago';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
    } else {
      return 'Just now';
    }
  }
}
