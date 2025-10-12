import '../../../core/network/api_client.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/services/cache_service.dart';
import '../models/fundi_model.dart';
import '../../job/models/job_model.dart';

/// Service class for handling feeds-related API operations
/// Implements proper separation of concerns for feeds functionality
class FeedsService {
  final ApiClient _apiClient;
  final CacheService _cacheService = CacheService();

  FeedsService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  /// Get paginated list of fundis with filters
  ///
  /// Parameters:
  /// - page: Page number for pagination
  /// - limit: Number of items per page
  /// - searchQuery: Search term for fundi name or skills
  /// - location: Filter by location
  /// - skills: Filter by specific skills
  /// - minRating: Minimum rating filter
  /// - isAvailable: Filter by availability status
  /// - isVerified: Filter by verification status
  Future<Map<String, dynamic>> getFundis({
    int page = 1,
    int limit = 20,
    String? searchQuery,
    String? location,
    List<String>? skills,
    double? minRating,
    bool? isAvailable,
    bool? isVerified,
    bool useCache = true,
  }) async {
    try {
      // Check cache first for first page without filters
      if (useCache &&
          page == 1 &&
          searchQuery == null &&
          location == null &&
          skills == null &&
          minRating == null &&
          isAvailable == null &&
          isVerified == null) {
        final cachedData = await _cacheService.getCachedApiResponse(
          'fundis_page_1',
        );
        if (cachedData != null) {
          return cachedData;
        }
      }

      // Build query parameters
      final queryParams = <String, dynamic>{'page': page, 'limit': limit};

      if (searchQuery != null && searchQuery.isNotEmpty) {
        queryParams['search'] = searchQuery;
      }
      if (location != null && location.isNotEmpty) {
        queryParams['location'] = location;
      }
      if (skills != null && skills.isNotEmpty) {
        queryParams['skills'] = skills.join(',');
      }
      if (minRating != null) {
        queryParams['minRating'] = minRating;
      }
      if (isAvailable != null) {
        queryParams['isAvailable'] = isAvailable;
      }
      if (isVerified != null) {
        queryParams['isVerified'] = isVerified;
      }

      print('FeedsService: Making API call to ${ApiEndpoints.feedsFundis}');
      print('FeedsService: Query parameters: $queryParams');

      final response = await _apiClient.get(
        ApiEndpoints.feedsFundis,
        queryParameters: queryParams,
      );

      print('FeedsService: API response success: ${response.success}');
      print('FeedsService: API response data: ${response.data}');
      print('FeedsService: API response message: ${response.message}');
      print('FeedsService: API response statusCode: ${response.statusCode}');

      // Log the raw response structure
      if (response.data != null) {
        print('FeedsService: Response data type: ${response.data.runtimeType}');
        if (response.data is Map) {
          print(
            'FeedsService: Response data keys: ${(response.data as Map).keys.toList()}',
          );
        }
      }

      if (response.success && response.data != null) {
        // Cache the response for first page without filters
        if (useCache &&
            page == 1 &&
            searchQuery == null &&
            location == null &&
            skills == null &&
            minRating == null &&
            isAvailable == null &&
            isVerified == null) {
          await _cacheService.cacheApiResponse('fundis_page_1', response.data);
        }

        // Return raw list; provider maps to models
        final List<dynamic> fundiData = response.data['fundis'] ?? [];
        print(
          'FeedsService: Extracted ${fundiData.length} fundis from response',
        );

        return {
          'success': true,
          'fundis': fundiData,
          'pagination': response.data['pagination'] ?? {},
          'message': 'Fundis fetched successfully',
        };
      } else {
        print(
          'FeedsService: API call failed - success: ${response.success}, data: ${response.data}',
        );
        return {
          'success': false,
          'fundis': <dynamic>[],
          'pagination': {},
          'message': response.message,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'fundis': <FundiModel>[],
        'pagination': {},
        'message': 'Error fetching fundis: ${e.toString()}',
      };
    }
  }

  /// Get paginated list of jobs with filters
  ///
  /// Parameters:
  /// - page: Page number for pagination
  /// - limit: Number of items per page
  /// - searchQuery: Search term for job title or description
  /// - category: Filter by job category
  /// - location: Filter by location
  /// - minBudget: Minimum budget filter
  /// - maxBudget: Maximum budget filter
  /// - status: Filter by job status
  /// - isUrgent: Filter by urgent jobs only
  Future<Map<String, dynamic>> getJobs({
    int page = 1,
    int limit = 20,
    String? searchQuery,
    String? category,
    String? location,
    double? minBudget,
    double? maxBudget,
    String? status,
    bool? isUrgent,
  }) async {
    try {
      // Build query parameters
      final queryParams = <String, dynamic>{'page': page, 'limit': limit};

      if (searchQuery != null && searchQuery.isNotEmpty) {
        queryParams['search'] = searchQuery;
      }
      if (category != null && category.isNotEmpty) {
        queryParams['category'] = category;
      }
      if (location != null && location.isNotEmpty) {
        queryParams['location'] = location;
      }
      if (minBudget != null) {
        queryParams['minBudget'] = minBudget;
      }
      if (maxBudget != null) {
        queryParams['maxBudget'] = maxBudget;
      }
      if (status != null && status.isNotEmpty) {
        queryParams['status'] = status;
      }
      if (isUrgent != null) {
        queryParams['isUrgent'] = isUrgent;
      }

      final response = await _apiClient.get(
        ApiEndpoints.feedsJobs,
        queryParameters: queryParams,
      );

      if (response.success && response.data != null) {
        // Return raw list; provider maps to models
        final List<dynamic> jobData = response.data['jobs'] ?? [];
        return {
          'success': true,
          'jobs': jobData,
          'pagination': response.data['pagination'] ?? {},
          'message': 'Jobs fetched successfully',
        };
      } else {
        return {
          'success': false,
          'jobs': <dynamic>[],
          'pagination': {},
          'message': response.message,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'jobs': <JobModel>[],
        'pagination': {},
        'message': 'Error fetching jobs: ${e.toString()}',
      };
    }
  }

  /// Get detailed fundi profile by ID
  Future<Map<String, dynamic>> getFundiProfile(String fundiId) async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.getFeedsFundiEndpoint(fundiId),
      );

      if (response.success && response.data != null) {
        return {
          'success': true,
          'fundi': response.data,
          'message': 'Fundi profile fetched successfully',
        };
      } else {
        return {'success': false, 'fundi': null, 'message': response.message};
      }
    } catch (e) {
      return {
        'success': false,
        'fundi': null,
        'message': 'Error fetching fundi profile: ${e.toString()}',
      };
    }
  }

  /// Get detailed job information by ID
  Future<Map<String, dynamic>> getJobDetails(String jobId) async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.getFeedsJobEndpoint(jobId),
      );

      if (response.success && response.data != null) {
        final job = JobModel.fromJson(response.data);
        return {
          'success': true,
          'job': job,
          'message': 'Job details fetched successfully',
        };
      } else {
        return {'success': false, 'job': null, 'message': response.message};
      }
    } catch (e) {
      return {
        'success': false,
        'job': null,
        'message': 'Error fetching job details: ${e.toString()}',
      };
    }
  }

  // Static variable to prevent concurrent category fetching
  static Future<Map<String, dynamic>>? _categoryFetchFuture;

  /// Get job categories
  Future<Map<String, dynamic>> getJobCategories() async {
    // If there's already a category fetch in progress, return that future
    if (_categoryFetchFuture != null) {
      return _categoryFetchFuture!;
    }

    _categoryFetchFuture = _fetchJobCategories();

    try {
      final result = await _categoryFetchFuture!;
      return result;
    } finally {
      // Clear the future when done
      _categoryFetchFuture = null;
    }
  }

  /// Internal method to fetch job categories
  Future<Map<String, dynamic>> _fetchJobCategories() async {
    try {
      final response = await _apiClient
          .get(ApiEndpoints.categories)
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw Exception(
                'Request timeout - categories fetch took too long',
              );
            },
          );

      if (response.success && response.data != null) {
        // Handle both list and object responses
        List<dynamic> categories;
        if (response.data is List) {
          categories = response.data as List<dynamic>;
        } else {
          categories = response.data['categories'] ?? [];
        }

        return {
          'success': true,
          'categories': categories,
          'message': 'Categories fetched successfully',
        };
      } else {
        return {
          'success': false,
          'categories': [],
          'message': response.message,
        };
      }
    } catch (e) {
      // Return error - no fallback categories
      return {
        'success': false,
        'categories': [],
        'message': 'Failed to load categories from API: ${e.toString()}',
      };
    }
  }

  /// Get available skills
  Future<Map<String, dynamic>> getSkills() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.categories);

      if (response.success && response.data != null) {
        return {
          'success': true,
          'skills': response.data['skills'] ?? [],
          'message': 'Skills fetched successfully',
        };
      } else {
        return {'success': false, 'skills': [], 'message': response.message};
      }
    } catch (e) {
      return {
        'success': false,
        'skills': [],
        'message': 'Error fetching skills: ${e.toString()}',
      };
    }
  }

  /// Get available locations
  Future<Map<String, dynamic>> getLocations() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.categories);

      if (response.success && response.data != null) {
        return {
          'success': true,
          'locations': response.data['locations'] ?? [],
          'message': 'Locations fetched successfully',
        };
      } else {
        return {'success': false, 'locations': [], 'message': response.message};
      }
    } catch (e) {
      return {
        'success': false,
        'locations': [],
        'message': 'Error fetching locations: ${e.toString()}',
      };
    }
  }

  /// Create a new job (customer action)
  Future<Map<String, dynamic>> createJob({
    required String title,
    required String description,
    required String categoryId,
    required double budget,
    required String budgetType,
    required String deadline,
    String? fundiId, // Optional: for specific fundi request
  }) async {
    try {
      final jobData = {
        'title': title,
        'description': description,
        'category_id': categoryId,
        'budget': budget.toString(),
        'budget_type': budgetType,
        'deadline': deadline,
        if (fundiId != null) 'fundi_id': fundiId,
      };

      final response = await _apiClient.post(ApiEndpoints.jobs, {}, jobData);

      if (response.success) {
        return {
          'success': true,
          'job': response.data,
          'message': response.message,
        };
      } else {
        return {'success': false, 'message': response.message};
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error creating job: ${e.toString()}',
      };
    }
  }
}
