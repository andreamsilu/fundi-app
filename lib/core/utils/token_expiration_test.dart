import '../services/session_manager.dart';
import '../services/jwt_token_manager.dart';
import '../services/navigation_service.dart';
import '../utils/logger.dart';

/// Test utility for token expiration handling
/// This class provides methods to test token expiration scenarios
class TokenExpirationTest {
  static final SessionManager _sessionManager = SessionManager();
  static final JwtTokenManager _jwtTokenManager = JwtTokenManager();
  static final NavigationService _navigationService = NavigationService();

  /// Test token expiration by simulating an expired token
  static Future<void> testTokenExpiration() async {
    try {
      Logger.info('TokenExpirationTest: Starting token expiration test');

      // Check current token status
      final tokenInfo = _jwtTokenManager.getTokenInfo();
      Logger.info('TokenExpirationTest: Current token info', data: tokenInfo);

      // Test if token is valid
      final isValid = _jwtTokenManager.isTokenValid();
      Logger.info('TokenExpirationTest: Token is valid: $isValid');

      if (!isValid) {
        Logger.info(
          'TokenExpirationTest: Token is invalid, testing expiration handling',
        );

        // Test token expiration handling
        await _sessionManager.handleTokenExpiration(
          reason: 'Test: Token expiration detected',
        );
      } else {
        Logger.info(
          'TokenExpirationTest: Token is valid, no expiration handling needed',
        );
      }

      Logger.info('TokenExpirationTest: Token expiration test completed');
    } catch (e) {
      Logger.error(
        'TokenExpirationTest: Error during token expiration test',
        error: e,
      );
    }
  }

  /// Test force logout functionality
  static Future<void> testForceLogout() async {
    try {
      Logger.info('TokenExpirationTest: Testing force logout');

      await _sessionManager.forceLogout(reason: 'Test: Force logout triggered');

      Logger.info('TokenExpirationTest: Force logout test completed');
    } catch (e) {
      Logger.error(
        'TokenExpirationTest: Error during force logout test',
        error: e,
      );
    }
  }

  /// Test navigation service redirect to login
  static Future<void> testNavigationRedirect() async {
    try {
      Logger.info('TokenExpirationTest: Testing navigation redirect to login');

      await _navigationService.redirectToLogin(
        reason: 'Test: Navigation redirect to login',
      );

      Logger.info('TokenExpirationTest: Navigation redirect test completed');
    } catch (e) {
      Logger.error(
        'TokenExpirationTest: Error during navigation redirect test',
        error: e,
      );
    }
  }

  /// Get comprehensive token information for debugging
  static Map<String, dynamic> getTokenDebugInfo() {
    try {
      final sessionManager = SessionManager();
      final jwtTokenManager = JwtTokenManager();

      return {
        'sessionManager': {
          'isInitialized': sessionManager.isInitialized,
          'isAuthenticated': sessionManager.isAuthenticated,
          'hasToken': sessionManager.authToken != null,
          'hasUser': sessionManager.currentUser != null,
        },
        'jwtTokenManager': jwtTokenManager.getTokenInfo(),
        'timestamp': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      Logger.error('TokenExpirationTest: Error getting debug info', error: e);
      return {
        'error': e.toString(),
        'timestamp': DateTime.now().toIso8601String(),
      };
    }
  }

  /// Run all token expiration tests
  static Future<void> runAllTests() async {
    try {
      Logger.info('TokenExpirationTest: Running all token expiration tests');

      // Get initial debug info
      final initialInfo = getTokenDebugInfo();
      Logger.info('TokenExpirationTest: Initial state', data: initialInfo);

      // Test token expiration
      await testTokenExpiration();

      // Wait a bit between tests
      await Future.delayed(const Duration(seconds: 1));

      // Test force logout
      await testForceLogout();

      // Wait a bit between tests
      await Future.delayed(const Duration(seconds: 1));

      // Test navigation redirect
      await testNavigationRedirect();

      Logger.info('TokenExpirationTest: All tests completed');
    } catch (e) {
      Logger.error('TokenExpirationTest: Error running tests', error: e);
    }
  }
}
