import 'package:flutter/material.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/onboarding/screens/onboarding_screen.dart';
import '../../features/onboarding/services/onboarding_service.dart';
import '../../features/dashboard/screens/main_dashboard.dart';
import '../../shared/widgets/loading_widget.dart';
import '../../core/services/session_manager.dart';
import 'app_initialization_service.dart';
import 'splash_screen.dart';

/// App initializer that handles authentication state and routing
/// Determines which screen to show based on user authentication status
class AppInitializer extends StatefulWidget {
  const AppInitializer({super.key});

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  bool _isCheckingOnboarding = true;
  bool _hasCompletedOnboarding = false;
  bool _showSplash = true;
  bool _isCheckingAuth = true;
  bool _isAuthenticated = false;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  /// Initialize app with optimized startup sequence
  Future<void> _initializeApp() async {
    debugPrint('App initializer: Starting initialization');

    // Show splash screen for 500ms
    await Future.delayed(const Duration(milliseconds: 500));
    debugPrint('App initializer: Splash screen duration completed');

    if (mounted) {
      setState(() {
        _showSplash = false;
      });
      debugPrint('App initializer: Splash screen hidden');
    }

    // Start background initialization after UI is shown
    AppInitializationService.initializeAsync();
    debugPrint('App initializer: Background initialization started');

    // Wait for SessionManager to be initialized
    await _waitForSessionManager();

    // Check authentication status
    await _checkAuthenticationStatus();

    // Check onboarding status (with timeout and error handling)
    try {
      debugPrint('App initializer: Checking onboarding status...');
      final hasCompleted = await OnboardingService.hasCompletedOnboarding()
          .timeout(const Duration(seconds: 2));
      debugPrint('App initializer: Onboarding check completed: $hasCompleted');

      if (mounted) {
        setState(() {
          _hasCompletedOnboarding = hasCompleted;
          _isCheckingOnboarding = false;
        });
        debugPrint(
          'App initializer: State updated - onboarding: $hasCompleted',
        );
      }
    } catch (e) {
      debugPrint('Onboarding check failed: $e');
      // Default to showing login screen if check fails
      if (mounted) {
        setState(() {
          _hasCompletedOnboarding = true; // Skip onboarding
          _isCheckingOnboarding = false;
        });
        debugPrint(
          'App initializer: Defaulted to skip onboarding due to error',
        );
      }
    }
  }

  /// Wait for SessionManager to be initialized
  Future<void> _waitForSessionManager() async {
    int attempts = 0;
    const maxAttempts = 50; // 5 seconds max wait

    while (attempts < maxAttempts) {
      if (AppInitializationService.isInitialized) {
        debugPrint('App initializer: SessionManager initialized');
        return;
      }

      await Future.delayed(const Duration(milliseconds: 100));
      attempts++;
    }

    debugPrint('App initializer: SessionManager initialization timeout');
  }

  /// Check if user is authenticated
  Future<void> _checkAuthenticationStatus() async {
    try {
      debugPrint('App initializer: Checking authentication status...');

      final sessionManager = SessionManager();
      final isAuthenticated = sessionManager.isAuthenticated;

      debugPrint('App initializer: Authentication status: $isAuthenticated');

      if (mounted) {
        setState(() {
          _isAuthenticated = isAuthenticated;
          _isCheckingAuth = false;
        });
        debugPrint('App initializer: Authentication check completed');
      }
    } catch (e) {
      debugPrint('Authentication check failed: $e');
      if (mounted) {
        setState(() {
          _isAuthenticated = false;
          _isCheckingAuth = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Step 1: Show splash screen first (500ms)
    if (_showSplash) {
      return SplashScreen();
    }

    // Step 2: Show loading while checking authentication and onboarding status
    if (_isCheckingAuth || _isCheckingOnboarding) {
      return const Scaffold(
        body: LoadingWidget(message: 'Initializing app...', size: 50),
      );
    }

    // Step 3: If user is authenticated, go directly to dashboard
    if (_isAuthenticated) {
      debugPrint('App initializer: User is authenticated, showing dashboard');
      return const MainDashboard();
    }

    // Step 4: Show onboarding if not completed
    if (!_hasCompletedOnboarding) {
      debugPrint('App initializer: Showing onboarding screen');
      return const OnboardingScreen();
    }

    // Step 5: Show login screen if onboarding completed but not authenticated
    debugPrint('App initializer: Showing login screen');
    return const LoginScreen();
  }
}
