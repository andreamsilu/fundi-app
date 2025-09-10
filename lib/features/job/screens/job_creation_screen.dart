import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../models/job_urgency.dart';
import '../services/job_service.dart';
import '../../../shared/widgets/input_widget.dart';
import '../../../shared/widgets/button_widget.dart';
import '../../../shared/widgets/error_widget.dart';
import '../../../core/theme/app_theme.dart';

/// Job creation screen for posting new jobs
/// Allows customers to create detailed job postings with images
class JobCreationScreen extends StatefulWidget {
  const JobCreationScreen({super.key});

  @override
  State<JobCreationScreen> createState() => _JobCreationScreenState();
}

class _JobCreationScreenState extends State<JobCreationScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _budgetController = TextEditingController();
  final _locationController = TextEditingController();
  final _durationController = TextEditingController();

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;
  String _selectedCategory = 'Other';
  List<File> _selectedImages = [];
  final ImagePicker _imagePicker = ImagePicker();

  final List<String> _categories = [
    'Plumbing',
    'Electrical',
    'Carpentry',
    'Painting',
    'Cleaning',
    'Gardening',
    'Repair',
    'Installation',
    'Other',
  ];

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
    _titleController.dispose();
    _descriptionController.dispose();
    _budgetController.dispose();
    _locationController.dispose();
    _durationController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  Future<void> _handleCreateJob() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final result = await JobService().createJob(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        category: _selectedCategory,
        budget: double.tryParse(_budgetController.text.trim()) ?? 0.0,
        budgetType: 'fixed',
        location: _locationController.text.trim(),
        deadline: DateTime.now().add(Duration(days: 30)),
        requiredSkills: [],
        imageUrls: _selectedImages as List<String>,
      );

      if (result.success) {
        setState(() {
          _successMessage = 'Job posted successfully!';
        });

        // Navigate back after a short delay
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            Navigator.pop(context, true);
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
      setState(() {
        _errorMessage = 'Failed to pick images. Please try again.';
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Post a Job'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _handleCreateJob,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Post'),
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

                  // Job Title
                  AppInputField(
                    label: 'Job Title',
                    hint: 'e.g., Fix leaking kitchen faucet',
                    controller: _titleController,
                    isRequired: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Job title is required';
                      }
                      if (value.length < 5) {
                        return 'Title must be at least 5 characters';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // Category Selection
                  _buildCategorySelector(),

                  const SizedBox(height: 16),

                  // Description
                  AppInputField(
                    label: 'Job Description',
                    hint: 'Describe the job in detail...',
                    controller: _descriptionController,
                    maxLines: 4,
                    isRequired: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Job description is required';
                      }
                      if (value.length < 20) {
                        return 'Description must be at least 20 characters';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // Budget and Duration Row
                  Row(
                    children: [
                      Expanded(
                        child: AppInputField(
                          label: 'Budget (TZS)',
                          hint: '0',
                          controller: _budgetController,
                          keyboardType: TextInputType.number,
                          prefixIcon: const Icon(Icons.attach_money),
                          validator: (value) {
                            if (value != null && value.isNotEmpty) {
                              final budget = double.tryParse(value);
                              if (budget == null || budget < 0) {
                                return 'Enter a valid budget';
                              }
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: AppInputField(
                          label: 'Duration',
                          hint: 'e.g., 2 days',
                          controller: _durationController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Duration is required';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Location
                  AppInputField(
                    label: 'Location',
                    hint: 'e.g., Dar es Salaam, Kinondoni',
                    controller: _locationController,
                    isRequired: true,
                    prefixIcon: const Icon(Icons.location_on_outlined),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Location is required';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // Urgency Selection
                  // _buildUrgencySelector(),

                  const SizedBox(height: 24),

                  // Images Section
                  _buildImagesSection(),

                  const SizedBox(height: 32),

                  // Create Job Button
                  AppButton(
                    text: 'Post Job',
                    onPressed: _isLoading ? null : _handleCreateJob,
                    isLoading: _isLoading,
                    isFullWidth: true,
                    size: ButtonSize.large,
                    icon: Icons.post_add,
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

  Widget _buildCategorySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Category',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.darkGray,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(color: AppTheme.mediumGray),
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedCategory,
              isExpanded: true,
              items: _categories.map((category) {
                return DropdownMenuItem(value: category, child: Text(category));
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedCategory = value;
                  });
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUrgencySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Urgency',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.darkGray,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: JobUrgency.values.map((urgency) {
            final isSelected = false;
            return Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    false;
                  });
                },
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? context.primaryColor.withValues(alpha: 0.1)
                        : AppTheme.lightGray,
                    border: Border.all(
                      color: isSelected
                          ? context.primaryColor
                          : AppTheme.mediumGray,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.timer,
                        color: isSelected
                            ? context.primaryColor
                            : AppTheme.mediumGray,
                        size: 20,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '2 days',
                        style: TextStyle(
                          color: isSelected
                              ? context.primaryColor
                              : AppTheme.mediumGray,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildImagesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Photos (Optional)',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.darkGray,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Add photos to help fundis understand your job better',
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: AppTheme.mediumGray),
        ),
        const SizedBox(height: 12),

        // Add Image Button
        GestureDetector(
          onTap: _pickImages,
          child: Container(
            height: 60,
            decoration: BoxDecoration(
              border: Border.all(
                color: AppTheme.mediumGray,
                style: BorderStyle.solid,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_photo_alternate, color: AppTheme.mediumGray),
                const SizedBox(width: 8),
                Text(
                  'Add Photos',
                  style: TextStyle(
                    color: AppTheme.mediumGray,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Selected Images
        if (_selectedImages.isNotEmpty) ...[
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _selectedImages.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.only(right: 8),
                  child: Stack(
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
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }
}
