import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/youtube_config.dart';

/// Service for fetching YouTube video metadata using YouTube Data API v3
class YouTubeService {
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
    if (!YouTubeConfig.isConfigured) {
      throw Exception('YouTube API key not configured. Please add your API key to youtube_config.dart');
    }
    
    final videoId = extractVideoId(videoIdOrUrl);
    if (videoId == null) {
      throw Exception('Invalid YouTube URL or video ID');
    }
    
    try {
      final url = Uri.parse(
        '${YouTubeConfig.baseUrl}/videos?'
        'part=snippet,contentDetails,statistics&'
        'id=$videoId&'
        'key=${YouTubeConfig.apiKey}'
      );
      
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
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
        String thumbnailUrl = 'https://img.youtube.com/vi/$videoId/maxresdefault.jpg';
        if (thumbnails['maxres'] != null) {
          thumbnailUrl = thumbnails['maxres']['url'];
        } else if (thumbnails['high'] != null) {
          thumbnailUrl = thumbnails['high']['url'];
        }
        
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
      } else if (response.statusCode == 403) {
        throw Exception('API key invalid or quota exceeded');
      } else {
        throw Exception('Failed to fetch video data: ${response.statusCode}');
      }
    } catch (e) {
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
