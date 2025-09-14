/// Hardcoded data constants for fallback when API fails
/// This centralizes all hardcoded data used throughout the app
class HardcodedData {
  // Private constructor to prevent instantiation
  HardcodedData._();

  /// Default job categories
  static const List<Map<String, String>> jobCategories = [
    {'id': 'plumbing', 'name': 'Plumbing'},
    {'id': 'electrical', 'name': 'Electrical'},
    {'id': 'carpentry', 'name': 'Carpentry'},
    {'id': 'painting', 'name': 'Painting'},
    {'id': 'cleaning', 'name': 'Cleaning'},
    {'id': 'gardening', 'name': 'Gardening'},
    {'id': 'repair', 'name': 'Repair'},
    {'id': 'installation', 'name': 'Installation'},
    {'id': 'other', 'name': 'Other'},
  ];

  /// Default skills for portfolio
  static const List<String> portfolioSkills = [
    'Plumbing',
    'Electrical',
    'Carpentry',
    'Painting',
    'Tiling',
    'Roofing',
    'Masonry',
    'Welding',
    'HVAC',
    'Landscaping',
    'Flooring',
    'Insulation',
    'Drywall',
    'Concrete',
    'Steel Work',
  ];

  /// Default locations for Tanzania
  static const List<String> tanzaniaLocations = [
    'Dar es Salaam',
    'Arusha',
    'Mwanza',
    'Dodoma',
    'Tanga',
    'Morogoro',
    'Mbeya',
    'Iringa',
    'Tabora',
    'Kigoma',
    'Mtwara',
    'Lindi',
    'Ruvuma',
    'Rukwa',
    'Katavi',
  ];

  /// Default error messages
  static const Map<String, String> errorMessages = {
    'network_error': 'Please check your internet connection and try again.',
    'server_error':
        'Server is temporarily unavailable. Please try again later.',
    'timeout_error': 'Request timed out. Please try again.',
    'unknown_error': 'An unexpected error occurred. Please try again.',
    'no_data': 'No data available at the moment.',
    'load_failed': 'Failed to load data. Please try again.',
  };

  /// Default app settings
  static const Map<String, dynamic> defaultSettings = {
    'theme': 'light',
    'language': 'en',
    'notifications': true,
    'location_permission': false,
    'camera_permission': false,
  };

  /// Default user preferences
  static const Map<String, dynamic> defaultUserPreferences = {
    'job_notifications': true,
    'message_notifications': true,
    'marketing_notifications': false,
    'location_sharing': false,
    'profile_visibility': 'public',
  };
}
