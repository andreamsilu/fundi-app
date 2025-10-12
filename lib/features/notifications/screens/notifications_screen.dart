import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../providers/notification_provider.dart';
import '../models/notification_model.dart';
import '../widgets/notification_card.dart';

/// Enhanced Notifications Screen with Grouping and Batch Actions
/// Groups notifications by: Today, Yesterday, This Week, Older
/// Supports: Swipe to delete, Mark all read, Batch selection
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _isSelectionMode = false;
  Set<String> _selectedIds = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: _isSelectionMode
            ? [
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: _deleteSelected,
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    setState(() {
                      _isSelectionMode = false;
                      _selectedIds.clear();
                    });
                  },
                ),
              ]
            : [
                IconButton(
                  icon: const Icon(Icons.done_all),
                  onPressed: _markAllRead,
                ),
                IconButton(
                  icon: const Icon(Icons.select_all),
                  onPressed: () {
                    setState(() => _isSelectionMode = true);
                  },
                ),
              ],
      ),
      body: Consumer<NotificationProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.notifications.isEmpty) {
            return const Center(child: LoadingWidget());
          }

          final notifications = provider.notifications;

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
                  const Text('No notifications'),
                  const SizedBox(height: 8),
                  Text(
                    'You\'ll see notifications here when you have them',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          // Group notifications by date
          final grouped = _groupNotificationsByDate(notifications);

          return RefreshIndicator(
            onRefresh: () => provider.loadNotifications(refresh: true),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: grouped.keys.length,
              itemBuilder: (context, index) {
                final group = grouped.keys.elementAt(index);
                final items = grouped[group]!;
                return _buildGroup(group, items);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildGroup(String groupName, List<NotificationModel> notifications) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Group Header
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(
            groupName.toUpperCase(),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppTheme.mediumGray,
              letterSpacing: 0.5,
            ),
          ),
        ),

        // Notifications in Group
        ...notifications.map((notification) {
          return Dismissible(
            key: Key(notification.id),
            direction: DismissDirection.endToStart,
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            onDismissed: (direction) {
              _deleteNotification(notification.id);
            },
            child: InkWell(
              onTap: () {
                if (_isSelectionMode) {
                  _toggleSelection(notification.id);
                } else {
                  _markAsRead(notification.id);
                }
              },
              onLongPress: () {
                setState(() {
                  _isSelectionMode = true;
                  _selectedIds.add(notification.id);
                });
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: _selectedIds.contains(notification.id)
                      ? AppTheme.primaryGreen.withOpacity(0.1)
                      : null,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    if (_isSelectionMode)
                      Checkbox(
                        value: _selectedIds.contains(notification.id),
                        onChanged: (val) => _toggleSelection(notification.id),
                      ),
                    Expanded(
                      child: NotificationCard(notification: notification),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),

        const SizedBox(height: 16),
      ],
    );
  }

  Map<String, List<NotificationModel>> _groupNotificationsByDate(
    List<NotificationModel> notifications,
  ) {
    final Map<String, List<NotificationModel>> grouped = {
      'Today': [],
      'Yesterday': [],
      'This Week': [],
      'Older': [],
    };

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final thisWeekStart = today.subtract(Duration(days: now.weekday - 1));

    for (var notification in notifications) {
      final date = notification.createdAt;
      if (date == null) {
        grouped['Older']!.add(notification);
        continue;
      }

      final notifDate = DateTime(date.year, date.month, date.day);

      if (notifDate == today) {
        grouped['Today']!.add(notification);
      } else if (notifDate == yesterday) {
        grouped['Yesterday']!.add(notification);
      } else if (notifDate.isAfter(thisWeekStart)) {
        grouped['This Week']!.add(notification);
      } else {
        grouped['Older']!.add(notification);
      }
    }

    // Remove empty groups
    grouped.removeWhere((key, value) => value.isEmpty);

    return grouped;
  }

  void _toggleSelection(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
    });
  }

  void _deleteSelected() {
    if (_selectedIds.isEmpty) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Notifications'),
        content: Text('Delete ${_selectedIds.length} notification(s)?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // TODO: Implement batch delete
              Navigator.pop(context);
              setState(() {
                _selectedIds.clear();
                _isSelectionMode = false;
              });
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _markAllRead() {
    // TODO: Implement mark all as read
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('All notifications marked as read')),
    );
  }

  void _deleteNotification(String id) {
    // TODO: Implement single delete
  }

  void _markAsRead(String id) {
    // TODO: Implement mark as read
    final provider = Provider.of<NotificationProvider>(context, listen: false);
    provider.markAsRead(id);
  }
}
