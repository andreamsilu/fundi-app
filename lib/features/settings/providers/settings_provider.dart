import 'package:flutter/material.dart';
import 'package:fundi/core/theme/app_theme.dart';
import '../models/settings_model.dart';
import '../services/settings_service.dart';

/// Settings provider for state management
/// Handles user settings and preferences
class SettingsProvider extends ChangeNotifier {
  final SettingsService _settingsService = SettingsService();

  SettingsModel _settings = SettingsModel.defaultSettings();
  bool _isLoading = false;
  String? _errorMessage;
  bool _isInitialized = false;

  /// Get current settings
  SettingsModel get settings => _settings;

  /// Check if loading
  bool get isLoading => _isLoading;

  /// Get error message
  String? get errorMessage => _errorMessage;

  /// Check if initialized
  bool get isInitialized => _isInitialized;

  /// Initialize settings
  Future<void> initialize() async {
    if (_isInitialized) return;

    await loadSettings();
  }

  /// Load settings from server
  Future<void> loadSettings() async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _settingsService.getSettings();
      if (result.success && result.settings != null) {
        _settings = result.settings!;
        _isInitialized = true;
      } else {
        _setError(result.message ?? 'Failed to load settings.');
      }
    } catch (e) {
      _setError('Failed to load settings. Please check your connection.');
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  /// Update settings
  Future<void> updateSettings(SettingsModel settings) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _settingsService.updateSettings(settings);
      if (result.success) {
        _settings = settings;
      } else {
        _setError(result.message ?? 'Failed to update settings.');
      }
    } catch (e) {
      _setError('Failed to update settings. Please try again.');
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  /// Update specific setting
  Future<void> updateSetting(String key, dynamic value) async {
    try {
      final result = await _settingsService.updateSetting(key, value);
      if (result.success) {
        // Update local settings
        _settings = _updateSettingValue(key, value);
        notifyListeners();
      } else {
        _setError(result.message ?? 'Failed to update setting.');
        notifyListeners();
      }
    } catch (e) {
      _setError('Failed to update setting. Please try again.');
      notifyListeners();
    }
  }

  /// Update notification preferences
  Future<void> updateNotificationPreferences({
    bool? pushNotifications,
    bool? emailNotifications,
    bool? jobAlerts,
    bool? messageNotifications,
  }) async {
    final updatedSettings = _settings.copyWith(
      pushNotifications: pushNotifications ?? _settings.pushNotifications,
      emailNotifications: emailNotifications ?? _settings.emailNotifications,
      jobAlerts: jobAlerts ?? _settings.jobAlerts,
      messageNotifications:
          messageNotifications ?? _settings.messageNotifications,
    );

    await updateSettings(updatedSettings);
  }

  /// Update privacy settings
  Future<void> updatePrivacySettings({
    String? profileVisibility,
    bool? showOnlineStatus,
    bool? locationSharing,
  }) async {
    final updatedSettings = _settings.copyWith(
      profileVisibility: profileVisibility ?? _settings.profileVisibility,
      showOnlineStatus: showOnlineStatus ?? _settings.showOnlineStatus,
      locationSharing: locationSharing ?? _settings.locationSharing,
    );

    await updateSettings(updatedSettings);
  }

  /// Update app settings
  Future<void> updateAppSettings({LanguageSettings? language, AppTheme? theme}) async {
    final updatedSettings = _settings.copyWith(
      language: language ?? _settings.language,
      theme: theme ?? _settings.theme,
    );

    await updateSettings(updatedSettings);
  }

  /// Reset settings to default
  Future<void> resetToDefault() async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _settingsService.resetToDefault();
      if (result.success) {
        _settings = SettingsModel.defaultSettings();
      } else {
        _setError(result.message ?? 'Failed to reset settings.');
      }
    } catch (e) {
      _setError('Failed to reset settings. Please try again.');
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  /// Export settings
  Future<Map<String, dynamic>?> exportSettings() async {
    try {
      final result = await _settingsService.exportSettings();
      if (result.success) {
        return result.settingsData;
      } else {
        _setError(result.message ?? 'Failed to export settings.');
        notifyListeners();
        return null;
      }
    } catch (e) {
      _setError('Failed to export settings. Please try again.');
      notifyListeners();
      return null;
    }
  }

  /// Import settings
  Future<void> importSettings(Map<String, dynamic> settingsData) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _settingsService.importSettings(settingsData);
      if (result.success) {
        await loadSettings(); // Reload settings after import
      } else {
        _setError(result.message ?? 'Failed to import settings.');
      }
    } catch (e) {
      _setError('Failed to import settings. Please try again.');
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  /// Get available themes
  Future<List<Object>> getAvailableThemes() async {
    try {
      return await _settingsService.getAvailableThemes();
    } catch (e) {
      return [];
    }
  }

  /// Get available languages
  Future<List<Object>> getAvailableLanguages() async {
    try {
      return await _settingsService.getAvailableLanguages();
    } catch (e) {
      return [];
    }
  }

  /// Clear error
  void clearError() {
    _clearError();
    notifyListeners();
  }

  /// Update setting value locally
  SettingsModel _updateSettingValue(String key, dynamic value) {
    switch (key) {
      case 'push_notifications':
        return _settings.copyWith(pushNotifications: value as bool);
      case 'email_notifications':
        return _settings.copyWith(emailNotifications: value as bool);
      case 'job_alerts':
        return _settings.copyWith(jobAlerts: value as bool);
      case 'message_notifications':
        return _settings.copyWith(messageNotifications: value as bool);
      case 'profile_visibility':
        return _settings.copyWith(profileVisibility: value as String);
      case 'show_online_status':
        return _settings.copyWith(showOnlineStatus: value as bool);
      case 'location_sharing':
        return _settings.copyWith(locationSharing: value as bool);
      case 'language':
        return _settings.copyWith(language: value as LanguageSettings);
      case 'theme':
        return _settings.copyWith(theme: value as AppTheme);
      default:
        return _settings;
    }
  }

  /// Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
  }

  /// Set error message
  void _setError(String message) {
    _errorMessage = message;
  }

  /// Clear error message
  void _clearError() {
    _errorMessage = null;
  }
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
}
