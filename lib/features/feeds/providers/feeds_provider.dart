import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/fundi_model.dart';
import '../models/job_model.dart';
import '../services/feeds_service.dart';
import '../../../core/network/api_client.dart';

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
  String? _metadataError;
  DateTime? _lastMetadataUpdate;

  FeedsProvider({FeedsService? feedsService})
    : _feedsService = feedsService ?? FeedsService();

  // Request management
  String? _currentFundisRequestId;
  String? _currentJobsRequestId;

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
  String? get metadataError => _metadataError;
  DateTime? get lastMetadataUpdate => _lastMetadataUpdate;
  bool get hasMetadataError => _metadataError != null;
  bool get isMetadataStale =>
      _lastMetadataUpdate == null ||
      DateTime.now().difference(_lastMetadataUpdate!).inMinutes > 5;

  /// Initialize feeds data
  Future<void> initialize() async {
    await Future.wait([loadFundis(), loadJobs(), loadMetadata()]);
  }

  /// Load fundis with current filters
  Future<void> loadFundis({bool refresh = false, int maxRetries = 3}) async {
    if (refresh) {
      _fundisCurrentPage = 1;
      _fundis.clear();
      _hasMoreFundis = true;
    }

    if (_isLoadingFundis || !_hasMoreFundis) return;

    _isLoadingFundis = true;
    _fundisError = null;
    notifyListeners();

    int attempts = 0;
    while (attempts < maxRetries) {
      try {
        final result = await _feedsService
            .getFundis(
              page: _fundisCurrentPage,
              searchQuery: _searchQuery.isNotEmpty ? _searchQuery : null,
              location: _selectedLocation,
              skills: _selectedSkills.isNotEmpty ? _selectedSkills : null,
              minRating: _minRating,
              isAvailable: _isAvailable,
              isVerified: _isVerified,
            )
            .timeout(
              const Duration(seconds: 30),
              onTimeout: () =>
                  throw TimeoutException('Fundis loading timed out'),
            );

        if (result['success']) {
          final fundisData = result['fundis'] as List<dynamic>;
          final newFundis = fundisData.map((json) {
            try {
              // Parse fundi data safely
              final jsonMap = json as Map<String, dynamic>;

              return FundiModel.fromJson(jsonMap);
            } catch (e) {
              print('Error parsing fundi: $e');
              print('Problematic JSON: $json');
              print('Error type: ${e.runtimeType}');
              if (e.toString().contains('bool')) {
                print('Boolean parsing error detected!');
              }
              // Return a default fundi model to prevent crashes
              return FundiModel.empty();
            }
          }).toList();

          if (refresh) {
            _fundis = newFundis;
          } else {
            _fundis.addAll(newFundis);
          }

          final paginationData = result['pagination'] as Map<dynamic, dynamic>;
          final pagination = Map<String, dynamic>.from(paginationData);
          final currentPage =
              (pagination['current_page'] ?? pagination['currentPage'] ?? 1)
                  as int;
          final lastPage =
              (pagination['last_page'] ?? pagination['lastPage'] ?? 1) as int;
          _hasMoreFundis = currentPage < lastPage;
          _fundisCurrentPage++;
          _fundisError = null;
          break; // Success, exit retry loop
        } else {
          _fundisError = result['message'];
          if (attempts < maxRetries - 1) {
            await Future.delayed(Duration(seconds: (attempts + 1) * 2));
          }
        }
      } catch (e) {
        _fundisError = 'Failed to load fundis: ${e.toString()}';
        if (attempts < maxRetries - 1) {
          await Future.delayed(Duration(seconds: (attempts + 1) * 2));
        }
      }
      attempts++;
    }

    _isLoadingFundis = false;
    notifyListeners();
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
        final fundisData = result['fundis'] as List<dynamic>;
        final newFundis = fundisData.map((json) {
          try {
            // Parse fundi data safely
            final jsonMap = json as Map<String, dynamic>;

            return FundiModel.fromJson(jsonMap);
          } catch (e) {
            print('Error parsing fundi: $e');
            print('Problematic JSON: $json');
            print('Error type: ${e.runtimeType}');
            if (e.toString().contains('bool')) {
              print('Boolean parsing error detected!');
            }
            // Return a default fundi model to prevent crashes
            return FundiModel.empty();
          }
        }).toList();
        _fundis.addAll(newFundis);

        final paginationData = result['pagination'] as Map<dynamic, dynamic>;
        final pagination = Map<String, dynamic>.from(paginationData);
        final currentPage =
            (pagination['current_page'] ?? pagination['currentPage'] ?? 1)
                as int;
        final lastPage =
            (pagination['last_page'] ?? pagination['lastPage'] ?? 1) as int;
        _hasMoreFundis = currentPage < lastPage;
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
  Future<void> loadJobs({bool refresh = false, int maxRetries = 3}) async {
    if (refresh) {
      _jobsCurrentPage = 1;
      _jobs.clear();
      _hasMoreJobs = true;
    }

    if (_isLoadingJobs || !_hasMoreJobs) return;

    _isLoadingJobs = true;
    _jobsError = null;
    notifyListeners();

    int attempts = 0;
    while (attempts < maxRetries) {
      try {
        final result = await _feedsService
            .getJobs(
              page: _jobsCurrentPage,
              searchQuery: _searchQuery.isNotEmpty ? _searchQuery : null,
              category: _selectedCategory,
              location: _selectedLocation,
              minBudget: _minBudget,
              maxBudget: _maxBudget,
              isUrgent: _isUrgent,
            )
            .timeout(
              const Duration(seconds: 30),
              onTimeout: () => throw TimeoutException('Jobs loading timed out'),
            );

        if (result['success']) {
          final jobsData = result['jobs'] as List<dynamic>;
          final newJobs = jobsData
              .map((json) => JobModel.fromJson(json as Map<String, dynamic>))
              .toList();

          if (refresh) {
            _jobs = newJobs;
          } else {
            _jobs.addAll(newJobs);
          }

          final paginationData = result['pagination'] as Map<dynamic, dynamic>;
          final pagination = Map<String, dynamic>.from(paginationData);
          _hasMoreJobs = pagination['hasNextPage'] ?? false;
          _jobsCurrentPage++;
          _jobsError = null;
          break; // Success, exit retry loop
        } else {
          _jobsError = result['message'];
          if (attempts < maxRetries - 1) {
            await Future.delayed(Duration(seconds: (attempts + 1) * 2));
          }
        }
      } catch (e) {
        _jobsError = 'Failed to load jobs: ${e.toString()}';
        if (attempts < maxRetries - 1) {
          await Future.delayed(Duration(seconds: (attempts + 1) * 2));
        }
      }
      attempts++;
    }

    _isLoadingJobs = false;
    notifyListeners();
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
        final jobsData = result['jobs'] as List<dynamic>;
        final newJobs = jobsData
            .map((json) => JobModel.fromJson(json as Map<String, dynamic>))
            .toList();
        _jobs.addAll(newJobs);

        final paginationData = result['pagination'] as Map<dynamic, dynamic>;
        final pagination = Map<String, dynamic>.from(paginationData);
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
  Future<void> loadMetadata({bool forceRefresh = false}) async {
    // Skip if already loading or data is fresh and not forcing refresh
    if (_isLoadingMetadata || (!forceRefresh && !isMetadataStale)) return;

    _isLoadingMetadata = true;
    _metadataError = null;
    notifyListeners();

    try {
      final results =
          await Future.wait([
            _feedsService.getJobCategories(),
            _feedsService.getSkills(),
            _feedsService.getLocations(),
          ]).timeout(
            const Duration(seconds: 30),
            onTimeout: () =>
                throw TimeoutException('Metadata loading timed out'),
          );

      bool hasAnyData = false;
      String? errorMessage;

      // Process categories
      if (results[0]['success'] && results[0]['categories'] != null) {
        _categories = List<String>.from(results[0]['categories']);
        hasAnyData = true;
      } else {
        errorMessage = results[0]['message'] ?? 'Failed to load categories';
      }

      // Process skills
      if (results[1]['success'] && results[1]['skills'] != null) {
        _skills = List<String>.from(results[1]['skills']);
        hasAnyData = true;
      } else {
        errorMessage =
            errorMessage ?? results[1]['message'] ?? 'Failed to load skills';
      }

      // Process locations
      if (results[2]['success'] && results[2]['locations'] != null) {
        _locations = List<String>.from(results[2]['locations']);
        hasAnyData = true;
      } else {
        errorMessage =
            errorMessage ?? results[2]['message'] ?? 'Failed to load locations';
      }

      if (hasAnyData) {
        _lastMetadataUpdate = DateTime.now();
        _metadataError = null;
      } else {
        _metadataError = errorMessage ?? 'Failed to load metadata';
      }
    } catch (e) {
      _metadataError = 'Error loading metadata: ${e.toString()}';
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
  /// Note: This method should be moved to a dedicated JobRequestService
  Future<Map<String, dynamic>> requestFundi({
    required String jobId,
    required String fundiId,
    required String message,
  }) async {
    // TODO: Implement fundi request logic or move to JobRequestService
    return {
      'success': false,
      'message': 'Fundi request functionality not implemented in FeedsService',
    };
  }

  /// Apply to a job
  /// Note: This method should be moved to a dedicated JobApplicationService
  Future<Map<String, dynamic>> applyToJob({
    required String jobId,
    required String coverLetter,
    required double proposedBudget,
    required int estimatedDuration,
    required Map<String, dynamic> budgetBreakdown,
  }) async {
    // TODO: Implement job application logic or move to JobApplicationService
    return {
      'success': false,
      'message':
          'Job application functionality not implemented in FeedsService',
    };
  }

  /// Reset pagination state
  void _resetPagination() {
    _fundisCurrentPage = 1;
    _jobsCurrentPage = 1;
    _hasMoreFundis = true;
    _hasMoreJobs = true;
  }

  /// Retry failed operations
  Future<void> retryFailedOperations() async {
    final futures = <Future<void>>[];

    if (_fundisError != null) {
      futures.add(loadFundis(refresh: true));
    }

    if (_jobsError != null) {
      futures.add(loadJobs(refresh: true));
    }

    if (_metadataError != null) {
      futures.add(loadMetadata(forceRefresh: true));
    }

    if (futures.isNotEmpty) {
      await Future.wait(futures);
    }
  }

  /// Clear all errors
  void clearErrors() {
    _fundisError = null;
    _jobsError = null;
    _metadataError = null;
    notifyListeners();
  }

  /// Check if any data is loading
  bool get isAnyLoading =>
      _isLoadingFundis || _isLoadingJobs || _isLoadingMetadata;

  /// Check if any data has errors
  bool get hasAnyError =>
      _fundisError != null || _jobsError != null || _metadataError != null;

  /// Get all errors as a list
  List<String> get allErrors {
    final errors = <String>[];
    if (_fundisError != null) errors.add('Fundis: $_fundisError');
    if (_jobsError != null) errors.add('Jobs: $_jobsError');
    if (_metadataError != null) errors.add('Metadata: $_metadataError');
    return errors;
  }

  /// Refresh all data
  Future<void> refreshAll() async {
    await Future.wait([
      loadFundis(refresh: true),
      loadJobs(refresh: true),
      loadMetadata(forceRefresh: true),
    ]);
  }

  @override
  void dispose() {
    // Cancel any active requests
    if (_currentFundisRequestId != null) {
      ApiClient().cancelRequest(_currentFundisRequestId!);
    }
    if (_currentJobsRequestId != null) {
      ApiClient().cancelRequest(_currentJobsRequestId!);
    }
    super.dispose();
  }
}
