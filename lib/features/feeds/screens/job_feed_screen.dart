import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../services/feeds_service.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../../shared/widgets/error_widget.dart';
import '../widgets/job_card.dart';
import '../widgets/job_feed_filters.dart';
import 'job_details_screen.dart';

class JobFeedScreen extends StatefulWidget {
  const JobFeedScreen({Key? key}) : super(key: key);

  @override
  State<JobFeedScreen> createState() => _JobFeedScreenState();
}

class _JobFeedScreenState extends State<JobFeedScreen> {
  final FeedsService _feedsService = FeedsService();
  final ScrollController _scrollController = ScrollController();

  List<dynamic> _jobs = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasMoreData = true;
  int _currentPage = 1;
  String? _error;

  // Filter parameters
  String _searchQuery = '';
  String? _selectedCategory;
  double? _minBudget;
  double? _maxBudget;
  String? _selectedLocation;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadJobs();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      _loadMoreJobs();
    }
  }

  Future<void> _loadJobs({bool refresh = false}) async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _error = null;
      if (refresh) {
        _currentPage = 1;
        _jobs.clear();
        _hasMoreData = true;
      }
    });

    try {
      final result = await _feedsService.getJobs(
        page: _currentPage,
        limit: 15,
        searchQuery: _searchQuery.isNotEmpty ? _searchQuery : null,
        category: _selectedCategory,
        location: _selectedLocation,
        minBudget: _minBudget,
        maxBudget: _maxBudget,
      );

      if (result['success']) {
        final newJobs = result['jobs'] as List<dynamic>;

        setState(() {
          if (refresh) {
            _jobs = newJobs;
          } else {
            _jobs.addAll(newJobs);
          }
          _hasMoreData = newJobs.length == 15;
          _currentPage++;
        });
      } else {
        setState(() {
          _error = result['message'];
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to load jobs: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMoreJobs() async {
    if (_isLoadingMore || !_hasMoreData) return;

    setState(() {
      _isLoadingMore = true;
    });

    await _loadJobs();

    setState(() {
      _isLoadingMore = false;
    });
  }

  Future<void> _refreshFeed() async {
    await _loadJobs(refresh: true);
  }

  void _applyFilters(Map<String, dynamic> filters) {
    setState(() {
      _searchQuery = filters['search'] ?? '';
      _selectedCategory = filters['category'];
      _minBudget = filters['min_budget'];
      _maxBudget = filters['max_budget'];
      _selectedLocation = filters['location'];
    });
    _loadJobs(refresh: true);
  }

  void _navigateToJobDetails(dynamic job) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => JobDetailsScreen(job: job)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Available Jobs'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilters(),
          ),
        ],
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          if (!authProvider.isFundi) {
            return const Center(child: Text('Only fundis can view job feeds'));
          }

          if (_isLoading && _jobs.isEmpty) {
            return const LoadingWidget();
          }

          if (_error != null && _jobs.isEmpty) {
            return AppErrorWidget(
              message: _error!,
              onRetry: () => _loadJobs(refresh: true),
            );
          }

          return RefreshIndicator(
            onRefresh: _refreshFeed,
            child: Column(
              children: [
                if (_searchQuery.isNotEmpty ||
                    _selectedCategory != null ||
                    _minBudget != null ||
                    _maxBudget != null)
                  Container(
                    padding: const EdgeInsets.all(16),
                    child: Wrap(
                      spacing: 8,
                      children: [
                        if (_searchQuery.isNotEmpty)
                          Chip(
                            label: Text('Search: $_searchQuery'),
                            onDeleted: () {
                              setState(() {
                                _searchQuery = '';
                              });
                              _loadJobs(refresh: true);
                            },
                          ),
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
                        if (_minBudget != null || _maxBudget != null)
                          Chip(
                            label: Text(
                              'Budget: ${_minBudget != null ? '${_minBudget!.toStringAsFixed(0)}+' : ''}${_maxBudget != null ? '${_maxBudget!.toStringAsFixed(0)}-' : ''}',
                            ),
                            onDeleted: () {
                              setState(() {
                                _minBudget = null;
                                _maxBudget = null;
                              });
                              _loadJobs(refresh: true);
                            },
                          ),
                      ],
                    ),
                  ),
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _jobs.length + (_isLoadingMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == _jobs.length) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }

                      final job = _jobs[index];
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
        },
      ),
    );
  }

  void _showFilters() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => JobFeedFilters(
        currentFilters: {
          'search': _searchQuery,
          'category': _selectedCategory,
          'min_budget': _minBudget,
          'max_budget': _maxBudget,
          'location': _selectedLocation,
        },
        onApplyFilters: _applyFilters,
      ),
    );
  }
}
