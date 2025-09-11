import 'package:flutter/material.dart';
import '../services/search_service.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../../shared/widgets/error_widget.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/extensions/string_extensions.dart';
import '../../job/models/job_model.dart';
import '../../portfolio/models/portfolio_model.dart';

/// Search screen for finding jobs and portfolios
/// Provides filtering and search functionality
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  late TabController _tabController;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  bool _isLoading = false;
  String? _errorMessage;
  List<JobModel> _jobs = [];
  List<PortfolioModel> _portfolios = [];
  String _selectedCategory = 'All';
  String _selectedLocation = 'All';
  double _minBudget = 0;
  double _maxBudget = 1000000;

  final List<String> _categories = [
    'All',
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

  final List<String> _locations = [
    'All',
    'Dar es Salaam',
    'Arusha',
    'Mwanza',
    'Dodoma',
    'Tanga',
    'Morogoro',
    'Mbeya',
    'Iringa',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _tabController = TabController(length: 2, vsync: this);
  }

  void _setupAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _fadeController.forward();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _performSearch() async {
    if (_searchController.text.trim().isEmpty) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await SearchService().search(
        query: _searchController.text.trim(),
        category: _selectedCategory == 'All' ? null : _selectedCategory,
        location: _selectedLocation == 'All' ? null : _selectedLocation,
        minBudget: _minBudget,
        maxBudget: _maxBudget,
      );

      if (result.success) {
        setState(() {
          _jobs = result.jobs as List<JobModel>;
          _portfolios = result.portfolios as List<PortfolioModel>;
        });
      } else {
        setState(() {
          _errorMessage = result.message;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Search failed. Please try again.';
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
      appBar: AppBar(
        title: const Text('Search'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Jobs', icon: Icon(Icons.work_outline)),
            Tab(text: 'Portfolios', icon: Icon(Icons.photo_library_outlined)),
          ],
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            // Search Bar and Filters
            _buildSearchSection(),

            // Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [_buildJobsTab(), _buildPortfoliosTab()],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Search Bar
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search jobs and portfolios...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: IconButton(
                onPressed: _performSearch,
                icon: const Icon(Icons.search),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppTheme.mediumGray),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppTheme.mediumGray),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AppTheme.accentGreen,
                  width: 2,
                ),
              ),
            ),
            onSubmitted: (_) => _performSearch(),
          ),

          const SizedBox(height: 16),

          // Filters
          _buildFilters(),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Column(
      children: [
        // Category and Location Row
        Row(
          children: [
            Expanded(
              child: _buildDropdownFilter(
                'Category',
                _selectedCategory,
                _categories,
                (value) => setState(() => _selectedCategory = value!),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildDropdownFilter(
                'Location',
                _selectedLocation,
                _locations,
                (value) => setState(() => _selectedLocation = value!),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Budget Range
        _buildBudgetRange(),

        const SizedBox(height: 16),

        // Search Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _performSearch,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Search'),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownFilter(
    String label,
    String value,
    List<String> items,
    ValueChanged<String?> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.darkGray,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(color: AppTheme.mediumGray),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              items: items.map((item) {
                return DropdownMenuItem(value: item, child: Text(item));
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBudgetRange() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Budget Range (TZS)',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.darkGray,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                decoration: const InputDecoration(
                  labelText: 'Min',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  _minBudget = double.tryParse(value) ?? 0;
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextField(
                decoration: const InputDecoration(
                  labelText: 'Max',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  _maxBudget = double.tryParse(value) ?? 1000000;
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildJobsTab() {
    if (_isLoading) {
      return const Center(
        child: LoadingWidget(message: 'Searching jobs...', size: 50),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: ErrorBanner(
          message: _errorMessage!,
          onDismiss: () {
            setState(() {
              _errorMessage = null;
            });
          },
        ),
      );
    }

    if (_jobs.isEmpty) {
      return _buildEmptyState('No jobs found', Icons.work_outline);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _jobs.length,
      itemBuilder: (context, index) {
        return _buildJobCard(_jobs[index]);
      },
    );
  }

  Widget _buildPortfoliosTab() {
    if (_isLoading) {
      return const Center(
        child: LoadingWidget(message: 'Searching portfolios...', size: 50),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: ErrorBanner(
          message: _errorMessage!,
          onDismiss: () {
            setState(() {
              _errorMessage = null;
            });
          },
        ),
      );
    }

    if (_portfolios.isEmpty) {
      return _buildEmptyState(
        'No portfolios found',
        Icons.photo_library_outlined,
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.8,
      ),
      itemCount: _portfolios.length,
      itemBuilder: (context, index) {
        return _buildPortfolioCard(_portfolios[index]);
      },
    );
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: AppTheme.mediumGray),
          const SizedBox(height: 16),
          Text(
            message,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(color: AppTheme.mediumGray),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search criteria',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppTheme.mediumGray),
          ),
        ],
      ),
    );
  }

  Widget _buildJobCard(JobModel job) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    job.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: job.status.toColor().withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    job.status.displayName,
                    style: TextStyle(
                      color: job.status.toColor(),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              job.description,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppTheme.mediumGray),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.location_on_outlined,
                  size: 16,
                  color: AppTheme.mediumGray,
                ),
                const SizedBox(width: 4),
                Text(
                  job.location ?? 'Location not specified',
                  style: TextStyle(color: AppTheme.mediumGray),
                ),
                const Spacer(),
                Text(
                  job.budget.toString(),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: context.primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPortfolioCard(PortfolioModel portfolio) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: portfolio.images.isNotEmpty
                ? Image.network(
                    portfolio.images.first,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return _buildImagePlaceholder();
                    },
                  )
                : _buildImagePlaceholder(),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    portfolio.title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    portfolio.category,
                    style: TextStyle(
                      color: context.primaryColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 12,
                        color: AppTheme.mediumGray,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          portfolio.location ?? 'No location',
                          style: TextStyle(
                            color: AppTheme.mediumGray,
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      width: double.infinity,
      color: AppTheme.lightGray,
      child: Center(
        child: Icon(Icons.work_outline, size: 32, color: AppTheme.mediumGray),
      ),
    );
  }
}
