import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/job_model.dart';
import '../services/job_service.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../../shared/widgets/error_widget.dart';
import '../../../shared/widgets/button_widget.dart';
import '../../../shared/widgets/input_widget.dart';
import '../../../core/theme/app_theme.dart';
import '../widgets/job_card.dart';

/// Screen displaying a list of available jobs
/// Features search, filtering, and pagination
class JobListScreen extends StatefulWidget {
  const JobListScreen({super.key});

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
        search:
            _searchController.text.isNotEmpty ? _searchController.text : null,
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
        search:
            _searchController.text.isNotEmpty ? _searchController.text : null,
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

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => _FilterBottomSheet(
            selectedCategory: _selectedCategory,
            selectedLocation: _selectedLocation,
            onApply: (category, location) {
              setState(() {
                _selectedCategory = category;
                _selectedLocation = location;
              });
              _loadJobs(refresh: true);
            },
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Available Jobs'),
        actions: [
          IconButton(
            onPressed: _showFilterDialog,
            icon: const Icon(Icons.filter_list),
            tooltip: 'Filter Jobs',
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
      floatingActionButton: AppFloatingActionButton(
        onPressed: () {
          // Navigate to create job screen
          Navigator.pushNamed(context, '/create-job');
        },
        icon: Icons.add,
        tooltip: 'Post a Job',
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
            child: JobCard(
              job: job,
              onTap: () {
                Navigator.pushNamed(context, '/job-details', arguments: job);
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
    _category = widget.selectedCategory;
    _location = widget.selectedLocation;
    _locationController.text = _location ?? '';
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
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children:
                      _categories.map((category) {
                        final isSelected = _category == category;
                        return FilterChip(
                          label: Text(category),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              _category = selected ? category : null;
                            });
                          },
                        );
                      }).toList(),
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



