import 'package:flutter/material.dart';
import '../models/notification_model.dart';
import '../services/notification_service.dart';

/// Notification provider for state management
/// Handles notification state and operations
class NotificationProvider extends ChangeNotifier {
  final NotificationService _notificationService = NotificationService();

  List<NotificationModel> _notifications = [];
  NotificationSettings _settings = NotificationSettings(
    pushNotifications: true,
    emailNotifications: true,
    jobAlerts: true,
    messageNotifications: true,
    applicationUpdates: true,
    systemUpdates: true,
  );
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _errorMessage;
  int _currentPage = 1;
  int _totalPages = 1;
  int _totalCount = 0;
  int _unreadCount = 0;
  String? _selectedFilter;
  String? _selectedType;

  /// Get notifications list
  List<NotificationModel> get notifications => _notifications;

  /// Get filtered notifications
  List<NotificationModel> get filteredNotifications {
    if (_selectedFilter == null) return _notifications;
    if (_selectedFilter == 'Unread') {
      return _notifications.where((n) => !n.isRead).toList();
    }
    if (_selectedType != null) {
      return _notifications
          .where(
            (n) => n.type.toLowerCase() == _selectedType!.toLowerCase(),
          )
          .toList();
    }
    return _notifications;
  }

  /// Get notification settings
  NotificationSettings get settings => _settings;

  /// Check if loading
  bool get isLoading => _isLoading;

  /// Check if loading more
  bool get isLoadingMore => _isLoadingMore;

  /// Get error message
  String? get errorMessage => _errorMessage;

  /// Get current page
  int get currentPage => _currentPage;

  /// Get total pages
  int get totalPages => _totalPages;

  /// Get total count
  int get totalCount => _totalCount;

  /// Get unread count
  int get unreadCount => _unreadCount;

  /// Get selected filter
  String? get selectedFilter => _selectedFilter;

  /// Get selected type
  String? get selectedType => _selectedType;

  /// Check if has more notifications
  bool get hasMoreNotifications => _currentPage < _totalPages;

  /// Load notifications
  Future<void> loadNotifications({
    bool refresh = false,
    String? type,
    bool? isRead,
  }) async {
    if (refresh) {
      _currentPage = 1;
      _notifications.clear();
    }

    _setLoading(true);
    _clearError();

    try {
      final result = await _notificationService.getNotifications(
        page: _currentPage,
        type: type,
        isRead: isRead,
      );

      if (result.success) {
        if (refresh) {
          _notifications = result.notifications;
        } else {
          _notifications.addAll(result.notifications);
        }
        _totalCount = result.totalCount;
        _unreadCount = result.unreadCount;
        _currentPage = result.currentPage;
        _totalPages = result.totalPages;
      } else {
        _setError(result.message ?? 'Failed to load notifications.');
      }
    } catch (e) {
      _setError('Failed to load notifications. Please check your connection.');
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  /// Load more notifications
  Future<void> loadMoreNotifications() async {
    if (_isLoadingMore || !hasMoreNotifications) return;

    _currentPage++;
    await loadNotifications();
  }

  /// Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      final result = await _notificationService.markAsRead(notificationId);
      if (result.success) {
        final index = _notifications.indexWhere((n) => n.id == notificationId);
        if (index != -1) {
          _notifications[index] = _notifications[index].copyWith(isRead: true);
          _unreadCount = (_unreadCount - 1).clamp(0, _unreadCount);
          notifyListeners();
        }
      }
    } catch (e) {
      // Silently fail for individual notifications
    }
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    try {
      final result = await _notificationService.markAllAsRead();
      if (result.success) {
        _notifications = _notifications
            .map((n) => n.copyWith(isRead: true))
            .toList();
        _unreadCount = 0;
        notifyListeners();
      }
    } catch (e) {
      _setError('Failed to mark all notifications as read.');
      notifyListeners();
    }
  }

  /// Delete notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      final result = await _notificationService.deleteNotification(
        notificationId,
      );
      if (result.success) {
        _notifications.removeWhere((n) => n.id == notificationId);
        _totalCount--;
        notifyListeners();
      }
    } catch (e) {
      _setError('Failed to delete notification.');
      notifyListeners();
    }
  }

  /// Clear all notifications
  Future<void> clearAllNotifications() async {
    try {
      final result = await _notificationService.clearAllNotifications();
      if (result.success) {
        _notifications.clear();
        _totalCount = 0;
        _unreadCount = 0;
        notifyListeners();
      }
    } catch (e) {
      _setError('Failed to clear all notifications.');
      notifyListeners();
    }
  }

  /// Load notification settings
  Future<void> loadNotificationSettings() async {
    try {
      final result = await _notificationService.getNotificationSettings();
      if (result.success && result.settings != null) {
        _settings = result.settings! as NotificationSettings;
        notifyListeners();
      }
    } catch (e) {
      // Silently fail for settings
    }
  }

  /// Update notification settings
  Future<void> updateNotificationSettings(NotificationSettings settings) async {
    try {
      final result = await _notificationService.updateNotificationSettings(
        settings,
      );
      if (result.success) {
        _settings = settings;
        notifyListeners();
      } else {
        _setError(result.message ?? 'Failed to update notification settings.');
        notifyListeners();
      }
    } catch (e) {
      _setError('Failed to update notification settings.');
      notifyListeners();
    }
  }

  /// Set filter
  void setFilter(String? filter) {
    _selectedFilter = filter;
    notifyListeners();
  }

  /// Set type filter
  void setTypeFilter(String? type) {
    _selectedType = type;
    notifyListeners();
  }

  /// Clear filters
  void clearFilters() {
    _selectedFilter = null;
    _selectedType = null;
    notifyListeners();
  }

  /// Clear error
  void clearError() {
    _clearError();
    notifyListeners();
  }

  /// Refresh notifications
  Future<void> refresh() async {
    await loadNotifications(refresh: true);
  }

  /// Set loading state
  void _setLoading(bool loading) {
    if (loading) {
      _isLoading = true;
      _isLoadingMore = false;
    } else {
      _isLoading = false;
      _isLoadingMore = false;
    }
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
