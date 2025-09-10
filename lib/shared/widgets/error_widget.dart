import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/network/api_client.dart';

/// Reusable error widget for displaying error states
/// Provides consistent error handling across the application
class AppErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final IconData? icon;
  final String? retryText;

  const AppErrorWidget({
    super.key,
    required this.message,
    this.onRetry,
    this.icon,
    this.retryText,
  });

  /// Create error widget from ApiError
  factory AppErrorWidget.fromApiError(
    ApiError error, {
    VoidCallback? onRetry,
    String? retryText,
  }) {
    return AppErrorWidget(
      message: error.message,
      onRetry: onRetry,
      retryText: retryText,
      icon: _getIconForError(error),
    );
  }

  /// Create network error widget
  factory AppErrorWidget.networkError({
    VoidCallback? onRetry,
    String? retryText,
  }) {
    return AppErrorWidget(
      message: 'Please check your internet connection and try again',
      onRetry: onRetry,
      retryText: retryText ?? 'Retry',
      icon: Icons.wifi_off,
    );
  }

  /// Create server error widget
  factory AppErrorWidget.serverError({
    VoidCallback? onRetry,
    String? retryText,
  }) {
    return AppErrorWidget(
      message: 'Something went wrong on our end. Please try again later',
      onRetry: onRetry,
      retryText: retryText ?? 'Retry',
      icon: Icons.error_outline,
    );
  }

  /// Create unauthorized error widget
  factory AppErrorWidget.unauthorized({
    VoidCallback? onRetry,
    String? retryText,
  }) {
    return AppErrorWidget(
      message: 'Your session has expired. Please login again',
      onRetry: onRetry,
      retryText: retryText ?? 'Login',
      icon: Icons.lock_outline,
    );
  }

  /// Create not found error widget
  factory AppErrorWidget.notFound({
    VoidCallback? onRetry,
    String? retryText,
  }) {
    return AppErrorWidget(
      message: 'The requested content was not found',
      onRetry: onRetry,
      retryText: retryText ?? 'Go Back',
      icon: Icons.search_off,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Error icon
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.errorColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon ?? Icons.error_outline,
                size: 48,
                color: AppTheme.errorColor,
              ),
            ),
            const SizedBox(height: 24),
            
            // Error message
            Text(
              message,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppTheme.darkGray,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            
            // Retry button
            if (onRetry != null)
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: Text(retryText ?? 'Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.accentColor,
                  foregroundColor: Colors.white,
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Get appropriate icon for different error types
  static IconData _getIconForError(ApiError error) {
    switch (error.code) {
      case 'CONNECTION_ERROR':
      case 'TIMEOUT':
        return Icons.wifi_off;
      case 'UNAUTHORIZED':
        return Icons.lock_outline;
      case 'SERVER_ERROR':
        return Icons.error_outline;
      default:
        return Icons.error_outline;
    }
  }
}

/// Error banner for displaying temporary error messages
class ErrorBanner extends StatelessWidget {
  final String message;
  final VoidCallback? onDismiss;
  final Color? backgroundColor;
  final Color? textColor;

  const ErrorBanner({
    super.key,
    required this.message,
    this.onDismiss,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: backgroundColor ?? AppTheme.errorColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: textColor ?? Colors.white,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: textColor ?? Colors.white,
              ),
            ),
          ),
          if (onDismiss != null)
            IconButton(
              onPressed: onDismiss,
              icon: Icon(
                Icons.close,
                color: textColor ?? Colors.white,
                size: 20,
              ),
            ),
        ],
      ),
    );
  }
}

/// Success banner for displaying success messages
class SuccessBanner extends StatelessWidget {
  final String message;
  final VoidCallback? onDismiss;
  final Color? backgroundColor;
  final Color? textColor;

  const SuccessBanner({
    super.key,
    required this.message,
    this.onDismiss,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: backgroundColor ?? AppTheme.successColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.check_circle_outline,
            color: textColor ?? Colors.white,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: textColor ?? Colors.white,
              ),
            ),
          ),
          if (onDismiss != null)
            IconButton(
              onPressed: onDismiss,
              icon: Icon(
                Icons.close,
                color: textColor ?? Colors.white,
                size: 20,
              ),
            ),
        ],
      ),
    );
  }
}

/// Warning banner for displaying warning messages
class WarningBanner extends StatelessWidget {
  final String message;
  final VoidCallback? onDismiss;
  final Color? backgroundColor;
  final Color? textColor;

  const WarningBanner({
    super.key,
    required this.message,
    this.onDismiss,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: backgroundColor ?? AppTheme.warningColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.warning_outlined,
            color: textColor ?? Colors.white,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: textColor ?? Colors.white,
              ),
            ),
          ),
          if (onDismiss != null)
            IconButton(
              onPressed: onDismiss,
              icon: Icon(
                Icons.close,
                color: textColor ?? Colors.white,
                size: 20,
              ),
            ),
        ],
      ),
    );
  }
}

/// Info banner for displaying informational messages
class InfoBanner extends StatelessWidget {
  final String message;
  final VoidCallback? onDismiss;
  final Color? backgroundColor;
  final Color? textColor;

  const InfoBanner({
    super.key,
    required this.message,
    this.onDismiss,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: backgroundColor ?? AppTheme.infoColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: textColor ?? Colors.white,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: textColor ?? Colors.white,
              ),
            ),
          ),
          if (onDismiss != null)
            IconButton(
              onPressed: onDismiss,
              icon: Icon(
                Icons.close,
                color: textColor ?? Colors.white,
                size: 20,
              ),
            ),
        ],
      ),
    );
  }
}

/// Empty state widget for when there's no data to display
class EmptyStateWidget extends StatelessWidget {
  final String title;
  final String message;
  final IconData? icon;
  final VoidCallback? onAction;
  final String? actionText;

  const EmptyStateWidget({
    super.key,
    required this.title,
    required this.message,
    this.icon,
    this.onAction,
    this.actionText,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Empty state icon
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.lightGray,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon ?? Icons.inbox_outlined,
                size: 48,
                color: AppTheme.mediumGray,
              ),
            ),
            const SizedBox(height: 24),
            
            // Title
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppTheme.darkGray,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            
            // Message
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.mediumGray,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            
            // Action button
            if (onAction != null && actionText != null)
              ElevatedButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.add),
                label: Text(actionText!),
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.accentColor,
                  foregroundColor: Colors.white,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

