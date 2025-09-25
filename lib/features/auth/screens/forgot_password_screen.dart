import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'otp_verification_screen.dart';
import '../../../shared/widgets/input_widget.dart';
import '../../../shared/widgets/button_widget.dart';
import '../../../shared/widgets/error_widget.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/validators.dart';

/// Forgot password screen for password reset
/// Uses phone number to send reset instructions
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  bool _isLoading = false;
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
    _phoneController.dispose();
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
      // Send OTP for password reset verification
      final otpResult = await AuthService().sendOtp(
        phoneNumber: _phoneController.text.trim(),
        type: OtpVerificationType.passwordReset,
      );

      if (otpResult.success) {
        // Navigate to OTP verification screen
        if (mounted) {
          final result = await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder: (context) => OtpVerificationScreen(
                phoneNumber: _phoneController.text.trim(),
                type: OtpVerificationType.passwordReset,
              ),
            ),
          );

          if (result == true) {
            setState(() {
              _isSuccess = true;
            });
          }
        }
      } else {
        setState(() {
          _errorMessage = otpResult.message;
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
        title: const Text('Reset Password'),
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

                    // Phone field
                    AppInputField(
                      label: 'Phone Number',
                      hint: 'Enter your phone number (e.g., 0654289824)',
                      controller: _phoneController,
                      isRequired: true,
                      prefixIcon: const Icon(Icons.phone_outlined),
                      keyboardType: TextInputType.phone,
                      validator: Validators.phoneNumber,
                    ),

                    const SizedBox(height: 32),

                    // Reset button
                    AppButton(
                      text: 'Send Reset Instructions',
                      onPressed: _isLoading ? null : _handleResetPassword,
                      isLoading: _isLoading,
                      isFullWidth: true,
                      size: ButtonSize.large,
                    ),

                    const SizedBox(height: 24),

                    // Back to login
                    AppButton(
                      text: 'Back to Login',
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      type: ButtonType.secondary,
                      isFullWidth: true,
                      size: ButtonSize.large,
                    ),
                  ],

                  const SizedBox(height: 32),

                  // Help text
                  Text(
                    'Enter your phone number and we\'ll send you instructions to reset your password.',
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
            color: context.primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(Icons.lock_reset, size: 40, color: context.primaryColor),
        ),

        const SizedBox(height: 24),

        // Title
        Text(
          'Reset Password',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: AppTheme.darkGray,
            fontWeight: FontWeight.w600,
          ),
        ),

        const SizedBox(height: 8),

        // Subtitle
        Text(
          'Enter your phone number to receive reset instructions',
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(color: AppTheme.mediumGray),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildSuccessMessage() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(Icons.check_circle, size: 64, color: Colors.green),

          const SizedBox(height: 16),

          Text(
            'Reset Instructions Sent!',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.green,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            'We\'ve sent password reset instructions to your phone number. Please check your messages.',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppTheme.mediumGray),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 24),

          AppButton(
            text: 'Back to Login',
            onPressed: () {
              Navigator.pop(context);
            },
            isFullWidth: true,
            size: ButtonSize.large,
          ),
        ],
      ),
    );
  }
}
