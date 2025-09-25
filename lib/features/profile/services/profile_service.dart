import 'package:fundi/core/constants/api_endpoints.dart';

import '../models/profile_model.dart';
import '../../../core/network/api_client.dart';
import '../../../core/utils/logger.dart';

/// Profile service handling all profile-related operations
/// Provides methods for updating user profile information
class ProfileService {
  static final ProfileService _instance = ProfileService._internal();
  factory ProfileService() => _instance;
  ProfileService._internal();

  final ApiClient _apiClient = ApiClient();

  /// Get user profile by ID
  Future<ProfileModel?> getProfile(String userId) async {
    try {
      Logger.userAction('Get profile', data: {'userId': userId});

      // Use the correct endpoint - get current user profile
      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiEndpoints.userMe,
        fromJson: (data) {
          // Handle different response structures
          if (data is Map<String, dynamic>) {
            return data;
          } else if (data is List && data.isNotEmpty) {
            // If it's a list, take the first item
            return data.first as Map<String, dynamic>;
          } else {
            throw Exception('Unexpected response format: ${data.runtimeType}');
          }
        },
      );

      if (response.success && response.data != null) {
        try {
          return ProfileModel.fromJson(response.data!);
        } catch (parseError) {
          Logger.error('Profile parsing error', error: parseError);
          return null;
        }
      }

      return null;
    } catch (e) {
      Logger.error('Get profile error', error: e);
      return null;
    }
  }

  /// Update the authenticated user's profile
  /// Aligns with API: PATCH /users/me/profile
  Future<ProfileResult> updateProfile({
    required String userId,
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
      Logger.userAction('Profile update attempt', data: {'userId': userId});

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

      final response = await _apiClient.patch<Map<String, dynamic>>(
        ApiEndpoints.authProfile,
        data: data,
        fromJson: (data) => data as Map<String, dynamic>,
      );

      if (response.success && response.data != null) {
        final profile = ProfileModel.fromJson(response.data!);
        Logger.userAction(
          'Profile updated successfully',
          data: {'userId': userId},
        );
        return ProfileResult.success(
          profile: profile,
          message: response.message,
        );
      } else {
        Logger.warning('Profile update failed: ${response.message}');
        return ProfileResult.failure(message: response.message);
      }
    } on ApiError catch (e) {
      Logger.error('Profile update API error', error: e);
      return ProfileResult.failure(message: e.message);
    } catch (e) {
      Logger.error('Profile update unexpected error', error: e);
      return ProfileResult.failure(message: 'An unexpected error occurred');
    }
  }

  // Note: Image upload is not supported via a dedicated endpoint on the API.
  // Clients should send profile image URL via updateProfile (profile_image_url).

  /// Update skills via PATCH /users/me/profile
  Future<ProfileResult> updateSkills({
    required String userId,
    required List<String> skills,
  }) async {
    try {
      Logger.userAction('Skills update attempt', data: {'skills': skills});

      final response = await _apiClient.patch<Map<String, dynamic>>(
        ApiEndpoints.authProfile,
        data: {'skills': skills},
        fromJson: (data) => data as Map<String, dynamic>,
      );

      if (response.success && response.data != null) {
        final profile = ProfileModel.fromJson(response.data!);
        Logger.userAction('Skills updated successfully');
        return ProfileResult.success(profile: profile, message: response.message);
      } else {
        Logger.warning('Skills update failed: ${response.message}');
        return ProfileResult.failure(message: response.message);
      }
    } on ApiError catch (e) {
      Logger.error('Skills update API error', error: e);
      return ProfileResult.failure(message: e.message);
    } catch (e) {
      Logger.error('Skills update unexpected error', error: e);
      return ProfileResult.failure(message: 'An unexpected error occurred');
    }
  }

  /// Update languages via PATCH /users/me/profile
  Future<ProfileResult> updateLanguages({
    required String userId,
    required List<String> languages,
  }) async {
    try {
      Logger.userAction('Languages update attempt', data: {'languages': languages});

      final response = await _apiClient.patch<Map<String, dynamic>>(
        ApiEndpoints.authProfile,
        data: {'languages': languages},
        fromJson: (data) => data as Map<String, dynamic>,
      );

      if (response.success && response.data != null) {
        final profile = ProfileModel.fromJson(response.data!);
        Logger.userAction('Languages updated successfully');
        return ProfileResult.success(profile: profile, message: response.message);
      } else {
        Logger.warning('Languages update failed: ${response.message}');
        return ProfileResult.failure(message: response.message);
      }
    } on ApiError catch (e) {
      Logger.error('Languages update API error', error: e);
      return ProfileResult.failure(message: e.message);
    } catch (e) {
      Logger.error('Languages update unexpected error', error: e);
      return ProfileResult.failure(message: 'An unexpected error occurred');
    }
  }

  /// Update preferences via PATCH /users/me/profile
  Future<ProfileResult> updatePreferences({
    required String userId,
    required Map<String, dynamic> preferences,
  }) async {
    try {
      Logger.userAction('Preferences update attempt', data: {'preferences': preferences});

      final response = await _apiClient.patch<Map<String, dynamic>>(
        ApiEndpoints.authProfile,
        data: {'preferences': preferences},
        fromJson: (data) => data as Map<String, dynamic>,
      );

      if (response.success && response.data != null) {
        final profile = ProfileModel.fromJson(response.data!);
        Logger.userAction('Preferences updated successfully');
        return ProfileResult.success(profile: profile, message: response.message);
      } else {
        Logger.warning('Preferences update failed: ${response.message}');
        return ProfileResult.failure(message: response.message);
      }
    } on ApiError catch (e) {
      Logger.error('Preferences update API error', error: e);
      return ProfileResult.failure(message: e.message);
    } catch (e) {
      Logger.error('Preferences update unexpected error', error: e);
      return ProfileResult.failure(message: 'An unexpected error occurred');
    }
  }

  // Search profiles method - REMOVED (search endpoint not implemented in API)
}

/// Profile operation result wrapper
class ProfileResult {
  final bool success;
  final String message;
  final ProfileModel? profile;

  ProfileResult._({required this.success, required this.message, this.profile});

  factory ProfileResult.success({
    required String message,
    ProfileModel? profile,
  }) {
    return ProfileResult._(success: true, message: message, profile: profile);
  }

  factory ProfileResult.failure({required String message}) {
    return ProfileResult._(success: false, message: message);
  }
}
