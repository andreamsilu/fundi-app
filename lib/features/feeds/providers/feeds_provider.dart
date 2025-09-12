import 'package:flutter/foundation.dart';
import '../models/fundi_model.dart';
import '../models/job_model.dart';
import '../services/feeds_service.dart';

/// Provider for managing feeds state and business logic
/// Implements proper separation of concerns for feeds functionality
class FeedsProvider extends ChangeNotifier {
  final FeedsService _feedsService;

  // Fundis state
  List<FundiModel> _fundis = [];
  bool _isLoadingFundis = false;
  bool _isLoadingMoreFundis = false;
  String? _fundisError;
  bool _hasMoreFundis = true;
  int _fundisCurrentPage = 1;

  // Jobs state
  List<JobModel> _jobs = [];
  bool _isLoadingJobs = false;
  bool _isLoadingMoreJobs = false;
  String? _jobsError;
  bool _hasMoreJobs = true;
  int _jobsCurrentPage = 1;

  // Filter state
  String _searchQuery = '';
  String? _selectedLocation;
  String? _selectedCategory;
  List<String> _selectedSkills = [];
  double? _minRating;
  double? _minBudget;
  double? _maxBudget;
  bool? _isUrgent;
  bool? _isAvailable;
  bool? _isVerified;

  // Metadata state
  List<String> _categories = [];
  List<String> _skills = [];
  List<String> _locations = [];
  bool _isLoadingMetadata = false;

  FeedsProvider({FeedsService? feedsService})
    : _feedsService = feedsService ?? FeedsService();

  // Getters for fundis state
  List<FundiModel> get fundis => _fundis;
  bool get isLoadingFundis => _isLoadingFundis;
  bool get isLoadingMoreFundis => _isLoadingMoreFundis;
  String? get fundisError => _fundisError;
  bool get hasMoreFundis => _hasMoreFundis;

  // Getters for jobs state
  List<JobModel> get jobs => _jobs;
  bool get isLoadingJobs => _isLoadingJobs;
  bool get isLoadingMoreJobs => _isLoadingMoreJobs;
  String? get jobsError => _jobsError;
  bool get hasMoreJobs => _hasMoreJobs;

  // Getters for filter state
  String get searchQuery => _searchQuery;
  String? get selectedLocation => _selectedLocation;
  String? get selectedCategory => _selectedCategory;
  List<String> get selectedSkills => _selectedSkills;
  double? get minRating => _minRating;
  double? get minBudget => _minBudget;
  double? get maxBudget => _maxBudget;
  bool? get isUrgent => _isUrgent;
  bool? get isAvailable => _isAvailable;
  bool? get isVerified => _isVerified;

  // Getters for metadata
  List<String> get categories => _categories;
  List<String> get skills => _skills;
  List<String> get locations => _locations;
  bool get isLoadingMetadata => _isLoadingMetadata;

  /// Initialize feeds data
  Future<void> initialize() async {
    await Future.wait([loadFundis(), loadJobs(), loadMetadata()]);
  }

  /// Load fundis with current filters
  Future<void> loadFundis({bool refresh = false}) async {
    if (refresh) {
      _fundisCurrentPage = 1;
      _fundis.clear();
      _hasMoreFundis = true;
    }

    if (_isLoadingFundis || !_hasMoreFundis) return;

    _isLoadingFundis = true;
    _fundisError = null;
    notifyListeners();

    try {
      final result = await _feedsService.getFundis(
        page: _fundisCurrentPage,
        searchQuery: _searchQuery.isNotEmpty ? _searchQuery : null,
        location: _selectedLocation,
        skills: _selectedSkills.isNotEmpty ? _selectedSkills : null,
        minRating: _minRating,
        isAvailable: _isAvailable,
        isVerified: _isVerified,
      );

      if (result['success']) {
        final newFundis = result['fundis'] as List<FundiModel>;
        if (refresh) {
          _fundis = newFundis;
        } else {
          _fundis.addAll(newFundis);
        }

        final pagination = result['pagination'] as Map<String, dynamic>;
        _hasMoreFundis = pagination['hasNextPage'] ?? false;
        _fundisCurrentPage++;
      } else {
        _fundisError = result['message'];
      }
    } catch (e) {
      _fundisError = 'Failed to load fundis: ${e.toString()}';
    } finally {
      _isLoadingFundis = false;
      notifyListeners();
    }
  }

