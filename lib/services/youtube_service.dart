import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../config/env_config.dart';

/// Service for fetching YouTube video metadata using YouTube Data API v3
class YouTubeService {
  static const String _baseUrl = 'https://www.googleapis.com/youtube/v3';
  
  /// Check if YouTube API is configured
  static bool get isConfigured => 
      EnvConfig.youtubeApiKey.isNotEmpty && 
      EnvConfig.youtubeApiKey != 'YOUR_YOUTUBE_API_KEY_HERE';
  
  /// Extract video ID from various YouTube URL formats
  static String? extractVideoId(String url) {
    // Already just the ID
    if (!url.contains('youtube.com') && !url.contains('youtu.be') && url.length == 11) {
      return url;
    }
    
    final patterns = [
      RegExp(r'youtube\.com/watch\?v=([^&]+)'),
      RegExp(r'youtube\.com/embed/([^?]+)'),
      RegExp(r'youtu\.be/([^?]+)'),
      RegExp(r'youtube\.com/v/([^?]+)'),
    ];
    
    for (final pattern in patterns) {
      final match = pattern.firstMatch(url);
      if (match != null && match.groupCount >= 1) {
        return match.group(1);
      }
    }
    
    return null;
  }
  
  /// Fetch video metadata from YouTube Data API v3
  /// Returns a map with: title, description, duration, thumbnailUrl
  static Future<Map<String, dynamic>?> fetchVideoMetadata(String videoIdOrUrl) async {
    if (!isConfigured) {
      throw Exception('YouTube API key not configured. Please add YOUTUBE_API_KEY to .env file');
    }
    
    final videoId = extractVideoId(videoIdOrUrl);
    if (videoId == null) {
      throw Exception('Invalid YouTube URL or video ID');
    }
    
    try {
      final url = Uri.parse(
        '$_baseUrl/videos?'
        'part=snippet,contentDetails,statistics&'
        'id=$videoId&'
        'key=${EnvConfig.youtubeApiKey}'
      );
      
      final response = await http.get(url);
      
      if (response.statusCode == 403) {
        throw Exception('YouTube API key is invalid, restricted, or quota exceeded. Please check your API key configuration in Google Cloud Console:\n1. Enable YouTube Data API v3\n2. Remove HTTP referrer restrictions\n3. Check quota limits');
      } else if (response.statusCode == 404) {
        throw Exception('Video not found. Please check the YouTube URL.');
      } else if (response.statusCode != 200) {
        throw Exception('Failed to fetch video data: ${response.statusCode}');
      }
      
      final data = json.decode(response.body);
      
      if (data['items'] == null || (data['items'] as List).isEmpty) {
        throw Exception('Video not found');
      }
      
      final item = data['items'][0];
      final snippet = item['snippet'];
      final contentDetails = item['contentDetails'];
      final statistics = item['statistics'];
        
      // Parse ISO 8601 duration (e.g., PT15M33S) to seconds
      final durationString = contentDetails['duration'] as String;
      final durationSeconds = _parseDuration(durationString);
      
      // Get best thumbnail
      final thumbnails = snippet['thumbnails'];
      String thumbnailUrl = 'https://img.youtube.com/vi/$videoId/hqdefault.jpg'; // Most reliable default
      if (thumbnails['maxres'] != null) {
        thumbnailUrl = thumbnails['maxres']['url'];
      } else if (thumbnails['standard'] != null) {
        thumbnailUrl = thumbnails['standard']['url'];
      } else if (thumbnails['high'] != null) {
        thumbnailUrl = thumbnails['high']['url'];
      } else if (thumbnails['medium'] != null) {
        thumbnailUrl = thumbnails['medium']['url'];
      }
      
      debugPrint('✅ YouTube metadata fetched for: ${snippet['title']}');
      
      return {
        'title': snippet['title'] ?? '',
        'description': snippet['description'] ?? '',
        'duration': durationSeconds,
        'thumbnailUrl': thumbnailUrl,
        'author': snippet['channelTitle'] ?? '',
        'publishedDate': snippet['publishedAt'] ?? '',
        'views': int.tryParse(statistics['viewCount']?.toString() ?? '0') ?? 0,
        'videoId': videoId,
      };
    } catch (e) {
      debugPrint('❌ YouTube API error: $e');
      rethrow;
    }
  }
  
  /// Parse ISO 8601 duration format to seconds
  /// Example: PT15M33S = 933 seconds, PT1H2M10S = 3730 seconds
  static int _parseDuration(String duration) {
    final regex = RegExp(r'PT(?:(\d+)H)?(?:(\d+)M)?(?:(\d+)S)?');
    final match = regex.firstMatch(duration);
    
    if (match == null) return 0;
    
    final hours = int.tryParse(match.group(1) ?? '0') ?? 0;
    final minutes = int.tryParse(match.group(2) ?? '0') ?? 0;
    final seconds = int.tryParse(match.group(3) ?? '0') ?? 0;
    
    return (hours * 3600) + (minutes * 60) + seconds;
  }
  
  /// Format duration in seconds to readable string (e.g., "15:33", "1:02:10")
  static String formatDuration(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;
    
    if (hours > 0) {
      return '$hours:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    } else {
      return '$minutes:${secs.toString().padLeft(2, '0')}';
    }
  }
}
