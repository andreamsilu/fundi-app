import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Environment configuration service
/// Handles loading and accessing environment variables from .env file
class EnvConfig {
  static bool _isInitialized = false;

  /// Initialize environment variables from .env file
  static Future<void> initialize() async {
    if (!_isInitialized) {
      await dotenv.load(fileName: ".env");
      _isInitialized = true;
    }
  }

  /// Get environment variable value
  static String get(String key, {String defaultValue = ''}) {
    return dotenv.env[key] ?? defaultValue;
  }

  /// Get environment variable as integer
  static int getInt(String key, {int defaultValue = 0}) {
    final value = get(key);
    return int.tryParse(value) ?? defaultValue;
  }

  /// Get environment variable as boolean
  static bool getBool(String key, {bool defaultValue = false}) {
    final value = get(key).toLowerCase();
    return value == 'true' || value == '1';
  }

  /// Get environment variable as double
  static double getDouble(String key, {double defaultValue = 0.0}) {
    final value = get(key);
    return double.tryParse(value) ?? defaultValue;
  }

  /// Check if environment variable exists
  static bool has(String key) {
    return dotenv.env.containsKey(key) && dotenv.env[key]!.isNotEmpty;
  }

  /// Get all environment variables
  static Map<String, String> getAll() {
    return Map.from(dotenv.env);
  }
}
