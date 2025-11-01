import 'package:flutter_dotenv/flutter_dotenv.dart';

/// YouTube Data API v3 configuration
class YouTubeConfig {
  // Get YouTube API key from environment variable
  static String get apiKey => dotenv.env['YOUTUBE_API_KEY'] ?? '';
  
  // API endpoint
  static const String baseUrl = 'https://www.googleapis.com/youtube/v3';
  
  // Validate if API key is configured
  static bool get isConfigured => apiKey.isNotEmpty && apiKey != 'YOUR_YOUTUBE_API_KEY_HERE';
}
