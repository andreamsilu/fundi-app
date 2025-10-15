import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../job/widgets/job_card.dart';
import '../../feeds/widgets/fundi_card.dart';
import '../services/search_service.dart';
import '../../job/models/job_model.dart';
import '../../feeds/models/fundi_model.dart';

/// Unified Search Screen - Single search box for everything
/// Auto-detects search intent (Jobs vs Fundis)
/// Shows recent searches and suggestions
class SearchUnifiedScreen extends StatefulWidget {
  const SearchUnifiedScreen({super.key});

  @override
  State<SearchUnifiedScreen> createState() => _SearchUnifiedScreenState();
}

class _SearchUnifiedScreenState extends State<SearchUnifiedScreen> {
  final _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  final SearchService _searchService = SearchService();

  bool _isSearching = false;
  List<String> _recentSearches = [];
  String _searchType = 'all'; // 'all', 'jobs', 'fundis'

  List<JobModel> _jobResults = [];
  List<FundiModel> _fundiResults = [];

  @override
  void initState() {
    super.initState();
    _loadRecentSearches();
    _searchFocus.requestFocus();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  Future<void> _loadRecentSearches() async {
    final searches = await _searchService.getRecentSearches();
    if (mounted) {
      setState(() {
        _recentSearches = searches;
      });
    }
  }

  Future<void> _search(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _jobResults = [];
        _fundiResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() => _isSearching = true);

    try {
      // Auto-detect search type
      _autoDetectSearchType(query);

      // Search based on type
      if (_searchType == 'jobs') {
        final result = await _searchService.searchJobs(query: query);
        if (mounted) {
          setState(() {
            _jobResults = result.results;
            _fundiResults = [];
            _isSearching = false;
          });
        }
      } else if (_searchType == 'fundis') {
        final result = await _searchService.searchFundis(query: query);
        if (mounted) {
          setState(() {
            _fundiResults = result.results;
            _jobResults = [];
            _isSearching = false;
          });
        }
      } else {
        // Search both
        final jobsResultFuture = _searchService.searchJobs(query: query);
        final fundisResultFuture = _searchService.searchFundis(query: query);

        final jobsResult = await jobsResultFuture;
        final fundisResult = await fundisResultFuture;

        if (mounted) {
          setState(() {
            _jobResults = jobsResult.results;
            _fundiResults = fundisResult.results;
            _isSearching = false;
          });
        }
      }

      // Save to recent searches
      await _searchService.saveRecentSearch(query);
      await _loadRecentSearches();
    } catch (e) {
      if (mounted) {
        setState(() => _isSearching = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Search failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _autoDetectSearchType(String query) {
    final lowerQuery = query.toLowerCase();

    // Job keywords
    if (lowerQuery.contains('job') ||
        lowerQuery.contains('work') ||
        lowerQuery.contains('urgent') ||
        lowerQuery.contains('hiring')) {
      _searchType = 'jobs';
    }
    // Fundi keywords
    else if (lowerQuery.contains('fundi') ||
        lowerQuery.contains('plumber') ||
        lowerQuery.contains('carpenter') ||
        lowerQuery.contains('electrician') ||
        lowerQuery.contains('mason')) {
      _searchType = 'fundis';
    }
    // Default to all
    else {
      _searchType = 'all';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _buildSearchBar(),
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      focusNode: _searchFocus,
      decoration: InputDecoration(
        hintText: 'Search for jobs, fundis, or services...',
        hintStyle: const TextStyle(color: Colors.white70),
        border: InputBorder.none,
        suffixIcon: _searchController.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear, color: Colors.white),
                onPressed: () {
                  _searchController.clear();
                  setState(() {
                    _jobResults = [];
                    _fundiResults = [];
                  });
                },
              )
            : const Icon(Icons.search, color: Colors.white70),
      ),
      style: const TextStyle(color: Colors.white),
      onSubmitted: _search,
      onChanged: (value) {
        // Live search with debounce
        Future.delayed(const Duration(milliseconds: 300), () {
          if (_searchController.text == value && value.length > 2) {
            _search(value);
          }
        });
      },
    );
  }

  Widget _buildBody() {
    // Show recent searches when not searching
    if (_searchController.text.isEmpty) {
      return _buildRecentSearches();
    }

    // Show loading
    if (_isSearching) {
      return const Center(child: LoadingWidget());
    }

    // Show results
    if (_jobResults.isNotEmpty || _fundiResults.isNotEmpty) {
      return _buildResults();
    }

    // No results
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text('No results found'),
          const SizedBox(height: 8),
          Text(
            'Try a different search term',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentSearches() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Row(
          children: [
            const Text(
              'Recent Searches',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            if (_recentSearches.isNotEmpty)
              TextButton(
                onPressed: () async {
                  await _searchService.clearRecentSearches();
                  await _loadRecentSearches();
                },
                child: const Text('Clear All'),
              ),
          ],
        ),

        const SizedBox(height: 12),

        if (_recentSearches.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Text(
                'Your recent searches will appear here',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
          )
        else
          ..._recentSearches.map((search) {
            return ListTile(
              leading: const Icon(Icons.history),
              title: Text(search),
              trailing: IconButton(
                icon: const Icon(Icons.close, size: 18),
                onPressed: () async {
                  await _searchService.removeRecentSearch(search);
                  await _loadRecentSearches();
                },
              ),
              onTap: () {
                _searchController.text = search;
                _search(search);
              },
            );
          }).toList(),

        const SizedBox(height: 32),

        // Popular Searches
        const Text(
          'Popular Searches',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 12),

        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: ['Plumber', 'Carpenter', 'Electrician', 'Painter', 'Mason']
              .map((term) {
                return ActionChip(
                  label: Text(term),
                  onPressed: () {
                    _searchController.text = term;
                    _search(term);
                  },
                );
              })
              .toList(),
        ),
      ],
    );
  }

  Widget _buildResults() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Search Type Indicator
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.primaryGreen.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                _searchType == 'jobs' ? Icons.work : Icons.person,
                color: AppTheme.primaryGreen,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Searching for: ${_searchType == 'jobs'
                    ? 'Jobs'
                    : _searchType == 'fundis'
                    ? 'Fundis'
                    : 'Everything'}',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  // Show type selector
                },
                child: const Text('Change'),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Job Results
        if (_jobResults.isNotEmpty) ...[
          Row(
            children: [
              const Icon(Icons.work, size: 20),
              const SizedBox(width: 8),
              Text(
                'Jobs (${_jobResults.length})',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ..._jobResults.map((job) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: JobCard(job: job),
            );
          }).toList(),
          if (_fundiResults.isNotEmpty) const SizedBox(height: 24),
        ],

        // Fundi Results
        if (_fundiResults.isNotEmpty) ...[
          Row(
            children: [
              const Icon(Icons.person, size: 20),
              const SizedBox(width: 8),
              Text(
                'Fundis (${_fundiResults.length})',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ..._fundiResults.map((fundi) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: FundiCard(fundi: fundi),
            );
          }).toList(),
        ],
      ],
    );
  }
}
