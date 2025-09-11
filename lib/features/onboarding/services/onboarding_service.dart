import '../../../core/services/session_manager.dart';

/// Service to manage onboarding state
/// Handles checking if user has completed onboarding and storing the state
class OnboardingService {
  static final SessionManager _sessionManager = SessionManager();

  /// Check if user has completed onboarding
  static Future<bool> hasCompletedOnboarding() async {
    await _sessionManager.initialize();
    return !_sessionManager.isFirstLaunch();
  }

  /// Mark onboarding as completed
  static Future<void> completeOnboarding() async {
    await _sessionManager.initialize();
    await _sessionManager.markFirstLaunchCompleted();
  }

  /// Reset onboarding (for testing purposes)
  static Future<void> resetOnboarding() async {
    await _sessionManager.initialize();
    await _sessionManager.resetFirstLaunch();
  }
}
