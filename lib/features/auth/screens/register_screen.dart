import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import 'otp_verification_screen.dart';
import '../../../shared/widgets/input_widget.dart';
import '../../../shared/widgets/button_widget.dart';
import '../../../shared/widgets/error_widget.dart';
import '../../../core/theme/app_theme.dart';

/// Registration screen for user authentication
/// Features phone/password registration with role selection
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String? _errorMessage;
  UserRole _selectedRole = UserRole.customer;

  @override
  void initState() {
    super.initState();
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
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // First, send OTP for verification
      final otpResult = await AuthService().sendOtp(
        phoneNumber: _phoneController.text.trim(),
        type: OtpVerificationType.registration,
      );

      if (otpResult.success) {
        // Navigate to OTP verification screen
        if (mounted) {
          final result = await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder: (context) => OtpVerificationScreen(
                phoneNumber: _phoneController.text.trim(),
                type: OtpVerificationType.registration,
              ),
            ),
          );

          if (result == true) {
            // OTP verified successfully, complete registration
            final registerResult = await AuthService().register(
              phoneNumber: _phoneController.text.trim(),
              password: _passwordController.text,
              role: _selectedRole,
            );

            if (registerResult.success && registerResult.user != null) {
              // Navigate to appropriate screen based on user role
              if (mounted) {
                if (registerResult.user!.isCustomer) {
                  Navigator.pushReplacementNamed(
                    context,
                    '/customer-dashboard',
                  );
                } else if (registerResult.user!.isFundi) {
                  Navigator.pushReplacementNamed(context, '/fundi-dashboard');
                } else {
                  Navigator.pushReplacementNamed(context, '/admin-dashboard');
                }
              }
            } else {
              setState(() {
                _errorMessage = registerResult.message;
              });
            }
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
      body: SafeArea(
        child: FadeTransition(
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

                    // Logo and title
                    _buildHeader(),

                    const SizedBox(height: 48),

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
                      hint: 'Enter your phone number',
                      controller: _phoneController,
                      isRequired: true,
                      prefixIcon: const Icon(Icons.phone_outlined),
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Phone number is required';
                        }
                        // Use the phone validator from validators
                        final cleanValue = value.replaceAll(
                          RegExp(r'[\s-]'),
                          '',
                        );
                        final phoneRegex = RegExp(r'^(\+255|0)[0-9]{9}$');
                        if (!phoneRegex.hasMatch(cleanValue)) {
                          return 'Please enter a valid Tanzanian phone number (e.g., +255123456789 or 0123456789)';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // Password field
                    AppInputField(
                      label: 'Password',
                      hint: 'Enter your password',
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
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Password is required';
                        }
                        if (value.length < 8) {
                          return 'Password must be at least 8 characters';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // Confirm Password field
                    AppInputField(
                      label: 'Confirm Password',
                      hint: 'Confirm your password',
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

                    const SizedBox(height: 24),

                    // Role selection
                    _buildRoleSelection(),

                    const SizedBox(height: 32),

                    // Register button
                    AppButton(
                      text: 'Create Account',
                      onPressed: _isLoading ? null : _handleRegister,
                      isLoading: _isLoading,
                      isFullWidth: true,
                      size: ButtonSize.large,
                    ),

                    const SizedBox(height: 24),

                    // Divider
                    Row(
                      children: [
                        const Expanded(child: Divider()),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'OR',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: AppTheme.mediumGray),
                          ),
                        ),
                        const Expanded(child: Divider()),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Login button
                    AppButton(
                      text: 'Already have an account? Login',
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, '/login');
                      },
                      type: ButtonType.secondary,
                      isFullWidth: true,
                      size: ButtonSize.large,
                    ),

                    const SizedBox(height: 32),

                    // Terms and privacy
                    Text(
                      'By creating an account, you agree to our Terms of Service and Privacy Policy',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
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
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // App logo
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: context.primaryColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: context.primaryColor.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: const Icon(Icons.build, color: Colors.white, size: 40),
        ),

        const SizedBox(height: 24),

        // App name
        Text(
          'Fundi App',
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
            color: context.primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 8),

        // Subtitle
        Text(
          'Connect with skilled craftsmen',
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(color: AppTheme.mediumGray),
        ),

        const SizedBox(height: 16),

        // Welcome message
        Text(
          'Create Account',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: AppTheme.darkGray,
            fontWeight: FontWeight.w600,
          ),
        ),

        const SizedBox(height: 8),

        Text(
          'Join our community of skilled professionals',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: AppTheme.mediumGray),
        ),
      ],
    );
  }

  Widget _buildRoleSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'I am a:',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.darkGray,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildRoleOption(
                role: UserRole.customer,
                title: 'Customer',
                subtitle: 'Looking for services',
                icon: Icons.person_outline,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildRoleOption(
                role: UserRole.fundi,
                title: 'Fundi',
                subtitle: 'Providing services',
                icon: Icons.build_outlined,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRoleOption({
    required UserRole role,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    final isSelected = _selectedRole == role;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedRole = role;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? context.primaryColor : AppTheme.lightGray,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color: isSelected
              ? context.primaryColor.withValues(alpha: 0.1)
              : Colors.transparent,
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: isSelected ? context.primaryColor : AppTheme.mediumGray,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: isSelected ? context.primaryColor : AppTheme.darkGray,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppTheme.mediumGray),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
