import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../../../shared/widgets/input_widget.dart';
import '../../../shared/widgets/button_widget.dart';
import '../../../shared/widgets/error_widget.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/navigation_guard.dart';
import '../../../core/app/app_initialization_service.dart';

/// Login screen for user authentication
/// Features email/password login with validation and error handling
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

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
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Check if API client is initialized
      if (!AppInitializationService.isInitialized) {
        setState(() {
          _errorMessage =
              'App is still loading. Please wait a moment and try again.';
        });
        return;
      }

      // Use AuthService directly for login
      final authService = AuthService();

      // Ensure service is initialized
      await authService.initialize();

      final result = await authService.login(
        phoneNumber: _phoneController.text.trim(),
        password: _passwordController.text,
      );

      if (result.success) {
        // Navigate to dashboard - MainDashboard will handle role-based UI
        if (mounted) {
          await NavigationGuard().safePushReplacementNamed(
            context,
            '/dashboard',
          );
        }
      } else {
        setState(() {
          _errorMessage = result.message;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage =
            'Connection error. Please check your internet and try again.';
      });
      debugPrint('Login error: $e');
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
                      hint: 'Enter your phone number (e.g., 0654289824)',
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
                        final phoneRegex = RegExp(r'^(06|07)[0-9]{8}$');
                        if (!phoneRegex.hasMatch(cleanValue)) {
                          return 'Please enter a valid Tanzanian phone number (e.g., 0654289824 or 0754289824)';
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
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 8),

                    // Forgot password
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/forgot-password');
                        },
                        child: const Text('Forgot Password?'),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Login button
                    AppButton(
                      text: 'Login',
                      onPressed: _isLoading ? null : _handleLogin,
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

                    // Register button
                    AppButton(
                      text: 'Create Account',
                      onPressed: () {
                        Navigator.pushNamed(context, '/register');
                      },
                      type: ButtonType.secondary,
                      isFullWidth: true,
                      size: ButtonSize.large,
                    ),

                    const SizedBox(height: 32),

                    // Terms and privacy
                    Text(
                      'By continuing, you agree to our Terms of Service and Privacy Policy',
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
          'Welcome back!',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: AppTheme.darkGray,
            fontWeight: FontWeight.w600,
          ),
        ),

        const SizedBox(height: 8),

        Text(
          'Sign in to continue',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: AppTheme.mediumGray),
        ),
      ],
    );
  }
}
