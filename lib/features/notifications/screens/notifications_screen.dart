import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

/// Notifications screen for viewing app notifications
class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // TODO: Navigate to notification settings
            },
          ),
        ],
      ),
      body: const Center(
        child: Text(
          'Notifications Screen\nComing Soon!',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18, color: AppTheme.mediumGray),
        ),
      ),
    );
  }
}

