import 'package:provider/provider.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/job/providers/job_provider.dart';
import '../../features/portfolio/providers/portfolio_provider.dart';
import '../../features/messaging/providers/messaging_provider.dart';
import '../../features/search/providers/search_provider.dart';
import '../../features/notifications/providers/notification_provider.dart';
import '../../features/settings/providers/settings_provider.dart';
import '../../features/feeds/providers/feeds_provider.dart';
import '../../features/work_approval/providers/work_approval_provider.dart';
import '../../features/payment/providers/payment_provider.dart';
import '../../features/rating/providers/rating_provider.dart';

/// Manages lazy initialization of providers to improve startup performance
/// Only creates providers when they are actually needed
class LazyProviderManager {
  static final Map<Type, ChangeNotifierProvider> _providers = {};
  static bool _isInitialized = false;

  /// Get all providers for the app (lazy initialization)
  static List<ChangeNotifierProvider> getProviders() {
    if (!_isInitialized) {
      _initializeProviders();
    }
    return _providers.values.toList();
  }

  /// Get only critical providers for startup (AuthProvider only)
  static List<ChangeNotifierProvider> getStartupProviders() {
    if (!_isInitialized) {
      _initializeProviders();
    }

    // Only return AuthProvider for immediate startup
    return [_providers[AuthProvider]!];
  }

  /// Initialize providers map (lightweight operation)
  static void _initializeProviders() {
    _providers[AuthProvider] = ChangeNotifierProvider(
      create: (_) {
        final provider = AuthProvider();
        // Initialize the provider asynchronously
        provider.initialize();
        return provider;
      },
      lazy: false, // Initialize immediately for critical provider
    );

    _providers[JobProvider] = ChangeNotifierProvider(
      create: (_) => JobProvider(),
      lazy: true,
    );

    _providers[PortfolioProvider] = ChangeNotifierProvider(
      create: (_) => PortfolioProvider(),
      lazy: true,
    );

    _providers[MessagingProvider] = ChangeNotifierProvider(
      create: (_) => MessagingProvider(),
      lazy: true,
    );

    _providers[SearchProvider] = ChangeNotifierProvider(
      create: (_) => SearchProvider(),
      lazy: true,
    );

    _providers[NotificationProvider] = ChangeNotifierProvider(
      create: (_) => NotificationProvider(),
      lazy: true,
    );

    _providers[SettingsProvider] = ChangeNotifierProvider(
      create: (_) => SettingsProvider(),
      lazy: true,
    );

    _providers[FeedsProvider] = ChangeNotifierProvider(
      create: (_) => FeedsProvider(),
      lazy: true,
    );

    _providers[WorkApprovalProvider] = ChangeNotifierProvider(
      create: (_) => WorkApprovalProvider(),
      lazy: true,
    );

    _providers[PaymentProvider] = ChangeNotifierProvider(
      create: (_) => PaymentProvider(),
      lazy: true,
    );

    _providers[RatingProvider] = ChangeNotifierProvider(
      create: (_) => RatingProvider(),
      lazy: true,
    );

    _isInitialized = true;
  }

  /// Get a specific provider by type
  static ChangeNotifierProvider? getProvider<T>() {
    if (!_isInitialized) {
      _initializeProviders();
    }
    return _providers[T];
  }

  /// Preload critical providers (AuthProvider only)
  static List<ChangeNotifierProvider> getCriticalProviders() {
    if (!_isInitialized) {
      _initializeProviders();
    }

    // Only return AuthProvider for immediate initialization
    return [_providers[AuthProvider]!];
  }

  /// Get non-critical providers (all except AuthProvider)
  static List<ChangeNotifierProvider> getNonCriticalProviders() {
    if (!_isInitialized) {
      _initializeProviders();
    }

    final nonCritical = <ChangeNotifierProvider>[];
    for (final provider in _providers.values) {
      if (provider != _providers[AuthProvider]) {
        nonCritical.add(provider);
      }
    }
    return nonCritical;
  }

  /// Reset providers (for testing)
  static void reset() {
    _providers.clear();
    _isInitialized = false;
  }
}
