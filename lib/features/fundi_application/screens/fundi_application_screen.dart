import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/fundi_application_service.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../shared/widgets/input_widget.dart';
import '../../../shared/widgets/button_widget.dart';
import '../../../core/theme/app_theme.dart';

/// Fundi Application Stepper - 4 Steps with Auto-Save
/// Step 1: Personal Info
/// Step 2: Professional Info
/// Step 3: Skills & Languages
/// Step 4: Review & Submit
class FundiApplicationScreen extends StatefulWidget {
  const FundiApplicationScreen({super.key});

  @override
  State<FundiApplicationScreen> createState() => _FundiApplicationScreenState();
}

class _FundiApplicationScreenState extends State<FundiApplicationScreen> {
  int _currentStep = 0;
  final _service = FundiApplicationService();

  // Form keys for each step
  final _step1Key = GlobalKey<FormState>();
  final _step2Key = GlobalKey<FormState>();
  final _step3Key = GlobalKey<FormState>();

  // Controllers
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _locationController = TextEditingController();
  final _nidaController = TextEditingController();
  final _vetaController = TextEditingController();
  final _bioController = TextEditingController();

  // State
  List<String> _selectedSkills = [];
  List<String> _selectedLanguages = [];
  bool _isSubmitting = false;
  String? _error;

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
  ];

  final List<String> _availableLanguages = [
    'Swahili',
    'English',
    'French',
    'Arabic',
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    try {
      final user = Provider.of<AuthProvider>(context, listen: false).user;
      if (user != null) {
        _fullNameController.text = user.fullName ?? '';
        _phoneController.text = user.phone;
        _emailController.text = user.email ?? '';
      }
    } catch (e) {
      // Proceed without pre-filling
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _locationController.dispose();
    _nidaController.dispose();
    _vetaController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  void _nextStep() {
    switch (_currentStep) {
      case 0:
        if (_step1Key.currentState!.validate()) {
          setState(() => _currentStep++);
        }
        break;
      case 1:
        if (_step2Key.currentState!.validate()) {
          setState(() => _currentStep++);
        }
        break;
      case 2:
        if (_step3Key.currentState!.validate() && _selectedSkills.isNotEmpty) {
          setState(() => _currentStep++);
        } else if (_selectedSkills.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please select at least one skill')),
          );
        }
        break;
      case 3:
        _submitApplication();
        break;
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  Future<void> _submitApplication() async {
    setState(() {
      _isSubmitting = true;
      _error = null;
    });

    try {
      final result = await _service.submitApplication(
        fullName: _fullNameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        email: _emailController.text.trim(),
        location: _locationController.text.trim(),
        nidaNumber: _nidaController.text.trim(),
        vetaCertificate: _vetaController.text.trim(),
        bio: _bioController.text.trim(),
        skills: _selectedSkills,
        languages: _selectedLanguages,
        portfolioImages: [],
      );

      if (result.success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Application submitted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } else {
        setState(() => _error = result.message);
      }
    } catch (e) {
      setState(() => _error = 'Failed to submit application: $e');
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Become a Fundi'),
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // Progress Stepper
          _buildStepIndicator(),

          // Step Content
          Expanded(child: _buildStepContent()),

          // Navigation Buttons
          _buildNavigationButtons(),
        ],
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Container(
      padding: const EdgeInsets.all(20),
      color: AppTheme.primaryGreen.withOpacity(0.1),
      child: Row(
        children: List.generate(4, (index) {
          final isActive = index == _currentStep;
          final isCompleted = index < _currentStep;
          return Expanded(
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isCompleted || isActive
                        ? AppTheme.primaryGreen
                        : Colors.grey[300],
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: isCompleted
                        ? const Icon(Icons.check, color: Colors.white, size: 18)
                        : Text(
                            '${index + 1}',
                            style: TextStyle(
                              color: isActive ? Colors.white : Colors.grey[600],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                if (index < 3)
                  Expanded(
                    child: Container(
                      height: 2,
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      color: isCompleted
                          ? AppTheme.primaryGreen
                          : Colors.grey[300],
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildStep1Personal();
      case 1:
        return _buildStep2Professional();
      case 2:
        return _buildStep3Skills();
      case 3:
        return _buildStep4Review();
      default:
        return _buildStep1Personal();
    }
  }

  /// Step 1: Personal Info
  Widget _buildStep1Personal() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _step1Key,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStepTitle('Personal Information', 'Tell us about yourself'),

            const SizedBox(height: 24),

            AppInputField(
              label: 'Full Name',
              controller: _fullNameController,
              isRequired: true,
              prefixIcon: const Icon(Icons.person),
              validator: (v) =>
                  v?.trim().isEmpty ?? true ? 'Name is required' : null,
            ),

            const SizedBox(height: 16),

            AppInputField(
              label: 'Phone Number',
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              isRequired: true,
              prefixIcon: const Icon(Icons.phone),
              validator: (v) =>
                  v?.trim().isEmpty ?? true ? 'Phone is required' : null,
            ),

            const SizedBox(height: 16),

            AppInputField(
              label: 'Email',
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              isRequired: true,
              prefixIcon: const Icon(Icons.email),
              validator: (v) =>
                  v?.trim().isEmpty ?? true ? 'Email is required' : null,
            ),

            const SizedBox(height: 16),

            AppInputField(
              label: 'Location',
              controller: _locationController,
              isRequired: true,
              prefixIcon: const Icon(Icons.location_on),
              hint: 'City, Region',
              validator: (v) =>
                  v?.trim().isEmpty ?? true ? 'Location is required' : null,
            ),
          ],
        ),
      ),
    );
  }

  /// Step 2: Professional Info
  Widget _buildStep2Professional() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _step2Key,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStepTitle(
              'Professional Details',
              'Verification and credentials',
            ),

            const SizedBox(height: 24),

            AppInputField(
              label: 'NIDA Number',
              controller: _nidaController,
              isRequired: true,
              prefixIcon: const Icon(Icons.badge),
              hint: 'Your national ID number',
              validator: (v) =>
                  v?.trim().isEmpty ?? true ? 'NIDA is required' : null,
            ),

            const SizedBox(height: 16),

            AppInputField(
              label: 'VETA Certificate (Optional)',
              controller: _vetaController,
              prefixIcon: const Icon(Icons.school),
              hint: 'Certificate number if you have one',
            ),

            const SizedBox(height: 16),

            AppInputField(
              label: 'About You',
              controller: _bioController,
              maxLines: 5,
              isRequired: true,
              prefixIcon: const Icon(Icons.description),
              hint:
                  'Describe your experience and expertise (min 50 characters)',
              validator: (v) {
                if (v?.trim().isEmpty ?? true) return 'Bio is required';
                if (v!.trim().length < 50) return 'Minimum 50 characters';
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Step 3: Skills & Languages
  Widget _buildStep3Skills() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _step3Key,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStepTitle('Skills & Languages', 'What can you do?'),

            const SizedBox(height: 24),

            const Text(
              'Select Your Skills *',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _availableSkills.map((skill) {
                final isSelected = _selectedSkills.contains(skill);
                return FilterChip(
                  label: Text(skill),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedSkills.add(skill);
                      } else {
                        _selectedSkills.remove(skill);
                      }
                    });
                  },
                  selectedColor: AppTheme.primaryGreen.withOpacity(0.3),
                  checkmarkColor: AppTheme.primaryGreen,
                );
              }).toList(),
            ),

            const SizedBox(height: 32),

            const Text(
              'Languages (Optional)',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _availableLanguages.map((lang) {
                final isSelected = _selectedLanguages.contains(lang);
                return FilterChip(
                  label: Text(lang),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedLanguages.add(lang);
                      } else {
                        _selectedLanguages.remove(lang);
                      }
                    });
                  },
                  selectedColor: AppTheme.accentGreen.withOpacity(0.3),
                  checkmarkColor: AppTheme.accentGreen,
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  /// Step 4: Review & Submit
  Widget _buildStep4Review() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepTitle('Review', 'Confirm your application'),

          const SizedBox(height: 24),

          _buildReviewSection('Personal Info', [
            _buildReviewItem('Name', _fullNameController.text),
            _buildReviewItem('Phone', _phoneController.text),
            _buildReviewItem('Email', _emailController.text),
            _buildReviewItem('Location', _locationController.text),
          ]),

          const SizedBox(height: 16),

          _buildReviewSection('Professional Info', [
            _buildReviewItem('NIDA', _nidaController.text),
            if (_vetaController.text.isNotEmpty)
              _buildReviewItem('VETA', _vetaController.text),
            _buildReviewItem('Bio', _bioController.text, maxLines: 3),
          ]),

          const SizedBox(height: 16),

          _buildReviewSection('Skills & Languages', [
            _buildReviewItem('Skills', _selectedSkills.join(', ')),
            if (_selectedLanguages.isNotEmpty)
              _buildReviewItem('Languages', _selectedLanguages.join(', ')),
          ]),

          if (_error != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error, color: Colors.red),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _error!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStepTitle(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(subtitle, style: TextStyle(color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildReviewSection(String title, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.lightGray),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryGreen,
            ),
          ),
          const Divider(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _buildReviewItem(String label, String value, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600),
            maxLines: maxLines,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons() {
    final isLastStep = _currentStep == 3;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: AppButton(
                text: 'Back',
                onPressed: _previousStep,
                type: ButtonType.secondary,
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 16),
          Expanded(
            flex: _currentStep == 0 ? 1 : 1,
            child: AppButton(
              text: isLastStep ? 'Submit Application' : 'Continue',
              onPressed: _isSubmitting ? null : _nextStep,
              isLoading: _isSubmitting && isLastStep,
              icon: isLastStep ? Icons.send : Icons.arrow_forward,
            ),
          ),
        ],
      ),
    );
  }
}
