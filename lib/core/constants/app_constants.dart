/// Application-wide constants and configuration
/// This file contains all the static values used throughout the app
class AppConstants {
  // API Configuration
  static const String baseUrl = 'https://api.fundi.app/v1';
  static const String apiVersion = 'v1';
  static const int connectionTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 30000; // 30 seconds

  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String themeKey = 'theme_mode';
  static const String languageKey = 'language';

  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);

  // UI Constants
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double borderRadius = 12.0;
  static const double cardElevation = 2.0;

  // Validation
  static const int minPasswordLength = 6;
  static const int maxNameLength = 50;
  static const int maxDescriptionLength = 500;

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // File Upload
  static const int maxImageSize = 5 * 1024 * 1024; // 5MB
  static const List<String> allowedImageTypes = ['jpg', 'jpeg', 'png', 'gif'];

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