  /// Load more fundis (pagination)
  Future<void> loadMoreFundis() async {
    if (_isLoadingMoreFundis || !_hasMoreFundis) return;

    _isLoadingMoreFundis = true;
    notifyListeners();

    try {
      final result = await _feedsService.getFundis(
        page: _fundisCurrentPage,
        searchQuery: _searchQuery.isNotEmpty ? _searchQuery : null,
        location: _selectedLocation,
        skills: _selectedSkills.isNotEmpty ? _selectedSkills : null,
        minRating: _minRating,
        isAvailable: _isAvailable,
        isVerified: _isVerified,
      );

      if (result['success']) {
        final newFundis = result['fundis'] as List<FundiModel>;
        _fundis.addAll(newFundis);

        final pagination = result['pagination'] as Map<String, dynamic>;
        _hasMoreFundis = pagination['hasNextPage'] ?? false;
        _fundisCurrentPage++;
      }
    } catch (e) {
      _fundisError = 'Failed to load more fundis: ${e.toString()}';
    } finally {
      _isLoadingMoreFundis = false;
      notifyListeners();
    }
  }

  /// Load jobs with current filters
  Future<void> loadJobs({bool refresh = false}) async {
    if (refresh) {
      _jobsCurrentPage = 1;
      _jobs.clear();
      _hasMoreJobs = true;
    }

    if (_isLoadingJobs || !_hasMoreJobs) return;

    _isLoadingJobs = true;
    _jobsError = null;
    notifyListeners();

    try {
      final result = await _feedsService.getJobs(
        page: _jobsCurrentPage,
        searchQuery: _searchQuery.isNotEmpty ? _searchQuery : null,
        category: _selectedCategory,
        location: _selectedLocation,
        minBudget: _minBudget,
        maxBudget: _maxBudget,
        isUrgent: _isUrgent,
      );

      if (result['success']) {
        final newJobs = result['jobs'] as List<JobModel>;
        if (refresh) {
          _jobs = newJobs;
        } else {
          _jobs.addAll(newJobs);
        }

        final pagination = result['pagination'] as Map<String, dynamic>;
        _hasMoreJobs = pagination['hasNextPage'] ?? false;
        _jobsCurrentPage++;
      } else {
        _jobsError = result['message'];
      }
    } catch (e) {
      _jobsError = 'Failed to load jobs: ${e.toString()}';
    } finally {
      _isLoadingJobs = false;
      notifyListeners();
    }
  }

  /// Load more jobs (pagination)
  Future<void> loadMoreJobs() async {
    if (_isLoadingMoreJobs || !_hasMoreJobs) return;

    _isLoadingMoreJobs = true;
    notifyListeners();

    try {
      final result = await _feedsService.getJobs(
        page: _jobsCurrentPage,
        searchQuery: _searchQuery.isNotEmpty ? _searchQuery : null,
        category: _selectedCategory,
        location: _selectedLocation,
        minBudget: _minBudget,
        maxBudget: _maxBudget,
        isUrgent: _isUrgent,
      );

      if (result['success']) {
        final newJobs = result['jobs'] as List<JobModel>;
        _jobs.addAll(newJobs);

        final pagination = result['pagination'] as Map<String, dynamic>;
        _hasMoreJobs = pagination['hasNextPage'] ?? false;
        _jobsCurrentPage++;
      }
    } catch (e) {
      _jobsError = 'Failed to load more jobs: ${e.toString()}';
    } finally {
      _isLoadingMoreJobs = false;
      notifyListeners();
    }
  }

  /// Load metadata (categories, skills, locations)
  Future<void> loadMetadata() async {
    _isLoadingMetadata = true;
    notifyListeners();

    try {
      final results = await Future.wait([
        _feedsService.getJobCategories(),
        _feedsService.getSkills(),
        _feedsService.getLocations(),
      ]);

      if (results[0]['success']) {
        _categories = List<String>.from(results[0]['categories']);
      }
      if (results[1]['success']) {
        _skills = List<String>.from(results[1]['skills']);
      }
      if (results[2]['success']) {
        _locations = List<String>.from(results[2]['locations']);
      }
    } catch (e) {
      debugPrint('Error loading metadata: ${e.toString()}');
    } finally {
      _isLoadingMetadata = false;
      notifyListeners();
    }
  }

  /// Update search query
  void updateSearchQuery(String query) {
    if (_searchQuery != query) {
      _searchQuery = query;
      _resetPagination();
      notifyListeners();
    }
  }

