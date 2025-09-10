import 'package:flutter/material.dart';
import 'package:fundi/features/auth/services/auth_service.dart';
import 'package:fundi/features/job/models/job_model.dart';
import 'package:fundi/features/messaging/models/chat_model.dart';
import 'package:fundi/features/portfolio/models/portfolio_model.dart';
import 'package:provider/provider.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/auth/screens/forgot_password_screen.dart';
import '../../features/auth/screens/otp_verification_screen.dart';
import '../../features/auth/screens/new_password_screen.dart';
import '../../features/dashboard/screens/main_dashboard.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/job/screens/job_creation_screen.dart';
import '../../features/job/screens/job_details_screen.dart';
import '../../features/portfolio/screens/portfolio_creation_screen.dart';
import '../../features/portfolio/screens/portfolio_gallery_screen.dart';
import '../../features/portfolio/screens/portfolio_details_screen.dart';
import '../../features/messaging/screens/chat_screen.dart';
import '../../features/search/screens/search_screen.dart';
import '../../features/notifications/screens/notifications_screen.dart';
import '../../features/settings/screens/settings_screen.dart';

/// Centralized routing configuration for the Fundi App
/// Handles route definitions, navigation, and route guards
class AppRouter {
  // Route names as constants to avoid typos
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String otpVerification = '/otp-verification';
  static const String newPassword = '/new-password';
  static const String dashboard = '/dashboard';
  static const String profile = '/profile';
  static const String createJob = '/create-job';
  static const String jobDetails = '/job-details';
  static const String createPortfolio = '/create-portfolio';
  static const String portfolioGallery = '/portfolio-gallery';
  static const String portfolioDetails = '/portfolio-details';
  static const String chat = '/chat';
  static const String search = '/search';
  static const String notifications = '/notifications';
  static const String settings = '/settings';
  static const String home = '/';

  /// Route generation function for named routes
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final routeName = settings.name;
    if (routeName == null) {
      return _buildRoute(
        const Scaffold(body: Center(child: Text('Route not found'))),
        settings,
      );
    }

