import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../services/job_service.dart';
import '../../dashboard/services/dashboard_service.dart';
import '../../../shared/widgets/input_widget.dart';
import '../../../shared/widgets/button_widget.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/error_handler.dart';

/// Job creation wizard with 3 simple steps
/// Step 1: Basic Info (What, Category, Description)
/// Step 2: Budget & Timeline (Budget, Duration, Deadline)
/// Step 3: Details (Location, Images) - Optional
class JobCreationScreen extends StatefulWidget {
  const JobCreationScreen({super.key});

  @override
  State<JobCreationScreen> createState() => _JobCreationScreenState();
}

class _JobCreationScreenState extends State<JobCreationScreen>
    with TickerProviderStateMixin, ErrorHandlingMixin {
  int _currentStep = 0;
  final _step1FormKey = GlobalKey<FormState>();
  final _step2FormKey = GlobalKey<FormState>();

  // Controllers
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _budgetController = TextEditingController();
  final _durationController = TextEditingController();
  final _locationController = TextEditingController();

  // State
  bool _isLoading = false;
  bool _isLoadingCategories = true;
  String _selectedCategory = '';
  DateTime? _selectedDeadline;
  List<File> _selectedImages = [];
  final ImagePicker _imagePicker = ImagePicker();
  List<JobCategory> _categories = [];

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    await handleApiCall(() async {
      final result = await DashboardService().getJobCategories();
      if (result.success &&
          result.categories != null &&
          result.categories!.isNotEmpty) {
        if (mounted) {
          setState(() {
            _categories = result.categories!;
            _selectedCategory = _categories.first.id;
            _isLoadingCategories = false;
          });
        }
      } else {
        throw Exception('No categories available');
      }
    }, loadingMessage: 'Loading categories...');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _budgetController.dispose();
    _durationController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep == 0) {
      if (_step1FormKey.currentState!.validate()) {
        setState(() => _currentStep++);
      }
    } else if (_currentStep == 1) {
      if (_step2FormKey.currentState!.validate()) {
        setState(() => _currentStep++);
      }
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  Future<void> _submitJob() async {
    await handleApiCall(() async {
      final result = await JobService().createJob(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        categoryId: int.parse(_selectedCategory),
        budget: double.tryParse(_budgetController.text.trim()) ?? 0.0,
        budgetType: 'fixed',
        location: _locationController.text.trim().isEmpty
            ? 'Not specified'
            : _locationController.text.trim(),
        deadline: _selectedDeadline ?? DateTime.now().add(Duration(days: 30)),
        urgency: 'medium',
        preferredTime: 'anytime',
        requiredSkills: [],
        imageUrls: _selectedImages.map((file) => file.path).toList(),
      );

      if (result.success && result.job != null) {
        ErrorHandler.showSuccessSnackBar(context, 'Job posted successfully!');
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            Navigator.pushReplacementNamed(
              context,
              '/dashboard',
              arguments: {'switchToMyJobs': true},
            );
          }
        });
      } else {
        throw Exception(result.message);
      }
    }, loadingMessage: 'Posting job...');
  }

  Future<void> _pickImages() async {
    try {
      final List<XFile> images = await _imagePicker.pickMultiImage(
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (images.isNotEmpty) {
        setState(() {
          _selectedImages.addAll(images.map((image) => File(image.path)));
        });
      }
    } catch (e) {
      ErrorHandler.showErrorSnackBar(
        context,
        'Failed to pick images. Please try again.',
      );
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  Future<void> _selectDeadline() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDeadline ?? DateTime.now().add(Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        _selectedDeadline = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Post a Job'),
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Progress Indicator
          _buildProgressIndicator(),

          // Error banner
          buildErrorBanner(),

          // Step Content
          Expanded(child: _buildStepContent()),

          // Navigation Buttons
          _buildNavigationButtons(),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      color: AppTheme.primaryGreen,
      child: Row(
        children: List.generate(3, (index) {
          final isActive = index == _currentStep;
          final isCompleted = index < _currentStep;
          return Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: isCompleted || isActive
                          ? Colors.white
                          : Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                if (index < 2) const SizedBox(width: 8),
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
        return _buildStep1();
      case 1:
        return _buildStep2();
      case 2:
        return _buildStep3();
      default:
        return _buildStep1();
    }
  }

  /// Step 1: Basic Info - What do you need?
  Widget _buildStep1() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _step1FormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Step Header
            _buildStepHeader(
              '1 of 3',
              'What do you need?',
              'Tell us about your project',
            ),

            const SizedBox(height: 32),

            // Job Title
            AppInputField(
              label: 'Job Title',
              hint: 'e.g., Fix leaking kitchen faucet',
              controller: _titleController,
              isRequired: true,
              prefixIcon: const Icon(Icons.work_outline),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a job title';
                }
                if (value.trim().length < 5) {
                  return 'Title must be at least 5 characters';
                }
                return null;
              },
            ),

            const SizedBox(height: 20),

            // Category Selection
            Text(
              'Category *',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.darkGray,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                border: Border.all(color: AppTheme.lightGray),
                borderRadius: BorderRadius.circular(12),
                color: Colors.white,
              ),
              child: _isLoadingCategories
                  ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  : DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedCategory.isNotEmpty
                            ? _selectedCategory
                            : null,
                        isExpanded: true,
                        hint: const Text('Select category'),
                        items: _categories.map((category) {
                          return DropdownMenuItem(
                            value: category.id,
                            child: Row(
                              children: [
                                Icon(_getCategoryIcon(category.name), size: 20),
                                const SizedBox(width: 12),
                                Text(category.name),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _selectedCategory = value);
                          }
                        },
                      ),
                    ),
            ),

            const SizedBox(height: 20),

            // Description
            AppInputField(
              label: 'Description',
              hint: 'Describe what needs to be done...',
              controller: _descriptionController,
              maxLines: 5,
              isRequired: true,
              prefixIcon: const Icon(Icons.description),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please describe the job';
                }
                if (value.trim().length < 20) {
                  return 'Description must be at least 20 characters';
                }
                return null;
              },
            ),

            const SizedBox(height: 24),

            // Help text
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.lightbulb_outline, color: Colors.blue[700]),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Be specific! Clear details help fundis understand your needs.',
                      style: TextStyle(color: Colors.blue[700], fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Step 2: Budget & Timeline
  Widget _buildStep2() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _step2FormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Step Header
            _buildStepHeader(
              '2 of 3',
              'Budget & Timeline',
              'Set your budget and deadline',
            ),

            const SizedBox(height: 32),

            // Budget
            AppInputField(
              label: 'Budget (TZS)',
              hint: '50,000',
              controller: _budgetController,
              keyboardType: TextInputType.number,
              prefixIcon: const Icon(Icons.attach_money),
              isRequired: true,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your budget';
                }
                final budget = double.tryParse(value.trim());
                if (budget == null || budget <= 0) {
                  return 'Enter a valid budget amount';
                }
                return null;
              },
            ),

            const SizedBox(height: 20),

            // Duration
            AppInputField(
              label: 'Expected Duration',
              hint: 'e.g., 2 days, 1 week',
              controller: _durationController,
              prefixIcon: const Icon(Icons.schedule),
              isRequired: true,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter expected duration';
                }
                return null;
              },
            ),

            const SizedBox(height: 20),

            // Deadline
            Text(
              'Deadline *',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.darkGray,
              ),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: _selectDeadline,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: AppTheme.lightGray),
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.white,
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      color: AppTheme.mediumGray,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _selectedDeadline != null
                            ? '${_selectedDeadline!.day}/${_selectedDeadline!.month}/${_selectedDeadline!.year}'
                            : 'Select deadline date',
                        style: TextStyle(
                          color: _selectedDeadline != null
                              ? AppTheme.darkGray
                              : AppTheme.mediumGray,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: AppTheme.mediumGray,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Budget Guide
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.amber[700]),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Competitive budgets get more applications from skilled fundis.',
                      style: TextStyle(color: Colors.amber[900], fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Step 3: Additional Details (Optional)
  Widget _buildStep3() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Step Header
          _buildStepHeader(
            '3 of 3',
            'Additional Details',
            'Help fundis find you (Optional)',
          ),

          const SizedBox(height: 32),

          // Location
          AppInputField(
            label: 'Location (Optional)',
            hint: 'e.g., Dar es Salaam, Kinondoni',
            controller: _locationController,
            prefixIcon: const Icon(Icons.location_on_outlined),
          ),

          const SizedBox(height: 24),

          // Photos
          Text(
            'Photos (Optional)',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.darkGray,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add photos to help fundis understand the job better',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppTheme.mediumGray),
          ),
          const SizedBox(height: 12),

          // Add Photos Button
          GestureDetector(
            onTap: _pickImages,
            child: Container(
              height: 120,
              decoration: BoxDecoration(
                border: Border.all(color: AppTheme.lightGray, width: 2),
                borderRadius: BorderRadius.circular(12),
                color: AppTheme.lightGray.withOpacity(0.3),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_photo_alternate,
                      size: 40,
                      color: AppTheme.mediumGray,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tap to add photos',
                      style: TextStyle(
                        color: AppTheme.mediumGray,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Selected Images
          if (_selectedImages.isNotEmpty) ...[
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(_selectedImages.length, (index) {
                return Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        _selectedImages[index],
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: GestureDetector(
                        onTap: () => _removeImage(index),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }),
            ),
            const SizedBox(height: 16),
          ],

          // Summary
          const SizedBox(height: 24),
          _buildSummaryCard(),
        ],
      ),
    );
  }

  Widget _buildStepHeader(String step, String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          step,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppTheme.primaryGreen,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.darkGray,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: AppTheme.mediumGray),
        ),
      ],
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryGreen.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primaryGreen.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.summarize, color: AppTheme.primaryGreen),
              const SizedBox(width: 8),
              Text(
                'Job Summary',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryGreen,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const Divider(height: 20),
          _buildSummaryRow('Title', _titleController.text),
          _buildSummaryRow(
            'Category',
            _categories.firstWhere((c) => c.id == _selectedCategory).name,
          ),
          _buildSummaryRow(
            'Budget',
            '${_budgetController.text.isNotEmpty ? _budgetController.text : '0'} TZS',
          ),
          _buildSummaryRow('Duration', _durationController.text),
          if (_selectedDeadline != null)
            _buildSummaryRow(
              'Deadline',
              '${_selectedDeadline!.day}/${_selectedDeadline!.month}/${_selectedDeadline!.year}',
            ),
          if (_locationController.text.isNotEmpty)
            _buildSummaryRow('Location', _locationController.text),
          if (_selectedImages.isNotEmpty)
            _buildSummaryRow('Photos', '${_selectedImages.length} attached'),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    if (value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: TextStyle(
                color: AppTheme.mediumGray,
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: AppTheme.darkGray,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.all(24),
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
                icon: Icons.arrow_back,
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 16),
          Expanded(
            flex: _currentStep == 0 ? 1 : 1,
            child: AppButton(
              text: _currentStep == 2 ? 'Post Job' : 'Continue',
              onPressed: _isLoading
                  ? null
                  : (_currentStep == 2 ? _submitJob : _nextStep),
              isLoading: _isLoading && _currentStep == 2,
              icon: _currentStep == 2 ? Icons.check : Icons.arrow_forward,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String categoryName) {
    switch (categoryName.toLowerCase()) {
      case 'plumbing':
        return Icons.plumbing;
      case 'electrical':
        return Icons.electrical_services;
      case 'carpentry':
        return Icons.build;
      case 'painting':
        return Icons.format_paint;
      case 'cleaning':
        return Icons.cleaning_services;
      default:
        return Icons.work;
    }
  }
}
