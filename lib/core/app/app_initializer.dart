import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/dashboard/screens/main_dashboard.dart';
import '../../features/onboarding/screens/onboarding_screen.dart';
import '../../features/onboarding/services/onboarding_service.dart';
import '../../shared/widgets/loading_widget.dart';

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

  @override
  void initState() {
    super.initState();
    _checkOnboardingStatus();
  }

  Future<void> _checkOnboardingStatus() async {
    final hasCompleted = await OnboardingService.hasCompletedOnboarding();
    if (mounted) {
      setState(() {
        _hasCompletedOnboarding = hasCompleted;
        _isCheckingOnboarding = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // AppInitializer build called

    // Show loading screen while checking onboarding status
    if (_isCheckingOnboarding) {
      return const Scaffold(
        body: LoadingWidget(message: 'Initializing Fundi App...', size: 50),
      );
    }

    // Show onboarding if not completed
    if (!_hasCompletedOnboarding) {
      // User has not completed onboarding, showing OnboardingScreen
      return const OnboardingScreen();
    }

    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        // Consumer<AuthProvider> builder called

        // Initialize auth provider on first build
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          if (mounted) {
            // Initializing AuthProvider
            await authProvider.initialize();
          }
        });

        // Show loading screen while initializing
        if (authProvider.isLoading) {
          // Showing loading screen
          return const Scaffold(
            body: LoadingWidget(message: 'Initializing Fundi App...', size: 50),
          );
        }

        // Route to appropriate screen based on authentication status
        if (authProvider.isAuthenticated) {
          // User is authenticated, showing MainDashboard
          return const MainDashboard();
        } else {
          // User is not authenticated, showing LoginScreen
          return const LoginScreen();
        }
      },
    );
  }
}
