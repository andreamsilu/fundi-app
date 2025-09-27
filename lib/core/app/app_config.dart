import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/env_config.dart';
import '../routing/app_router.dart';
import '../theme/app_theme.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/job/providers/job_provider.dart';
import '../../features/portfolio/providers/portfolio_provider.dart';
// Removed messaging and search providers as features were deleted
import '../../features/notifications/providers/notification_provider.dart';
import '../../features/settings/providers/settings_provider.dart';

/// Application configuration and setup
/// Centralizes app initialization, providers, and theme configuration
class AppConfig {
  /// Initialize the application with lightweight configuration only
  /// Heavy initialization is handled by AppInitializationService
  static void initialize() {
    // Initialize environment variables (lightweight, synchronous)
    EnvConfig.initialize();

    // Note: Heavy initialization (API client, services) is now handled
    // asynchronously by AppInitializationService to avoid blocking startup
  }

  /// Get the list of providers for the app
  static List<ChangeNotifierProvider> get providers => [
    ChangeNotifierProvider(create: (_) => AuthProvider()),
    ChangeNotifierProvider(create: (_) => JobProvider()),
    ChangeNotifierProvider(create: (_) => PortfolioProvider()),
    // Removed MessagingProvider and SearchProvider as features were deleted
    ChangeNotifierProvider(create: (_) => NotificationProvider()),
    ChangeNotifierProvider(create: (_) => SettingsProvider()),
  ];

  /// Get the app theme configuration
  static ThemeData get lightTheme => AppTheme.lightTheme;
  static ThemeData get darkTheme => AppTheme.darkTheme;

  /// Get the app title from environment or default
  static String get appTitle =>
      EnvConfig.get('APP_NAME', defaultValue: 'Fundi App');

  /// Get the app version from environment or default
  static String get appVersion =>
      EnvConfig.get('APP_VERSION', defaultValue: '1.0.0');

  /// Check if debug mode is enabled
  static bool get isDebugMode =>
      EnvConfig.getBool('DEBUG_MODE', defaultValue: true);

  /// Get the initial route
  static String get initialRoute => AppRouter.home;

  /// Get the home widget
  static Widget get homeWidget => const SizedBox.shrink(); // Not used anymore

  /// Get the debug banner setting
  static bool get showDebugBanner => !isDebugMode;
}
