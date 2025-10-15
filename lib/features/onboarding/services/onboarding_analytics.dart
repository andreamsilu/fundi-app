import 'package:flutter/foundation.dart';
import '../models/onboarding_page_model.dart';

/// Analytics service for tracking onboarding events
/// Helps understand user behavior during onboarding
class OnboardingAnalytics {
  /// Log when onboarding starts
  static void logOnboardingStart() {
    _logEvent(
      'onboarding_start',
      parameters: {'timestamp': DateTime.now().toIso8601String()},
    );
  }

  /// Log when a page is viewed
  static void logPageView(int pageIndex, OnboardingPageModel page) {
    _logEvent(
      'onboarding_page_view',
      parameters: {
        'page_index': pageIndex,
        'page_title': page.title,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  /// Log when user goes to next page
  static void logNextPage(int fromPage, int toPage) {
    _logEvent(
      'onboarding_next',
      parameters: {
        'from_page': fromPage,
        'to_page': toPage,
        'direction': 'forward',
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  /// Log when user goes to previous page
  static void logPreviousPage(int fromPage, int toPage) {
    _logEvent(
      'onboarding_previous',
      parameters: {
        'from_page': fromPage,
        'to_page': toPage,
        'direction': 'backward',
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  /// Log when user skips onboarding
  static void logSkip(int currentPage, int totalPages) {
    _logEvent(
      'onboarding_skip',
      parameters: {
        'skipped_from_page': currentPage,
        'total_pages': totalPages,
        'completion_percentage': ((currentPage + 1) / totalPages * 100).round(),
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  /// Log when onboarding is completed
  static void logComplete() {
    _logEvent(
      'onboarding_complete',
      parameters: {'timestamp': DateTime.now().toIso8601String()},
    );
  }

  /// Log when user taps on an interactive demo
  static void logDemoInteraction(String pageTitle) {
    _logEvent(
      'onboarding_demo_tap',
      parameters: {
        'page_title': pageTitle,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  /// Log when user swipes
  static void logSwipeGesture(String direction) {
    _logEvent(
      'onboarding_swipe',
      parameters: {
        'direction': direction,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  /// Log time spent on a page
  static void logTimeOnPage(int pageIndex, Duration duration) {
    _logEvent(
      'onboarding_time_on_page',
      parameters: {
        'page_index': pageIndex,
        'duration_seconds': duration.inSeconds,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  /// Log when user clicks on page indicator
  static void logPageIndicatorTap(int targetPage) {
    _logEvent(
      'onboarding_indicator_tap',
      parameters: {
        'target_page': targetPage,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  /// Internal method to log events
  /// In production, this would integrate with Firebase Analytics, Mixpanel, etc.
  static void _logEvent(String eventName, {Map<String, dynamic>? parameters}) {
    if (kDebugMode) {
      debugPrint('📊 Analytics: $eventName');
      if (parameters != null) {
        debugPrint('   Parameters: $parameters');
      }
    }

    // TODO: Integrate with actual analytics service
    // Examples:
    // - Firebase Analytics: FirebaseAnalytics.instance.logEvent(name: eventName, parameters: parameters);
    // - Mixpanel: Mixpanel.track(eventName, properties: parameters);
    // - Custom Backend: ApiService.logEvent(eventName, parameters);
  }

  /// Get analytics summary (for debugging)
  static Map<String, dynamic> getAnalyticsSummary() {
    return {
      'service': 'OnboardingAnalytics',
      'status': 'active',
      'features': [
        'Page view tracking',
        'Navigation tracking',
        'Skip tracking',
        'Completion tracking',
        'Demo interaction tracking',
        'Time on page tracking',
      ],
    };
  }
}

