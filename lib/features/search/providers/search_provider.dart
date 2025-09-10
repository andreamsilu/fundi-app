import 'package:flutter/material.dart';
import '../models/search_model.dart';
import '../services/search_service.dart';
import '../../job/models/job_model.dart';
import '../../portfolio/models/portfolio_model.dart';

/// Search provider for state management
/// Handles search operations and state
class SearchProvider extends ChangeNotifier {
  final SearchService _searchService = SearchService();

  List<JobModel> _jobs = [];
  List<PortfolioModel> _portfolios = [];
  List<String> _suggestions = [];
  List<String> _popularSearches = [];
  SearchFilters _filters = SearchFilters.empty();
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _errorMessage;
  String _currentQuery = '';
  String? _selectedCategory;
  String? _selectedLocation;
  double? _minBudget;
  double? _maxBudget;
  int _currentPage = 1;
  int _totalPages = 1;
  int _totalJobs = 0;
  int _totalPortfolios = 0;

  /// Get jobs list
  List<JobModel> get jobs => _jobs;

  /// Get portfolios list
  List<PortfolioModel> get portfolios => _portfolios;

  /// Get suggestions list
  List<String> get suggestions => _suggestions;

  /// Get popular searches list
  List<String> get popularSearches => _popularSearches;

  /// Get filters
  SearchFilters get filters => _filters;

  /// Check if loading
  bool get isLoading => _isLoading;

  /// Check if loading more
  bool get isLoadingMore => _isLoadingMore;

  /// Get error message
  String? get errorMessage => _errorMessage;

  /// Get current query
  String get currentQuery => _currentQuery;

  /// Get selected category
  String? get selectedCategory => _selectedCategory;

  /// Get selected location
  String? get selectedLocation => _selectedLocation;

  /// Get min budget
  double? get minBudget => _minBudget;

  /// Get max budget
  double? get maxBudget => _maxBudget;

  /// Get current page
  int get currentPage => _currentPage;

  /// Get total pages
  int get totalPages => _totalPages;

  /// Get total jobs count
  int get totalJobs => _totalJobs;

  /// Get total portfolios count
  int get totalPortfolios => _totalPortfolios;

  /// Check if has more results
  bool get hasMoreResults => _currentPage < _totalPages;

  /// Search for jobs and portfolios
  Future<void> search({
    required String query,
    String? category,
    String? location,
    double? minBudget,
    double? maxBudget,
    bool loadMore = false,
  }) async {
    if (query.trim().isEmpty) return;

    if (loadMore) {
      _isLoadingMore = true;
    } else {
      _isLoading = true;
      _currentPage = 1;
      _jobs.clear();
      _portfolios.clear();
    }

    _clearError();
    _currentQuery = query;
    _selectedCategory = category;
    _selectedLocation = location;
    _minBudget = minBudget;
    _maxBudget = maxBudget;

    try {
      final result = await _searchService.search(
        query: query,
        category: category,
        location: location,
        minBudget: minBudget,
        maxBudget: maxBudget,
        page: _currentPage,
      );

      if (result.success) {
        if (loadMore) {
          _jobs.addAll(result.jobs as Iterable<JobModel>);
          _portfolios.addAll(result.portfolios as Iterable<PortfolioModel>);
        } else {
          _jobs = result.jobs as List<JobModel>;
          _portfolios = result.portfolios as List<PortfolioModel>;
        }
        _totalJobs = result.totalJobs;
        _totalPortfolios = result.totalPortfolios;
        _currentPage = result.currentPage;
        _totalPages = result.totalPages;

        // Save search query for analytics
        _searchService.saveSearchQuery(query);
      } else {
        _setError(result.message ?? 'Search failed. Please try again.');
      }
    } catch (e) {
      _setError('Search failed. Please check your connection and try again.');
    } finally {
      _isLoading = false;
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  /// Load more results
  Future<void> loadMore() async {
    if (_isLoadingMore || !hasMoreResults) return;

    _currentPage++;
    await search(
      query: _currentQuery,
      category: _selectedCategory,
      location: _selectedLocation,
      minBudget: _minBudget,
      maxBudget: _maxBudget,
      loadMore: true,
    );
  }

  /// Get search suggestions
  Future<void> getSuggestions(String query) async {
    if (query.trim().isEmpty) {
      _suggestions.clear();
      notifyListeners();
      return;
    }

    try {
      final suggestions = await _searchService.getSuggestions(query);
      _suggestions = suggestions;
      notifyListeners();
    } catch (e) {
      // Silently fail for suggestions
    }
  }

  /// Get popular searches
  Future<void> getPopularSearches() async {
    try {
      final popularSearches = await _searchService.getPopularSearches();
      _popularSearches = popularSearches;
      notifyListeners();
    } catch (e) {
      // Silently fail for popular searches
    }
  }

  /// Get search filters
  Future<void> getFilters() async {
    try {
      final filters = await _searchService.getFilters();
      _filters = filters;
      notifyListeners();
    } catch (e) {
      // Silently fail for filters
    }
  }

  /// Clear search results
  void clearResults() {
    _jobs.clear();
    _portfolios.clear();
    _currentQuery = '';
    _selectedCategory = null;
    _selectedLocation = null;
    _minBudget = null;
    _maxBudget = null;
    _currentPage = 1;
    _totalPages = 1;
    _totalJobs = 0;
    _totalPortfolios = 0;
    _clearError();
    notifyListeners();
  }

  /// Clear suggestions
  void clearSuggestions() {
    _suggestions.clear();
    notifyListeners();
  }

  /// Set search filters
  void setFilters({
    String? category,
    String? location,
    double? minBudget,
    double? maxBudget,
  }) {
    _selectedCategory = category;
    _selectedLocation = location;
    _minBudget = minBudget;
    _maxBudget = maxBudget;
    notifyListeners();
  }

  /// Clear error
  void clearError() {
    _clearError();
    notifyListeners();
  }

  /// Set error message
  void _setError(String message) {
    _errorMessage = message;
  }

  /// Clear error message
  void _clearError() {
    _errorMessage = null;
  }
}
