import 'package:flutter/material.dart';
import '../models/notification_model.dart';
import '../services/notification_service.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../../shared/widgets/error_widget.dart';
import '../../../core/theme/app_theme.dart';

/// Notifications screen showing all user notifications
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

  bool _isLoading = false;
  String? _errorMessage;
  List<NotificationModel> _notifications = [];
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
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await NotificationService().getNotifications();

      if (result.success) {
        setState(() {
          _notifications = result.notifications;
        });
      } else {
        setState(() {
          _errorMessage = result.message;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load notifications. Please try again.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _markAsRead(NotificationModel notification) async {
    if (notification.isRead) return;

    try {
      final result = await NotificationService().markAsRead(notification.id);
      if (result.success) {
        setState(() {
          final index = _notifications.indexWhere(
            (n) => n.id == notification.id,
          );
          if (index != -1) {
            _notifications[index] = notification.copyWith(isRead: true);
          }
        });
      }
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> _deleteNotification(NotificationModel notification) async {
    try {
      final result = await NotificationService().deleteNotification(
        notification.id,
      );
      if (result.success) {
        setState(() {
          _notifications.removeWhere((n) => n.id == notification.id);
        });
      }
    } catch (e) {
      // Handle error silently
    }
  }

  List<NotificationModel> get _filteredNotifications {
    if (_selectedFilter == 'All') return _notifications;
    if (_selectedFilter == 'Unread')
      return _notifications.where((n) => !n.isRead).toList();
    return _notifications
        .where(
          (n) => n.type.toLowerCase() == _selectedFilter.toLowerCase(),
        )
        .toList();
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
          final count = _getFilterCount(filter);

          return Container(
            margin: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(filter),
                  if (count > 0) ...[
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.white : context.primaryColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        count.toString(),
                        style: TextStyle(
                          color: isSelected
                              ? context.primaryColor
                              : Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _selectedFilter = filter;
                  });
                }
              },
              selectedColor: context.primaryColor.withValues(alpha: 0.1),
              checkmarkColor: context.primaryColor,
              labelStyle: TextStyle(
                color: isSelected ? context.primaryColor : AppTheme.mediumGray,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          );
        },
      ),
    );
  }

  int _getFilterCount(String filter) {
    if (filter == 'All') return _notifications.length;
    if (filter == 'Unread')
      return _notifications.where((n) => !n.isRead).length;
    return _notifications
        .where((n) => n.type.toLowerCase() == filter.toLowerCase())
        .length;
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: LoadingWidget(message: 'Loading notifications...', size: 50),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: ErrorBanner(
          message: _errorMessage!,
          onDismiss: () {
            setState(() {
              _errorMessage = null;
            });
          },
        ),
      );
    }

    final filteredNotifications = _filteredNotifications;
    if (filteredNotifications.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _loadNotifications,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: filteredNotifications.length,
        itemBuilder: (context, index) {
          return _buildNotificationCard(filteredNotifications[index]);
        },
      ),
    );
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

  Widget _buildNotificationCard(NotificationModel notification) {
    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (direction) {
        _deleteNotification(notification);
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: _getNotificationColor(notification.type).withValues(alpha: 0.1),
            child: Icon(_getNotificationIcon(notification.type), color: _getNotificationColor(notification.type)),
          ),
          title: Text(
            notification.title,
            style: TextStyle(
              fontWeight: notification.isRead
                  ? FontWeight.normal
                  : FontWeight.w600,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                notification.message,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                notification.formattedTime,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppTheme.mediumGray),
              ),
            ],
          ),
          trailing: notification.isRead
              ? null
              : Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: context.primaryColor,
                    shape: BoxShape.circle,
                  ),
                ),
          onTap: () {
            _markAsRead(notification);
            _handleNotificationTap(notification);
          },
        ),
      ),
    );
  }

  void _handleNotificationTap(NotificationModel notification) {
    // TODO: Navigate to relevant screen based on notification type
    switch (notification.type.toLowerCase()) {
      case 'job_application':
      case 'job_approved':
      case 'job_rejected':
      case 'job_completed':
        // Navigate to job details
        break;
      case 'message_received':
        // Navigate to chat
        break;
      case 'payment_received':
      case 'verification':
        // Navigate to relevant details
        break;
      case 'system':
      case 'promotion':
        // Show system message
        break;
    }
  }

  Future<void> _markAllAsRead() async {
    try {
      final result = await NotificationService().markAllAsRead();
      if (result.success) {
        setState(() {
          _notifications = _notifications
              .map((n) => n.copyWith(isRead: true))
              .toList();
        });
      }
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> _clearAllNotifications() async {
    try {
      final result = await NotificationService().clearAllNotifications();
      if (result.success) {
        setState(() {
          _notifications.clear();
        });
      }
    } catch (e) {
      // Handle error silently
    }
  }

  Color _getNotificationColor(String type) {
    switch (type.toLowerCase()) {
      case 'job_application':
        return Colors.blue;
      case 'job_approved':
        return Colors.green;
      case 'job_rejected':
        return Colors.red;
      case 'payment_received':
        return Colors.orange;
      case 'rating_received':
        return Colors.amber;
      case 'message_received':
        return Colors.purple;
      case 'system':
        return Colors.grey;
      default:
        return Colors.blue;
    }
  }

  IconData _getNotificationIcon(String type) {
    switch (type.toLowerCase()) {
      case 'job_application':
        return Icons.work;
      case 'job_approved':
        return Icons.check_circle;
      case 'job_rejected':
        return Icons.cancel;
      case 'payment_received':
        return Icons.payment;
      case 'rating_received':
        return Icons.star;
      case 'message_received':
        return Icons.message;
      case 'system':
        return Icons.info;
      default:
        return Icons.notifications;
    }
  }
}
