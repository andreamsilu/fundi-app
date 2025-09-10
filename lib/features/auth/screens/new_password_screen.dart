import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../../../shared/widgets/input_widget.dart';
import '../../../shared/widgets/button_widget.dart';
import '../../../shared/widgets/error_widget.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/validators.dart';

/// New Password Screen for password reset
/// Allows users to set a new password after OTP verification
class NewPasswordScreen extends StatefulWidget {
  final String phoneNumber;
  final String otp;

  const NewPasswordScreen({
    super.key,
    required this.phoneNumber,
    required this.otp,
  });

  @override
  State<NewPasswordScreen> createState() => _NewPasswordScreenState();
}

class _NewPasswordScreenState extends State<NewPasswordScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isSuccess = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  Future<void> _handleResetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await AuthService().resetPassword(
        phoneNumber: widget.phoneNumber,
        otp: widget.otp,
        newPassword: _passwordController.text,
      );

      if (result.success) {
        setState(() {
          _isSuccess = true;
        });

        // Navigate to login after a short delay
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            Navigator.pushReplacementNamed(context, '/login');
          }
        });
      } else {
        setState(() {
          _errorMessage = result.message;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'An unexpected error occurred. Please try again.';
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
        title: const Text('Set New Password'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 40),

                  // Header
                  _buildHeader(),

                  const SizedBox(height: 48),

                  if (_isSuccess) ...[
                    // Success message
                    _buildSuccessMessage(),
                  ] else ...[
                    // Error message
                    if (_errorMessage != null) ...[
                      ErrorBanner(
                        message: _errorMessage!,
                        onDismiss: () {
                          setState(() {
                            _errorMessage = null;
                          });
                        },
                      ),
                      const SizedBox(height: 24),
                    ],

                    // New password field
                    AppInputField(
                      label: 'New Password',
                      hint: 'Enter your new password',
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      isRequired: true,
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                      ),
                      validator: Validators.password,
                    ),

                    const SizedBox(height: 16),

                    // Confirm password field
                    AppInputField(
                      label: 'Confirm New Password',
                      hint: 'Confirm your new password',
                      controller: _confirmPasswordController,
                      obscureText: _obscureConfirmPassword,
                      isRequired: true,
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            _obscureConfirmPassword = !_obscureConfirmPassword;
                          });
                        },
                        icon: Icon(
                          _obscureConfirmPassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please confirm your password';
                        }
                        if (value != _passwordController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 32),

                    // Reset password button
                    AppButton(
                      text: 'Reset Password',
                      onPressed: _isLoading ? null : _handleResetPassword,
                      isLoading: _isLoading,
                      isFullWidth: true,
                      size: ButtonSize.large,
                      icon: Icons.lock_reset,
                    ),

                    const SizedBox(height: 24),

                    // Back to login
                    AppButton(
                      text: 'Back to Login',
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, '/login');
                      },
                      type: ButtonType.secondary,
                      isFullWidth: true,
                      size: ButtonSize.large,
                    ),
                  ],

                  const SizedBox(height: 32),

                  // Help text
                  Text(
                    'Create a strong password with at least 8 characters, including uppercase, lowercase, numbers, and special characters.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.mediumGray,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // Icon
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: context.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(Icons.lock_reset, size: 40, color: context.primaryColor),
        ),

        const SizedBox(height: 24),

        // Title
        Text(
          'Set New Password',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: AppTheme.darkGray,
            fontWeight: FontWeight.w600,
          ),
        ),

        const SizedBox(height: 8),

        // Subtitle
        Text(
          'Create a new password for your account',
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(color: AppTheme.mediumGray),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 16),

        // Phone number info
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.lightGray.withOpacity(0.3),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.phone, size: 16, color: AppTheme.mediumGray),
              const SizedBox(width: 8),
              Text(
                widget.phoneNumber,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.darkGray,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessMessage() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(Icons.check_circle, size: 64, color: Colors.green),

          const SizedBox(height: 16),

          Text(
            'Password Reset Successful!',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.green,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            'Your password has been successfully reset. You can now login with your new password.',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppTheme.mediumGray),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 24),

          AppButton(
            text: 'Go to Login',
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/login');
            },
            isFullWidth: true,
            size: ButtonSize.large,
          ),
        ],
      ),
    );
  }
}
