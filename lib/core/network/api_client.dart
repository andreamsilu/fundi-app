import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';
import '../utils/logger.dart';

/// Centralized API client for all network communications
/// Handles authentication, error handling, and request/response logging
class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  late Dio _dio;
  String? _authToken;

  /// Initialize the API client with base configuration
  Future<void> initialize() async {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.baseUrl,
        connectTimeout: const Duration(
          milliseconds: AppConstants.connectionTimeout,
        ),
        receiveTimeout: const Duration(
          milliseconds: AppConstants.receiveTimeout,
        ),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Add interceptors
    _dio.interceptors.add(_createAuthInterceptor());
    _dio.interceptors.add(_createLoggingInterceptor());
    _dio.interceptors.add(_createErrorInterceptor());

    // Load stored token
    await _loadStoredToken();
  }

  /// Create authentication interceptor
  Interceptor _createAuthInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) {
        if (_authToken != null) {
          options.headers['Authorization'] = 'Bearer $_authToken';
        }
        handler.next(options);
      },
      onError: (error, handler) {
        if (error.response?.statusCode == 401) {
          _handleUnauthorized();
        }
        handler.next(error);
      },
    );
  }

  /// Create logging interceptor
  Interceptor _createLoggingInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) {
        Logger.apiRequest(
          options.method,
          options.uri.toString(),
          headers: options.headers,
          body: options.data,
        );
        handler.next(options);
      },
      onResponse: (response, handler) {
        Logger.apiResponse(
          response.requestOptions.method,
          response.requestOptions.uri.toString(),
          response.statusCode ?? 0,
          response: response.data,
        );
        handler.next(response);
      },
      onError: (error, handler) {
        Logger.apiError(
          error.requestOptions.method,
          error.requestOptions.uri.toString(),
          error,
          stackTrace: error.stackTrace,
        );
        handler.next(error);
      },
    );
  }

  /// Create error handling interceptor
  Interceptor _createErrorInterceptor() {
    return InterceptorsWrapper(
      onError: (error, handler) {
        final apiError = _handleApiError(error);
        handler.reject(
          DioException(
            requestOptions: error.requestOptions,
            error: apiError,
            type: error.type,
            response: error.response,
          ),
        );
      },
    );
  }

  /// Handle API errors and convert to user-friendly messages
  ApiError _handleApiError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiError(
          message: AppConstants.networkErrorMessage,
          code: 'TIMEOUT',
          statusCode: 408,
        );

      case DioExceptionType.connectionError:
        return ApiError(
          message: AppConstants.networkErrorMessage,
          code: 'CONNECTION_ERROR',
          statusCode: 0,
        );

      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode ?? 0;
        final responseData = error.response?.data;

        if (statusCode == 401) {
          return ApiError(
            message: AppConstants.unauthorizedMessage,
            code: 'UNAUTHORIZED',
            statusCode: statusCode,
          );
        }

        if (statusCode >= 500) {
          return ApiError(
            message: AppConstants.serverErrorMessage,
            code: 'SERVER_ERROR',
            statusCode: statusCode,
          );
        }

        // Try to extract error message from response
        String message = AppConstants.serverErrorMessage;
        if (responseData is Map<String, dynamic>) {
          message = responseData['message'] ?? responseData['error'] ?? message;
        }

        return ApiError(
          message: message,
          code: 'API_ERROR',
          statusCode: statusCode,
        );

      default:
        return ApiError(
          message: AppConstants.serverErrorMessage,
          code: 'UNKNOWN_ERROR',
          statusCode: 0,
        );
    }
  }

  /// Load stored authentication token
  Future<void> _loadStoredToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _authToken = prefs.getString(AppConstants.tokenKey);
    } catch (e) {
      Logger.error('Failed to load stored token', error: e);
    }
  }

  /// Save authentication token
  Future<void> saveToken(String token) async {
    try {
      _authToken = token;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.tokenKey, token);
      Logger.info('Authentication token saved', data: {'token': 'saved'});
    } catch (e) {
      Logger.error('Failed to save token', error: e);
    }
  }

  /// Clear authentication token
  Future<void> clearToken() async {
    try {
      _authToken = null;
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(AppConstants.tokenKey);
      Logger.info('Authentication token cleared', data: {'token': 'cleared'});
    } catch (e) {
      Logger.error('Failed to clear token', error: e);
    }
  }

  /// Handle unauthorized access
  void _handleUnauthorized() {
    clearToken();
    // TODO: Navigate to login screen or show login dialog
    Logger.warning('User session expired, redirecting to login');
  }

  /// GET request
  Future<ApiResponse<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
      );
      return _handleResponse<T>(response, fromJson);
    } on DioException catch (e) {
      throw _handleApiError(e);
    }
  }

  /// POST request
  Future<ApiResponse<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return _handleResponse<T>(response, fromJson);
    } on DioException catch (e) {
      throw _handleApiError(e);
    }
  }

  /// PUT request
  Future<ApiResponse<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return _handleResponse<T>(response, fromJson);
    } on DioException catch (e) {
      throw _handleApiError(e);
    }
  }

  /// DELETE request
  Future<ApiResponse<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return _handleResponse<T>(response, fromJson);
    } on DioException catch (e) {
      throw _handleApiError(e);
    }
  }

  /// Upload file
  Future<ApiResponse<T>> uploadFile<T>(
    String path,
    File file, {
    String fieldName = 'file',
    Map<String, dynamic>? additionalData,
    ProgressCallback? onSendProgress,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final formData = FormData.fromMap({
        fieldName: await MultipartFile.fromFile(file.path),
        ...?additionalData,
      });

      final response = await _dio.post(
        path,
        data: formData,
        onSendProgress: onSendProgress,
      );
      return _handleResponse<T>(response, fromJson);
    } on DioException catch (e) {
      throw _handleApiError(e);
    }
  }

  /// Handle API response
  ApiResponse<T> _handleResponse<T>(
    Response response,
    T Function(dynamic)? fromJson,
  ) {
    final data = response.data;

    if (fromJson != null && data != null) {
      try {
        final parsedData = fromJson(data);
        return ApiResponse<T>(
          data: parsedData,
          message: data['message'] ?? 'Success',
          success: true,
          statusCode: response.statusCode ?? 200,
        );
      } catch (e) {
        Logger.error('Failed to parse response data', error: e);
        return ApiResponse<T>(
          data: null,
          message: 'Failed to parse response',
          success: false,
          statusCode: response.statusCode ?? 200,
        );
      }
    }

    return ApiResponse<T>(
      data: data as T?,
      message: (data is Map<String, dynamic>) ? data['message'] ?? 'Success' : 'Success',
      success: true,
      statusCode: response.statusCode ?? 200,
    );
  }
}

/// API Response wrapper class
class ApiResponse<T> {
  final T? data;
  final String message;
  final bool success;
  final int statusCode;

  ApiResponse({
    required this.data,
    required this.message,
    required this.success,
    required this.statusCode,
  });
}

/// API Error class
class ApiError implements Exception {
  final String message;
  final String code;
  final int statusCode;

  ApiError({
    required this.message,
    required this.code,
    required this.statusCode,
  });

  @override
  String toString() => 'ApiError: $message (Code: $code, Status: $statusCode)';
}
