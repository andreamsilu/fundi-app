import 'package:flutter/foundation.dart';
import 'env_config.dart';

/// Centralized API configuration
/// Manages all API-related URLs and endpoints
class ApiConfig {
  static const String _defaultApiVersion = 'v1';
  static const int _defaultTimeout = 30000;

  /// Get API base URL strictly from environment (.env or system)
  static String get baseUrl {
    final url = EnvConfig.get('API_BASE_URL', defaultValue: '');
    if (kDebugMode) {
      print('ApiConfig.baseUrl: $url');
    }
    return url;
  }

  /// Get API version
  static String get version => EnvConfig.get('API_VERSION', defaultValue: _defaultApiVersion);

  /// Get connection timeout
  static int get timeout => EnvConfig.getInt('API_TIMEOUT', defaultValue: _defaultTimeout);

  /// Check if using HTTPS
  static bool get isSecure => baseUrl.startsWith('https://');

  /// Get environment-specific configuration
  static Map<String, dynamic> get environmentConfig {
    return {
      'baseUrl': baseUrl,
      'version': version,
      'timeout': timeout,
      'isSecure': isSecure,
      'isDebug': kDebugMode,
    };
  }

  /// Validate API configuration
  static bool validate() {
    try {
      final uri = Uri.parse(baseUrl);
      return uri.hasScheme && uri.hasAuthority;
    } catch (e) {
      return false;
    }
  }

  /// Get full endpoint URL
  static String getFullUrl(String endpoint) {
    // Remove leading slash if present
    final cleanEndpoint = endpoint.startsWith('/') ? endpoint.substring(1) : endpoint;
    return '$baseUrl/$cleanEndpoint';
  }

  /// Get environment info for debugging
  static Map<String, dynamic> getDebugInfo() {
    return {
      'baseUrl': baseUrl,
      'version': version,
      'timeout': timeout,
      'isSecure': isSecure,
      'isDebug': kDebugMode,
    };
  }
}
