/// YouTube Data API v3 configuration
class YouTubeConfig {
  // TODO: Replace with your actual YouTube Data API v3 key
  // Get your key from: https://console.cloud.google.com/apis/credentials
  static const String apiKey = 'YOUR_YOUTUBE_API_KEY_HERE';
  
  // API endpoint
  static const String baseUrl = 'https://www.googleapis.com/youtube/v3';
  
  // Validate if API key is configured
  static bool get isConfigured => apiKey != 'YOUR_YOUTUBE_API_KEY_HERE' && apiKey.isNotEmpty;
}
