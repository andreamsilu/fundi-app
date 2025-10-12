import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

/// Privacy & Security Settings Sub-Screen
class SettingsPrivacyScreen extends StatefulWidget {
  const SettingsPrivacyScreen({super.key});

  @override
  State<SettingsPrivacyScreen> createState() => _SettingsPrivacyScreenState();
}

class _SettingsPrivacyScreenState extends State<SettingsPrivacyScreen> {
  bool _profileVisible = true;
  bool _locationVisible = true;
  bool _portfolioVisible = true;
  bool _allowMessages = true;
  bool _showOnlineStatus = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy & Security'),
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        children: [
          _buildSectionHeader('Profile Visibility'),

          SwitchListTile(
            title: const Text('Show Profile'),
            subtitle: const Text('Let others view your profile'),
            value: _profileVisible,
            onChanged: (value) => setState(() => _profileVisible = value),
          ),

          SwitchListTile(
            title: const Text('Show Location'),
            subtitle: const Text('Display your location to others'),
            value: _locationVisible,
            onChanged: (value) => setState(() => _locationVisible = value),
          ),

          SwitchListTile(
            title: const Text('Show Portfolio'),
            subtitle: const Text('Make your portfolio publicly visible'),
            value: _portfolioVisible,
            onChanged: (value) => setState(() => _portfolioVisible = value),
          ),

          const Divider(height: 1),

          _buildSectionHeader('Communication'),

          SwitchListTile(
            title: const Text('Allow Messages'),
            subtitle: const Text('Receive messages from users'),
            value: _allowMessages,
            onChanged: (value) => setState(() => _allowMessages = value),
          ),

          SwitchListTile(
            title: const Text('Show Online Status'),
            subtitle: const Text('Let others know when you\'re online'),
            value: _showOnlineStatus,
            onChanged: (value) => setState(() => _showOnlineStatus = value),
          ),

          const Divider(height: 1),

          _buildSectionHeader('Security'),

          ListTile(
            leading: const Icon(Icons.fingerprint),
            title: const Text('Biometric Login'),
            subtitle: const Text('Use fingerprint or face ID'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // TODO: Configure biometric
            },
          ),

          ListTile(
            leading: const Icon(Icons.devices),
            title: const Text('Active Sessions'),
            subtitle: const Text('Manage your active devices'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // TODO: Show active sessions
            },
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
