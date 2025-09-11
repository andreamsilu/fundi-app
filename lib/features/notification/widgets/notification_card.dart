import 'package:flutter/material.dart';
import '../models/notification_model.dart';

/// Notification card widget for displaying notification information
class NotificationCard extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback? onTap;
  final VoidCallback? onMarkAsRead;
  final VoidCallback? onDelete;
  final bool showActions;

  const NotificationCard({
    super.key,
    required this.notification,
    this.onTap,
    this.onMarkAsRead,
    this.onDelete,
    this.showActions = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: notification.isRead ? null : Colors.blue[50],
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Notification icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _getNotificationColor(notification.type).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  _getNotificationIcon(notification.type),
                  color: _getNotificationColor(notification.type),
                  size: 20,
                ),
              ),
              
              const SizedBox(width: 12),
              
              // Notification content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title and time
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          notification.formattedCreatedAt,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 4),
                    
                    // Message
                    Text(
                      notification.message,
                      style: Theme.of(context).textTheme.bodyMedium,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    if (notification.data != null && notification.data!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Data: ${notification.data}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              
              // Actions
              if (showActions) ...[
                PopupMenuButton<String>(
                  onSelected: (value) {
                    switch (value) {
                      case 'mark_read':
                        onMarkAsRead?.call();
                        break;
                      case 'delete':
                        onDelete?.call();
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    if (!notification.isRead)
                      const PopupMenuItem(
                        value: 'mark_read',
                        child: Row(
                          children: [
                            Icon(Icons.mark_email_read),
                            SizedBox(width: 8),
                            Text('Mark as Read'),
                          ],
                        ),
                      ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Delete', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  IconData _getNotificationIcon(NotificationType type) {
    switch (type) {
      case NotificationType.jobApplication:
        return Icons.assignment;
      case NotificationType.jobUpdate:
        return Icons.work;
      case NotificationType.payment:
        return Icons.payment;
      case NotificationType.rating:
        return Icons.star;
      case NotificationType.message:
        return Icons.message;
      case NotificationType.system:
        return Icons.info;
      case NotificationType.reminder:
        return Icons.alarm;
    }
  }

  Color _getNotificationColor(NotificationType type) {
    switch (type) {
      case NotificationType.jobApplication:
        return Colors.blue;
      case NotificationType.jobUpdate:
        return Colors.orange;
      case NotificationType.payment:
        return Colors.green;
      case NotificationType.rating:
        return Colors.amber;
      case NotificationType.message:
        return Colors.purple;
      case NotificationType.system:
        return Colors.grey;
      case NotificationType.reminder:
        return Colors.red;
    }
  }
}

/// Notification list widget
class NotificationListWidget extends StatelessWidget {
  final List<NotificationModel> notifications;
  final VoidCallback? onTap;
  final VoidCallback? onMarkAsRead;
  final VoidCallback? onDelete;
  final bool showActions;
  final bool isLoading;
  final VoidCallback? onRefresh;

  const NotificationListWidget({
    super.key,
    required this.notifications,
    this.onTap,
    this.onMarkAsRead,
    this.onDelete,
    this.showActions = false,
    this.isLoading = false,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading && notifications.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (notifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_none,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No notifications',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'You\'ll see notifications here when you have them',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            if (onRefresh != null) ...[
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: onRefresh,
                child: const Text('Refresh'),
              ),
            ],
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh ?? () async {},
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notification = notifications[index];
          return NotificationCard(
            notification: notification,
            onTap: onTap,
            onMarkAsRead: onMarkAsRead,
            onDelete: onDelete,
            showActions: showActions,
          );
        },
      ),
    );
  }
}

/// Notification type filter widget
class NotificationTypeFilter extends StatelessWidget {
  final NotificationType? selectedType;
  final Function(NotificationType?) onTypeChanged;

  const NotificationTypeFilter({
    super.key,
    this.selectedType,
    required this.onTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          // All types
          _buildFilterChip(
            context,
            'All',
            null,
            selectedType == null,
          ),
          
          // Individual types
          ...NotificationType.values.map((type) =>
            _buildFilterChip(
              context,
              type.displayName,
              type,
              selectedType == type,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    BuildContext context,
    String label,
    NotificationType? type,
    bool isSelected,
  ) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          onTypeChanged(selected ? type : null);
        },
      ),
    );
  }
}

/// Notification summary widget
class NotificationSummaryWidget extends StatelessWidget {
  final int totalNotifications;
  final int unreadNotifications;
  final VoidCallback? onViewAll;

  const NotificationSummaryWidget({
    super.key,
    required this.totalNotifications,
    required this.unreadNotifications,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Notification icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(
                Icons.notifications,
                color: Theme.of(context).primaryColor,
                size: 24,
              ),
            ),
            
            const SizedBox(width: 16),
            
            // Summary info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Notifications',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$unreadNotifications unread of $totalNotifications total',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            
            // View all button
            if (onViewAll != null)
              TextButton(
                onPressed: onViewAll,
                child: const Text('View All'),
              ),
          ],
        ),
      ),
    );
  }
}
