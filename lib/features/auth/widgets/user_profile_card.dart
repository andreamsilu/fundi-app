import 'package:flutter/material.dart';
import '../models/user_model.dart';

/// User profile card widget for displaying user information
class UserProfileCard extends StatelessWidget {
  final UserModel user;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onMessage;
  final bool showActions;
  final bool showRating;

  const UserProfileCard({
    super.key,
    required this.user,
    this.onTap,
    this.onEdit,
    this.onMessage,
    this.showActions = false,
    this.showRating = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                children: [
                  // User avatar
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: user.profileImageUrl != null
                        ? NetworkImage(user.profileImageUrl!)
                        : null,
                    child: user.profileImageUrl == null
                        ? Text(
                            user.firstName?.isNotEmpty == true
                                ? user.firstName![0].toUpperCase()
                                : 'U',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : null,
                  ),

                  const SizedBox(width: 16),

                  // User info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.displayName,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user.email ?? 'No email',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          user.phone,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),

                  // User type badge
                  _buildUserTypeBadge(context),
                ],
              ),

              // Bio section removed - not available in UserModel

              // Location section removed - not available in UserModel

              // Rating section removed - not available in UserModel
              if (showActions) ...[
                const SizedBox(height: 16),
                Row(
                  children: [
                    if (onEdit != null) ...[
                      Expanded(
                        child: OutlinedButton(
                          onPressed: onEdit,
                          child: const Text('Edit Profile'),
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                    if (onMessage != null) ...[
                      Expanded(
                        child: ElevatedButton(
                          onPressed: onMessage,
                          child: const Text('Message'),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserTypeBadge(BuildContext context) {
    Color backgroundColor;
    Color textColor;

    switch (user.primaryRole) {
      case UserRole.fundi:
        backgroundColor = Colors.blue[100]!;
        textColor = Colors.blue[800]!;
        break;
      case UserRole.customer:
        backgroundColor = Colors.green[100]!;
        textColor = Colors.green[800]!;
        break;
      case UserRole.admin:
        backgroundColor = Colors.red[100]!;
        textColor = Colors.red[800]!;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        user.primaryRole.displayName,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// User profile summary widget
class UserProfileSummary extends StatelessWidget {
  final UserModel user;
  final VoidCallback? onTap;

  const UserProfileSummary({super.key, required this.user, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // User avatar
              CircleAvatar(
                radius: 25,
                backgroundImage: user.profileImageUrl != null
                    ? NetworkImage(user.profileImageUrl!)
                    : null,
                child: user.profileImageUrl == null
                    ? Text(
                        user.shortDisplayName.isNotEmpty
                            ? user.shortDisplayName[0].toUpperCase()
                            : 'U',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              ),

              const SizedBox(width: 12),

              // User info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.displayName,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      user.email ?? 'No email',
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),

              // User type badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getUserTypeColor(user.primaryRole).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  user.primaryRole.displayName,
                  style: TextStyle(
                    color: _getUserTypeColor(user.primaryRole),
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getUserTypeColor(UserRole userRole) {
    switch (userRole) {
      case UserRole.fundi:
        return Colors.blue[800]!;
      case UserRole.customer:
        return Colors.green[800]!;
      case UserRole.admin:
        return Colors.red[800]!;
    }
  }
}

/// User stats widget
class UserStatsWidget extends StatelessWidget {
  final UserModel user;
  final List<Map<String, dynamic>>? stats;

  const UserStatsWidget({super.key, required this.user, this.stats});

  @override
  Widget build(BuildContext context) {
    if (stats == null || stats!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Statistics',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: stats!
                  .map(
                    (stat) => Expanded(
                      child: _buildStatItem(
                        context,
                        stat['label'] as String,
                        stat['value'] as String,
                        stat['icon'] as IconData?,
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value,
    IconData? icon,
  ) {
    return Column(
      children: [
        if (icon != null) ...[
          Icon(icon, size: 24, color: Theme.of(context).primaryColor),
          const SizedBox(height: 8),
        ],
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
