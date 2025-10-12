import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/loading_widget.dart';

/// Unified Search Screen - Single search box for everything
/// Auto-detects search intent (Jobs vs Fundis)
/// Shows recent searches and suggestions
class SearchScreen extends StatefulWidget {
  final String? initialQuery;
  final int? initialTabIndex;

  const SearchScreen({super.key, this.initialQuery, this.initialTabIndex});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();

  bool _isSearching = false;
  List<String> _recentSearches = [];
  String _searchType = 'all'; // 'all', 'jobs', 'fundis'

  List<dynamic> _results = [];

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

  void _loadRecentSearches() {
    // TODO: Load from shared preferences
    setState(() {
      _recentSearches = ['Plumber', 'Carpenter', 'Electrician'];
    });
  }

  void _search(String query) {
    if (query.trim().isEmpty) {
      setState(() {
        _results = [];
        _isSearching = false;
      });
      return;
    }

    setState(() => _isSearching = true);

    // TODO: Implement actual search
    // For now, simulating search
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _isSearching = false;
          // Auto-detect if searching for jobs or fundis
          _autoDetectSearchType(query);
        });
      }
    });

    // Save to recent searches
    if (!_recentSearches.contains(query)) {
      setState(() {
        _recentSearches.insert(0, query);
        if (_recentSearches.length > 5) {
          _recentSearches = _recentSearches.take(5).toList();
        }
      });
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
        iconTheme: const IconThemeData(color: Colors.white),
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
                    _results = [];
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
    if (_results.isNotEmpty) {
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
                onPressed: () {
                  setState(() => _recentSearches.clear());
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
                onPressed: () {
                  setState(() => _recentSearches.remove(search));
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

        // Results (placeholder)
        const Text('Search results will appear here...'),
      ],
    );
  }
}
