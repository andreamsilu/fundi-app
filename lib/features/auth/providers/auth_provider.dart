import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../../../core/utils/logger.dart';

/// Authentication provider for state management
/// Handles user authentication state and operations
class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  UserModel? _user;
  bool _isLoading = false;
  String? _errorMessage;

  /// Get current user
  UserModel? get user => _user;

  /// Check if user is authenticated
  bool get isAuthenticated => _user != null;

  /// Check if loading
  bool get isLoading => _isLoading;

  /// Get error message
  String? get errorMessage => _errorMessage;

  /// Check if user is customer
  bool get isCustomer => _user?.isCustomer ?? false;

  /// Check if user is fundi
  bool get isFundi => _user?.isFundi ?? false;

  /// Check if user is admin
  bool get isAdmin => _user?.isAdmin ?? false;

  /// Initialize authentication state
  Future<void> initialize() async {
    _setLoading(true);
    try {
      await _authService.initialize();
      _user = _authService.currentUser;
      Logger.info('Auth provider initialized');
    } catch (e) {
      Logger.error('Auth provider initialization error', error: e);
      _setError('Failed to initialize authentication');
    } finally {
      _setLoading(false);
    }
  }

  /// Login user
  Future<bool> login({required String phoneNumber, required String password}) async {
    _setLoading(true);
    _clearError();
    try {
      final result = await _authService.login(phoneNumber: phoneNumber, password: password);

      if (result.success && result.user != null) {
        _user = result.user;
        notifyListeners();
        Logger.info('User logged in successfully');
        return true;
      } else {
        _setError(result.message);
        return false;
      }
    } catch (e) {
      Logger.error('Login error', error: e);
      _setError('An unexpected error occurred');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Register user
  Future<bool> register({
    required String phoneNumber,
    required String password,
    required UserRole role,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _authService.register(
        phoneNumber: phoneNumber,
        password: password,
        role: role,
      );

      if (result.success && result.user != null) {
        _user = result.user;
        notifyListeners();
        Logger.info('User registered successfully');
        return true;
      } else {
        _setError(result.message);
        return false;
      }
    } catch (e) {
      Logger.error('Registration error', error: e);
      _setError('An unexpected error occurred');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Logout user
  Future<void> logout() async {
    _setLoading(true);

    try {
      await _authService.logout();
      _user = null;
      _clearError();
      notifyListeners();
      Logger.info('User logged out successfully');
    } catch (e) {
      Logger.error('Logout error', error: e);
      _setError('Failed to logout');
    } finally {
      _setLoading(false);
    }
  }

  /// Update user profile
  Future<bool> updateProfile({
    required String phoneNumber,
    String? profileImageUrl,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _authService.updateProfile(
        phoneNumber: phoneNumber,
        profileImageUrl: profileImageUrl,
      );

      if (result.success && result.user != null) {
        _user = result.user;
        notifyListeners();
        Logger.info('Profile updated successfully');
        return true;
      } else {
        _setError(result.message);
        return false;
      }
    } catch (e) {
      Logger.error('Profile update error', error: e);
      _setError('An unexpected error occurred');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Change password
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _authService.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );

      if (result.success) {
        Logger.info('Password changed successfully');
        return true;
      } else {
        _setError(result.message);
        return false;
      }
    } catch (e) {
      Logger.error('Password change error', error: e);
      _setError('An unexpected error occurred');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Request password reset
    Future<bool> requestPasswordReset({required String phoneNumber}) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _authService.requestPasswordReset(phoneNumber: phoneNumber);

      if (result.success) {
        Logger.info('Password reset email sent');
        return true;
      } else {
        _setError(result.message);
        return false;
      }
    } catch (e) {
      Logger.error('Password reset request error', error: e);
      _setError('An unexpected error occurred');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Refresh user data
  Future<void> refreshUser() async {
    try {
      final user = await _authService.getCurrentUserProfile();
      if (user != null) {
        _user = user;
        notifyListeners();
      }
    } catch (e) {
      Logger.error('Refresh user error', error: e);
    }
  }

  /// Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// Set error message
  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  /// Clear error message
  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Clear error manually
  void clearError() {
    _clearError();
  }
}
