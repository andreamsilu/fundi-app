import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/dashboard/screens/main_dashboard.dart';
import '../../shared/widgets/loading_widget.dart';

/// App initializer that handles authentication state and routing
/// Determines which screen to show based on user authentication status
class AppInitializer extends StatefulWidget {
  const AppInitializer({super.key});

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  /// Initialize the app by checking authentication state
  Future<void> _initializeApp() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        // Show loading screen while initializing
        if (authProvider.isLoading) {
          return const Scaffold(
            body: LoadingWidget(message: 'Initializing Fundi App...', size: 50),
          );
        }

        // Route to appropriate screen based on authentication status
        if (authProvider.isAuthenticated) {
          return const MainDashboard();
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}
