import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

/// Notifications Settings Sub-Screen
class SettingsNotificationsScreen extends StatefulWidget {
  const SettingsNotificationsScreen({super.key});

  @override
  State<SettingsNotificationsScreen> createState() =>
      _SettingsNotificationsScreenState();
}

class _SettingsNotificationsScreenState
    extends State<SettingsNotificationsScreen> {
  bool _pushEnabled = true;
  bool _emailEnabled = false;
  bool _smsEnabled = false;
  bool _jobAlerts = true;
  bool _messageAlerts = true;
  bool _paymentAlerts = true;
  bool _marketingEmails = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Settings'),
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        children: [
          _buildSectionHeader('Notification Channels'),

          SwitchListTile(
            title: const Text('Push Notifications'),
            subtitle: const Text('Receive notifications on your device'),
            value: _pushEnabled,
            onChanged: (value) => setState(() => _pushEnabled = value),
          ),

          SwitchListTile(
            title: const Text('Email Notifications'),
            subtitle: const Text('Receive notifications via email'),
            value: _emailEnabled,
            onChanged: (value) => setState(() => _emailEnabled = value),
          ),

          SwitchListTile(
            title: const Text('SMS Notifications'),
            subtitle: const Text('Receive SMS alerts for important updates'),
            value: _smsEnabled,
            onChanged: (value) => setState(() => _smsEnabled = value),
          ),

          const Divider(height: 1),

          _buildSectionHeader('Alert Types'),

          SwitchListTile(
            title: const Text('Job Alerts'),
            subtitle: const Text('New jobs, applications, updates'),
            value: _jobAlerts,
            onChanged: (value) => setState(() => _jobAlerts = value),
          ),

          SwitchListTile(
            title: const Text('Message Alerts'),
            subtitle: const Text('New messages and chat updates'),
            value: _messageAlerts,
            onChanged: (value) => setState(() => _messageAlerts = value),
          ),

          SwitchListTile(
            title: const Text('Payment Alerts'),
            subtitle: const Text('Payment confirmations and reminders'),
            value: _paymentAlerts,
            onChanged: (value) => setState(() => _paymentAlerts = value),
          ),

          SwitchListTile(
            title: const Text('Marketing Emails'),
            subtitle: const Text('Tips, news, and special offers'),
            value: _marketingEmails,
            onChanged: (value) => setState(() => _marketingEmails = value),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppTheme.mediumGray,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
