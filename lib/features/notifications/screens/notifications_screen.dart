import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/notification_model.dart';
import '../providers/notification_provider.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../../shared/widgets/error_widget.dart';
import '../../../core/theme/app_theme.dart';

/// Notifications screen showing all user notifications using NotificationProvider
/// Allows managing and interacting with notifications
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'Unread', 'Jobs', 'Messages', 'System'];

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadNotifications();
  }

  void _setupAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _loadNotifications() async {
    try {
      final notificationProvider = Provider.of<NotificationProvider>(
        context,
        listen: false,
      );
      await notificationProvider.loadNotifications();
    } catch (e) {
      print('NotificationProvider not available: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'mark_all_read') {
                _markAllAsRead();
              } else if (value == 'clear_all') {
                _clearAllNotifications();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'mark_all_read',
                child: Row(
                  children: [
                    Icon(Icons.mark_email_read),
                    SizedBox(width: 8),
                    Text('Mark All Read'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'clear_all',
                child: Row(
                  children: [
                    Icon(Icons.clear_all),
                    SizedBox(width: 8),
                    Text('Clear All'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            // Filter Tabs
            _buildFilterTabs(),
            // Content
            Expanded(child: _buildContent()),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterTabs() {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _filters.length,
        itemBuilder: (context, index) {
          final filter = _filters[index];
          final isSelected = _selectedFilter == filter;

          return Container(
            margin: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(filter),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedFilter = filter;
                });
              },
              selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
              checkmarkColor: Theme.of(context).primaryColor,
            ),
          );
        },
      ),
    );
  }

  Widget _buildContent() {
    // Try to get the existing provider, if not available create a new one
    try {
      Provider.of<NotificationProvider>(context, listen: false);
      return Consumer<NotificationProvider>(
        builder: (context, notificationProvider, child) {
          return _buildNotificationList(notificationProvider);
        },
      );
    } catch (e) {
      // Provider not available, create a new one
      return ChangeNotifierProvider(
        create: (_) => NotificationProvider()..loadNotifications(),
        child: Consumer<NotificationProvider>(
          builder: (context, notificationProvider, child) {
            return _buildNotificationList(notificationProvider);
          },
        ),
      );
    }
  }

  Widget _buildNotificationList(NotificationProvider notificationProvider) {
    if (notificationProvider.isLoading &&
        notificationProvider.notifications.isEmpty) {
      return const Center(
        child: LoadingWidget(message: 'Loading notifications...', size: 50),
      );
    }

    if (notificationProvider.errorMessage != null &&
        notificationProvider.notifications.isEmpty) {
      return Center(
        child: ErrorBanner(
          message: notificationProvider.errorMessage!,
          onDismiss: () {
            notificationProvider.clearError();
          },
        ),
      );
    }

    final filteredNotifications = _getFilteredNotifications(
      notificationProvider,
    );
    if (filteredNotifications.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: () async {
        await notificationProvider.loadNotifications(refresh: true);
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: filteredNotifications.length,
        itemBuilder: (context, index) {
          final notification = filteredNotifications[index];
          return _buildNotificationItem(notification, notificationProvider);
        },
      ),
    );
  }

  List<NotificationModel> _getFilteredNotifications(
    NotificationProvider notificationProvider,
  ) {
    if (_selectedFilter == 'All') {
      return notificationProvider.notifications;
    } else if (_selectedFilter == 'Unread') {
      return notificationProvider.notifications
          .where((n) => !n.isRead)
          .toList();
    } else {
      return notificationProvider.notifications
          .where((n) => n.type.toLowerCase() == _selectedFilter.toLowerCase())
          .toList();
    }
  }

  Widget _buildNotificationItem(
    NotificationModel notification,
    NotificationProvider notificationProvider,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: notification.isRead
              ? Colors.grey
              : Theme.of(context).primaryColor,
          child: Icon(
            _getNotificationIcon(notification.type),
            color: Colors.white,
            size: 20,
          ),
        ),
        title: Text(
          notification.title,
          style: TextStyle(
            fontWeight: notification.isRead
                ? FontWeight.normal
                : FontWeight.bold,
          ),
        ),
        subtitle: Text(notification.message),
        trailing: notification.isRead
            ? null
            : Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
        onTap: () => _onNotificationTap(notification, notificationProvider),
      ),
    );
  }

  IconData _getNotificationIcon(String type) {
    switch (type.toLowerCase()) {
      case 'job':
        return Icons.work;
      case 'message':
        return Icons.message;
      case 'system':
        return Icons.settings;
      default:
        return Icons.notifications;
    }
  }

  void _onNotificationTap(
    NotificationModel notification,
    NotificationProvider notificationProvider,
  ) {
    if (!notification.isRead) {
      notificationProvider.markAsRead(notification.id);
    }
    // Handle navigation based on notification type
    // This would typically navigate to the relevant screen
  }

  void _markAllAsRead() {
    try {
      final notificationProvider = Provider.of<NotificationProvider>(
        context,
        listen: false,
      );
      notificationProvider.markAllAsRead();
    } catch (e) {
      print('Error marking all notifications as read: $e');
    }
  }

  void _clearAllNotifications() {
    try {
      final notificationProvider = Provider.of<NotificationProvider>(
        context,
        listen: false,
      );
      notificationProvider.clearAllNotifications();
    } catch (e) {
      print('Error clearing all notifications: $e');
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_none, size: 64, color: AppTheme.mediumGray),
          const SizedBox(height: 16),
          Text(
            'No notifications',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(color: AppTheme.mediumGray),
          ),
          const SizedBox(height: 8),
          Text(
            'You\'re all caught up!',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppTheme.mediumGray),
          ),
        ],
      ),
    );
  }
}
