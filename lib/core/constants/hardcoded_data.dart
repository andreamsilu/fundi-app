/// App constants for error messages and default settings
/// All dynamic data (categories, skills, locations) must be loaded from API
class HardcodedData {
  // Private constructor to prevent instantiation
  HardcodedData._();

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
