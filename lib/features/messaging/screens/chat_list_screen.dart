import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

/// Chat list screen for viewing conversations
class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Messages')),
      body: const Center(
        child: Text(
          'Messages Screen\nComing Soon!',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18, color: AppTheme.mediumGray),
        ),
      ),
    );
  }
}
