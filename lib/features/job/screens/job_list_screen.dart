import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/job_model.dart';
import '../services/job_service.dart';
import '../../dashboard/services/dashboard_service.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../../shared/widgets/error_widget.dart';
import '../../../shared/widgets/button_widget.dart';
import '../../../shared/widgets/input_widget.dart';
import '../../../core/theme/app_theme.dart';
import '../widgets/job_card.dart';

/// Screen displaying a list of available jobs
/// Features search, filtering, and pagination
class JobListScreen extends StatefulWidget {
  final String? title;
  final bool showFilterButton;

  const JobListScreen({super.key, this.title, this.showFilterButton = true});

  @override
  State<JobListScreen> createState() => _JobListScreenState();
}

class _JobListScreenState extends State<JobListScreen>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  List<JobModel> _jobs = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _errorMessage;
  int _currentPage = 1;
  int _totalPages = 1;
  String? _selectedCategory;
  String? _selectedLocation;
  List<JobCategory> _categories = [];
  bool _isLoadingCategories = true;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _scrollController.addListener(_onScroll);
    _loadJobs();
    _loadCategories();
    _fadeController.forward();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreJobs();
    }
  }

  Future<void> _loadJobs({bool refresh = false}) async {
    if (refresh) {
      setState(() {
        _currentPage = 1;
        _jobs.clear();
        _errorMessage = null;
      });
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await JobService().getJobs(
        page: _currentPage,
        category: _selectedCategory,
        location: _selectedLocation,
        search: _searchController.text.isNotEmpty
            ? _searchController.text
            : null,
      );

      if (result.success) {
        setState(() {
          if (refresh) {
            _jobs = result.jobs;
          } else {
            _jobs.addAll(result.jobs);
          }
          _totalPages = result.totalPages;
          _errorMessage = null;
        });
      } else {
        setState(() {
          _errorMessage = result.message;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load jobs. Please try again.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMoreJobs() async {
    if (_isLoadingMore || _currentPage >= _totalPages) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      _currentPage++;
      final result = await JobService().getJobs(
        page: _currentPage,
        category: _selectedCategory,
        location: _selectedLocation,
        search: _searchController.text.isNotEmpty
            ? _searchController.text
            : null,
      );

      if (result.success) {
        setState(() {
          _jobs.addAll(result.jobs);
        });
      }
    } catch (e) {
      _currentPage--; // Revert page increment on error
    } finally {
      setState(() {
        _isLoadingMore = false;
      });
    }
  }

  void _onSearchChanged(String value) {
    // Debounce search
    Future.delayed(const Duration(milliseconds: 500), () {
      if (_searchController.text == value) {
        _loadJobs(refresh: true);
      }
    });
  }

  Future<void> _loadCategories() async {
    // Use hardcoded categories for now to ensure they always load
    if (mounted) {
      setState(() {
        _categories = [
          const JobCategory(id: 'plumbing', name: 'Plumbing'),
          const JobCategory(id: 'electrical', name: 'Electrical'),
          const JobCategory(id: 'carpentry', name: 'Carpentry'),
          const JobCategory(id: 'painting', name: 'Painting'),
          const JobCategory(id: 'cleaning', name: 'Cleaning'),
          const JobCategory(id: 'gardening', name: 'Gardening'),
          const JobCategory(id: 'repair', name: 'Repair'),
          const JobCategory(id: 'installation', name: 'Installation'),
          const JobCategory(id: 'other', name: 'Other'),
        ];
        _isLoadingCategories = false;
        print('Loaded hardcoded categories: ${_categories.length}');
      });
    }

    // Try to load from API in background
    try {
      final result = await DashboardService().getJobCategories();
      if (mounted &&
          result.success &&
          result.categories != null &&
          result.categories!.isNotEmpty) {
        setState(() {
          _categories = result.categories!;
          print('Updated with API categories: ${_categories.length}');
        });
      }
    } catch (e) {
      print('API categories failed, using hardcoded: $e');
    }
  }

  Future<bool> _hasUserAppliedForJob(String jobId, String userId) async {
    try {
      final result = await JobService().getJobApplications(jobId);
      if (result.success) {
        return result.applications.any(
          (application) => application.fundiId == userId,
        );
      }
      return false;
    } catch (e) {
      // If we can't check, assume they haven't applied to avoid blocking them
      return false;
    }
  }

  void _showLocationFilterDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _LocationFilterBottomSheet(
        selectedLocation: _selectedLocation,
        onApply: (location) {
          setState(() {
            _selectedLocation = location;
          });
          _loadJobs(refresh: true);
        },
      ),
    );
  }

  Future<void> _applyForJob(JobModel job) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (!authProvider.isFundi) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Only fundis can apply for jobs'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Check if user has already applied for this job
    if (await _hasUserAppliedForJob(job.id, authProvider.user!.id)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('You have already applied for this job'),
          backgroundColor: Colors.orange,
          action: SnackBarAction(
            label: 'View Application',
            textColor: Colors.white,
            onPressed: () {
              // TODO: Navigate to application details
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            },
          ),
        ),
      );
      return;
    }

    // Show application dialog
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => _JobApplicationDialog(job: job),
    );

    if (result != null) {
      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      try {
        final applicationResult = await JobService().applyForJob(
          authProvider.user!.id,
          jobId: job.id,
          message: result['message'],
          proposedBudget: result['proposedBudget'],
          proposedBudgetType: result['proposedBudgetType'],
          estimatedDays: result['estimatedDays'],
        );

        // Close loading dialog
        Navigator.of(context).pop();

        if (applicationResult.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Application submitted successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          // Handle specific error messages from the API
          String errorMessage = applicationResult.message;
          Color backgroundColor = Colors.red;

          if (applicationResult.message.contains('already applied')) {
            errorMessage = 'You have already applied for this job.';
            backgroundColor = Colors.orange;
          } else if (applicationResult.message.contains('400')) {
            errorMessage =
                'Unable to apply for this job. Please try again later.';
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: backgroundColor,
              action: SnackBarAction(
                label: 'Dismiss',
                textColor: Colors.white,
                onPressed: () {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                },
              ),
            ),
          );
        }
      } catch (e) {
        // Close loading dialog
        Navigator.of(context).pop();

        String errorMessage = 'Failed to submit application. Please try again.';

        // Handle specific error cases
        if (e.toString().contains('You have already applied for this job')) {
          errorMessage = 'You have already applied for this job.';
        } else if (e.toString().contains('400')) {
          errorMessage =
              'Unable to apply for this job. Please try again later.';
        } else if (e.toString().contains('network') ||
            e.toString().contains('connection')) {
          errorMessage =
              'Network error. Please check your connection and try again.';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'Dismiss',
              textColor: Colors.white,
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
              },
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? 'Available Jobs'),
        actions: [
          IconButton(
            onPressed: _showLocationFilterDialog,
            icon: const Icon(Icons.location_on_outlined),
            tooltip: 'Filter by Location',
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            // Search bar
            Padding(
              padding: const EdgeInsets.all(16),
              child: SearchInputField(
                hint: 'Search jobs...',
                controller: _searchController,
                onChanged: _onSearchChanged,
              ),
            ),

            // Category filter - More prominent display
            Container(
              color: AppTheme.lightGray.withValues(alpha: 0.1),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category header
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                    child: Row(
                      children: [
                        Icon(
                          Icons.category_outlined,
                          size: 18,
                          color: AppTheme.mediumGray,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Categories',
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(
                                color: AppTheme.mediumGray,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        const Spacer(),
                        if (_selectedCategory != null)
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _selectedCategory = null;
                              });
                              _loadJobs(refresh: true);
                            },
                            child: const Text('Clear'),
                          ),
                      ],
                    ),
                  ),

                  // Category chips
                  if (!_isLoadingCategories && _categories.isNotEmpty)
                    Container(
                      height: 50,
                      padding: const EdgeInsets.only(bottom: 12),
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount:
                            _categories.length + 1, // +1 for "All" option
                        itemBuilder: (context, index) {
                          if (index == 0) {
                            // "All" option
                            final isSelected = _selectedCategory == null;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: FilterChip(
                                label: const Text('All'),
                                selected: isSelected,
                                selectedColor: AppTheme.accentGreen.withValues(
                                  alpha: 0.2,
                                ),
                                checkmarkColor: AppTheme.accentGreen,
                                onSelected: (selected) {
                                  setState(() {
                                    _selectedCategory = null;
                                  });
                                  _loadJobs(refresh: true);
                                },
                              ),
                            );
                          }

                          final category = _categories[index - 1];
                          final isSelected = _selectedCategory == category.id;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: FilterChip(
                              label: Text(category.name),
                              selected: isSelected,
                              selectedColor: AppTheme.accentGreen.withValues(
                                alpha: 0.2,
                              ),
                              checkmarkColor: AppTheme.accentGreen,
                              onSelected: (selected) {
                                setState(() {
                                  _selectedCategory = selected
                                      ? category.id
                                      : null;
                                });
                                _loadJobs(refresh: true);
                              },
                            ),
                          );
                        },
                      ),
                    ),

                  // Loading state
                  if (_isLoadingCategories)
                    Container(
                      height: 50,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: const Center(child: LoadingWidget(size: 20)),
                    ),
                ],
              ),
            ),

            // Filter chips
            if (_selectedCategory != null || _selectedLocation != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Wrap(
                  spacing: 8,
                  children: [
                    if (_selectedCategory != null)
                      Chip(
                        label: Text('Category: $_selectedCategory'),
                        onDeleted: () {
                          setState(() {
                            _selectedCategory = null;
                          });
                          _loadJobs(refresh: true);
                        },
                      ),
                    if (_selectedLocation != null)
                      Chip(
                        label: Text('Location: $_selectedLocation'),
                        onDeleted: () {
                          setState(() {
                            _selectedLocation = null;
                          });
                          _loadJobs(refresh: true);
                        },
                      ),
                  ],
                ),
              ),

            // Content
            Expanded(child: _buildContent()),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading && _jobs.isEmpty) {
      return const LoadingWidget(message: 'Loading jobs...');
    }

    if (_errorMessage != null && _jobs.isEmpty) {
      return AppErrorWidget(
        message: _errorMessage!,
        onRetry: () => _loadJobs(refresh: true),
      );
    }

    if (_jobs.isEmpty) {
      return EmptyStateWidget(
        title: 'No Jobs Found',
        message:
            'There are no jobs available at the moment. Check back later or post a new job.',
        icon: Icons.work_outline,
        actionText: 'Post a Job',
        onAction: () {
          Navigator.pushNamed(context, '/create-job');
        },
      );
    }

    return RefreshIndicator(
      onRefresh: () => _loadJobs(refresh: true),
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: _jobs.length + (_isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _jobs.length) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: LoadingWidget(size: 24)),
            );
          }

          final job = _jobs[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Consumer<AuthProvider>(
              builder: (context, authProvider, child) {
                final shouldShowApplyButton =
                    authProvider.isFundi && job.status.toLowerCase() == 'open';

                return JobCard(
                  job: job,
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/job-details',
                      arguments: job,
                    );
                  },
                  onApply: shouldShowApplyButton
                      ? () => _applyForJob(job)
                      : null,
                  showApplyButton: shouldShowApplyButton,
                );
              },
            ),
          );
        },
      ),
    );
  }
}

