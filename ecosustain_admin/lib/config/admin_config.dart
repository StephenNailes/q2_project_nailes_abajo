/// Environment configuration for EcoSustain Admin Panel
class AdminConfig {
  // Supabase Configuration
  static const String supabaseUrl = 'https://uxiticipaqsfpsvijbcn.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InV4aXRpY2lwYXFzZnBzdmlqYmNuIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjE3NjcyMzcsImV4cCI6MjA3NzM0MzIzN30.2393xhFT3p41liNjiVjVwD53CjmmsPLq9s-ljg1eygA';
  
  // App Configuration
  static const String appName = 'EcoSustain Admin';
  static const String appVersion = '1.0.0';
  
  // Categories
  static const List<String> categories = [
    'smartphone',
    'laptop',
    'tablet',
    'charger',
    'battery',
    'cable',
    'general',
  ];
  
  // Category display names
  static String getCategoryDisplayName(String category) {
    switch (category) {
      case 'smartphone':
        return 'Smartphones';
      case 'laptop':
        return 'Laptops';
      case 'tablet':
        return 'Tablets';
      case 'charger':
        return 'Chargers';
      case 'battery':
        return 'Batteries';
      case 'cable':
        return 'Cables';
      case 'general':
        return 'General';
      default:
        return category;
    }
  }
}
