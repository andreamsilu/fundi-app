import 'package:flutter/material.dart';
import '../utils/logger.dart';
import '../../features/auth/screens/login_screen.dart';
import '../routing/app_router.dart';

/// Global navigation service for handling app-wide navigation
/// Provides centralized navigation methods and handles authentication redirects
class NavigationService {
  static final NavigationService _instance = NavigationService._internal();
  factory NavigationService() => _instance;
  NavigationService._internal();

  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  bool _isRedirecting = false;

  /// Get the navigator key
  GlobalKey<NavigatorState> get navigatorKey => _navigatorKey;

  /// Get current context
  BuildContext? get currentContext => _navigatorKey.currentContext;

  /// Check if currently redirecting
  bool get isRedirecting => _isRedirecting;

  /// Navigate to login screen and clear the navigation stack
  Future<void> redirectToLogin({String? reason, bool clearStack = true}) async {
    if (_isRedirecting) {
      Logger.warning(
        'Navigation service: Already redirecting to login, ignoring duplicate request',
      );
      return;
    }

    _isRedirecting = true;

    try {
      final context = currentContext;
      if (context == null) {
        Logger.error(
          'Navigation service: No context available for redirect to login',
        );
        return;
      }

      Logger.warning(
        'Navigation service: Redirecting to login screen',
        data: {'reason': reason ?? 'Token expired or unauthorized'},
      );

      if (clearStack) {
        // Clear all routes and navigate to login
        await Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => const LoginScreen(),
            settings: const RouteSettings(name: AppRouter.login),
          ),
          (route) => false,
        );
      } else {
        // Just navigate to login without clearing stack
        await Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const LoginScreen(),
            settings: const RouteSettings(name: AppRouter.login),
          ),
        );
      }

      Logger.info(
        'Navigation service: Successfully redirected to login screen',
      );
    } catch (e) {
      Logger.error('Navigation service: Failed to redirect to login', error: e);
    } finally {
      _isRedirecting = false;
    }
  }

  /// Navigate to dashboard
  Future<void> navigateToDashboard() async {
    try {
      final context = currentContext;
      if (context == null) {
        Logger.error(
          'Navigation service: No context available for dashboard navigation',
        );
        return;
      }

      await Navigator.pushNamedAndRemoveUntil(
        context,
        AppRouter.dashboard,
        (route) => false,
      );

      Logger.info('Navigation service: Successfully navigated to dashboard');
    } catch (e) {
      Logger.error(
        'Navigation service: Failed to navigate to dashboard',
        error: e,
      );
    }
  }

  /// Navigate to a specific route
  Future<T?> navigateTo<T extends Object?>(
    String routeName, {
    Object? arguments,
    bool clearStack = false,
  }) async {
    try {
      final context = currentContext;
      if (context == null) {
        Logger.error(
          'Navigation service: No context available for navigation to $routeName',
        );
        return null;
      }

      if (clearStack) {
        return await Navigator.pushNamedAndRemoveUntil(
          context,
          routeName,
          (route) => false,
          arguments: arguments,
        );
      } else {
        return await Navigator.pushNamed(
          context,
          routeName,
          arguments: arguments,
        );
      }
    } catch (e) {
      Logger.error(
        'Navigation service: Failed to navigate to $routeName',
        error: e,
      );
      return null;
    }
  }

  /// Replace current route
  Future<T?> replaceWith<T extends Object?, TO extends Object?>(
    String routeName, {
    Object? arguments,
    TO? result,
  }) async {
    try {
      final context = currentContext;
      if (context == null) {
        Logger.error(
          'Navigation service: No context available for route replacement with $routeName',
        );
        return null;
      }

      return await Navigator.pushReplacementNamed<T, TO>(
        context,
        routeName,
        arguments: arguments,
        result: result,
      );
    } catch (e) {
      Logger.error(
        'Navigation service: Failed to replace with $routeName',
        error: e,
      );
      return null;
    }
  }

  /// Go back
  void goBack<T extends Object?>([T? result]) {
    try {
      final context = currentContext;
      if (context == null) {
        Logger.error('Navigation service: No context available for go back');
        return;
      }

      if (Navigator.canPop(context)) {
        Navigator.pop(context, result);
        Logger.info('Navigation service: Navigated back');
      } else {
        Logger.warning('Navigation service: Cannot go back, no routes to pop');
      }
    } catch (e) {
      Logger.error('Navigation service: Failed to go back', error: e);
    }
  }

  /// Check if can go back
  bool canGoBack() {
    final context = currentContext;
    if (context == null) return false;
    return Navigator.canPop(context);
  }

  /// Get current route name
  String? getCurrentRouteName() {
    final context = currentContext;
    if (context == null) return null;

    final route = ModalRoute.of(context);
    return route?.settings.name;
  }

  /// Show dialog with token expiration message
  Future<void> showTokenExpirationDialog({
    String? message,
    VoidCallback? onOkPressed,
  }) async {
    try {
      final context = currentContext;
      if (context == null) {
        Logger.error(
          'Navigation service: No context available for showing token expiration dialog',
        );
        return;
      }

      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Session Expired'),
            content: Text(
              message ?? 'Your session has expired. Please log in again.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  onOkPressed?.call();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      Logger.error(
        'Navigation service: Failed to show token expiration dialog',
        error: e,
      );
    }
  }

  /// Reset navigation state
  void reset() {
    _isRedirecting = false;
  }
}

