import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/network/api_client.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/utils/logger.dart';
import '../../job/models/job_model.dart';
import '../../feeds/models/fundi_model.dart';

/// Unified search service for jobs and fundis
/// Handles search operations and recent search history
class SearchService {
  static final SearchService _instance = SearchService._internal();
  factory SearchService() => _instance;
  SearchService._internal();

  final ApiClient _apiClient = ApiClient();
  static const String _recentSearchesKey = 'recent_searches';
  static const int _maxRecentSearches = 10;

  /// Search for jobs
  /// Returns a list of jobs matching the search query
  Future<SearchResult<JobModel>> searchJobs({
    required String query,
    int page = 1,
    int limit = 20,
    String? location,
    double? minBudget,
    double? maxBudget,
  }) async {
    try {
      Logger.userAction('Search jobs', data: {'query': query, 'page': page});

      final queryParams = <String, dynamic>{
        'search': query,
        'page': page,
        'limit': limit,
      };

      if (location != null && location.isNotEmpty) {
        queryParams['location'] = location;
      }
      if (minBudget != null) {
        queryParams['minBudget'] = minBudget;
      }
      if (maxBudget != null) {
        queryParams['maxBudget'] = maxBudget;
      }

      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiEndpoints.jobs,
        queryParameters: queryParams,
        fromJson: (data) => data as Map<String, dynamic>,
      );

      if (response.success && response.data != null) {
        final data = response.data!;
        final jobs = <JobModel>[];

        if (data['jobs'] is List) {
          for (var jobJson in data['jobs']) {
            try {
              jobs.add(JobModel.fromJson(jobJson));
            } catch (e) {
              Logger.error('Error parsing job', error: e);
            }
          }
        }

        final pagination = data['pagination'] as Map<String, dynamic>?;

        return SearchResult<JobModel>(
          results: jobs,
          totalCount: pagination?['total'] ?? jobs.length,
          currentPage: pagination?['currentPage'] ?? page,
          totalPages: pagination?['totalPages'] ?? 1,
          hasMore: pagination?['hasNextPage'] ?? false,
        );
      } else {
        Logger.warning('Search jobs failed: ${response.message}');
        return SearchResult<JobModel>(
          results: [],
          totalCount: 0,
          currentPage: page,
          totalPages: 0,
          hasMore: false,
        );
      }
    } on ApiError catch (e) {
      Logger.error('Search jobs API error', error: e);
      throw Exception(e.message);
    } catch (e) {
      Logger.error('Search jobs unexpected error', error: e);
      throw Exception('Failed to search jobs');
    }
  }

  /// Search for fundis
  /// Returns a list of fundis matching the search query
  Future<SearchResult<FundiModel>> searchFundis({
    required String query,
    int page = 1,
    int limit = 20,
    String? location,
    List<String>? skills,
    double? minRating,
  }) async {
    try {
      Logger.userAction('Search fundis', data: {'query': query, 'page': page});

      final queryParams = <String, dynamic>{
        'search': query,
        'page': page,
        'limit': limit,
      };

      if (location != null && location.isNotEmpty) {
        queryParams['location'] = location;
      }
      if (skills != null && skills.isNotEmpty) {
        queryParams['skills'] = skills.join(',');
      }
      if (minRating != null) {
        queryParams['minRating'] = minRating;
      }

      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiEndpoints.feedsFundis,
        queryParameters: queryParams,
        fromJson: (data) => data as Map<String, dynamic>,
      );

      if (response.success && response.data != null) {
        final data = response.data!;
        final fundis = <FundiModel>[];

        if (data['fundis'] is List) {
          for (var fundiJson in data['fundis']) {
            try {
              fundis.add(FundiModel.fromJson(fundiJson));
            } catch (e) {
              Logger.error('Error parsing fundi', error: e);
            }
          }
        }

        final pagination = data['pagination'] as Map<String, dynamic>?;

        return SearchResult<FundiModel>(
          results: fundis,
          totalCount: pagination?['total'] ?? fundis.length,
          currentPage: pagination?['currentPage'] ?? page,
          totalPages: pagination?['totalPages'] ?? 1,
          hasMore: pagination?['hasNextPage'] ?? false,
        );
      } else {
        Logger.warning('Search fundis failed: ${response.message}');
        return SearchResult<FundiModel>(
          results: [],
          totalCount: 0,
          currentPage: page,
          totalPages: 0,
          hasMore: false,
        );
      }
    } on ApiError catch (e) {
      Logger.error('Search fundis API error', error: e);
      throw Exception(e.message);
    } catch (e) {
      Logger.error('Search fundis unexpected error', error: e);
      throw Exception('Failed to search fundis');
    }
  }

  /// Get recent searches from local storage
  Future<List<String>> getRecentSearches() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final searches = prefs.getStringList(_recentSearchesKey) ?? [];
      return searches;
    } catch (e) {
      Logger.error('Failed to get recent searches', error: e);
      return [];
    }
  }

  /// Save a search query to recent searches
  Future<void> saveRecentSearch(String query) async {
    if (query.trim().isEmpty) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      List<String> searches = prefs.getStringList(_recentSearchesKey) ?? [];

      // Remove duplicate if exists
      searches.remove(query);

      // Add to beginning
      searches.insert(0, query);

      // Limit to max recent searches
      if (searches.length > _maxRecentSearches) {
        searches = searches.take(_maxRecentSearches).toList();
      }

      await prefs.setStringList(_recentSearchesKey, searches);
    } catch (e) {
      Logger.error('Failed to save recent search', error: e);
    }
  }

  /// Clear all recent searches
  Future<void> clearRecentSearches() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_recentSearchesKey);
    } catch (e) {
      Logger.error('Failed to clear recent searches', error: e);
    }
  }

  /// Remove a specific search from recent searches
  Future<void> removeRecentSearch(String query) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<String> searches = prefs.getStringList(_recentSearchesKey) ?? [];
      searches.remove(query);
      await prefs.setStringList(_recentSearchesKey, searches);
    } catch (e) {
      Logger.error('Failed to remove recent search', error: e);
    }
  }
}

/// Generic search result model
class SearchResult<T> {
  final List<T> results;
  final int totalCount;
  final int currentPage;
  final int totalPages;
  final bool hasMore;

  SearchResult({
    required this.results,
    required this.totalCount,
    required this.currentPage,
    required this.totalPages,
    required this.hasMore,
  });
}
