import 'package:jwt_decoder/jwt_decoder.dart';
import '../utils/logger.dart';
import 'session_manager.dart';

/// JWT Token Manager for handling JWT token operations
/// Manages token validation, expiration checking, and refresh logic
class JwtTokenManager {
  static final JwtTokenManager _instance = JwtTokenManager._internal();
  factory JwtTokenManager() => _instance;
  JwtTokenManager._internal();

  final SessionManager _sessionManager = SessionManager();

  /// Check if JWT token is valid and not expired
  bool isTokenValid() {
    try {
      final token = _sessionManager.authToken;
      if (token == null) {
        Logger.warning('JWT token manager: No token available');
        return false;
      }

      // Check if token is expired
      final isExpired = JwtDecoder.isExpired(token);
      if (isExpired) {
        Logger.warning('JWT token manager: Token is expired');
        // Trigger token expiration handling
        _handleTokenExpiration();
        return false;
      }

      // Check if token will expire soon (within 5 minutes)
      final expirationDate = JwtDecoder.getExpirationDate(token);
      final now = DateTime.now();
      final timeUntilExpiry = expirationDate.difference(now);

      if (timeUntilExpiry.inMinutes < 5) {
        Logger.info(
          'JWT token manager: Token expires soon: ${timeUntilExpiry.inMinutes} minutes',
        );
        return true; // Still valid but should be refreshed
      }

      return true;
    } catch (e) {
      Logger.error('JWT token manager: Error validating JWT token', error: e);
      return false;
    }
  }

  /// Check if JWT token is expired
  bool isTokenExpired() {
    try {
      final token = _sessionManager.authToken;
      if (token == null) return true;

      return JwtDecoder.isExpired(token);
    } catch (e) {
      Logger.error('Error checking JWT token expiration', error: e);
      return true;
    }
  }

  /// Get token expiration date
  DateTime? getTokenExpirationDate() {
    try {
      final token = _sessionManager.authToken;
      if (token == null) return null;

      return JwtDecoder.getExpirationDate(token);
    } catch (e) {
      Logger.error('Error getting JWT token expiration date', error: e);
      return null;
    }
  }

  /// Get token payload
  Map<String, dynamic>? getTokenPayload() {
    try {
      final token = _sessionManager.authToken;
      if (token == null) return null;

      return JwtDecoder.decode(token);
    } catch (e) {
      Logger.error('Error decoding JWT token payload', error: e);
      return null;
    }
  }

  /// Get user ID from token
  String? getUserIdFromToken() {
    try {
      final payload = getTokenPayload();
      if (payload == null) return null;

      return payload['sub']?.toString() ?? payload['user_id']?.toString();
    } catch (e) {
      Logger.error('Error getting user ID from JWT token', error: e);
      return null;
    }
  }

  /// Get user roles from token
  List<String>? getUserRolesFromToken() {
    try {
      final payload = getTokenPayload();
      if (payload == null) return null;

      final roles = payload['roles'] as List<dynamic>?;
      if (roles == null) return null;

      return roles.map((role) => role.toString()).toList();
    } catch (e) {
      Logger.error('Error getting user roles from JWT token', error: e);
      return null;
    }
  }

  /// Get time until token expiration
  Duration? getTimeUntilExpiration() {
    try {
      final expirationDate = getTokenExpirationDate();
      if (expirationDate == null) return null;

      final now = DateTime.now();
      return expirationDate.difference(now);
    } catch (e) {
      Logger.error('Error calculating time until token expiration', error: e);
      return null;
    }
  }

  /// Check if token needs refresh (expires within 5 minutes)
  bool needsRefresh() {
    try {
      final timeUntilExpiry = getTimeUntilExpiration();
      if (timeUntilExpiry == null) return true;

      return timeUntilExpiry.inMinutes < 5;
    } catch (e) {
      Logger.error('Error checking if token needs refresh', error: e);
      return true;
    }
  }

  /// Get token information for debugging
  Map<String, dynamic> getTokenInfo() {
    try {
      final token = _sessionManager.authToken;
      if (token == null) {
        return {
          'hasToken': false,
          'isValid': false,
          'isExpired': true,
          'expirationDate': null,
          'timeUntilExpiry': null,
          'needsRefresh': true,
        };
      }

      final isExpired = isTokenExpired();
      final expirationDate = getTokenExpirationDate();
      final timeUntilExpiry = getTimeUntilExpiration();
      final tokenNeedsRefresh = needsRefresh();

      return {
        'hasToken': true,
        'isValid': !isExpired,
        'isExpired': isExpired,
        'expirationDate': expirationDate?.toIso8601String(),
        'timeUntilExpiry': timeUntilExpiry?.inMinutes,
        'needsRefresh': tokenNeedsRefresh,
        'userId': getUserIdFromToken(),
        'userRoles': getUserRolesFromToken(),
      };
    } catch (e) {
      Logger.error('Error getting JWT token info', error: e);
      return {
        'error': e.toString(),
        'hasToken': false,
        'isValid': false,
        'isExpired': true,
      };
    }
  }

  /// Clear token and session
  Future<void> clearToken() async {
    try {
      await _sessionManager.clearSession();
      Logger.info('JWT token cleared');
    } catch (e) {
      Logger.error('Error clearing JWT token', error: e);
    }
  }

  /// Handle token expiration
  void _handleTokenExpiration() {
    // Use session manager to handle token expiration
    _sessionManager.handleTokenExpiration(
      reason: 'Your session has expired. Please log in again.',
    );
  }

  /// Force logout due to token issues
  Future<void> forceLogout({String? reason}) async {
    try {
      Logger.warning(
        'JWT token manager: Force logout due to token issues',
        data: {'reason': reason},
      );
      await _sessionManager.forceLogout(reason: reason);
    } catch (e) {
      Logger.error('JWT token manager: Error during force logout', error: e);
    }
  }
}
