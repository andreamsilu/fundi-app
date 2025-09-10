import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/auth/models/user_model.dart';
import '../constants/app_constants.dart';
import '../utils/logger.dart';

/// Session manager for handling user authentication state and token management
/// Manages user sessions, token storage, and automatic session restoration
class SessionManager {
  static final SessionManager _instance = SessionManager._internal();
  factory SessionManager() => _instance;
  SessionManager._internal();

  UserModel? _currentUser;
  String? _authToken;
  DateTime? _tokenExpiry;
  bool _isInitialized = false;

  /// Get current authenticated user
  UserModel? get currentUser => _currentUser;

  /// Get current auth token
  String? get authToken => _authToken;

  /// Check if user is authenticated
  bool get isAuthenticated => _currentUser != null && _authToken != null;

  /// Check if session is valid (not expired)
  bool get isSessionValid {
    if (_authToken == null || _tokenExpiry == null) return false;
    return DateTime.now().isBefore(_tokenExpiry!);
  }

  /// Check if session manager is initialized
  bool get isInitialized => _isInitialized;

  /// Initialize session manager and restore session from storage
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      final prefs = await SharedPreferences.getInstance();

      // Load stored token
      _authToken = prefs.getString(AppConstants.tokenKey);

      // Load stored user data
      final userDataString = prefs.getString(AppConstants.userKey);
      if (userDataString != null) {
        final userData = jsonDecode(userDataString) as Map<String, dynamic>;
        _currentUser = UserModel.fromJson(userData);
      }

      // Load token expiry
      final tokenExpiryString = prefs.getString(
        '${AppConstants.tokenKey}_expiry',
      );
      if (tokenExpiryString != null) {
        _tokenExpiry = DateTime.parse(tokenExpiryString);
      }

      // Check if session is still valid
      if (_authToken != null && !isSessionValid) {
        Logger.warning('Stored session has expired, clearing session');
        await clearSession();
      }

      _isInitialized = true;
      Logger.info(
        'Session manager initialized',
        data: {
          'hasToken': _authToken != null,
          'hasUser': _currentUser != null,
          'isValid': isSessionValid,
        },
      );
    } catch (e) {
      Logger.error('Session manager initialization error', error: e);
      await clearSession();
      _isInitialized = true;
    }
  }

  /// Save user session with token and user data
  Future<void> saveSession({
    required String token,
    required UserModel user,
    Duration? tokenExpiry,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Save token
      _authToken = token;
      await prefs.setString(AppConstants.tokenKey, token);

      // Save user data
      _currentUser = user;
      final userDataString = jsonEncode(user.toJson());
      await prefs.setString(AppConstants.userKey, userDataString);

      // Save token expiry (default to 24 hours if not provided)
      _tokenExpiry = DateTime.now().add(
        tokenExpiry ?? const Duration(hours: 24),
      );
      await prefs.setString(
        '${AppConstants.tokenKey}_expiry',
        _tokenExpiry!.toIso8601String(),
      );

      Logger.info(
        'Session saved successfully',
        data: {
          'userId': user.id,
          'tokenLength': token.length,
          'expiresAt': _tokenExpiry!.toIso8601String(),
        },
      );
    } catch (e) {
      Logger.error('Failed to save session', error: e);
      rethrow;
    }
  }

  /// Update current user data
  Future<void> updateUser(UserModel user) async {
    try {
      _currentUser = user;

      if (_isInitialized) {
        final prefs = await SharedPreferences.getInstance();
        final userDataString = jsonEncode(user.toJson());
        await prefs.setString(AppConstants.userKey, userDataString);
      }

      Logger.info('User data updated', data: {'userId': user.id});
    } catch (e) {
      Logger.error('Failed to update user data', error: e);
      rethrow;
    }
  }

  /// Refresh authentication token
  Future<bool> refreshToken(String newToken, {Duration? tokenExpiry}) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Update token
      _authToken = newToken;
      await prefs.setString(AppConstants.tokenKey, newToken);

      // Update token expiry
      _tokenExpiry = DateTime.now().add(
        tokenExpiry ?? const Duration(hours: 24),
      );
      await prefs.setString(
        '${AppConstants.tokenKey}_expiry',
        _tokenExpiry!.toIso8601String(),
      );

      Logger.info(
        'Token refreshed successfully',
        data: {
          'newTokenLength': newToken.length,
          'expiresAt': _tokenExpiry!.toIso8601String(),
        },
      );

      return true;
    } catch (e) {
      Logger.error('Failed to refresh token', error: e);
      return false;
    }
  }

  /// Clear current session
  Future<void> clearSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Clear stored data
      await prefs.remove(AppConstants.tokenKey);
      await prefs.remove(AppConstants.userKey);
      await prefs.remove('${AppConstants.tokenKey}_expiry');

      // Clear memory
      _currentUser = null;
      _authToken = null;
      _tokenExpiry = null;

      Logger.info('Session cleared successfully');
    } catch (e) {
      Logger.error('Failed to clear session', error: e);
      // Force clear memory even if storage fails
      _currentUser = null;
      _authToken = null;
      _tokenExpiry = null;
    }
  }

  /// Check if token needs refresh (within 1 hour of expiry)
  bool get needsTokenRefresh {
    if (_tokenExpiry == null) return false;
    final oneHourFromNow = DateTime.now().add(const Duration(hours: 1));
    return _tokenExpiry!.isBefore(oneHourFromNow);
  }

  /// Get time until token expires
  Duration? get timeUntilExpiry {
    if (_tokenExpiry == null) return null;
    final now = DateTime.now();
    if (_tokenExpiry!.isBefore(now)) return Duration.zero;
    return _tokenExpiry!.difference(now);
  }

  /// Force logout (clear session and notify)
  Future<void> forceLogout() async {
    await clearSession();
    Logger.warning('User session force logged out');
  }

  /// Get session info for debugging
  Map<String, dynamic> getSessionInfo() {
    return {
      'isAuthenticated': isAuthenticated,
      'isSessionValid': isSessionValid,
      'hasToken': _authToken != null,
      'hasUser': _currentUser != null,
      'tokenExpiry': _tokenExpiry?.toIso8601String(),
      'timeUntilExpiry': timeUntilExpiry?.inMinutes,
      'needsRefresh': needsTokenRefresh,
      'isInitialized': _isInitialized,
    };
  }
}
