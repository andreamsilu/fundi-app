import '../../../core/network/api_client.dart';
import '../models/settings_model.dart';

/// Settings service for managing user preferences and app configuration
/// Handles CRUD operations for user settings
class SettingsService {
  final ApiClient _apiClient = ApiClient();

  /// Get user settings
  Future<SettingsResult> getSettings() async {
    try {
      final response = await _apiClient.get('/settings');

      if (response.statusCode == 200) {
        final data = response.data;
        return SettingsResult(
          success: true,
          settings: SettingsModel.fromJson(data),
        );
      } else {
        return SettingsResult(
          success: false,
          message: 'Failed to load settings. Please try again.',
        );
      }
    } catch (e) {
      return SettingsResult(
        success: false,
        message: 'Failed to load settings. Please check your connection.',
      );
    }
  }

  /// Update user settings
  Future<ServiceResult> updateSettings(SettingsModel settings) async {
    try {
      final response = await _apiClient.put(
        '/settings',
        data: settings.toJson(),
      );

      if (response.statusCode == 200) {
        return ServiceResult(success: true);
      } else {
        return ServiceResult(
          success: false,
          message: 'Failed to update settings. Please try again.',
        );
      }
    } catch (e) {
      return ServiceResult(
        success: false,
        message: 'Failed to update settings. Please try again.',
      );
    }
  }

  /// Update specific setting
  Future<ServiceResult> updateSetting(String key, dynamic value) async {
    try {
      final response = await _apiClient.patch(
        '/settings/$key',
        data: {'value': value},
      );

      if (response.statusCode == 200) {
        return ServiceResult(success: true);
      } else {
        return ServiceResult(
          success: false,
          message: 'Failed to update setting. Please try again.',
        );
      }
    } catch (e) {
      return ServiceResult(
        success: false,
        message: 'Failed to update setting. Please try again.',
      );
    }
  }

  /// Reset settings to default
  Future<ServiceResult> resetToDefault() async {
    try {
      final response = await _apiClient.post('/settings/reset');

      if (response.statusCode == 200) {
        return ServiceResult(success: true);
      } else {
        return ServiceResult(
          success: false,
          message: 'Failed to reset settings. Please try again.',
        );
      }
    } catch (e) {
      return ServiceResult(
        success: false,
        message: 'Failed to reset settings. Please try again.',
      );
    }
  }

  /// Export settings
  Future<SettingsExportResult> exportSettings() async {
    try {
      final response = await _apiClient.get('/settings/export');

      if (response.statusCode == 200) {
        final data = response.data;
        return SettingsExportResult(success: true, settingsData: data);
      } else {
        return SettingsExportResult(
          success: false,
          message: 'Failed to export settings. Please try again.',
        );
      }
    } catch (e) {
      return SettingsExportResult(
        success: false,
        message: 'Failed to export settings. Please try again.',
      );
    }
  }

  /// Import settings
  Future<ServiceResult> importSettings(
    Map<String, dynamic> settingsData,
  ) async {
    try {
      final response = await _apiClient.post(
        '/settings/import',
        data: settingsData,
      );

      if (response.statusCode == 200) {
        return ServiceResult(success: true);
      } else {
        return ServiceResult(
          success: false,
          message: 'Failed to import settings. Please try again.',
        );
      }
    } catch (e) {
      return ServiceResult(
        success: false,
        message: 'Failed to import settings. Please try again.',
      );
    }
  }