/// Filter bottom sheet for job filtering
class _FilterBottomSheet extends StatefulWidget {
  final String? selectedCategory;
  final String? selectedLocation;
  final Function(String?, String?) onApply;

  const _FilterBottomSheet({
    required this.selectedCategory,
    required this.selectedLocation,
    required this.onApply,
  });

  @override
  State<_FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<_FilterBottomSheet> {
  String? _category;
  String? _location;
  final TextEditingController _locationController = TextEditingController();

  List<JobCategory> _categories = [];
  bool _isLoadingCategories = true;

  @override
  void initState() {
    super.initState();
    _category = widget.selectedCategory;
    _location = widget.selectedLocation;
    _locationController.text = _location ?? '';
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final result = await DashboardService().getJobCategories();
      if (mounted) {
        setState(() {
          if (result.success && result.categories != null) {
            _categories = result.categories!;
          } else {
            // Fallback to hardcoded categories if API fails
            _categories = [
              const JobCategory(id: 'plumbing', name: 'Plumbing'),
              const JobCategory(id: 'electrical', name: 'Electrical'),
              const JobCategory(id: 'carpentry', name: 'Carpentry'),
              const JobCategory(id: 'painting', name: 'Painting'),
              const JobCategory(id: 'cleaning', name: 'Cleaning'),
              const JobCategory(id: 'gardening', name: 'Gardening'),
              const JobCategory(id: 'repair', name: 'Repair'),
              const JobCategory(id: 'installation', name: 'Installation'),
              const JobCategory(id: 'other', name: 'Other'),
            ];
          }
          _isLoadingCategories = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          // Fallback to hardcoded categories
          _categories = [
            const JobCategory(id: 'plumbing', name: 'Plumbing'),
            const JobCategory(id: 'electrical', name: 'Electrical'),
            const JobCategory(id: 'carpentry', name: 'Carpentry'),
            const JobCategory(id: 'painting', name: 'Painting'),
            const JobCategory(id: 'cleaning', name: 'Cleaning'),
            const JobCategory(id: 'gardening', name: 'Gardening'),
            const JobCategory(id: 'repair', name: 'Repair'),
            const JobCategory(id: 'installation', name: 'Installation'),
            const JobCategory(id: 'other', name: 'Other'),
          ];
          _isLoadingCategories = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: AppTheme.mediumGray,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Text(
                  'Filter Jobs',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _category = null;
                      _location = null;
                      _locationController.clear();
                    });
                  },
                  child: const Text('Clear All'),
                ),
              ],
            ),
          ),

          const Divider(),

          // Category selection
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Category',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                _isLoadingCategories
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: LoadingWidget(size: 24),
                        ),
                      )
                    : SizedBox(
                        height: 40,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _categories.length,
                          itemBuilder: (context, index) {
                            final category = _categories[index];
                            final isSelected = _category == category.id;
                            return Padding(
                              padding: EdgeInsets.only(
                                right: index < _categories.length - 1 ? 8 : 0,
                              ),
                              child: FilterChip(
                                label: Text(category.name),
                                selected: isSelected,
                                onSelected: (selected) {
                                  setState(() {
                                    _category = selected ? category.id : null;
                                  });
                                },
                              ),
                            );
                          },
                        ),
                      ),
              ],
            ),
          ),

          // Location input
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: AppInputField(
              label: 'Location',
              hint: 'Enter location',
              controller: _locationController,
              onChanged: (value) {
                _location = value.isNotEmpty ? value : null;
              },
              prefixIcon: const Icon(Icons.location_on_outlined),
            ),
          ),

          const SizedBox(height: 20),

          // Apply button
          Padding(
            padding: const EdgeInsets.all(20),
            child: AppButton(
              text: 'Apply Filters',
              onPressed: () {
                widget.onApply(_category, _location);
                Navigator.pop(context);
              },
              isFullWidth: true,
            ),
          ),
        ],
      ),
    );
  }
}

