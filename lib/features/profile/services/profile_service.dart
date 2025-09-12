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
        fromJson: (data) => data as Map<String, dynamic>,
      );

      if (response.success && response.data != null) {
        return ProfileModel.fromJson(response.data!);
      }

      return null;
    } catch (e) {
      Logger.error('Get profile error', error: e);
      return null;
    }
  }

  /// Update user profile with comprehensive details
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

      final response = await _apiClient.put<Map<String, dynamic>>(
        ApiEndpoints.userProfileEndpoint(userId),
        {},
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

  /// Upload profile image
  Future<ProfileResult> uploadProfileImage({
    required String userId,
    required String imagePath,
  }) async {
    try {
      Logger.userAction(
        'Profile image upload attempt',
        data: {'userId': userId},
      );

      final response = await _apiClient.post<Map<String, dynamic>>(
        ApiEndpoints.userProfileImageEndpoint(userId),
        {},
        {'image_path': imagePath},
        fromJson: (data) => data as Map<String, dynamic>,
      );

      if (response.success && response.data != null) {
        final profile = ProfileModel.fromJson(response.data!);
        Logger.userAction(
          'Profile image uploaded successfully',
          data: {'userId': userId},
        );
        return ProfileResult.success(
          profile: profile,
          message: response.message,
        );
      } else {
        Logger.warning('Profile image upload failed: ${response.message}');
        return ProfileResult.failure(message: response.message);
      }
    } on ApiError catch (e) {
      Logger.error('Profile image upload API error', error: e);
      return ProfileResult.failure(message: e.message);
    } catch (e) {
      Logger.error('Profile image upload unexpected error', error: e);
      return ProfileResult.failure(message: 'An unexpected error occurred');
    }
  }

  /// Update skills
  Future<ProfileResult> updateSkills({
    required String userId,
    required List<String> skills,
  }) async {
    try {
      Logger.userAction(
        'Skills update attempt',
        data: {'userId': userId, 'skills': skills},
      );

      final response = await _apiClient.put<Map<String, dynamic>>(
        ApiEndpoints.userProfileSkillsEndpoint(userId),
        {},
        data: {'skills': skills},
        fromJson: (data) => data as Map<String, dynamic>,
      );

      if (response.success && response.data != null) {
        final profile = ProfileModel.fromJson(response.data!);
        Logger.userAction(
          'Skills updated successfully',
          data: {'userId': userId},
        );
        return ProfileResult.success(
          profile: profile,
          message: response.message,
        );
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

  /// Update languages
  Future<ProfileResult> updateLanguages({
    required String userId,
    required List<String> languages,
  }) async {
    try {
      Logger.userAction(
        'Languages update attempt',
        data: {'userId': userId, 'languages': languages},
      );

      final response = await _apiClient.put<Map<String, dynamic>>(
        ApiEndpoints.userProfileLanguagesEndpoint(userId),
        {},
        data: {'languages': languages},
        fromJson: (data) => data as Map<String, dynamic>,
      );

      if (response.success && response.data != null) {
        final profile = ProfileModel.fromJson(response.data!);
        Logger.userAction(
          'Languages updated successfully',
          data: {'userId': userId},
        );
        return ProfileResult.success(
          profile: profile,
          message: response.message,
        );
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

  /// Update preferences
  Future<ProfileResult> updatePreferences({
    required String userId,
    required Map<String, dynamic> preferences,
  }) async {
    try {
      Logger.userAction('Preferences update attempt', data: {'userId': userId});

      final response = await _apiClient.put<Map<String, dynamic>>(
        ApiEndpoints.userProfilePreferencesEndpoint(userId),
        {},
        data: {'preferences': preferences},
        fromJson: (data) => data as Map<String, dynamic>,
      );

      if (response.success && response.data != null) {
        final profile = ProfileModel.fromJson(response.data!);
        Logger.userAction(
          'Preferences updated successfully',
          data: {'userId': userId},
        );
        return ProfileResult.success(
          profile: profile,
          message: response.message,
        );
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

  /// Search profiles by criteria
  Future<List<ProfileModel>> searchProfiles({
    String? query,
    UserRole? role,
    String? location,
    List<String>? skills,
    double? minRating,
    int? limit = 20,
    int? offset = 0,
  }) async {
    try {
      Logger.userAction(
        'Profile search',
        data: {
          'query': query,
          'role': role?.value,
          'location': location,
          'skills': skills,
          'minRating': minRating,
        },
      );

      final queryParams = <String, dynamic>{};
      if (query != null) queryParams['q'] = query;
      if (role != null) queryParams['role'] = role.value;
      if (location != null) queryParams['location'] = location;
      if (skills != null) queryParams['skills'] = skills.join(',');
      if (minRating != null) queryParams['min_rating'] = minRating;
      queryParams['limit'] = limit;
      queryParams['offset'] = offset;

      final response = await _apiClient.get<List<dynamic>>(
        ApiEndpoints.search,
        queryParameters: queryParams,
        fromJson: (data) => data as List<dynamic>,
      );

      if (response.success && response.data != null) {
        final profiles = response.data!
            .map((json) => ProfileModel.fromJson(json as Map<String, dynamic>))
            .toList();
        Logger.userAction(
          'Profile search successful',
          data: {'count': profiles.length},
        );
        return profiles;
      }

      return [];
    } catch (e) {
      Logger.error('Profile search error', error: e);
      return [];
    }
  }
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