  /// Get available themes
  Future<List<ThemeOption>> getAvailableThemes() async {
    try {
      final response = await _apiClient.get('/settings/themes');

      if (response.statusCode == 200) {
        final data = response.data;
        return (data['themes'] as List?)
                ?.map((theme) => ThemeOption.fromJson(theme))
                .toList() ??
            [];
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Get available languages
  Future<List<LanguageOption>> getAvailableLanguages() async {
    try {
      final response = await _apiClient.get('/settings/languages');

      if (response.statusCode == 200) {
        final data = response.data;
        return (data['languages'] as List?)
                ?.map((language) => LanguageOption.fromJson(language))
                .toList() ??
            [];
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Update privacy settings
  Future<ServiceResult> updatePrivacySettings(PrivacySettings privacy) async {
    try {
      final response = await _apiClient.put(
        '/settings/privacy',
        data: privacy.toJson(),
      );

      if (response.statusCode == 200) {
        return ServiceResult(success: true);
      } else {
        return ServiceResult(
          success: false,
          message: 'Failed to update privacy settings. Please try again.',
        );
      }
    } catch (e) {
      return ServiceResult(
        success: false,
        message: 'Failed to update privacy settings. Please try again.',
      );
    }
  }

  /// Update notification preferences
  Future<ServiceResult> updateNotificationPreferences(
    NotificationPreferences preferences,
  ) async {
    try {
      final response = await _apiClient.put(
        '/settings/notifications',
        data: preferences.toJson(),
      );

      if (response.statusCode == 200) {
        return ServiceResult(success: true);
      } else {
        return ServiceResult(
          success: false,
          message:
              'Failed to update notification preferences. Please try again.',
        );
      }
    } catch (e) {
      return ServiceResult(
        success: false,
        message: 'Failed to update notification preferences. Please try again.',
      );
    }
  }
}

/// Result class for settings operations
class SettingsResult {
  final bool success;
  final String? message;
  final SettingsModel? settings;

  SettingsResult({required this.success, this.message, this.settings});
}

/// Result class for settings export
class SettingsExportResult {
  final bool success;
  final String? message;
  final Map<String, dynamic>? settingsData;

  SettingsExportResult({
    required this.success,
    this.message,
    this.settingsData,
  });
}

/// Generic service result
class ServiceResult {
  final bool success;
  final String? message;

  ServiceResult({required this.success, this.message});
}

/// Theme option model
class ThemeOption {
  final String id;
  final String name;
  final String description;
  final bool isDefault;

  ThemeOption({
    required this.id,
    required this.name,
    required this.description,
    this.isDefault = false,
  });

  factory ThemeOption.fromJson(Map<String, dynamic> json) {
    return ThemeOption(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      isDefault: json['is_default'] ?? false,
    );
  }
}

/// Language option model
class LanguageOption {
  final String code;
  final String name;
  final String nativeName;
  final bool isDefault;

  LanguageOption({
    required this.code,
    required this.name,
    required this.nativeName,
    this.isDefault = false,
  });

  factory LanguageOption.fromJson(Map<String, dynamic> json) {
    return LanguageOption(
      code: json['code'] ?? '',
      name: json['name'] ?? '',
      nativeName: json['native_name'] ?? '',
      isDefault: json['is_default'] ?? false,
    );
  }
}

/// Privacy settings model
class PrivacySettings {
  final String profileVisibility;
  final bool showOnlineStatus;
  final bool locationSharing;
  final bool allowDirectMessages;
  final bool showLastSeen;

  PrivacySettings({
    required this.profileVisibility,
    required this.showOnlineStatus,
    required this.locationSharing,
    required this.allowDirectMessages,
    required this.showLastSeen,
  });

  factory PrivacySettings.fromJson(Map<String, dynamic> json) {
    return PrivacySettings(
      profileVisibility: json['profile_visibility'] ?? 'public',
      showOnlineStatus: json['show_online_status'] ?? true,
      locationSharing: json['location_sharing'] ?? false,
      allowDirectMessages: json['allow_direct_messages'] ?? true,
      showLastSeen: json['show_last_seen'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'profile_visibility': profileVisibility,
      'show_online_status': showOnlineStatus,
      'location_sharing': locationSharing,
      'allow_direct_messages': allowDirectMessages,
      'show_last_seen': showLastSeen,
    };
  }
}

/// Notification preferences model
class NotificationPreferences {
  final bool pushNotifications;
  final bool emailNotifications;
  final bool jobAlerts;
  final bool messageNotifications;
  final bool applicationUpdates;
  final bool systemUpdates;

  NotificationPreferences({
    required this.pushNotifications,
    required this.emailNotifications,
    required this.jobAlerts,
    required this.messageNotifications,
    required this.applicationUpdates,
    required this.systemUpdates,
  });

  factory NotificationPreferences.fromJson(Map<String, dynamic> json) {
    return NotificationPreferences(
      pushNotifications: json['push_notifications'] ?? true,
      emailNotifications: json['email_notifications'] ?? true,
      jobAlerts: json['job_alerts'] ?? true,
      messageNotifications: json['message_notifications'] ?? true,
      applicationUpdates: json['application_updates'] ?? true,
      systemUpdates: json['system_updates'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'push_notifications': pushNotifications,
      'email_notifications': emailNotifications,
      'job_alerts': jobAlerts,
      'message_notifications': messageNotifications,
      'application_updates': applicationUpdates,
      'system_updates': systemUpdates,
    };
  }
}
