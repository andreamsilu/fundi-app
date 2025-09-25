import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/app/app_config.dart';
import 'core/app/app_initializer.dart';
import 'core/app/app_initialization_service.dart';
import 'core/providers/lazy_provider_manager.dart';
import 'core/routing/app_router.dart';
import 'core/utils/startup_performance.dart';
import 'core/config/env_config.dart';
// Removed debug-only imports

/// Main entry point of the Fundi App
/// Optimized for fast startup with minimal blocking operations
void main() async {
  // Mark startup milestone
  StartupPerformance.markMilestone('app_start');

  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();
  StartupPerformance.markMilestone('flutter_binding_initialized');

  // Initialize environment configuration first
  await EnvConfig.initialize();
  StartupPerformance.markMilestone('env_config_initialized');

  // Initialize only lightweight configuration
  AppConfig.initialize();
  StartupPerformance.markMilestone('app_config_initialized');

  // Start background initialization (non-blocking)
  AppInitializationService.initializeAsync();
  StartupPerformance.markMilestone('background_init_started');

  // Run app immediately with splash screen
  runApp(const FundiApp());
  StartupPerformance.markMilestone('runapp_called');

  // Calculate and log startup performance
  StartupPerformance.calculateDuration('app_start', 'runapp_called');
  StartupPerformance.logPerformanceSummary();
}

class FundiApp extends StatelessWidget {
  const FundiApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Use all providers but with lazy loading for performance
    final providers = LazyProviderManager.getProviders();

    return MultiProvider(
      providers: providers,
      child: MaterialApp(
        title: AppConfig.appTitle,
        debugShowCheckedModeBanner: AppConfig.showDebugBanner,
        theme: AppConfig.lightTheme,
        darkTheme: AppConfig.darkTheme,
        themeMode: ThemeMode.light,
        // Provide a guaranteed entry screen to avoid null initialRoute
        home: const AppInitializer(),
        onGenerateRoute: AppRouter.generateRoute,
      ),
    );
  }
}

// Removed debug-only widgets (SimpleLoginTest, ProviderTestWidget)
