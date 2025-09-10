import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';

/// Comprehensive logging utility for the Fundi App
/// Provides different log levels and formatted output for debugging and monitoring
class Logger {
  static const String _tag = 'FundiApp';

  /// Log levels for different types of messages
  static const int _verbose = 0;
  static const int _debug = 1;
  static const int _info = 2;
  static const int _warning = 3;
  static const int _error = 4;

  /// Log verbose messages (most detailed)
  static void verbose(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    _log(
      _verbose,
      'VERBOSE',
      message,
      tag: tag,
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// Log debug messages
  static void debug(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    _log(
      _debug,
      'DEBUG',
      message,
      tag: tag,
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// Log info messages
  static void info(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
    Map<String, dynamic>? data,
  }) {
    _log(
      _info,
      'INFO',
      message,
      tag: tag,
      error: error,
      stackTrace: stackTrace,
      data: data,
    );
  }

  /// Log warning messages
  static void warning(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    _log(
      _warning,
      'WARNING',
      message,
      tag: tag,
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// Log error messages
  static void error(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    _log(
      _error,
      'ERROR',
      message,
      tag: tag,
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// Log API requests
  static void apiRequest(
    String method,
    String url, {
    Map<String, dynamic>? headers,
    dynamic body,
  }) {
    final message = 'API Request: $method $url';
    final details = <String, dynamic>{
      'method': method,
      'url': url,
      'headers': headers,
      'body': body,
    };

    if (kDebugMode) {
      developer.log(message, name: '${_tag}_API', level: _info, error: details);
    }
  }

  /// Log API responses
  static void apiResponse(
    String method,
    String url,
    int statusCode, {
    dynamic response,
  }) {
    final message = 'API Response: $method $url - $statusCode';
    final details = <String, dynamic>{
      'method': method,
      'url': url,
      'statusCode': statusCode,
      'response': response,
    };

    if (kDebugMode) {
      developer.log(message, name: '${_tag}_API', level: _info, error: details);
    }
  }

  /// Log API errors
  static void apiError(
    String method,
    String url,
    Object error, {
    StackTrace? stackTrace,
  }) {
    final message = 'API Error: $method $url';

    if (kDebugMode) {
      developer.log(
        message,
        name: '${_tag}_API',
        level: _error,
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  /// Log user actions
  static void userAction(String action, {Map<String, dynamic>? data}) {
    final message = 'User Action: $action';

    if (kDebugMode) {
      developer.log(message, name: '${_tag}_USER', level: _info, error: data);
    }
  }

  /// Log navigation events
  static void navigation(String from, String to, {Map<String, dynamic>? data}) {
    final message = 'Navigation: $from -> $to';

    if (kDebugMode) {
      developer.log(message, name: '${_tag}_NAV', level: _debug, error: data);
    }
  }

  /// Log performance metrics
  static void performance(
    String operation,
    Duration duration, {
    Map<String, dynamic>? metadata,
  }) {
    final message = 'Performance: $operation took ${duration.inMilliseconds}ms';

    if (kDebugMode) {
      developer.log(
        message,
        name: '${_tag}_PERF',
        level: _info,
        error: {
          'operation': operation,
          'duration_ms': duration.inMilliseconds,
          ...?metadata,
        },
      );
    }
  }

  /// Internal logging method
  static void _log(
    int level,
    String levelName,
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
    Map<String, dynamic>? data,
  }) {
    if (kDebugMode) {
      final logData = <String, dynamic>{
        if (error != null) 'error': error,
        if (data != null) ...data,
      };

      developer.log(
        message,
        name: tag ?? _tag,
        level: level,
        error: logData.isNotEmpty ? logData : null,
        stackTrace: stackTrace,
      );
    }
  }
}
