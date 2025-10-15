import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/app_constants.dart';
import '../utils/logger.dart';
import '../../features/auth/models/user_model.dart';
import 'navigation_service.dart';
import 'dart:convert';

/// Session manager for handling user authentication state
/// Manages token storage, user data, and session persistence
/// Uses flutter_secure_storage for secure token storage
class SessionManager {
  static final SessionManager _instance = SessionManager._internal();
  factory SessionManager() => _instance;
  SessionManager._internal();

  SharedPreferences? _prefs;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );
  String? _authToken;
  UserModel? _currentUser;
  bool _isInitialized = false;

  /// Initialize the session manager
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _prefs = await SharedPreferences.getInstance();

      // Read token from secure storage
      _authToken = await _secureStorage.read(key: AppConstants.tokenKey);

      // Migrate old token from SharedPreferences if exists
      if (_authToken == null) {
        final oldToken = _prefs?.getString(AppConstants.tokenKey);
        if (oldToken != null) {
          Logger.info(
            'Migrating token from SharedPreferences to secure storage',
          );
          await _secureStorage.write(
            key: AppConstants.tokenKey,
            value: oldToken,
          );
          await _prefs?.remove(AppConstants.tokenKey);
          _authToken = oldToken;
        }
      }

      final userDataString = _prefs?.getString(AppConstants.userKey);
      if (userDataString != null) {
        final userData = jsonDecode(userDataString) as Map<String, dynamic>;
        _currentUser = UserModel.fromJson(userData);
      }

      _isInitialized = true;
      Logger.info(
        'Session manager initialized',
        data: {
          'hasToken': _authToken != null,
          'hasUser': _currentUser != null,
          'isAuthenticated': isAuthenticated,
        },
      );
      debugPrint(
        'SessionManager: Initialized - hasToken: ${_authToken != null}, hasUser: ${_currentUser != null}, isAuthenticated: $isAuthenticated',
      );
    } catch (e) {
      Logger.error('Failed to initialize session manager', error: e);
      debugPrint('SessionManager: Initialization failed - $e');
      _isInitialized = false;
    }
  }

  /// Get current authentication token
  String? get authToken => _authToken;

  /// Get current user
  UserModel? get currentUser => _currentUser;

  /// Check if user is authenticated
  bool get isAuthenticated => _authToken != null && _currentUser != null;

  /// Check if session manager is initialized
  bool get isInitialized => _isInitialized;

  /// Save authentication token to secure storage
  Future<void> saveToken(String token) async {
    try {
      _authToken = token;
      // Store token in secure storage (encrypted)
      await _secureStorage.write(key: AppConstants.tokenKey, value: token);
      Logger.auth(
        'Token saved successfully to secure storage',
        data: {
          'tokenLength': token.length,
          'tokenPreview': token.substring(0, 6) + '***',
        },
      );
    } catch (e) {
      Logger.error('Failed to save token', error: e);
      throw Exception('Failed to save authentication token');
    }
  }

  /// Save user data
  Future<void> saveUser(UserModel user) async {
    try {
      _currentUser = user;
      final userJson = jsonEncode(user.toJson());
      await _prefs?.setString(AppConstants.userKey, userJson);
      Logger.auth(
        'User data saved successfully',
        data: {'userId': user.id, 'userType': user.userType},
      );
    } catch (e) {
      Logger.error('Failed to save user data', error: e);
      throw Exception('Failed to save user data');
    }
  }

  /// Save session (token and user data)
  Future<void> saveSession({
    required String token,
    required UserModel user,
  }) async {
    try {
      await saveToken(token);
      await saveUser(user);
      Logger.auth(
        'Session saved successfully',
        data: {'userId': user.id, 'userType': user.userType},
      );
    } catch (e) {
      Logger.error('Failed to save session', error: e);
      throw Exception('Failed to save session');
    }
  }

  /// Update user data
  Future<void> updateUser(UserModel user) async {
    try {
      _currentUser = user;
      final userJson = jsonEncode(user.toJson());
      await _prefs?.setString(AppConstants.userKey, userJson);
      Logger.auth(
        'User data updated successfully',
        data: {'userId': user.id, 'userType': user.userType},
      );
    } catch (e) {
      Logger.error('Failed to update user data', error: e);
      throw Exception('Failed to update user data');
    }
  }

  /// Clear session data
  Future<void> clearSession() async {
    try {
      _authToken = null;
      _currentUser = null;
      // Clear token from secure storage
      await _secureStorage.delete(key: AppConstants.tokenKey);
      // Clear user data from SharedPreferences
      await _prefs?.remove(AppConstants.userKey);
      // Also clear old token from SharedPreferences if it exists
      await _prefs?.remove(AppConstants.tokenKey);
      Logger.auth('Session cleared successfully from secure storage');
    } catch (e) {
      Logger.error('Failed to clear session', error: e);
      throw Exception('Failed to clear session data');
    }
  }

  /// Force logout (clear session and redirect to login)
  Future<void> forceLogout({String? reason}) async {
    try {
      Logger.warning(
        'Session manager: Force logout triggered',
        data: {'reason': reason ?? 'Token expired or unauthorized'},
      );

      // Clear session data
      await clearSession();

      // Redirect to login screen using navigation service
      final navigationService = NavigationService();
      await navigationService.redirectToLogin(
        reason: reason ?? 'Your session has expired. Please log in again.',
        clearStack: true,
      );

      Logger.info('Session manager: Force logout completed successfully');
    } catch (e) {
      Logger.error('Session manager: Error during force logout', error: e);
    }
  }

  /// Handle token expiration
  Future<void> handleTokenExpiration({String? reason}) async {
    try {
      Logger.warning(
        'Session manager: Token expiration detected',
        data: {'reason': reason ?? 'JWT token expired'},
      );

      // Directly clear session and redirect to login without showing dialog
      await forceLogout(reason: reason);
    } catch (e) {
      Logger.error(
        'Session manager: Error handling token expiration',
        error: e,
      );
      // Fallback: directly redirect to login
      await forceLogout(reason: reason);
    }
  }

  /// Get token information for debugging
  Map<String, dynamic> getTokenInfo() {
    try {
      return {
        'hasToken': _authToken != null,
        'tokenLength': _authToken?.length ?? 0,
      };
    } catch (e) {
      Logger.error('Failed to get token info', error: e);
      return {'error': e.toString()};
    }
  }

  /// Get stored theme mode
  String? getThemeMode() {
    return _prefs?.getString(AppConstants.themeKey);
  }

  /// Save theme mode
  Future<void> saveThemeMode(String themeMode) async {
    try {
      await _prefs?.setString(AppConstants.themeKey, themeMode);
      Logger.info('Theme mode saved', data: {'theme': themeMode});
    } catch (e) {
      Logger.error('Failed to save theme mode', error: e);
    }
  }

  /// Get stored language
  String? getLanguage() {
    return _prefs?.getString(AppConstants.languageKey);
  }

  /// Save language
  Future<void> saveLanguage(String language) async {
    try {
      await _prefs?.setString(AppConstants.languageKey, language);
      Logger.info('Language saved', data: {'language': language});
    } catch (e) {
      Logger.error('Failed to save language', error: e);
    }
  }

  /// Get user preferences
  Map<String, dynamic> getUserPreferences() {
    return {'theme': getThemeMode(), 'language': getLanguage()};
  }

  /// Save user preferences
  Future<void> saveUserPreferences(Map<String, dynamic> preferences) async {
    try {
      if (preferences.containsKey('theme')) {
        await saveThemeMode(preferences['theme']);
      }
      if (preferences.containsKey('language')) {
        await saveLanguage(preferences['language']);
      }
      Logger.info('User preferences saved', data: preferences);
    } catch (e) {
      Logger.error('Failed to save user preferences', error: e);
    }
  }

  /// Check if first launch
  bool isFirstLaunch() {
    return _prefs?.getBool('first_launch') ?? true;
  }

  /// Mark first launch as completed
  Future<void> markFirstLaunchCompleted() async {
    try {
      await _prefs?.setBool('first_launch', false);
      Logger.info('First launch marked as completed');
    } catch (e) {
      Logger.error('Failed to mark first launch as completed', error: e);
    }
  }

  /// Reset first launch (for testing purposes)
  Future<void> resetFirstLaunch() async {
    try {
      await _prefs?.setBool('first_launch', true);
      Logger.info('First launch reset');
    } catch (e) {
      Logger.error('Failed to reset first launch', error: e);
    }
  }

  /// Get app version
  String? getAppVersion() {
    return _prefs?.getString('app_version');
  }

  /// Save app version
  Future<void> saveAppVersion(String version) async {
    try {
      await _prefs?.setString('app_version', version);
      Logger.info('App version saved', data: {'version': version});
    } catch (e) {
      Logger.error('Failed to save app version', error: e);
    }
  }

  /// Close session manager
  Future<void> close() async {
    try {
      _isInitialized = false;
      Logger.info('Session manager closed');
    } catch (e) {
      Logger.error('Failed to close session manager', error: e);
    }
  }
}