  /// Update location filter
  void updateLocation(String? location) {
    if (_selectedLocation != location) {
      _selectedLocation = location;
      _resetPagination();
      notifyListeners();
    }
  }

  /// Update category filter
  void updateCategory(String? category) {
    if (_selectedCategory != category) {
      _selectedCategory = category;
      _resetPagination();
      notifyListeners();
    }
  }

  /// Update skills filter
  void updateSkills(List<String> skills) {
    if (!listEquals(_selectedSkills, skills)) {
      _selectedSkills = List.from(skills);
      _resetPagination();
      notifyListeners();
    }
  }

  /// Update rating filter
  void updateMinRating(double? rating) {
    if (_minRating != rating) {
      _minRating = rating;
      _resetPagination();
      notifyListeners();
    }
  }

  /// Update budget filters
  void updateBudgetFilters({double? minBudget, double? maxBudget}) {
    bool changed = false;
    if (_minBudget != minBudget) {
      _minBudget = minBudget;
      changed = true;
    }
    if (_maxBudget != maxBudget) {
      _maxBudget = maxBudget;
      changed = true;
    }
    if (changed) {
      _resetPagination();
      notifyListeners();
    }
  }

  /// Update urgent filter
  void updateIsUrgent(bool? isUrgent) {
    if (_isUrgent != isUrgent) {
      _isUrgent = isUrgent;
      _resetPagination();
      notifyListeners();
    }
  }

  /// Update availability filter
  void updateIsAvailable(bool? isAvailable) {
    if (_isAvailable != isAvailable) {
      _isAvailable = isAvailable;
      _resetPagination();
      notifyListeners();
    }
  }

  /// Update verification filter
  void updateIsVerified(bool? isVerified) {
    if (_isVerified != isVerified) {
      _isVerified = isVerified;
      _resetPagination();
      notifyListeners();
    }
  }

  /// Clear all filters
  void clearFilters() {
    _searchQuery = '';
    _selectedLocation = null;
    _selectedCategory = null;
    _selectedSkills.clear();
    _minRating = null;
    _minBudget = null;
    _maxBudget = null;
    _isUrgent = null;
    _isAvailable = null;
    _isVerified = null;
    _resetPagination();
    notifyListeners();
  }

  /// Apply filters and reload data
  Future<void> applyFilters() async {
    await Future.wait([loadFundis(refresh: true), loadJobs(refresh: true)]);
  }

  /// Get fundi profile details
  Future<Map<String, dynamic>> getFundiProfile(String fundiId) async {
    try {
      return await _feedsService.getFundiProfile(fundiId);
    } catch (e) {
      return {
        'success': false,
        'fundi': null,
        'message': 'Error fetching fundi profile: ${e.toString()}',
      };
    }
  }

  /// Get job details
  Future<Map<String, dynamic>> getJobDetails(String jobId) async {
    try {
      return await _feedsService.getJobDetails(jobId);
    } catch (e) {
      return {
        'success': false,
        'job': null,
        'message': 'Error fetching job details: ${e.toString()}',
      };
    }
  }

  /// Request fundi for a job
  Future<Map<String, dynamic>> requestFundi({
    required String jobId,
    required String fundiId,
    required String message,
  }) async {
    try {
      return await _feedsService.requestFundi(
        jobId: jobId,
        fundiId: fundiId,
        message: message,
      );
    } catch (e) {
      return {
        'success': false,
        'message': 'Error sending fundi request: ${e.toString()}',
      };
    }
  }

  /// Apply to a job
  Future<Map<String, dynamic>> applyToJob({
    required String jobId,
    required String coverLetter,
    required double proposedBudget,
    required int estimatedDuration,
    required Map<String, dynamic> budgetBreakdown,
  }) async {
    try {
      return await _feedsService.applyToJob(
        jobId: jobId,
        coverLetter: coverLetter,
        proposedBudget: proposedBudget,
        estimatedDuration: estimatedDuration,
        budgetBreakdown: budgetBreakdown,
      );
    } catch (e) {
      return {
        'success': false,
        'message': 'Error submitting job application: ${e.toString()}',
      };
    }
  }

  /// Reset pagination state
  void _resetPagination() {
    _fundisCurrentPage = 1;
    _jobsCurrentPage = 1;
    _hasMoreFundis = true;
    _hasMoreJobs = true;
  }

  @override
  void dispose() {
    super.dispose();
  }
}