    switch (routeName) {
      case '/login':
        return _buildRoute(const LoginScreen(), settings);

      case '/register':
        return _buildRoute(const RegisterScreen(), settings);

      case '/forgot-password':
        return _buildRoute(const ForgotPasswordScreen(), settings);

      case '/otp-verification':
        final args = settings.arguments as Map<String, dynamic>?;
        return _buildRoute(
          OtpVerificationScreen(
            phoneNumber: args?['phoneNumber'] ?? '',
            type: args?['type'] ?? OtpVerificationType.registration,
            userId: args?['userId'],
          ),
          settings,
        );

      case '/new-password':
        final args = settings.arguments as Map<String, dynamic>?;
        return _buildRoute(
          NewPasswordScreen(
            phoneNumber: args?['phoneNumber'] ?? '',
            otp: args?['otp'] ?? '',
          ),
          settings,
        );

      case '/dashboard':
        return _buildRoute(const MainDashboard(), settings);

      case '/profile':
        return _buildRoute(
          ProfileScreen(userId: _getCurrentUserId(settings)),
          settings,
        );

      case '/create-job':
        return _buildRoute(const JobCreationScreen(), settings);

      case '/job-details':
        final args = settings.arguments as JobModel?;
        if (args == null) {
          return _buildRoute(
            const Scaffold(body: Center(child: Text('Job not found'))),
            settings,
          );
        }
        return _buildRoute(JobDetailsScreen(job: args), settings);

      case '/create-portfolio':
        return _buildRoute(const PortfolioCreationScreen(), settings);

      case '/portfolio-gallery':
        final args = settings.arguments as String?;
        return _buildRoute(PortfolioGalleryScreen(portfolioId: args ?? ''), settings);

      case '/portfolio-details':
        final args = settings.arguments as PortfolioModel?;
        if (args == null) {
          return _buildRoute(
            const Scaffold(body: Center(child: Text('Portfolio not found'))),
            settings,
          );
        }
        return _buildRoute(PortfolioDetailsScreen(portfolio: args), settings);

      case '/chat':
        final args = settings.arguments as ChatModel?;
        if (args == null) {
          return _buildRoute(
            const Scaffold(body: Center(child: Text('Chat not found'))),
            settings,
          );
        }
        return _buildRoute(ChatScreen(chat: args), settings);

      case '/search':
        return _buildRoute(const SearchScreen(), settings);

      case '/notifications':
        return _buildRoute(const NotificationsScreen(), settings);

      case '/settings':
        return _buildRoute(const SettingsScreen(), settings);

      default:
        return _buildRoute(
          const Scaffold(body: Center(child: Text('Route not found'))),
          settings,
        );
    }
  }

  /// Build a route with custom transition and settings
  static Route<dynamic> _buildRoute(Widget page, RouteSettings settings) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        // Custom transition animations
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;

        var tween = Tween(
          begin: begin,
          end: end,
        ).chain(CurveTween(curve: curve));

        return SlideTransition(position: animation.drive(tween), child: child);
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }

  /// Get current user ID from context or arguments
  static String _getCurrentUserId(RouteSettings settings) {
    // Try to get from arguments first
    final args = settings.arguments as Map<String, dynamic>?;
    if (args?['userId'] != null) {
      return args!['userId'] as String;
    }

    // Fallback to empty string (will be handled by ProfileScreen)
    return '';
  }

  /// Navigation helper methods
  static Future<T?> pushNamed<T extends Object?>(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    return Navigator.pushNamed<T>(context, routeName, arguments: arguments);
  }

  static Future<T?> pushReplacementNamed<T extends Object?, TO extends Object?>(
    BuildContext context,
    String routeName, {
    Object? arguments,
    TO? result,
  }) {
    return Navigator.pushReplacementNamed<T, TO>(
      context,
      routeName,
      arguments: arguments,
      result: result,
    );
  }

  static Future<T?> pushNamedAndRemoveUntil<T extends Object?>(
    BuildContext context,
    String routeName,
    RoutePredicate predicate, {
    Object? arguments,
  }) {
    return Navigator.pushNamedAndRemoveUntil<T>(
      context,
      routeName,
      predicate,
      arguments: arguments,
    );
  }

  /// Route guards and authentication checks
  static bool canAccessRoute(BuildContext context, String routeName) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Define protected routes
    const protectedRoutes = [dashboard, profile];

    if (protectedRoutes.contains(routeName)) {
      return authProvider.isAuthenticated;
    }

    // Define auth-only routes (login, register when already authenticated)
    const authOnlyRoutes = [login, register];

    if (authOnlyRoutes.contains(routeName)) {
      return !authProvider.isAuthenticated;
    }

    return true;
  }

  /// Navigate with authentication check
  static Future<T?> pushNamedWithAuth<T extends Object?>(
    BuildContext context,
    String routeName, {
    Object? arguments,
    String? redirectRoute,
  }) {
    if (canAccessRoute(context, routeName)) {
      return pushNamed<T>(context, routeName, arguments: arguments);
    } else {
      // Redirect to appropriate route
      final redirect =
          redirectRoute ??
          (Provider.of<AuthProvider>(context, listen: false).isAuthenticated
              ? dashboard
              : login);
      return pushNamed<T>(context, redirect, arguments: arguments);
    }
  }

  /// Clear navigation stack and navigate to route
  static Future<T?> navigateAndClearStack<T extends Object?>(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    return pushNamedAndRemoveUntil<T>(
      context,
      routeName,
      (route) => false, // Remove all previous routes
      arguments: arguments,
    );
  }
}

/// Route arguments classes for type safety
class OtpVerificationArgs {
  final String phoneNumber;
  final OtpVerificationType type;
  final String? userId;

  OtpVerificationArgs({
    required this.phoneNumber,
    required this.type,
    this.userId,
  });

  Map<String, dynamic> toMap() {
    return {'phoneNumber': phoneNumber, 'type': type, 'userId': userId};
  }
}

class NewPasswordArgs {
  final String phoneNumber;
  final String otp;

  NewPasswordArgs({required this.phoneNumber, required this.otp});

  Map<String, dynamic> toMap() {
    return {'phoneNumber': phoneNumber, 'otp': otp};
  }
}

class ProfileArgs {
  final String userId;

  ProfileArgs({required this.userId});

  Map<String, dynamic> toMap() {
    return {'userId': userId};
  }
}
