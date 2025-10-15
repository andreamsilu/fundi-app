import '../../../core/network/api_client.dart';
import '../../../core/constants/api_endpoints.dart';
import '../models/notification_model.dart';

/// Notification service for managing user notifications
/// Handles CRUD operations for notifications
class NotificationService {
  final ApiClient _apiClient = ApiClient();

  /// Get all notifications for the current user
  Future<NotificationResult> getNotifications({
    int page = 1,
    int limit = 20,
    String? type,
    bool? isRead,
  }) async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.notifications,
        queryParameters: {
          'page': page,
          'limit': limit,
          if (type != null) 'type': type,
          if (isRead != null) 'is_read': isRead,
        },
      );

      if (response.success && response.data != null) {
        final data = response.data!;
        final notificationsData = data['data'] as List<dynamic>? ?? [];
        final notifications = notificationsData
            .map((notification) => NotificationModel.fromJson(notification))
            .toList();

        return NotificationResult(
          success: true,
          notifications: notifications,
          totalCount: data['total'] ?? 0,
          unreadCount: data['unread_count'] ?? 0,
          currentPage: data['current_page'] ?? 1,
          totalPages: data['last_page'] ?? 1,
        );
      } else {
        return NotificationResult(success: false, message: response.message);
      }
    } catch (e) {
      return NotificationResult(
        success: false,
        message: 'Failed to load notifications. Please check your connection.',
      );
    }
  }

  /// Mark a notification as read
  Future<ServiceResult> markAsRead(String notificationId) async {
    try {
      final response = await _apiClient.patch(
        ApiEndpoints.getMarkNotificationAsReadEndpoint(notificationId),
      );

      if (response.success) {
        return ServiceResult(success: true);
      } else {
        return ServiceResult(success: false, message: response.message);
      }
    } catch (e) {
      return ServiceResult(
        success: false,
        message: 'Failed to mark notification as read. Please try again.',
      );
    }
  }

  /// Mark all notifications as read
  Future<ServiceResult> markAllAsRead() async {
    try {
      final response = await _apiClient.put(
        ApiEndpoints.markAllNotificationsAsRead,
        {},
        data: null,
      );

      if (response.success) {
        return ServiceResult(success: true);
      } else {
        return ServiceResult(success: false, message: response.message);
      }
    } catch (e) {
      return ServiceResult(
        success: false,
        message: 'Failed to mark all notifications as read. Please try again.',
      );
    }
  }

  /// Delete a notification
  Future<ServiceResult> deleteNotification(String notificationId) async {
    try {
      final response = await _apiClient.delete(
        ApiEndpoints.getDeleteNotificationEndpoint(notificationId),
      );

      if (response.success) {
        return ServiceResult(success: true);
      } else {
        return ServiceResult(success: false, message: response.message);
      }
    } catch (e) {
      return ServiceResult(
        success: false,
        message: 'Failed to delete notification. Please try again.',
      );
    }
  }

  /// Delete multiple notifications
  /// Returns a result with success=true if at least one deletion succeeded
  Future<ServiceResult> deleteNotifications(
    List<String> notificationIds,
  ) async {
    if (notificationIds.isEmpty) {
      return ServiceResult(success: true);
    }

    int successCount = 0;
    int failCount = 0;

    for (final id in notificationIds) {
      final result = await deleteNotification(id);
      if (result.success) {
        successCount++;
      } else {
        failCount++;
      }
    }

    if (successCount > 0) {
      return ServiceResult(
        success: true,
        message: failCount > 0
            ? '$successCount notifications deleted, $failCount failed'
            : 'All notifications deleted successfully',
      );
    } else {
      return ServiceResult(
        success: false,
        message: 'Failed to delete notifications',
      );
    }
  }

  /// Clear all notifications
  Future<ServiceResult> clearAllNotifications() async {
    try {
      final response = await _apiClient.delete(
        ApiEndpoints.clearAllNotifications,
      );

      if (response.success) {
        return ServiceResult(success: true);
      } else {
        return ServiceResult(success: false, message: response.message);
      }
    } catch (e) {
      return ServiceResult(
        success: false,
        message: 'Failed to clear all notifications. Please try again.',
      );
    }
  }

  /// Get notification settings
  Future<NotificationSettingsResult> getNotificationSettings() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.notificationSettings);

      if (response.success && response.data != null) {
        final data = response.data!;
        return NotificationSettingsResult(
          success: true,
          settings: NotificationSettings.fromJson(data),
        );
      } else {
        return NotificationSettingsResult(
          success: false,
          message: response.message,
        );
      }
    } catch (e) {
      return NotificationSettingsResult(
        success: false,
        message: 'Failed to load notification settings. Please try again.',
      );
    }
  }

  /// Update notification settings
  Future<ServiceResult> updateNotificationSettings(
    NotificationSettings settings,
  ) async {
    try {
      final response = await _apiClient.put(
        ApiEndpoints.notificationSettings,
        {},
        data: settings.toJson(),
      );

      if (response.success) {
        return ServiceResult(success: true);
      } else {
        return ServiceResult(success: false, message: response.message);
      }
    } catch (e) {
      return ServiceResult(
        success: false,
        message: 'Failed to update notification settings. Please try again.',
      );
    }
  }

  /// Send a test notification
  Future<ServiceResult> sendTestNotification() async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.testNotification,
        {},
        {},
      );

      if (response.success) {
        return ServiceResult(success: true);
      } else {
        return ServiceResult(success: false, message: response.message);
      }
    } catch (e) {
      return ServiceResult(
        success: false,
        message: 'Failed to send test notification. Please try again.',
      );
    }
  }
}

/// Result class for notification operations
class NotificationResult {
  final bool success;
  final String? message;
  final List<NotificationModel> notifications;
  final int totalCount;
  final int unreadCount;
  final int currentPage;
  final int totalPages;

  NotificationResult({
    required this.success,
    this.message,
    this.notifications = const [],
    this.totalCount = 0,
    this.unreadCount = 0,
    this.currentPage = 1,
    this.totalPages = 1,
  });
}

/// Result class for notification settings operations
class NotificationSettingsResult {
  final bool success;
  final String? message;
  final NotificationSettings? settings;

  NotificationSettingsResult({
    required this.success,
    this.message,
    this.settings,
  });
}

/// Generic service result
class ServiceResult {
  final bool success;
  final String? message;

  ServiceResult({required this.success, this.message});
}

/// Notification settings model
class NotificationSettings {
  final bool pushNotifications;
  final bool emailNotifications;
  final bool jobAlerts;
  final bool messageNotifications;
  final bool applicationUpdates;
  final bool systemUpdates;

  NotificationSettings({
    required this.pushNotifications,
    required this.emailNotifications,
    required this.jobAlerts,
    required this.messageNotifications,
    required this.applicationUpdates,
    required this.systemUpdates,
  });

  factory NotificationSettings.fromJson(Map<String, dynamic> json) {
    return NotificationSettings(
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

  NotificationSettings copyWith({
    bool? pushNotifications,
    bool? emailNotifications,
    bool? jobAlerts,
    bool? messageNotifications,
    bool? applicationUpdates,
    bool? systemUpdates,
  }) {
    return NotificationSettings(
      pushNotifications: pushNotifications ?? this.pushNotifications,
      emailNotifications: emailNotifications ?? this.emailNotifications,
      jobAlerts: jobAlerts ?? this.jobAlerts,
      messageNotifications: messageNotifications ?? this.messageNotifications,
      applicationUpdates: applicationUpdates ?? this.applicationUpdates,
      systemUpdates: systemUpdates ?? this.systemUpdates,
    );
  }
}
