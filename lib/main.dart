import 'package:flutter/material.dart';
import 'package:fundi/features/auth/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'core/network/api_client.dart';
import 'core/app/app_config.dart';
import 'core/routing/app_router.dart';

/// Main entry point of the Fundi App
/// Initializes the app with proper theme, providers, and routing
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize app configuration
  await AppConfig.initialize();

  // Initialize API client
  await ApiClient().initialize();

  runApp(const FundiApp());
}

class FundiApp extends StatelessWidget {
  const FundiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: AppConfig.providers,
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          return MaterialApp(
            title: AppConfig.appTitle,
            debugShowCheckedModeBanner: AppConfig.showDebugBanner,
            theme: AppConfig.lightTheme,
            darkTheme: AppConfig.darkTheme,
            themeMode: ThemeMode.light,
            home: AppConfig.homeWidget,
            onGenerateRoute: AppRouter.generateRoute,
            initialRoute: AppConfig.initialRoute,
          );
        },
      ),
    );
  }
}
