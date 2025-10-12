import 'package:flutter/material.dart';
import 'package:fundi/features/auth/services/auth_service.dart';
import 'package:fundi/features/job/models/job_model.dart';
// Removed chat_model import as messaging feature was deleted
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
import '../../features/job/screens/job_creation_screen.dart'; // Now using wizard version
import '../../features/job/screens/job_details_screen.dart';
import '../../features/job/screens/job_list_screen.dart';
import '../../features/job/screens/application_details_screen.dart';
import '../../features/job/screens/job_applications_screen.dart';
import '../../features/portfolio/screens/portfolio_creation_screen.dart';
import '../../features/portfolio/screens/portfolio_details_screen.dart';
import '../../features/search/screens/search_screen.dart';
import '../../features/payment/screens/payment_main_screen.dart'; // Consolidated payment screen
import '../../features/notifications/screens/notifications_screen.dart';
import '../../features/settings/screens/settings_screen.dart';
import '../../features/fundi_application/screens/fundi_application_screen.dart';
import '../../features/feeds/screens/fundi_feed_screen.dart';
import '../../features/feeds/screens/comprehensive_fundi_profile_screen.dart';
import '../../features/work_approval/screens/work_approval_screen.dart';

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
  static const String portfolioDetails = '/portfolio-details';
  static const String chat = '/chat';
  static const String search = '/search';
  static const String notifications = '/notifications';
  static const String settings = '/settings';
  static const String fundiApplication = '/fundi-application';
  static const String fundiFeed = '/fundi-feed';
  static const String jobFeed = '/job-feed';
  static const String fundiProfile = '/fundi-profile';
  static const String workApproval = '/work-approval';
  static const String home = '/';
  static const String paymentPlans = '/payment-plans';
  static const String paymentManagement = '/payment-management';
  static const String applicationDetails = '/application-details';
  static const String jobApplications = '/job-applications';

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
        // Messaging feature removed - show coming soon
        return _buildRoute(
          const Scaffold(
            body: Center(child: Text('Messaging feature coming soon!')),
          ),
          settings,
        );

      case '/search':
        final args = settings.arguments as Map<String, dynamic>?;
        return _buildRoute(
          SearchScreen(
            initialQuery: args?['query'] as String?,
            initialTabIndex: args?['tabIndex'] as int? ?? 0,
          ),
          settings,
        );

      case '/notifications':
        return _buildRoute(const NotificationsScreen(), settings);

      case '/settings':
        return _buildRoute(const SettingsScreen(), settings);

      case '/fundi-application':
        return _buildRoute(const FundiApplicationScreen(), settings);

      case '/fundi-feed':
        return _buildRoute(const FundiFeedScreen(), settings);

      case '/job-feed':
        // Consolidated: Use JobListScreen for job listings
        return _buildRoute(
          const JobListScreen(
            title: 'Available Jobs',
            showAppBar: true,
            showFilterButton: true,
          ),
          settings,
        );

      case '/fundi-profile':
        final args = settings.arguments as Map<String, dynamic>?;
        if (args?['fundi'] == null) {
          return _buildRoute(
            const Scaffold(body: Center(child: Text('Fundi not found'))),
            settings,
          );
        }
        return _buildRoute(
          ComprehensiveFundiProfileScreen(fundi: args!['fundi']),
          settings,
        );

      case '/work-approval':
        return _buildRoute(const WorkApprovalScreen(), settings);

      case '/payment-plans':
        return _buildRoute(const PaymentMainScreen(initialTab: 0), settings);

      case '/payment-management':
        return _buildRoute(const PaymentMainScreen(initialTab: 1), settings);

      case '/application-details':
        final args = settings.arguments as Map<String, dynamic>?;
        if (args?['applicationId'] == null) {
          return _buildRoute(
            const Scaffold(body: Center(child: Text('Application not found'))),
            settings,
          );
        }
        return _buildRoute(
          ApplicationDetailsScreen(
            applicationId: args!['applicationId'] as String,
            jobId: args['jobId'] as String?,
          ),
          settings,
        );

      case '/job-applications':
        final jobArgs = settings.arguments as JobModel?;
        if (jobArgs == null) {
          return _buildRoute(
            const Scaffold(body: Center(child: Text('Job not found'))),
            settings,
          );
        }
        return _buildRoute(JobApplicationsScreen(job: jobArgs), settings);

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
