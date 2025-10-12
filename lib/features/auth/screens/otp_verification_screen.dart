import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/auth_service.dart';
import '../../../shared/widgets/otp_input_widget.dart';
import '../../../shared/widgets/button_widget.dart';
import '../../../shared/widgets/error_widget.dart';
import '../../../core/theme/app_theme.dart';

/// OTP Verification Screen
/// Handles phone number verification with 6-digit OTP
class OtpVerificationScreen extends StatefulWidget {
  final String phoneNumber;
  final OtpVerificationType type;
  final String? userId; // For password reset verification

  const OtpVerificationScreen({
    super.key,
    required this.phoneNumber,
    required this.type,
    this.userId,
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _otpController = TextEditingController();

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _pulseAnimation;

  bool _isLoading = false;
  bool _isResending = false;
  bool _isVerified = false;
  String? _errorMessage;
  String? _successMessage;
  int _resendCountdown = 0;
  final int _maxAttempts = 3;
  int _attempts = 0;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startResendCountdown();
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
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _fadeController.forward();
    _slideController.forward();
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _otpController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _startResendCountdown() {
    setState(() {
      _resendCountdown = 60; // 60 seconds countdown
    });

    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        setState(() {
          _resendCountdown--;
        });
        return _resendCountdown > 0;
      }
      return false;
    });
  }

  Future<void> _handleVerifyOtp() async {
    if (!_formKey.currentState!.validate()) return;

    if (_otpController.text.length != 6) {
      setState(() {
        _errorMessage = 'Please enter a valid 6-digit OTP';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final result = await AuthService().verifyOtp(
        phoneNumber: widget.phoneNumber,
        otp: _otpController.text,
        type: widget.type,
        userId: widget.userId,
      );

      if (result.success) {
        setState(() {
          _isVerified = true;
          _successMessage = result.message;
        });

        // Navigate based on verification type
        _handleVerificationSuccess();
      } else {
        setState(() {
          _errorMessage = result.message;
          _attempts++;
        });

        if (_attempts >= _maxAttempts) {
          _showMaxAttemptsDialog();
        }
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

  void _handleVerificationSuccess() {
    switch (widget.type) {
      case OtpVerificationType.registration:
        // Navigate to appropriate dashboard based on user role
        Navigator.pushReplacementNamed(context, '/dashboard');
        break;
      case OtpVerificationType.passwordReset:
        // Navigate to new password screen
        Navigator.pushReplacementNamed(
          context,
          '/new-password',
          arguments: {
            'phoneNumber': widget.phoneNumber,
            'otp': _otpController.text,
          },
        );
        break;
      case OtpVerificationType.phoneChange:
        // Navigate back to profile or show success
        Navigator.pop(context, true);
        break;
    }
  }

  Future<void> _handleResendOtp() async {
    if (_resendCountdown > 0) return;

    setState(() {
      _isResending = true;
      _errorMessage = null;
    });

    try {
      final result = await AuthService().resendOtp(
        phoneNumber: widget.phoneNumber,
        type: widget.type,
        userId: widget.userId,
      );

      if (result.success) {
        setState(() {
          _successMessage = 'OTP sent successfully';
        });
        _startResendCountdown();
      } else {
        setState(() {
          _errorMessage = result.message;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to resend OTP. Please try again.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isResending = false;
        });
      }
    }
  }

  void _showMaxAttemptsDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Maximum Attempts Reached'),
        content: const Text(
          'You have exceeded the maximum number of verification attempts. Please request a new OTP.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _handleResendOtp();
            },
            child: const Text('Request New OTP'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Phone Number'),
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back),
        ),
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

                  // Messages
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

                  if (_successMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.green.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle, color: Colors.green),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _successMessage!,
                              style: const TextStyle(color: Colors.green),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // OTP Input
                  _buildOtpInput(),

                  const SizedBox(height: 32),

                  // Verify Button
                  AppButton(
                    text: _isVerified ? 'Verified' : 'Verify OTP',
                    onPressed: _isVerified
                        ? null
                        : (_isLoading ? null : _handleVerifyOtp),
                    isLoading: _isLoading,
                    isFullWidth: true,
                    size: ButtonSize.large,
                    icon: _isVerified
                        ? Icons.check_circle
                        : Icons.verified_user,
                  ),

                  const SizedBox(height: 24),

                  // Resend OTP
                  _buildResendSection(),

                  const SizedBox(height: 32),

                  // Help text
                  _buildHelpText(),

                  const SizedBox(height: 24),

                  // Attempts counter
                  if (_attempts > 0) ...[
                    Text(
                      'Attempts: $_attempts/$_maxAttempts',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: _attempts >= _maxAttempts
                            ? Colors.red
                            : AppTheme.mediumGray,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                  ],
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
        // Animated icon
        AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _pulseAnimation.value,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: context.primaryColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.sms, size: 50, color: context.primaryColor),
              ),
            );
          },
        ),

        const SizedBox(height: 24),

        // Title
        Text(
          'Verify Your Phone',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: AppTheme.darkGray,
            fontWeight: FontWeight.w600,
          ),
        ),

        const SizedBox(height: 8),

        // Subtitle
        Text(
          'We sent a 6-digit code to',
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(color: AppTheme.mediumGray),
        ),

        const SizedBox(height: 8),

        // Phone number
        Text(
          widget.phoneNumber,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: context.primaryColor,
            fontWeight: FontWeight.w600,
          ),
        ),

        const SizedBox(height: 8),

        Text(
          'Enter the code below to verify',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: AppTheme.mediumGray),
        ),
      ],
    );
  }

  Widget _buildOtpInput() {
    return Column(
      children: [
        OtpInputWidget(
          controller: _otpController,
          onChanged: (value) {
            // Auto-verify when 6 digits are entered
            if (value.length == 6 && !_isLoading) {
              _handleVerifyOtp();
            }
          },
          onCompleted: (value) {
            if (!_isLoading) {
              _handleVerifyOtp();
            }
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter the OTP';
            }
            if (value.length != 6) {
              return 'Please enter a valid 6-digit OTP';
            }
            return null;
          },
        ),

        const SizedBox(height: 16),

        // Paste from clipboard button
        TextButton.icon(
          onPressed: _pasteFromClipboard,
          icon: const Icon(Icons.content_paste, size: 18),
          label: const Text('Paste from Clipboard'),
        ),
      ],
    );
  }

  Future<void> _pasteFromClipboard() async {
    try {
      final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
      if (clipboardData?.text != null) {
        final cleanText = clipboardData!.text!.replaceAll(
          RegExp(r'[^0-9]'),
          '',
        );
        if (cleanText.length >= 6) {
          _otpController.text = cleanText.substring(0, 6);
        }
      }
    } catch (e) {
      // Handle clipboard error silently
    }
  }

  Widget _buildResendSection() {
    return Column(
      children: [
        if (_resendCountdown > 0) ...[
          Text(
            'Resend code in ${_resendCountdown}s',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppTheme.mediumGray),
          ),
        ] else ...[
          AppButton(
            text: _isResending ? 'Sending...' : 'Resend Code',
            onPressed: _isResending ? null : _handleResendOtp,
            type: ButtonType.secondary,
            isFullWidth: true,
            size: ButtonSize.medium,
            icon: Icons.refresh,
          ),
        ],
      ],
    );
  }

  Widget _buildHelpText() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.lightGray.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(Icons.info_outline, color: AppTheme.mediumGray, size: 24),
          const SizedBox(height: 8),
          Text(
            'Didn\'t receive the code?',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.darkGray,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Check your SMS messages or request a new code. The code will expire in 10 minutes.',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppTheme.mediumGray),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
