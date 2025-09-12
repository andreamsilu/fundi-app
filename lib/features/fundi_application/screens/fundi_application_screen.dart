import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/fundi_application_model.dart';
import '../services/fundi_application_service.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../shared/widgets/button_widget.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../../shared/widgets/error_widget.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/logger.dart';

/// Screen for users to apply to become a fundi
/// Displays application form with all required fields
class FundiApplicationScreen extends StatefulWidget {
  const FundiApplicationScreen({super.key});

  @override
  State<FundiApplicationScreen> createState() => _FundiApplicationScreenState();
}

class _FundiApplicationScreenState extends State<FundiApplicationScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _service = FundiApplicationService();

  // Form controllers
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _nidaController = TextEditingController();
  final _vetaController = TextEditingController();
  final _locationController = TextEditingController();
  final _bioController = TextEditingController();

  // Form state
  List<String> _selectedSkills = [];
  List<String> _selectedLanguages = [];
  List<String> _portfolioImages = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Animation controllers
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Available options
  final List<String> _availableSkills = [
    'Plumbing',
    'Electrical Work',
    'Carpentry',
    'Masonry',
    'Painting',
    'Roofing',
    'Flooring',
    'Tiling',
    'Welding',
    'Mechanical Repair',
    'Air Conditioning',
    'Solar Installation',
    'Furniture Making',
    'Metal Work',
    'Glass Work',
  ];

  final List<String> _availableLanguages = [
    'Swahili',
    'English',
    'French',
    'Arabic',
    'Portuguese',
    'Chinese',
    'Hindi',
  ];

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadUserData();
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

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
    );

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _fullNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _nidaController.dispose();
    _vetaController.dispose();
    _locationController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  void _loadUserData() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;

    if (user != null) {
      _fullNameController.text = user.fullName ?? '';
      _phoneController.text = user.phone;
      _emailController.text = user.email ?? '';
    }
  }

  Future<void> _submitApplication() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedSkills.isEmpty) {
      _showError('Please select at least one skill');
      return;
    }

    if (_selectedLanguages.isEmpty) {
      _showError('Please select at least one language');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _service.submitApplication(
        fullName: _fullNameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        email: _emailController.text.trim(),
        nidaNumber: _nidaController.text.trim(),
        vetaCertificate: _vetaController.text.trim(),
        location: _locationController.text.trim(),
        bio: _bioController.text.trim(),
        skills: _selectedSkills,
        languages: _selectedLanguages,
        portfolioImages: _portfolioImages,
      );

      if (mounted) {
        if (result.success) {
          _showSuccessDialog();
        } else {
          _showError(result.message);
        }
      }
    } catch (e) {
      Logger.error('Application submission error', error: e);
      if (mounted) {
        _showError('An unexpected error occurred. Please try again.');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showError(String message) {
    setState(() {
      _errorMessage = message;
    });
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text('Application Submitted'),
          ],
        ),
        content: const Text(
          'Your fundi application has been submitted successfully. '
          'We will review your application and notify you of the status.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop(); // Go back to previous screen
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Become a Fundi'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: _buildBody(),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: LoadingWidget(message: 'Submitting application...'),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            _buildHeader(),
            const SizedBox(height: 32),

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
              const SizedBox(height: 16),
            ],

            // Personal Information
            _buildSection(
              title: 'Personal Information',
              children: [
                _buildTextField(
                  controller: _fullNameController,
                  label: 'Full Name',
                  hint: 'Enter your full name',
                  icon: Icons.person,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your full name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _phoneController,
                  label: 'Phone Number',
                  hint: 'Enter your phone number',
                  icon: Icons.phone,
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your phone number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _emailController,
                  label: 'Email Address',
                  hint: 'Enter your email address',
                  icon: Icons.email,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your email address';
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                      return 'Please enter a valid email address';
                    }
                    return null;
                  },
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Professional Information
            _buildSection(
              title: 'Professional Information',
              children: [
                _buildTextField(
                  controller: _nidaController,
                  label: 'NIDA Number',
                  hint: 'Enter your NIDA number',
                  icon: Icons.badge,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your NIDA number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _vetaController,
                  label: 'VETA Certificate Number',
                  hint: 'Enter your VETA certificate number',
                  icon: Icons.school,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your VETA certificate number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _locationController,
                  label: 'Location',
                  hint: 'Enter your location (City, Region)',
                  icon: Icons.location_on,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your location';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _bioController,
                  label: 'Bio',
                  hint: 'Tell us about yourself and your experience',
                  icon: Icons.description,
                  maxLines: 4,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your bio';
                    }
                    if (value.trim().length < 50) {
                      return 'Bio must be at least 50 characters long';
                    }
                    return null;
                  },
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Skills Selection
            _buildSection(
              title: 'Skills',
              children: [
                Text(
                  'Select your skills (at least one required)',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.mediumGray,
                  ),
                ),
                const SizedBox(height: 16),
                _buildChipSelection(
                  options: _availableSkills,
                  selected: _selectedSkills,
                  onChanged: (skills) {
                    setState(() {
                      _selectedSkills = skills;
                    });
                  },
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Languages Selection
            _buildSection(
              title: 'Languages',
              children: [
                Text(
                  'Select languages you speak (at least one required)',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.mediumGray,
                  ),
                ),
                const SizedBox(height: 16),
                _buildChipSelection(
                  options: _availableLanguages,
                  selected: _selectedLanguages,
                  onChanged: (languages) {
                    setState(() {
                      _selectedLanguages = languages;
                    });
                  },
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Portfolio Images
            _buildSection(
              title: 'Portfolio',
              children: [
                Text(
                  'Upload images of your work (optional)',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.mediumGray,
                  ),
                ),
                const SizedBox(height: 16),
                _buildPortfolioUpload(),
              ],
            ),

            const SizedBox(height: 48),

            // Submit Button
            AppButton(
              text: 'Submit Application',
              onPressed: _submitApplication,
              isFullWidth: true,
              size: ButtonSize.large,
              icon: Icons.send,
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryGreen,
            AppTheme.primaryGreen.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryGreen.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            Icons.build_circle,
            size: 64,
            color: Colors.white,
          ),
          const SizedBox(height: 16),
          Text(
            'Become a Fundi',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Join our community of skilled craftsmen and start earning',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white70,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.darkGray,
          ),
        ),
        const SizedBox(height: 16),
        ...children,
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppTheme.lightGray),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppTheme.primaryGreen),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
      ),
    );
  }

  Widget _buildChipSelection({
    required List<String> options,
    required List<String> selected,
    required Function(List<String>) onChanged,
  }) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((option) {
        final isSelected = selected.contains(option);
        return FilterChip(
          label: Text(option),
          selected: isSelected,
          onSelected: (value) {
            final newSelection = List<String>.from(selected);
            if (value) {
              newSelection.add(option);
            } else {
              newSelection.remove(option);
            }
            onChanged(newSelection);
          },
          selectedColor: AppTheme.primaryGreen.withValues(alpha: 0.2),
          checkmarkColor: AppTheme.primaryGreen,
          labelStyle: TextStyle(
            color: isSelected ? AppTheme.primaryGreen : AppTheme.darkGray,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPortfolioUpload() {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.lightGray),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_photo_alternate,
              size: 32,
              color: AppTheme.mediumGray,
            ),
            const SizedBox(height: 8),
            Text(
              'Tap to add portfolio images',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.mediumGray,
              ),
            ),
            Text(
              'Coming soon',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.mediumGray,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
