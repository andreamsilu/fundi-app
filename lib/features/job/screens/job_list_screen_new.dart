import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/job_model.dart';
import '../providers/job_provider.dart';
import '../../dashboard/services/dashboard_service.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../../shared/widgets/error_widget.dart';
import '../../../shared/widgets/button_widget.dart';
import '../../../shared/widgets/input_widget.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/hardcoded_data.dart';
import '../widgets/job_card.dart';

/// Screen displaying a list of available jobs using JobProvider
/// Features search, filtering, and pagination with proper state management
class JobListScreenNew extends StatefulWidget {
  final String? title;
  final bool showFilterButton;
  final bool showAppBar;

  const JobListScreenNew({
    super.key,
    this.title,
    this.showFilterButton = true,
    this.showAppBar = true,
  });

  @override
  State<JobListScreenNew> createState() => _JobListScreenNewState();
}

class _JobListScreenNewState extends State<JobListScreenNew>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  List<JobCategory> _categories = [];

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _scrollController.addListener(_onScroll);
    _loadCategories();
    _loadJobs();
    _fadeController.forward();
  }

  void _setupAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
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
      context.read<JobProvider>().loadMoreJobs();
    }
  }

  Future<void> _loadJobs() async {
    try {
      final jobProvider = Provider.of<JobProvider>(context, listen: false);
      await jobProvider.loadJobs(refresh: true);
    } catch (e) {
      print('JobProvider not available: $e');
    }
  }

  Future<void> _loadCategories() async {
    try {
      final dashboardService = DashboardService();
      final result = await dashboardService.getJobCategories();
      if (mounted) {
        setState(() {
          _categories = result.categories ?? [];
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _categories = HardcodedData.jobCategories
              .map((cat) => JobCategory(id: cat['id']!, name: cat['name']!))
              .toList();
        });
      }
    }
  }

  Future<void> _refreshJobs() async {
    final jobProvider = context.read<JobProvider>();
    await jobProvider.loadJobs(refresh: true);
  }

  void _searchJobs(String query) {
    final jobProvider = context.read<JobProvider>();
    jobProvider.loadJobs(refresh: true, search: query.isEmpty ? null : query);
  }

  void _filterByCategory(String? category) {
    final jobProvider = context.read<JobProvider>();
    jobProvider.loadJobs(refresh: true, category: category);
  }

  void _filterByLocation(String? location) {
    final jobProvider = context.read<JobProvider>();
    jobProvider.loadJobs(refresh: true, location: location);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.showAppBar
          ? AppBar(
              title: Text(widget.title ?? 'Jobs'),
              backgroundColor: Colors.transparent,
              elevation: 0,
              actions: widget.showFilterButton
                  ? [
                      IconButton(
                        icon: const Icon(Icons.filter_list),
                        onPressed: _showFilterDialog,
                      ),
                    ]
                  : null,
            )
          : null,
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    // Try to get the existing provider, if not available create a new one
    try {
      Provider.of<JobProvider>(context, listen: false);
      return Consumer<JobProvider>(
        builder: (context, jobProvider, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: _buildJobList(jobProvider),
          );
        },
      );
    } catch (e) {
      // Provider not available, create a new one
      return ChangeNotifierProvider(
        create: (_) => JobProvider()..loadJobs(),
        child: Consumer<JobProvider>(
          builder: (context, jobProvider, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: _buildJobList(jobProvider),
            );
          },
        ),
      );
    }
  }

  Widget _buildJobList(JobProvider jobProvider) {
    if (jobProvider.isLoading && jobProvider.jobs.isEmpty) {
      return const Center(
        child: LoadingWidget(message: 'Loading jobs...', size: 50),
      );
    }

    if (jobProvider.errorMessage != null && jobProvider.jobs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppErrorWidget(
              message: jobProvider.errorMessage!,
              onRetry: _refreshJobs,
            ),
          ],
        ),
      );
    }

    if (jobProvider.jobs.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _refreshJobs,
      child: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount:
                  jobProvider.jobs.length + (jobProvider.isLoadingMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == jobProvider.jobs.length) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                final job = jobProvider.jobs[index];
                return JobCard(
                  job: job,
                  onTap: () => _navigateToJobDetails(job),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: AppInputField(
        controller: _searchController,
        hint: 'Search jobs...',
        prefixIcon: const Icon(Icons.search),
        onChanged: _searchJobs,
        suffixIcon: _searchController.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _searchController.clear();
                  _searchJobs('');
                },
              )
            : null,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.work_outline, size: 64, color: AppTheme.mediumGray),
          const SizedBox(height: 16),
          Text(
            'No Jobs Available',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(color: AppTheme.mediumGray),
          ),
          const SizedBox(height: 8),
          Text(
            'Check back later for new job postings',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppTheme.mediumGray),
          ),
          const SizedBox(height: 24),
          AppButton(
            text: 'Refresh',
            onPressed: _refreshJobs,
            type: ButtonType.secondary,
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _buildFilterSheet(),
    );
  }

  Widget _buildFilterSheet() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Filter Jobs', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 24),
          Text('Category', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: null,
            decoration: const InputDecoration(
              hintText: 'Select category',
              border: OutlineInputBorder(),
            ),
            items: _categories.map((category) {
              return DropdownMenuItem(
                value: category.id,
                child: Text(category.name),
              );
            }).toList(),
            onChanged: _filterByCategory,
          ),
          const SizedBox(height: 16),
          Text('Location', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: null,
            decoration: const InputDecoration(
              hintText: 'Select location',
              border: OutlineInputBorder(),
            ),
            items: HardcodedData.tanzaniaLocations.map((location) {
              return DropdownMenuItem(value: location, child: Text(location));
            }).toList(),
            onChanged: _filterByLocation,
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: AppButton(
                  text: 'Clear Filters',
                  onPressed: () {
                    Navigator.pop(context);
                    _searchJobs('');
                  },
                  type: ButtonType.secondary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: AppButton(
                  text: 'Apply Filters',
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _navigateToJobDetails(JobModel job) {
    // Navigation logic here
    print('Navigate to job details: ${job.id}');
  }
}