/// Job application dialog for fundis to apply for jobs
class _JobApplicationDialog extends StatefulWidget {
  final JobModel job;

  const _JobApplicationDialog({required this.job});

  @override
  State<_JobApplicationDialog> createState() => _JobApplicationDialogState();
}

class _JobApplicationDialogState extends State<_JobApplicationDialog> {
  final _formKey = GlobalKey<FormState>();
  final _messageController = TextEditingController();
  final _proposedBudgetController = TextEditingController();
  final _estimatedDaysController = TextEditingController();

  String _proposedBudgetType = 'fixed';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Pre-fill with job budget as starting point
    _proposedBudgetController.text = widget.job.budget.toString();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _proposedBudgetController.dispose();
    _estimatedDaysController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Apply for ${widget.job.title}'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Job details
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.lightGray.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Job Budget: ${widget.job.formattedBudget}',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Category: ${widget.job.category ?? 'General'}',
                      style: TextStyle(color: AppTheme.mediumGray),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Application message
              AppInputField(
                label: 'Application Message',
                hint:
                    'Tell the customer why you\'re the best fit for this job...',
                controller: _messageController,
                isRequired: true,
                maxLines: 4,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your application message';
                  }
                  if (value.trim().length < 20) {
                    return 'Message must be at least 20 characters';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Proposed budget
              AppInputField(
                label: 'Your Proposed Budget',
                hint: 'Enter your proposed budget',
                controller: _proposedBudgetController,
                isRequired: true,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your proposed budget';
                  }
                  final budget = double.tryParse(value.trim());
                  if (budget == null || budget <= 0) {
                    return 'Please enter a valid budget amount';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Budget type
              DropdownButtonFormField<String>(
                value: _proposedBudgetType,
                decoration: const InputDecoration(
                  labelText: 'Budget Type',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'fixed', child: Text('Fixed Price')),
                  DropdownMenuItem(value: 'hourly', child: Text('Hourly Rate')),
                ],
                onChanged: (value) {
                  setState(() {
                    _proposedBudgetType = value!;
                  });
                },
              ),

              const SizedBox(height: 16),

              // Estimated days
              AppInputField(
                label: 'Estimated Days to Complete',
                hint: 'How many days do you need?',
                controller: _estimatedDaysController,
                isRequired: true,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter estimated days';
                  }
                  final days = int.tryParse(value.trim());
                  if (days == null || days <= 0) {
                    return 'Please enter a valid number of days';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        AppButton(
          text: _isLoading ? 'Submitting...' : 'Submit Application',
          onPressed: _isLoading ? null : _submitApplication,
          type: ButtonType.primary,
        ),
      ],
    );
  }

  Future<void> _submitApplication() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final result = {
        'message': _messageController.text.trim(),
        'proposedBudget': double.parse(_proposedBudgetController.text.trim()),
        'proposedBudgetType': _proposedBudgetType,
        'estimatedDays': int.parse(_estimatedDaysController.text.trim()),
      };

      Navigator.of(context).pop(result);
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please check your input and try again'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

