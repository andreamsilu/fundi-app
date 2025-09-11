import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';

/// Centralized logging utility for the application
/// Provides different log levels and formatted output
class Logger {
  static const String _tag = 'FundiApp';

  /// Log info message
  static void info(String message, {Map<String, dynamic>? data}) {
    if (kDebugMode) {
      developer.log(
        message,
        name: _tag,
        level: 800,
        time: DateTime.now(),
        error: data != null ? data.toString() : null,
      );
    }
  }

  /// Log warning message
  static void warning(String message, {Map<String, dynamic>? data, Object? error}) {
    if (kDebugMode) {
      developer.log(
        message,
        name: _tag,
        level: 900,
        time: DateTime.now(),
        error: error ?? (data != null ? data.toString() : null),
      );
    }
  }

  /// Log error message
  static void error(String message, {Object? error, StackTrace? stackTrace}) {
    if (kDebugMode) {
      developer.log(
        message,
        name: _tag,
        level: 1000,
        time: DateTime.now(),
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  /// Log debug message
  static void debug(String message, {Map<String, dynamic>? data}) {
    if (kDebugMode) {
      developer.log(
        message,
        name: _tag,
        level: 700,
        time: DateTime.now(),
        error: data != null ? data.toString() : null,
      );
    }
  }

  /// Log API request
  static void apiRequest(
    String method,
    String url, {
    Map<String, dynamic>? headers,
    dynamic body,
  }) {
    if (kDebugMode) {
      developer.log(
        'API Request: $method $url',
        name: '${_tag}_API',
        level: 800,
        time: DateTime.now(),
        error: {
          'headers': headers,
          'body': body,
        }.toString(),
      );
    }
  }

  /// Log API response
  static void apiResponse(
    String method,
    String url,
    int statusCode, {
    dynamic response,
  }) {
    if (kDebugMode) {
      developer.log(
        'API Response: $method $url - $statusCode',
        name: '${_tag}_API',
        level: 800,
        time: DateTime.now(),
        error: response?.toString(),
      );
    }
  }

  /// Log API error
  static void apiError(
    String method,
    String url,
    Object error, {
    StackTrace? stackTrace,
  }) {
    if (kDebugMode) {
      developer.log(
        'API Error: $method $url',
        name: '${_tag}_API',
        level: 1000,
        time: DateTime.now(),
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  /// Log authentication events
  static void auth(String message, {Map<String, dynamic>? data}) {
    if (kDebugMode) {
      developer.log(
        'AUTH: $message',
        name: '${_tag}_AUTH',
        level: 800,
        time: DateTime.now(),
        error: data?.toString(),
      );
    }
  }

  /// Log payment events
  static void payment(String message, {Map<String, dynamic>? data}) {
    if (kDebugMode) {
      developer.log(
        'PAYMENT: $message',
        name: '${_tag}_PAYMENT',
        level: 800,
        time: DateTime.now(),
        error: data?.toString(),
      );
    }
  }

  /// Log rating events
  static void rating(String message, {Map<String, dynamic>? data}) {
    if (kDebugMode) {
      developer.log(
        'RATING: $message',
        name: '${_tag}_RATING',
        level: 800,
        time: DateTime.now(),
        error: data?.toString(),
      );
    }
  }

  /// Log job events
  static void job(String message, {Map<String, dynamic>? data}) {
    if (kDebugMode) {
      developer.log(
        'JOB: $message',
        name: '${_tag}_JOB',
        level: 800,
        time: DateTime.now(),
        error: data?.toString(),
      );
    }
  }

  /// Log portfolio events
  static void portfolio(String message, {Map<String, dynamic>? data}) {
    if (kDebugMode) {
      developer.log(
        'PORTFOLIO: $message',
        name: '${_tag}_PORTFOLIO',
        level: 800,
        time: DateTime.now(),
        error: data?.toString(),
      );
    }
  }

  /// Log user events
  static void user(String message, {Map<String, dynamic>? data}) {
    if (kDebugMode) {
      developer.log(
        'USER: $message',
        name: '${_tag}_USER',
        level: 800,
        time: DateTime.now(),
        error: data?.toString(),
      );
    }
  }

  /// Log user actions (alias for user method)
  static void userAction(String message, {Map<String, dynamic>? data}) {
    user(message, data: data);
  }
}