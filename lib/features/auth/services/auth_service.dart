import '../models/user_model.dart';
import '../../../core/network/api_client.dart';
import '../../../core/utils/logger.dart';

/// OTP Verification Types
enum OtpVerificationType { registration, passwordReset, phoneChange }

/// Authentication service handling all auth-related operations
/// Provides methods for login, registration, logout, and user management
class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final ApiClient _apiClient = ApiClient();
  UserModel? _currentUser;

  /// Get current authenticated user
  UserModel? get currentUser => _currentUser;

  /// Check if user is authenticated
  bool get isAuthenticated => _currentUser != null;

  /// User login with phone and password
  Future<AuthResult> login({
    required String phoneNumber,
    required String password,
  }) async {
    try {
      Logger.userAction('Login attempt', data: {'phoneNumber': phoneNumber});

      final response = await _apiClient.post<Map<String, dynamic>>(
        '/auth/login',
        data: {'phone_number': phoneNumber, 'password': password},
        fromJson: (data) => data as Map<String, dynamic>,
      );

      if (response.success && response.data != null) {
        final token = response.data!['token'] as String;
        final userData = response.data!['user'] as Map<String, dynamic>;

        // Save token and user data
        await _apiClient.saveToken(token);
        _currentUser = UserModel.fromJson(userData);

        Logger.userAction(
          'Login successful',
          data: {'userId': _currentUser!.id},
        );

        return AuthResult.success(
          user: _currentUser!,
          message: response.message,
        );
      } else {
        Logger.warning('Login failed: ${response.message}');
        return AuthResult.failure(message: response.message);
      }
    } on ApiError catch (e) {
      Logger.error('Login API error', error: e);
      return AuthResult.failure(message: e.message);
    } catch (e) {
      Logger.error('Login unexpected error', error: e);
      return AuthResult.failure(message: 'An unexpected error occurred');
    }
  }

  /// User registration with phone and password only
  Future<AuthResult> register({
    required String phoneNumber,
    required String password,
    required UserRole role,
  }) async {
    try {
      Logger.userAction(
        'Registration attempt',
        data: {'phoneNumber': phoneNumber, 'role': role.value},
      );

      final response = await _apiClient.post<Map<String, dynamic>>(
        '/auth/register',
        data: {
          'phone_number': phoneNumber,
          'password': password,
          'role': role.value,
        },
        fromJson: (data) => data as Map<String, dynamic>,
      );

      if (response.success && response.data != null) {
        final token = response.data!['token'] as String;
        final userData = response.data!['user'] as Map<String, dynamic>;

        // Save token and user data
        await _apiClient.saveToken(token);
        _currentUser = UserModel.fromJson(userData);

        Logger.userAction(
          'Registration successful',
          data: {'userId': _currentUser!.id},
        );

        return AuthResult.success(
          user: _currentUser!,
          message: response.message,
        );
      } else {
        Logger.warning('Registration failed: ${response.message}');
        return AuthResult.failure(message: response.message);
      }
    } on ApiError catch (e) {
      Logger.error('Registration API error', error: e);
      return AuthResult.failure(message: e.message);
    } catch (e) {
      Logger.error('Registration unexpected error', error: e);
      return AuthResult.failure(message: 'An unexpected error occurred');
    }
  }

  /// Logout user
  Future<void> logout() async {
    try {
      Logger.userAction('Logout');

      // Call logout endpoint if user is authenticated
      if (_currentUser != null) {
        try {
          await _apiClient.post('/auth/logout');
        } catch (e) {
          // Continue with logout even if API call fails
          Logger.warning('Logout API call failed', error: e);
        }
      }

      // Clear local data
      await _apiClient.clearToken();
      _currentUser = null;

      Logger.info('User logged out successfully');
    } catch (e) {
      Logger.error('Logout error', error: e);
      // Force clear local data even if there's an error
      await _apiClient.clearToken();
      _currentUser = null;
    }
  }

  /// Refresh authentication token
  Future<bool> refreshToken() async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        '/auth/refresh',
        fromJson: (data) => data as Map<String, dynamic>,
      );

      if (response.success && response.data != null) {
        final token = response.data!['token'] as String;
        await _apiClient.saveToken(token);

        Logger.info('Token refreshed successfully');
        return true;
      }

      Logger.warning('Token refresh failed');
      return false;
    } catch (e) {
      Logger.error('Token refresh error', error: e);
      return false;
    }
  }

  /// Get current user profile
  Future<UserModel?> getCurrentUserProfile() async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        '/auth/profile',
        fromJson: (data) => data as Map<String, dynamic>,
      );

      if (response.success && response.data != null) {
        _currentUser = UserModel.fromJson(response.data!);
        return _currentUser;
      }

      return null;
    } catch (e) {
      Logger.error('Get profile error', error: e);
      return null;
    }
  }

  /// Update user profile with all user details
  Future<AuthResult> updateProfile({
    String? firstName,
    String? lastName,
    String? email,
    String? phoneNumber,
    String? profileImageUrl,
    String? bio,
    String? location,
    String? nidaNumber,
    String? vetaCertificate,
    List<String>? skills,
    List<String>? languages,
    Map<String, dynamic>? preferences,
  }) async {
    try {
      Logger.userAction('Profile update attempt');

      final data = <String, dynamic>{};
      if (firstName != null) data['first_name'] = firstName;
      if (lastName != null) data['last_name'] = lastName;
      if (email != null) data['email'] = email;
      if (phoneNumber != null) data['phone_number'] = phoneNumber;
      if (profileImageUrl != null) data['profile_image_url'] = profileImageUrl;
      if (bio != null) data['bio'] = bio;
      if (location != null) data['location'] = location;
      if (nidaNumber != null) data['nida_number'] = nidaNumber;
      if (vetaCertificate != null) data['veta_certificate'] = vetaCertificate;
      if (skills != null) data['skills'] = skills;
      if (languages != null) data['languages'] = languages;
      if (preferences != null) data['preferences'] = preferences;

      final response = await _apiClient.put<Map<String, dynamic>>(
        '/auth/profile',
        data: data,
        fromJson: (data) => data as Map<String, dynamic>,
      );

      if (response.success && response.data != null) {
        _currentUser = UserModel.fromJson(response.data!);

        Logger.userAction('Profile updated successfully');

        return AuthResult.success(
          user: _currentUser!,
          message: response.message,
        );
      } else {
        Logger.warning('Profile update failed: ${response.message}');
        return AuthResult.failure(message: response.message);
      }
    } on ApiError catch (e) {
      Logger.error('Profile update API error', error: e);
      return AuthResult.failure(message: e.message);
    } catch (e) {
      Logger.error('Profile update unexpected error', error: e);
      return AuthResult.failure(message: 'An unexpected error occurred');
    }
  }

  /// Change password
  Future<AuthResult> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      Logger.userAction('Password change attempt');

      final response = await _apiClient.put<Map<String, dynamic>>(
        '/auth/change-password',
        data: {
          'current_password': currentPassword,
          'new_password': newPassword,
        },
        fromJson: (data) => data as Map<String, dynamic>,
      );

      if (response.success) {
        Logger.userAction('Password changed successfully');
        return AuthResult.success(message: response.message);
      } else {
        Logger.warning('Password change failed: ${response.message}');
        return AuthResult.failure(message: response.message);
      }
    } on ApiError catch (e) {
      Logger.error('Password change API error', error: e);
      return AuthResult.failure(message: e.message);
    } catch (e) {
      Logger.error('Password change unexpected error', error: e);
      return AuthResult.failure(message: 'An unexpected error occurred');
    }
  }

  /// Request password reset
  Future<AuthResult> requestPasswordReset({required String phoneNumber}) async {
    try {
      Logger.userAction(
        'Password reset request',
        data: {'phoneNumber': phoneNumber},
      );

      final response = await _apiClient.post<Map<String, dynamic>>(
        '/auth/forgot-password',
        data: {'phone_number': phoneNumber},
        fromJson: (data) => data as Map<String, dynamic>,
      );

      if (response.success) {
        Logger.userAction('Password reset SMS sent');
        return AuthResult.success(message: response.message);
      } else {
        Logger.warning('Password reset request failed: ${response.message}');
        return AuthResult.failure(message: response.message);
      }
    } on ApiError catch (e) {
      Logger.error('Password reset API error', error: e);
      return AuthResult.failure(message: e.message);
    } catch (e) {
      Logger.error('Password reset unexpected error', error: e);
      return AuthResult.failure(message: 'An unexpected error occurred');
    }
  }

  /// Send OTP for phone verification
  Future<AuthResult> sendOtp({
    required String phoneNumber,
    required OtpVerificationType type,
    String? userId,
  }) async {
    try {
      Logger.userAction(
        'OTP send attempt',
        data: {'phoneNumber': phoneNumber, 'type': type.name},
      );

      final response = await _apiClient.post<Map<String, dynamic>>(
        '/auth/send-otp',
        data: {
          'phone_number': phoneNumber,
          'type': type.name,
          if (userId != null) 'user_id': userId,
        },
        fromJson: (data) => data as Map<String, dynamic>,
      );

      if (response.success) {
        Logger.userAction('OTP sent successfully');
        return AuthResult.success(message: response.message);
      } else {
        Logger.warning('OTP send failed: ${response.message}');
        return AuthResult.failure(message: response.message);
      }
    } on ApiError catch (e) {
      Logger.error('OTP send API error', error: e);
      return AuthResult.failure(message: e.message);
    } catch (e) {
      Logger.error('OTP send unexpected error', error: e);
      return AuthResult.failure(message: 'An unexpected error occurred');
    }
  }

  /// Verify OTP
  Future<AuthResult> verifyOtp({
    required String phoneNumber,
    required String otp,
    required OtpVerificationType type,
    String? userId,
  }) async {
    try {
      Logger.userAction(
        'OTP verification attempt',
        data: {'phoneNumber': phoneNumber, 'type': type.name},
      );

      final response = await _apiClient.post<Map<String, dynamic>>(
        '/auth/verify-otp',
        data: {
          'phone_number': phoneNumber,
          'otp': otp,
          'type': type.name,
          if (userId != null) 'user_id': userId,
        },
        fromJson: (data) => data as Map<String, dynamic>,
      );

      if (response.success && response.data != null) {
        // For registration, update current user
        if (type == OtpVerificationType.registration) {
          final token = response.data!['token'] as String;
          final userData = response.data!['user'] as Map<String, dynamic>;
          await _apiClient.saveToken(token);
          _currentUser = UserModel.fromJson(userData);
        }

        Logger.userAction('OTP verified successfully');
        return AuthResult.success(
          user: _currentUser,
          message: response.message,
        );
      } else {
        Logger.warning('OTP verification failed: ${response.message}');
        return AuthResult.failure(message: response.message);
      }
    } on ApiError catch (e) {
      Logger.error('OTP verification API error', error: e);
      return AuthResult.failure(message: e.message);
    } catch (e) {
      Logger.error('OTP verification unexpected error', error: e);
      return AuthResult.failure(message: 'An unexpected error occurred');
    }
  }

  /// Resend OTP
  Future<AuthResult> resendOtp({
    required String phoneNumber,
    required OtpVerificationType type,
    String? userId,
  }) async {
    return await sendOtp(phoneNumber: phoneNumber, type: type, userId: userId);
  }

  /// Reset password with OTP verification
  Future<AuthResult> resetPassword({
    required String phoneNumber,
    required String otp,
    required String newPassword,
  }) async {
    try {
      Logger.userAction(
        'Password reset attempt',
        data: {'phoneNumber': phoneNumber},
      );

      final response = await _apiClient.post<Map<String, dynamic>>(
        '/auth/reset-password',
        data: {
          'phone_number': phoneNumber,
          'otp': otp,
          'new_password': newPassword,
        },
        fromJson: (data) => data as Map<String, dynamic>,
      );

      if (response.success) {
        Logger.userAction('Password reset successful');
        return AuthResult.success(message: response.message);
      } else {
        Logger.warning('Password reset failed: ${response.message}');
        return AuthResult.failure(message: response.message);
      }
    } on ApiError catch (e) {
      Logger.error('Password reset API error', error: e);
      return AuthResult.failure(message: e.message);
    } catch (e) {
      Logger.error('Password reset unexpected error', error: e);
      return AuthResult.failure(message: 'An unexpected error occurred');
    }
  }

  /// Initialize authentication state
  Future<void> initialize() async {
    try {
      // Try to get current user profile if token exists
      final user = await getCurrentUserProfile();
      if (user != null) {
        _currentUser = user;
        Logger.info('User authentication restored');
      }
    } catch (e) {
      Logger.error('Auth initialization error', error: e);
      // Clear invalid token
      await _apiClient.clearToken();
    }
  }
}

/// Authentication result wrapper
class AuthResult {
  final bool success;
  final String message;
  final UserModel? user;

  AuthResult._({required this.success, required this.message, this.user});

  factory AuthResult.success({required String message, UserModel? user}) {
    return AuthResult._(success: true, message: message, user: user);
  }

  factory AuthResult.failure({required String message}) {
    return AuthResult._(success: false, message: message);
  }
}
