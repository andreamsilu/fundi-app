import 'package:flutter/material.dart';
import '../network/api_client.dart';
import '../../shared/widgets/error_widget.dart';

/// Standardized error handling utility
/// Provides consistent error handling patterns across the app
class ErrorHandler {
  /// Handle API errors and return user-friendly messages
  static String handleApiError(dynamic error) {
    if (error is ApiError) {
      switch (error.code) {
        case 'CONNECTION_ERROR':
        case 'TIMEOUT':
          return 'Please check your internet connection and try again.';
        case 'UNAUTHORIZED':
          return 'Your session has expired. Please login again.';
        case 'SERVER_ERROR':
          return 'Something went wrong on our end. Please try again later.';
        case 'API_ERROR':
          return error.message;
        default:
          return 'An unexpected error occurred. Please try again.';
      }
    }
    
    if (error is Exception) {
      return 'An unexpected error occurred. Please try again.';
    }
    
    return 'Something went wrong. Please try again.';
  }

  /// Show error snackbar
  static void showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red[600],
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  /// Show success snackbar
  static void showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green[600],
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Show warning snackbar
  static void showWarningSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.orange[600],
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Show error dialog
  static void showErrorDialog(
    BuildContext context, {
    required String title,
    required String message,
    String? retryText,
    VoidCallback? onRetry,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red[600]),
            const SizedBox(width: 8),
            Text(title),
          ],
        ),
        content: Text(message),
        actions: [
          if (onRetry != null && retryText != null)
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onRetry();
              },
              child: Text(retryText),
            ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  /// Create error widget for screens
  static Widget createErrorWidget({
    required String message,
    VoidCallback? onRetry,
    String? retryText,
  }) {
    return AppErrorWidget(
      message: message,
      onRetry: onRetry,
      retryText: retryText,
    );
  }

  /// Create network error widget
  static Widget createNetworkErrorWidget({
    VoidCallback? onRetry,
    String? retryText,
  }) {
    return AppErrorWidget.networkError(
      onRetry: onRetry,
      retryText: retryText,
    );
  }

  /// Create server error widget
  static Widget createServerErrorWidget({
    VoidCallback? onRetry,
    String? retryText,
  }) {
    return AppErrorWidget.serverError(
      onRetry: onRetry,
      retryText: retryText,
    );
  }

  /// Create unauthorized error widget
  static Widget createUnauthorizedErrorWidget({
    VoidCallback? onRetry,
    String? retryText,
  }) {
    return AppErrorWidget.unauthorized(
      onRetry: onRetry,
      retryText: retryText,
    );
  }

  /// Handle service call with standardized error handling
  static Future<T?> handleServiceCall<T>(
    Future<T> Function() serviceCall, {
    required BuildContext context,
    String? loadingMessage,
    bool showErrorSnackBar = true,
    VoidCallback? onError,
  }) async {
    try {
      return await serviceCall();
    } catch (e) {
      final errorMessage = handleApiError(e);
      
      if (showErrorSnackBar) {
        showErrorSnackBar(context, errorMessage);
      }
      
      if (onError != null) {
        onError();
      }
      
      return null;
    }
  }

  /// Handle service call with result pattern
  static Future<bool> handleServiceCallWithResult<T>(
    Future<T> Function() serviceCall, {
    required BuildContext context,
    String? loadingMessage,
    bool showErrorSnackBar = true,
    VoidCallback? onSuccess,
    VoidCallback? onError,
  }) async {
    try {
      final result = await serviceCall();
      
      if (result != null) {
        if (onSuccess != null) {
          onSuccess();
        }
        return true;
      } else {
        if (showErrorSnackBar) {
          showErrorSnackBar(context, 'Operation failed. Please try again.');
        }
        if (onError != null) {
          onError();
        }
        return false;
      }
    } catch (e) {
      final errorMessage = handleApiError(e);
      
      if (showErrorSnackBar) {
        showErrorSnackBar(context, errorMessage);
      }
      
      if (onError != null) {
        onError();
      }
      
      return false;
    }
  }
}

/// Mixin for standardized error handling in screens
mixin ErrorHandlingMixin<T extends StatefulWidget> on State<T> {
  String? _errorMessage;
  bool _isLoading = false;

  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;

  /// Set loading state
  void setLoading(bool loading) {
    if (mounted) {
      setState(() {
        _isLoading = loading;
      });
    }
  }

  /// Set error message
  void setError(String? error) {
    if (mounted) {
      setState(() {
        _errorMessage = error;
      });
    }
  }

  /// Clear error message
  void clearError() {
    if (mounted) {
      setState(() {
        _errorMessage = null;
      });
    }
  }

  /// Handle API call with error handling
  Future<T?> handleApiCall<T>(
    Future<T> Function() apiCall, {
    String? loadingMessage,
    bool showErrorSnackBar = true,
    VoidCallback? onError,
  }) async {
    setLoading(true);
    clearError();

    try {
      final result = await apiCall();
      return result;
    } catch (e) {
      final errorMessage = ErrorHandler.handleApiError(e);
      setError(errorMessage);
      
      if (showErrorSnackBar) {
        ErrorHandler.showErrorSnackBar(context, errorMessage);
      }
      
      if (onError != null) {
        onError();
      }
      
      return null;
    } finally {
      setLoading(false);
    }
  }

  /// Show error banner
  Widget buildErrorBanner() {
    if (_errorMessage == null) return const SizedBox.shrink();
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      color: Colors.red[50],
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red[600], size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _errorMessage!,
              style: TextStyle(color: Colors.red[600]),
            ),
          ),
          IconButton(
            onPressed: clearError,
            icon: Icon(Icons.close, color: Colors.red[600], size: 20),
          ),
        ],
      ),
    );
  }
}
