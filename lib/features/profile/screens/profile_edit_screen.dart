import 'package:flutter/material.dart';
import '../models/profile_model.dart';
import '../services/profile_service.dart';
import '../../../shared/widgets/input_widget.dart';
import '../../../shared/widgets/button_widget.dart';
import '../../../shared/widgets/error_widget.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/validators.dart';

/// Profile edit screen for updating user details
/// Allows users to update all their profile information
class ProfileEditScreen extends StatefulWidget {
  final ProfileModel profile;

  const ProfileEditScreen({super.key, required this.profile});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _bioController = TextEditingController();
  final _locationController = TextEditingController();
  final _nidaController = TextEditingController();
  final _vetaController = TextEditingController();

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;
  List<String> _skills = [];
  List<String> _languages = [];
  String _newSkill = '';
  String _newLanguage = '';

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _setupAnimations();
  }

  void _initializeControllers() {
    _firstNameController.text = widget.profile.firstName;
    _lastNameController.text = widget.profile.lastName;
    _emailController.text = widget.profile.email;
    _phoneController.text = widget.profile.phoneNumber ?? '';
    _bioController.text = widget.profile.bio ?? '';
    _locationController.text = widget.profile.location ?? '';
    _nidaController.text = widget.profile.nidaNumber ?? '';
    _vetaController.text = widget.profile.vetaCertificate ?? '';
    _skills = List.from(widget.profile.skills);
    _languages = List.from(widget.profile.languages);
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
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    _locationController.dispose();
    _nidaController.dispose();
    _vetaController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final result = await ProfileService().updateProfile(
        userId: widget.profile.id,
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        email: _emailController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        bio: _bioController.text.trim().isEmpty
            ? null
            : _bioController.text.trim(),
        location: _locationController.text.trim().isEmpty
            ? null
            : _locationController.text.trim(),
        nidaNumber: _nidaController.text.trim().isEmpty
            ? null
            : _nidaController.text.trim(),
        vetaCertificate: _vetaController.text.trim().isEmpty
            ? null
            : _vetaController.text.trim(),
        skills: _skills,
        languages: _languages,
      );

      if (result.success) {
        setState(() {
          _successMessage = result.message;
        });

        // Navigate back after a short delay
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            Navigator.pop(context, result.profile);
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

  void _addSkill() {
    if (_newSkill.trim().isNotEmpty && !_skills.contains(_newSkill.trim())) {
      setState(() {
        _skills.add(_newSkill.trim());
        _newSkill = '';
      });
    }
  }

  void _removeSkill(String skill) {
    setState(() {
      _skills.remove(skill);
    });
  }

  void _addLanguage() {
    if (_newLanguage.trim().isNotEmpty &&
        !_languages.contains(_newLanguage.trim())) {
      setState(() {
        _languages.add(_newLanguage.trim());
        _newLanguage = '';
      });
    }
  }

  void _removeLanguage(String language) {
    setState(() {
      _languages.remove(language);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _handleSave,
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
                    const SizedBox(height: 16),
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
                    const SizedBox(height: 16),
                  ],

                  // Basic Information Section
                  _buildSectionHeader('Basic Information'),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: AppInputField(
                          label: 'First Name',
                          controller: _firstNameController,
                          isRequired: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'First name is required';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: AppInputField(
                          label: 'Last Name',
                          controller: _lastNameController,
                          isRequired: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Last name is required';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  AppInputField(
                    label: 'Email',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    validator: Validators.email,
                  ),

                  const SizedBox(height: 16),

                  AppInputField(
                    label: 'Phone Number',
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    validator: Validators.phoneNumber,
                  ),

                  const SizedBox(height: 32),

                  // Professional Information Section
                  _buildSectionHeader('Professional Information'),
                  const SizedBox(height: 16),

                  AppInputField(
                    label: 'Bio',
                    controller: _bioController,
                    maxLines: 3,
                    hint: 'Tell us about yourself...',
                  ),

                  const SizedBox(height: 16),

                  AppInputField(
                    label: 'Location',
                    controller: _locationController,
                    hint: 'City, Region',
                  ),

                  const SizedBox(height: 16),

                  AppInputField(
                    label: 'NIDA Number',
                    controller: _nidaController,
                    hint: '20-digit NIDA number',
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        return Validators.nidaNumber(value);
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  AppInputField(
                    label: 'VETA Certificate',
                    controller: _vetaController,
                    hint: 'VETA certificate number',
                  ),

                  const SizedBox(height: 32),

                  // Skills Section
                  _buildSectionHeader('Skills'),
                  const SizedBox(height: 16),

                  _buildSkillsSection(),

                  const SizedBox(height: 32),

                  // Languages Section
                  _buildSectionHeader('Languages'),
                  const SizedBox(height: 16),

                  _buildLanguagesSection(),

                  const SizedBox(height: 32),

                  // Save Button
                  AppButton(
                    text: 'Save Changes',
                    onPressed: _isLoading ? null : _handleSave,
                    isLoading: _isLoading,
                    isFullWidth: true,
                    size: ButtonSize.large,
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w600,
        color: AppTheme.darkGray,
      ),
    );
  }

  Widget _buildSkillsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Add skill input
        Row(
          children: [
            Expanded(
              child: AppInputField(
                label: 'Add Skill',
                controller: TextEditingController(text: _newSkill),
                onChanged: (value) => _newSkill = value,
                hint: 'Enter a skill',
              ),
            ),
            const SizedBox(width: 12),
            AppButton(
              text: 'Add',
              onPressed: _addSkill,
              type: ButtonType.secondary,
              size: ButtonSize.medium,
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Skills list
        if (_skills.isNotEmpty) ...[
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _skills
                .map(
                  (skill) => Chip(
                    label: Text(skill),
                    onDeleted: () => _removeSkill(skill),
                    deleteIcon: const Icon(Icons.close, size: 18),
                  ),
                )
                .toList(),
          ),
        ] else ...[
          Text(
            'No skills added yet',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.mediumGray,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildLanguagesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Add language input
        Row(
          children: [
            Expanded(
              child: AppInputField(
                label: 'Add Language',
                controller: TextEditingController(text: _newLanguage),
                onChanged: (value) => _newLanguage = value,
                hint: 'Enter a language',
              ),
            ),
            const SizedBox(width: 12),
            AppButton(
              text: 'Add',
              onPressed: _addLanguage,
              type: ButtonType.secondary,
              size: ButtonSize.medium,
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Languages list
        if (_languages.isNotEmpty) ...[
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _languages
                .map(
                  (language) => Chip(
                    label: Text(language),
                    onDeleted: () => _removeLanguage(language),
                    deleteIcon: const Icon(Icons.close, size: 18),
                  ),
                )
                .toList(),
          ),
        ] else ...[
          Text(
            'No languages added yet',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.mediumGray,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ],
    );
  }
}
