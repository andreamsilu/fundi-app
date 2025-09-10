import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/network/api_client.dart';
import 'core/providers/auth_provider.dart';
import 'core/providers/job_provider.dart';
import 'core/providers/portfolio_provider.dart';
import 'core/providers/messaging_provider.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/register_screen.dart';
import 'features/auth/screens/forgot_password_screen.dart';
import 'features/auth/screens/otp_verification_screen.dart';
import 'features/auth/screens/new_password_screen.dart';
import 'features/dashboard/screens/main_dashboard.dart';
import 'features/profile/screens/profile_screen.dart';
import 'shared/widgets/loading_widget.dart';

/// Main entry point of the Fundi App
/// Initializes the app with proper theme, providers, and routing
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize API client
  await ApiClient().initialize();

  runApp(const FundiApp());
}

class FundiApp extends StatelessWidget {
  const FundiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => JobProvider()),
        ChangeNotifierProvider(create: (_) => PortfolioProvider()),
        ChangeNotifierProvider(create: (_) => MessagingProvider()),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          return MaterialApp(
            title: 'Fundi App',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.light,
            home: const AppInitializer(),
            routes: {
              '/login': (context) => const LoginScreen(),
              '/register': (context) => const RegisterScreen(),
              '/forgot-password': (context) => const ForgotPasswordScreen(),
              '/otp-verification': (context) {
                final args =
                    ModalRoute.of(context)?.settings.arguments
                        as Map<String, dynamic>?;
                return OtpVerificationScreen(
                  phoneNumber: args?['phoneNumber'] ?? '',
                  type: args?['type'] ?? OtpVerificationType.registration,
                  userId: args?['userId'],
                );
              },
              '/new-password': (context) {
                final args =
                    ModalRoute.of(context)?.settings.arguments
                        as Map<String, dynamic>?;
                return NewPasswordScreen(
                  phoneNumber: args?['phoneNumber'] ?? '',
                  otp: args?['otp'] ?? '',
                );
              },
              '/dashboard': (context) => const MainDashboard(),
              '/profile': (context) => ProfileScreen(
                userId:
                    Provider.of<AuthProvider>(
                      context,
                      listen: false,
                    ).user?.id ??
                    '',
              ),
              // Add more routes as needed
            },
          );
        },
      ),
    );
  }
}

/// App initializer that handles authentication state
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

  Future<void> _initializeApp() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (authProvider.isLoading) {
          return const Scaffold(
            body: LoadingWidget(message: 'Initializing Fundi App...', size: 50),
          );
        }

        if (authProvider.isAuthenticated) {
          return const MainDashboard();
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}
