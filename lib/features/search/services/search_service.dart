import '../../../core/network/api_client.dart';
import '../../../core/constants/api_endpoints.dart';
import '../models/search_model.dart';
import '../../job/models/job_model.dart';
import '../../portfolio/models/portfolio_model.dart';

/// Search service for finding jobs and portfolios
/// Handles search operations with filtering and pagination
class SearchService {
  final ApiClient _apiClient = ApiClient();

  /// Search for jobs and portfolios with filters
  Future<JobPortfolioSearchResult> search({
    required String query,
    String? category,
    String? location,
    double? minBudget,
    double? maxBudget,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.search,
        {
          'query': query.toString(),
          'category': category.toString(),
          'location': location.toString(),
          'min_budget': minBudget.toString(),
          'max_budget': maxBudget.toString(),
          'page': page.toString(),
          'limit': limit.toString(),
        },
        {},
        fromJson: (data) => data as Map<String, dynamic>,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final jobs =
            (data?['jobs'] as List?)
                ?.map((job) => JobModel.fromJson(job))
                .toList() ??
            [];
        final portfolios =
            (data?['portfolios'] as List?)
                ?.map((portfolio) => PortfolioModel.fromJson(portfolio))
                .toList() ??
            [];

        return JobPortfolioSearchResult(
          success: true,
          jobs: jobs,
          portfolios: portfolios,
          totalJobs: data?['total_jobs'] ?? 0,
          totalPortfolios: data?['total_portfolios'] ?? 0,
          currentPage: data?['current_page'] ?? 1,
          totalPages: data?['total_pages'] ?? 1,
        );
      } else {
        return JobPortfolioSearchResult(
          success: false,
          message: 'Search failed. Please try again.',
        );
      }
    } catch (e) {
      return JobPortfolioSearchResult(
        success: false,
        message: 'Search failed. Please check your connection and try again.',
      );
    }
  }

  /// Get search suggestions based on query
  Future<List<String>> getSuggestions(String query) async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.searchSuggestions,
        queryParameters: {'q': query},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        return (data?['suggestions'] as List?)
                ?.map((suggestion) => suggestion.toString())
                .toList() ??
            [];
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Get popular search terms
  Future<List<String>> getPopularSearches() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.searchPopular);

      if (response.statusCode == 200) {
        final data = response.data;
        return (data?['popular_searches'] as List?)
                ?.map((term) => term.toString())
                .toList() ??
            [];
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Get search filters (categories, locations, etc.)
  Future<SearchFilters> getFilters() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.searchFilters);

      if (response.statusCode == 200) {
        final data = response.data;
        return SearchFilters.fromJson(data);
      }
      return SearchFilters.empty();
    } catch (e) {
      return SearchFilters.empty();
    }
  }

  /// Save search query for analytics
  Future<void> saveSearchQuery(String query) async {
    try {
      await _apiClient.post(
        ApiEndpoints.searchAnalytics,
        {'query': query.toString()},
        {},
        fromJson: (data) => data as Map<String, dynamic>,
      );
    } catch (e) {
      // Silently fail for analytics
    }
  }
}
