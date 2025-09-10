import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/settings_model.dart';
import '../services/settings_service.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../../shared/widgets/error_widget.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/providers/auth_provider.dart';

/// Settings screen for managing user preferences and app configuration
/// Provides comprehensive settings management
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  bool _isLoading = false;
  String? _errorMessage;
  SettingsModel _settings = SettingsModel.defaultSettings();

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadSettings();
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

  Future<void> _loadSettings() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await SettingsService().getSettings();
      if (result.success) {
        setState(() {
          _settings = result.settings ?? SettingsModel.defaultSettings();
        });
      } else {
        setState(() {
          _errorMessage = result.message;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load settings. Please try again.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _updateSettings() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await SettingsService().updateSettings(_settings);
      if (result.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Settings updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        setState(() {
          _errorMessage = result.message;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to update settings. Please try again.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _updateSettings,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save'),
          ),
        ],
      ),
      body: FadeTransition(opacity: _fadeAnimation, child: _buildContent()),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: LoadingWidget(message: 'Loading settings...', size: 50),
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

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Section
          _buildSectionHeader('Profile'),
          _buildProfileSection(),

          const SizedBox(height: 24),

          // Notifications Section
          _buildSectionHeader('Notifications'),
          _buildNotificationsSection(),

          const SizedBox(height: 24),

          // Privacy Section
          _buildSectionHeader('Privacy & Security'),
          _buildPrivacySection(),

          const SizedBox(height: 24),

          // App Settings Section
          _buildSectionHeader('App Settings'),
          _buildAppSettingsSection(),

          const SizedBox(height: 24),

          // Account Section
          _buildSectionHeader('Account'),
          _buildAccountSection(),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
          color: AppTheme.darkGray,
        ),
      ),
    );
  }

  Widget _buildProfileSection() {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundColor: context.primaryColor.withValues(alpha: 0.1),
              child: Icon(Icons.person, color: context.primaryColor),
            ),
            title: const Text('Profile Information'),
            subtitle: const Text('Manage your personal details'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // TODO: Navigate to profile edit screen
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: CircleAvatar(
              backgroundColor: context.primaryColor.withValues(alpha: 0.1),
              child: Icon(Icons.work_outline, color: context.primaryColor),
            ),
            title: const Text('Professional Information'),
            subtitle: const Text('Update your skills and experience'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // TODO: Navigate to professional info screen
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsSection() {
    return Card(
      child: Column(
        children: [
          SwitchListTile(
            title: const Text('Push Notifications'),
            subtitle: const Text('Receive notifications on your device'),
            value: _settings.pushNotifications,
            onChanged: (value) {
              setState(() {
                _settings = _settings.copyWith(pushNotifications: value);
              });
            },
          ),
          const Divider(height: 1),
          SwitchListTile(
            title: const Text('Email Notifications'),
            subtitle: const Text('Receive notifications via email'),
            value: _settings.emailNotifications,
            onChanged: (value) {
              setState(() {
                _settings = _settings.copyWith(emailNotifications: value);
              });
            },
          ),
          const Divider(height: 1),
          SwitchListTile(
            title: const Text('Job Alerts'),
            subtitle: const Text('Get notified about new job opportunities'),
            value: _settings.jobAlerts,
            onChanged: (value) {
              setState(() {
                _settings = _settings.copyWith(jobAlerts: value);
              });
            },
          ),
          const Divider(height: 1),
          SwitchListTile(
            title: const Text('Message Notifications'),
            subtitle: const Text('Get notified about new messages'),
            value: _settings.messageNotifications,
            onChanged: (value) {
              setState(() {
                _settings = _settings.copyWith(messageNotifications: value);
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacySection() {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundColor: context.primaryColor.withValues(alpha: 0.1),
              child: Icon(Icons.visibility, color: context.primaryColor),
            ),
            title: const Text('Profile Visibility'),
            subtitle: const Text('Control who can see your profile'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              _showProfileVisibilityDialog();
            },
          ),
          const Divider(height: 1),
          SwitchListTile(
            title: const Text('Show Online Status'),
            subtitle: const Text('Let others know when you\'re online'),
            value: _settings.showOnlineStatus,
            onChanged: (value) {
              setState(() {
                _settings = _settings.copyWith(showOnlineStatus: value);
              });
            },
          ),
          const Divider(height: 1),
          SwitchListTile(
            title: const Text('Location Sharing'),
            subtitle: const Text('Share your location with other users'),
            value: _settings.locationSharing,
            onChanged: (value) {
              setState(() {
                _settings = _settings.copyWith(locationSharing: value);
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAppSettingsSection() {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundColor: context.primaryColor.withValues(alpha: 0.1),
              child: Icon(Icons.language, color: context.primaryColor),
            ),
            title: const Text('Language'),
            subtitle: Text(_settings.languageString),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              _showLanguageDialog();
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: CircleAvatar(
              backgroundColor: context.primaryColor.withValues(alpha: 0.1),
              child: Icon(Icons.palette, color: context.primaryColor),
            ),
            title: const Text('Theme'),
            subtitle: Text(_settings.theme.name),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              _showThemeDialog();
            },
          ),
          const Divider(height: 1),
          SwitchListTile(
            title: const Text('Dark Mode'),
            subtitle: const Text('Use dark theme'),
            value: _settings.theme == AppTheme.dark,
            onChanged: (value) {
              setState(() {
                _settings = _settings.copyWith(
                  theme: value ? AppTheme.dark : AppTheme.light,
                );
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAccountSection() {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.orange.withValues(alpha: 0.1),
              child: const Icon(Icons.security, color: Colors.orange),
            ),
            title: const Text('Change Password'),
            subtitle: const Text('Update your account password'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // TODO: Navigate to change password screen
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.blue.withValues(alpha: 0.1),
              child: const Icon(Icons.phone, color: Colors.blue),
            ),
            title: const Text('Phone Number'),
            subtitle: const Text('Update your phone number'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // TODO: Navigate to phone update screen
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.red.withValues(alpha: 0.1),
              child: const Icon(Icons.logout, color: Colors.red),
            ),
            title: const Text('Sign Out'),
            subtitle: const Text('Sign out of your account'),
            onTap: () {
              _showSignOutDialog();
            },
          ),
        ],
      ),
    );
  }

  void _showProfileVisibilityDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Profile Visibility'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('Public'),
              subtitle: const Text('Anyone can see your profile'),
              value: 'public',
              groupValue: _settings.profileVisibility,
              onChanged: (value) {
                setState(() {
                  _settings = _settings.copyWith(profileVisibility: value!);
                });
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('Private'),
              subtitle: const Text('Only you can see your profile'),
              value: 'private',
              groupValue: _settings.profileVisibility,
              onChanged: (value) {
                setState(() {
                  _settings = _settings.copyWith(profileVisibility: value!);
                });
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('English'),
              value: 'English',
              groupValue: _settings.language.toString(),
              onChanged: (value) {
                setState(() {
                  _settings = _settings.copyWith(languageString: value!);
                });
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('Swahili'),
              value: 'Swahili',
              groupValue: _settings.language.toString(),
              onChanged: (value) {
                setState(() {
                  _settings = _settings.copyWith(languageString: value!);
                });
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showThemeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Theme'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<AppTheme>(
              title: const Text('Light'),
              value: AppTheme.light,
              groupValue: _settings.theme,
              onChanged: (value) {
                setState(() {
                  _settings = _settings.copyWith(theme: value!);
                });
                Navigator.pop(context);
              },
            ),
            RadioListTile<AppTheme>(
              title: const Text('Dark'),
              value: AppTheme.dark,
              groupValue: _settings.theme,
              onChanged: (value) {
                setState(() {
                  _settings = _settings.copyWith(theme: value!);
                });
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showSignOutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Provider.of<AuthProvider>(context, listen: false).logout();
            },
            child: const Text('Sign Out', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
