import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Environment configuration utility
/// Handles loading configuration from .env file and environment variables
class EnvConfig {
  static final Map<String, String> _config = {};
  static bool _isInitialized = false;

  /// Initialize configuration from .env file and environment variables
  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Load .env file if it exists
      await dotenv.load(fileName: ".env");
      
      // Load from .env file first
      dotenv.env.forEach((key, value) {
        if (value != null && value.isNotEmpty) {
          _config[key] = value;
        }
      });
    } catch (e) {
      // .env file not found or error loading, continue with defaults
      print('Warning: Could not load .env file: $e');
    }

    // Load from system environment variables (override .env)
    Platform.environment.forEach((key, value) {
      if (value.isNotEmpty) {
        _config[key] = value;
      }
    });

    // Set default values if not configured (avoid real URLs)
    if (!_config.containsKey('API_BASE_URL')) {
      _config['API_BASE_URL'] = '';
    }
    if (!_config.containsKey('API_VERSION')) {
      _config['API_VERSION'] = 'v1';
    }
    if (!_config.containsKey('API_TIMEOUT')) {
      _config['API_TIMEOUT'] = '30000';
    }
    if (!_config.containsKey('MIN_PASSWORD_LENGTH')) {
      _config['MIN_PASSWORD_LENGTH'] = '6';
    }
    if (!_config.containsKey('MAX_NAME_LENGTH')) {
      _config['MAX_NAME_LENGTH'] = '50';
    }
    if (!_config.containsKey('MAX_DESCRIPTION_LENGTH')) {
      _config['MAX_DESCRIPTION_LENGTH'] = '500';
    }
    if (!_config.containsKey('DEFAULT_PAGE_SIZE')) {
      _config['DEFAULT_PAGE_SIZE'] = '20';
    }
    if (!_config.containsKey('MAX_PAGE_SIZE')) {
      _config['MAX_PAGE_SIZE'] = '100';
    }
    if (!_config.containsKey('MAX_FILE_SIZE')) {
      _config['MAX_FILE_SIZE'] = '5242880'; // 5MB
    }
    if (!_config.containsKey('ALLOWED_FILE_TYPES')) {
      _config['ALLOWED_FILE_TYPES'] = 'jpg,jpeg,png,gif';
    }

    _isInitialized = true;
    print('Environment configuration loaded successfully');
  }

  /// Get configuration value as string
  static String get(String key, {String? defaultValue}) {
    return _config[key] ?? defaultValue ?? '';
  }

  /// Get configuration value as integer
  static int getInt(String key, {int? defaultValue}) {
    final value = _config[key];
    if (value == null) return defaultValue ?? 0;
    return int.tryParse(value) ?? defaultValue ?? 0;
  }

  /// Get configuration value as double
  static double getDouble(String key, {double? defaultValue}) {
    final value = _config[key];
    if (value == null) return defaultValue ?? 0.0;
    return double.tryParse(value) ?? defaultValue ?? 0.0;
  }

  /// Get configuration value as boolean
  static bool getBool(String key, {bool? defaultValue}) {
    final value = _config[key];
    if (value == null) return defaultValue ?? false;
    return value.toLowerCase() == 'true';
  }

  /// Get configuration value as list
  static List<String> getList(String key, {List<String>? defaultValue}) {
    final value = _config[key];
    if (value == null) return defaultValue ?? [];
    return value.split(',').map((e) => e.trim()).toList();
  }

  /// Set configuration value
  static void set(String key, String value) {
    _config[key] = value;
  }

  /// Check if configuration key exists
  static bool has(String key) {
    return _config.containsKey(key);
  }

  /// Get all configuration keys
  static List<String> getKeys() {
    return _config.keys.toList();
  }

  /// Get all configuration values
  static Map<String, String> getAll() {
    return Map.from(_config);
  }

  /// Clear all configuration
  static void clear() {
    _config.clear();
  }

  /// Check if running in development mode
  static bool get isDevelopment {
    return get('ENVIRONMENT', defaultValue: 'development') == 'development';
  }

  /// Check if running in production mode
  static bool get isProduction {
    return get('ENVIRONMENT', defaultValue: 'development') == 'production';
  }

  /// Check if running in test mode
  static bool get isTest {
    return get('ENVIRONMENT', defaultValue: 'development') == 'test';
  }

  /// Get API base URL
  static String get apiBaseUrl {
    return get('API_BASE_URL', defaultValue: '');
  }

  /// Get API version
  static String get apiVersion {
    return get('API_VERSION', defaultValue: 'v1');
  }

  /// Get API timeout
  static int get apiTimeout {
    return getInt('API_TIMEOUT', defaultValue: 30000);
  }

  /// Get minimum password length
  static int get minPasswordLength {
    return getInt('MIN_PASSWORD_LENGTH', defaultValue: 6);
  }

  /// Get maximum name length
  static int get maxNameLength {
    return getInt('MAX_NAME_LENGTH', defaultValue: 50);
  }

  /// Get maximum description length
  static int get maxDescriptionLength {
    return getInt('MAX_DESCRIPTION_LENGTH', defaultValue: 500);
  }

  /// Get default page size
  static int get defaultPageSize {
    return getInt('DEFAULT_PAGE_SIZE', defaultValue: 20);
  }

  /// Get maximum page size
  static int get maxPageSize {
    return getInt('MAX_PAGE_SIZE', defaultValue: 100);
  }

  /// Get maximum file size
  static int get maxFileSize {
    return getInt('MAX_FILE_SIZE', defaultValue: 5242880); // 5MB
  }

  /// Get allowed file types
  static List<String> get allowedFileTypes {
    return getList(
      'ALLOWED_FILE_TYPES',
      defaultValue: ['jpg', 'jpeg', 'png', 'gif'],
    );
  }
}
