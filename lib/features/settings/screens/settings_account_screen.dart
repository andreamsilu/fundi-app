import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/input_widget.dart';
import '../../../shared/widgets/button_widget.dart';

/// Account Settings Sub-Screen
class SettingsAccountScreen extends StatefulWidget {
  const SettingsAccountScreen({super.key});

  @override
  State<SettingsAccountScreen> createState() => _SettingsAccountScreenState();
}

class _SettingsAccountScreenState extends State<SettingsAccountScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Account Settings'),
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          AppInputField(
            label: 'Full Name',
            controller: _nameController,
            prefixIcon: const Icon(Icons.person),
          ),

          const SizedBox(height: 16),

          AppInputField(
            label: 'Email',
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            prefixIcon: const Icon(Icons.email),
          ),

          const SizedBox(height: 16),

          AppInputField(
            label: 'Phone Number',
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            prefixIcon: const Icon(Icons.phone),
          ),

          const SizedBox(height: 32),

          AppButton(
            text: 'Save Changes',
            onPressed: () {
              // TODO: Save account changes
              Navigator.pop(context);
            },
            icon: Icons.save,
          ),

          const SizedBox(height: 16),

          AppButton(
            text: 'Change Password',
            onPressed: () {
              // TODO: Navigate to change password
            },
            type: ButtonType.secondary,
            icon: Icons.lock,
          ),

          const SizedBox(height: 16),

          AppButton(
            text: 'Delete Account',
            onPressed: () {
              // TODO: Show delete confirmation
            },
            type: ButtonType.danger,
            icon: Icons.delete_forever,
          ),
        ],
      ),
    );
  }
}