/// Simple location filter bottom sheet
class _LocationFilterBottomSheet extends StatefulWidget {
  final String? selectedLocation;
  final Function(String?) onApply;

  const _LocationFilterBottomSheet({
    required this.selectedLocation,
    required this.onApply,
  });

  @override
  State<_LocationFilterBottomSheet> createState() =>
      _LocationFilterBottomSheetState();
}

class _LocationFilterBottomSheetState
    extends State<_LocationFilterBottomSheet> {
  final TextEditingController _locationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _locationController.text = widget.selectedLocation ?? '';
  }

  @override
  void dispose() {
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: AppTheme.mediumGray,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Text(
                  'Filter by Location',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _locationController.clear();
                    });
                  },
                  child: const Text('Clear'),
                ),
              ],
            ),
          ),

          const Divider(),

          // Location input
          Padding(
            padding: const EdgeInsets.all(20),
            child: AppInputField(
              label: 'Location',
              hint: 'Enter city, district, or area',
              controller: _locationController,
              prefixIcon: const Icon(Icons.location_on_outlined),
            ),
          ),

          const SizedBox(height: 20),

          // Apply button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: AppButton(
              text: 'Apply Location Filter',
              onPressed: () {
                final location = _locationController.text.trim().isNotEmpty
                    ? _locationController.text.trim()
                    : null;
                widget.onApply(location);
                Navigator.pop(context);
              },
              isFullWidth: true,
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
