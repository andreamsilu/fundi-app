import '../config/env_config.dart';
import '../config/api_config.dart';

/// Application-wide constants and configuration
/// This file contains all the static values used throughout the app
class AppConstants {
  // API Configuration
  static String get baseUrl => ApiConfig.baseUrl;
  static String get apiVersion =>
      EnvConfig.get('API_VERSION', defaultValue: 'v1');
  static int get connectionTimeout => ApiConfig.timeout;
  static int get receiveTimeout => ApiConfig.timeout;

  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String themeKey = 'theme_mode';
  static const String languageKey = 'language';

  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);

  // UI Constants (compact defaults)
  static const double defaultPadding = 12.0; // was 16.0
  static const double smallPadding = 6.0; // was 8.0
  static const double largePadding = 20.0; // was 24.0
  static const double borderRadius = 10.0; // was 12.0
  static const double cardElevation = 2.0;

  // Asset Paths
  static const String logoPath = 'assets/images/logo.png';

  // Validation
  static int get minPasswordLength =>
      EnvConfig.getInt('MIN_PASSWORD_LENGTH', defaultValue: 6);
  static int get maxNameLength =>
      EnvConfig.getInt('MAX_NAME_LENGTH', defaultValue: 50);
  static int get maxDescriptionLength =>
      EnvConfig.getInt('MAX_DESCRIPTION_LENGTH', defaultValue: 500);

  // Pagination
  static int get defaultPageSize =>
      EnvConfig.getInt('DEFAULT_PAGE_SIZE', defaultValue: 20);
  static int get maxPageSize =>
      EnvConfig.getInt('MAX_PAGE_SIZE', defaultValue: 100);

  // File Upload
  static int get maxImageSize =>
      EnvConfig.getInt('MAX_FILE_SIZE', defaultValue: 5 * 1024 * 1024);
  static List<String> get allowedImageTypes => EnvConfig.get(
    'ALLOWED_FILE_TYPES',
    defaultValue: 'jpg,jpeg,png,gif',
  ).split(',');

  // Error Messages
  static const String networkErrorMessage =
      'Please check your internet connection';
  static const String serverErrorMessage =
      'Something went wrong. Please try again';
  static const String unauthorizedMessage =
      'Session expired. Please login again';
  static const String validationErrorMessage =
      'Please check your input and try again';
}
