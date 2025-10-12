import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/providers/auth_provider.dart';
import 'settings_account_screen.dart';
import 'settings_privacy_screen.dart';
import 'settings_notifications_screen.dart';

/// Main Settings Screen - Categorized List
/// Replaces the 568-line monolithic settings screen
/// Categories: Account, Privacy & Security, Notifications, Appearance, About
class SettingsMainScreen extends StatelessWidget {
  const SettingsMainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        children: [
          // User Info Header
          _buildUserHeader(context),

          const Divider(height: 1),

          // Account Settings
          _buildSettingsTile(
            context,
            icon: Icons.person_outline,
            title: 'Account',
            subtitle: 'Manage your account details',
            onTap: () => _navigateTo(context, const SettingsAccountScreen()),
          ),

          // Privacy & Security
          _buildSettingsTile(
            context,
            icon: Icons.security,
            title: 'Privacy & Security',
            subtitle: 'Control your privacy settings',
            onTap: () => _navigateTo(context, const SettingsPrivacyScreen()),
          ),

          // Notifications
          _buildSettingsTile(
            context,
            icon: Icons.notifications_outlined,
            title: 'Notifications',
            subtitle: 'Manage notification preferences',
            onTap: () =>
                _navigateTo(context, const SettingsNotificationsScreen()),
          ),

          const Divider(height: 1),

          // Appearance (inline toggle)
          _buildAppearanceSection(context),

          const Divider(height: 1),

          // Payment & Subscription
          _buildSettingsTile(
            context,
            icon: Icons.payment,
            title: 'Payment & Subscription',
            subtitle: 'Manage payments and plans',
            onTap: () => Navigator.pushNamed(context, '/payment-management'),
          ),

          const Divider(height: 1),

          // About & Legal
          _buildSettingsTile(
            context,
            icon: Icons.info_outline,
            title: 'About & Legal',
            subtitle: 'App version, terms, privacy policy',
            onTap: () => _showAboutDialog(context),
          ),

          const Divider(height: 1),

          // Logout
          _buildSettingsTile(
            context,
            icon: Icons.logout,
            title: 'Logout',
            subtitle: 'Sign out of your account',
            onTap: () => _showLogoutDialog(context),
            isDestructive: true,
          ),

          const SizedBox(height: 32),

          // Version Info
          Center(
            child: Text(
              'Version 1.0.0',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildUserHeader(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.user;
        return Container(
          padding: const EdgeInsets.all(20),
          color: AppTheme.primaryGreen.withOpacity(0.1),
          child: Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: AppTheme.primaryGreen,
                child: Text(
                  user?.firstName?.substring(0, 1).toUpperCase() ?? 'U',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user?.fullName ?? 'User',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user?.email ?? '',
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                  ],
                ),
              ),
              Icon(Icons.edit, color: AppTheme.primaryGreen),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSettingsTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isDestructive
              ? Colors.red.withOpacity(0.1)
              : AppTheme.primaryGreen.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: isDestructive ? Colors.red : AppTheme.primaryGreen,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: isDestructive ? Colors.red : AppTheme.darkGray,
        ),
      ),
      subtitle: Text(subtitle),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Colors.grey[400],
      ),
      onTap: onTap,
    );
  }

  Widget _buildAppearanceSection(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.palette, color: AppTheme.primaryGreen),
          ),
          title: const Text(
            'Appearance',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: const Text('Theme and display settings'),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 72),
          child: Column(
            children: [
              SwitchListTile(
                title: const Text('Dark Mode'),
                value: false, // TODO: Connect to theme provider
                onChanged: (value) {
                  // TODO: Toggle dark mode
                },
                dense: true,
              ),
              SwitchListTile(
                title: const Text('Compact View'),
                value: false, // TODO: Connect to settings
                onChanged: (value) {
                  // TODO: Toggle compact view
                },
                dense: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _navigateTo(BuildContext context, Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Fundi App',
      applicationVersion: '1.0.0',
      applicationLegalese: '© 2025 Fundi App. All rights reserved.',
      children: [
        const SizedBox(height: 16),
        const Text('Connect skilled craftsmen with customers'),
        const SizedBox(height: 16),
        TextButton(
          onPressed: () {
            // TODO: Open terms of service
          },
          child: const Text('Terms of Service'),
        ),
        TextButton(
          onPressed: () {
            // TODO: Open privacy policy
          },
          child: const Text('Privacy Policy'),
        ),
      ],
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Provider.of<AuthProvider>(context, listen: false).logout();
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                (route) => false,
              );
            },
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}


