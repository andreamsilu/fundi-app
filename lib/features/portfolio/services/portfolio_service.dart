import 'dart:io';
import 'dart:async';

import '../../../core/network/api_client.dart';
import '../../../core/utils/logger.dart';
import '../../../core/constants/api_endpoints.dart';
import '../models/portfolio_model.dart';

/// Feed data model for categories, skills, and locations
class FeedData {
  final List<String> categories;
  final List<String> skills;
  final List<String> locations;

  const FeedData({
    required this.categories,
    required this.skills,
    required this.locations,
  });

  factory FeedData.fromJson(Map<String, dynamic> json) {
    return FeedData(
      categories: List<String>.from(json['categories'] ?? []),
      skills: List<String>.from(json['skills'] ?? []),
      locations: List<String>.from(json['locations'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {'categories': categories, 'skills': skills, 'locations': locations};
  }

  bool get isEmpty => categories.isEmpty && skills.isEmpty && locations.isEmpty;
  bool get isNotEmpty => !isEmpty;
}

/// Feed data result wrapper
class FeedDataResult {
  final bool success;
  final String message;
  final FeedData? data;

  FeedDataResult._({required this.success, required this.message, this.data});

  factory FeedDataResult.success({
    required List<String> categories,
    required List<String> skills,
    required List<String> locations,
  }) {
    return FeedDataResult._(
      success: true,
      message: 'Feed data loaded successfully',
      data: FeedData(
        categories: categories,
        skills: skills,
        locations: locations,
      ),
    );
  }

  factory FeedDataResult.failure({required String message}) {
    return FeedDataResult._(success: false, message: message);
  }
}

/// Feed data state for UI management
class FeedDataState {
  final bool isLoading;
  final FeedData? data;
  final String? error;
  final DateTime? lastUpdated;

  const FeedDataState({
    this.isLoading = false,
    this.data,
    this.error,
    this.lastUpdated,
  });

  FeedDataState copyWith({
    bool? isLoading,
    FeedData? data,
    String? error,
    DateTime? lastUpdated,
  }) {
    return FeedDataState(
      isLoading: isLoading ?? this.isLoading,
      data: data ?? this.data,
      error: error ?? this.error,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  bool get hasData => data != null && data!.isNotEmpty;
  bool get hasError => error != null;
  bool get isStale =>
      lastUpdated != null &&
      DateTime.now().difference(lastUpdated!).inMinutes > 5;
}

/// Portfolio service for managing fundi portfolios
/// Handles CRUD operations for portfolio items
class PortfolioService {
  final ApiClient _apiClient = ApiClient();

  // FeedsService instance - you can inject this or create it as needed
  dynamic _feedsService;

  /// Initialize the feeds service
  void initializeFeedsService(dynamic feedsService) {
    _feedsService = feedsService;
  }

  /// Get feeds service instance
  dynamic get feedsService => _feedsService;

  /// Get portfolios for a specific fundi
  Future<PortfolioResult> getPortfolios({
    required String fundiId,
    int page = 1,
    int limit = 20,
    String? category,
    String? search,
    String? requestId,
  }) async {
    try {
      Logger.apiRequest('GET', ApiEndpoints.myPortfolio);

      // The API returns { success, message, data: List, portfolio_count, ... }
      // ApiClient extracts only `data` into response.data, which may be a List
      final response = await _apiClient.get<dynamic>(
        ApiEndpoints.myPortfolio,
        queryParameters: {
          'page': page,
          'limit': limit,
          if (category != null) 'category': category,
          if (search != null) 'search': search,
        },
        requestId: requestId,
      );

      Logger.apiResponse(
        'GET',
        ApiEndpoints.myPortfolio,
        response.statusCode,
        response: response.data,
      );

      if (response.success) {
        final dynamic data = response.data;
        // When ApiClient extracts `data` as a List
        if (data is List) {
          final portfolios = data
              .whereType<Map<String, dynamic>>()
              .map((json) => PortfolioModel.fromJson(json))
              .toList();

          return PortfolioResult(
            success: true,
            portfolios: portfolios,
            totalCount: portfolios.length,
            totalPages: 1,
            message: response.message,
          );
        }

        // When `data` is a Map with nested portfolios and counts
        if (data is Map<String, dynamic>) {
          final portfolios = (data['portfolios'] as List? ?? const [])
              .whereType<Map<String, dynamic>>()
              .map((json) => PortfolioModel.fromJson(json))
              .toList();

          return PortfolioResult(
            success: true,
            portfolios: portfolios,
            totalCount: (data['total_count'] as int?) ?? portfolios.length,
            totalPages: (data['total_pages'] as int?) ?? 1,
            message: response.message,
          );
        }

        // Unknown shape, return empty success
        return PortfolioResult(
          success: true,
          portfolios: const [],
          totalCount: 0,
          totalPages: 1,
          message: response.message,
        );
      } else {
        return PortfolioResult(
          success: false,
          portfolios: [],
          totalCount: 0,
          totalPages: 0,
          message: response.message,
        );
      }
    } catch (e) {
      Logger.apiError('GET', ApiEndpoints.myPortfolio, e);
      return PortfolioResult(
        success: false,
        portfolios: [],
        totalCount: 0,
        totalPages: 0,
        message: 'Failed to load portfolios',
      );
    }
  }

  /// Create a new portfolio item
  Future<PortfolioDetailResult> createPortfolio({
    required String fundiId,
    required String title,
    required String description,
    required String category,
    required List<String> skills,
    List<String>? imageUrls,
    List<String>? videoUrls,
    double? budget,
    String? budgetType,
    int? durationDays,
    DateTime? completedAt,
    Map<String, dynamic>? metadata,
    required List<String> images,
    required String clientName,
    required String address,
    required List<File> videos,
  }) async {
    try {
      Logger.apiRequest('POST', ApiEndpoints.createPortfolio);

      final response = await _apiClient.post<Map<String, dynamic>>(
        ApiEndpoints.createPortfolio,
        {},
        {
          'fundi_id': fundiId,
          'title': title,
          'description': description,
          'category': category,
          'skills': skills,
          'image_urls': imageUrls ?? [],
          'video_urls': videoUrls ?? [],
          'budget': budget,
          'budget_type': budgetType,
          'duration_days': durationDays,
          'completed_at': completedAt?.toIso8601String(),
          'metadata': metadata,
        },
        fromJson: (data) => data as Map<String, dynamic>,
      );

      Logger.apiResponse(
        'POST',
        ApiEndpoints.createPortfolio,
        response.statusCode,
        response: response.data,
      );

      if (response.success && response.data != null) {
        final portfolio = PortfolioModel.fromJson(response.data!);
        return PortfolioDetailResult(
          success: true,
          portfolio: portfolio,
          message: response.message,
        );
      } else {
        return PortfolioDetailResult(
          success: false,
          portfolio: null,
          message: response.message,
        );
      }
    } catch (e) {
      Logger.apiError('POST', ApiEndpoints.createPortfolio, e);
      return PortfolioDetailResult(
        success: false,
        portfolio: null,
        message: 'Failed to create portfolio',
      );
    }
  }

  /// Update an existing portfolio item
  Future<PortfolioDetailResult> updatePortfolio({
    required String portfolioId,
    String? title,
    String? description,
    String? category,
    List<String>? skills,
    List<String>? imageUrls,
    List<String>? videoUrls,
    double? budget,
    String? budgetType,
    int? durationDays,
    DateTime? completedAt,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      Logger.apiRequest(
        'PUT',
        ApiEndpoints.getUpdatePortfolioEndpoint(portfolioId),
      );

      final response = await _apiClient.put<Map<String, dynamic>>(
        ApiEndpoints.getUpdatePortfolioEndpoint(portfolioId),
        {},
        data: {
          if (title != null) 'title': title,
          if (description != null) 'description': description,
          if (category != null) 'category': category,
          if (skills != null) 'skills': skills,
          if (imageUrls != null) 'image_urls': imageUrls,
          if (videoUrls != null) 'video_urls': videoUrls,
          if (budget != null) 'budget': budget,
          if (budgetType != null) 'budget_type': budgetType,
          if (durationDays != null) 'duration_days': durationDays,
          if (completedAt != null)
            'completed_at': completedAt.toIso8601String(),
          if (metadata != null) 'metadata': metadata,
        },
        fromJson: (data) => data as Map<String, dynamic>,
      );

      Logger.apiResponse(
        'PUT',
        ApiEndpoints.getUpdatePortfolioEndpoint(portfolioId),
        response.statusCode,
        response: response.data,
      );

      if (response.success && response.data != null) {
        final portfolio = PortfolioModel.fromJson(response.data!);
        return PortfolioDetailResult(
          success: true,
          portfolio: portfolio,
          message: response.message,
        );
      } else {
        return PortfolioDetailResult(
          success: false,
          portfolio: null,
          message: response.message,
        );
      }
    } catch (e) {
      Logger.apiError(
        'PUT',
        ApiEndpoints.getUpdatePortfolioEndpoint(portfolioId),
        e,
      );
      return PortfolioDetailResult(
        success: false,
        portfolio: null,
        message: 'Failed to update portfolio',
      );
    }
  }

  /// Delete a portfolio item
  Future<PortfolioResult> deletePortfolio(String portfolioId) async {
    try {
      Logger.apiRequest(
        'DELETE',
        ApiEndpoints.getDeletePortfolioEndpoint(portfolioId),
      );

      final response = await _apiClient.delete<Map<String, dynamic>>(
        ApiEndpoints.getDeletePortfolioEndpoint(portfolioId),
        fromJson: (data) => data as Map<String, dynamic>,
      );

      Logger.apiResponse(
        'DELETE',
        ApiEndpoints.getDeletePortfolioEndpoint(portfolioId),
        response.statusCode,
        response: response.data,
      );

      return PortfolioResult(
        success: response.success,
        portfolios: [],
        totalCount: 0,
        totalPages: 0,
        message: response.message,
      );
    } catch (e) {
      Logger.apiError(
        'DELETE',
        ApiEndpoints.getDeletePortfolioEndpoint(portfolioId),
        e,
      );
      return PortfolioResult(
        success: false,
        portfolios: [],
        totalCount: 0,
        totalPages: 0,
        message: 'Failed to delete portfolio',
      );
    }
  }

  /// Get portfolio categories
  Future<List<String>> getCategories() async {
    try {
      Logger.apiRequest('GET', ApiEndpoints.categories);

      final response = await _apiClient.get<List<dynamic>>(
        ApiEndpoints.categories,
        fromJson: (data) => data as List<dynamic>,
      );

      Logger.apiResponse(
        'GET',
        ApiEndpoints.categories,
        response.statusCode,
        response: response.data,
      );

      if (response.success && response.data != null) {
        return response.data!.cast<String>();
      } else {
        // Return empty list if API fails - no fallback
        return [];
      }
    } catch (e) {
      Logger.apiError('GET', ApiEndpoints.categories, e);
      // Return empty list - force API dependency
      return [];
    }
  }

  /// Load feed data (categories, skills, locations) with enhanced error handling
  Future<FeedDataResult> loadFeedDataWithFallback() async {
    try {
      Logger.userAction('Loading feed data with fallback');

      // Check if feeds service is initialized
      if (_feedsService == null) {
        Logger.warning('FeedsService not initialized, using fallback data');
        return _getFallbackFeedData();
      }

      // Try to load from API first with parallel calls
      final results =
          await Future.wait<List<dynamic>>([
            _feedsService!.getJobCategories(),
            _feedsService!.getSkills(),
            _feedsService!.getLocations(),
          ]).timeout(
            const Duration(seconds: 30),
            onTimeout: () =>
                throw TimeoutException('Feed data loading timed out'),
          );

      // Process results with type safety
      final categories = results[0] as List<String>;
      final skills = results[1] as List<String>;
      final locations = results[2] as List<String>;

      // Validate data
      if (categories.isEmpty && skills.isEmpty && locations.isEmpty) {
        Logger.warning('Empty feed data received from API');
        return _getFallbackFeedData();
      }

      Logger.userAction('Feed data loaded successfully from API');

      return FeedDataResult.success(
        categories: categories,
        skills: skills,
        locations: locations,
      );
    } catch (e) {
      Logger.error('Failed to load feed data from API', error: e);

      // Fallback to local data
      return _getFallbackFeedData();
    }
  }

  /// Get fallback feed data when API fails
  FeedDataResult _getFallbackFeedData() {
    Logger.userAction('API failed - returning empty feed data');

    return FeedDataResult.success(categories: [], skills: [], locations: []);
  }



  /// Load feed data with retry mechanism
  Future<FeedDataResult> loadFeedDataWithRetry({int maxRetries = 3}) async {
    int attempts = 0;

    while (attempts < maxRetries) {
      try {
        final result = await loadFeedDataWithFallback();

        if (result.success) {
          return result;
        }

        attempts++;

        if (attempts < maxRetries) {
          Logger.warning(
            'Feed data load attempt $attempts failed, retrying...',
          );
          await Future.delayed(
            Duration(seconds: attempts * 2),
          ); // Exponential backoff
        }
      } catch (e) {
        attempts++;

        if (attempts < maxRetries) {
          Logger.warning(
            'Feed data load attempt $attempts failed with error: $e',
          );
          await Future.delayed(Duration(seconds: attempts * 2));
        } else {
          Logger.error('All feed data load attempts failed', error: e);
          return FeedDataResult.failure(
            message: 'Failed to load feed data after $maxRetries attempts',
          );
        }
      }
    }

    return FeedDataResult.failure(
      message: 'Failed to load feed data after $maxRetries attempts',
    );
  }

  /// Check if feed data needs refresh based on last update time
  bool shouldRefreshFeedData(DateTime? lastUpdated) {
    if (lastUpdated == null) return true;

    final now = DateTime.now();
    final difference = now.difference(lastUpdated);

    // Refresh if data is older than 5 minutes
    return difference.inMinutes > 5;
  }

  /// Get cached feed data if available and not stale
  Future<FeedDataResult?> getCachedFeedData(DateTime? lastUpdated) async {
    if (lastUpdated == null || shouldRefreshFeedData(lastUpdated)) {
      return null;
    }

    // In a real implementation, you might want to cache this data
    // For now, we'll always fetch fresh data
    return null;
  }
}

/// Portfolio result wrapper
class PortfolioResult {
  final bool success;
  final List<PortfolioModel> portfolios;
  final int totalCount;
  final int totalPages;
  final String message;

  PortfolioResult({
    required this.success,
    required this.portfolios,
    required this.totalCount,
    required this.totalPages,
    required this.message,
  });
}

/// Portfolio detail result wrapper
class PortfolioDetailResult {
  final bool success;
  final PortfolioModel? portfolio;
  final String message;

  PortfolioDetailResult({
    required this.success,
    required this.portfolio,
    required this.message,
  });

  /// Upload media file to portfolio
  /// This should be called for each file individually
  Future<MediaUploadResult> uploadMedia({
    required String portfolioId,
    required File file,
    required String mediaType, // 'image' or 'video'
    int? orderIndex,
    Function(int sent, int total)? onProgress,
  }) async {
    try {
      Logger.userAction(
        'Uploading portfolio media',
        data: {'portfolio_id': portfolioId, 'media_type': mediaType},
      );

      final apiClient = ApiClient();
      final response = await apiClient.uploadFile<Map<String, dynamic>>(
        ApiEndpoints.uploadPortfolioMedia,
        file,
        fieldName: 'file',
        additionalData: {
          'portfolio_id': portfolioId,
          'media_type': mediaType,
          if (orderIndex != null) 'order_index': orderIndex,
        },
        onSendProgress: onProgress,
        fromJson: (data) => data as Map<String, dynamic>,
      );

      if (response.success && response.data != null) {
        Logger.userAction('Media uploaded successfully');
        return MediaUploadResult.success(
          mediaId: response.data!['id'].toString(),
          fileUrl: response.data!['file_url'] as String,
          filePath: response.data!['file_path'] as String,
        );
      } else {
        Logger.warning('Failed to upload media: ${response.message}');
        return MediaUploadResult.failure(message: response.message);
      }
    } on ApiError catch (e) {
      Logger.error('Upload media API error', error: e);
      return MediaUploadResult.failure(message: e.message);
    } catch (e) {
      Logger.error('Upload media unexpected error', error: e);
      return MediaUploadResult.failure(message: 'Upload failed');
    }
  }

  /// Upload multiple media files to portfolio
  Future<List<MediaUploadResult>> uploadMultipleMedia({
    required String portfolioId,
    required List<File> files,
    required String mediaType,
    Function(int fileIndex, int sent, int total)? onProgress,
  }) async {
    final results = <MediaUploadResult>[];

    for (var i = 0; i < files.length; i++) {
      final result = await uploadMedia(
        portfolioId: portfolioId,
        file: files[i],
        mediaType: mediaType,
        orderIndex: i,
        onProgress: onProgress != null
            ? (sent, total) => onProgress(i, sent, total)
            : null,
      );
      results.add(result);
    }

    return results;
  }

  /// Delete media file
  Future<bool> deleteMedia(String mediaId) async {
    try {
      Logger.userAction('Deleting media', data: {'media_id': mediaId});

      final apiClient = ApiClient();
      final response = await apiClient.delete(
        ApiEndpoints.getDeleteMediaEndpoint(mediaId),
      );

      if (response.success) {
        Logger.userAction('Media deleted successfully');
        return true;
      } else {
        Logger.warning('Failed to delete media: ${response.message}');
        return false;
      }
    } catch (e) {
      Logger.error('Delete media error', error: e);
      return false;
    }
  }
}

/// Media upload result wrapper
class MediaUploadResult {
  final bool success;
  final String? mediaId;
  final String? fileUrl;
  final String? filePath;
  final String message;

  MediaUploadResult._({
    required this.success,
    this.mediaId,
    this.fileUrl,
    this.filePath,
    required this.message,
  });

  factory MediaUploadResult.success({
    required String mediaId,
    required String fileUrl,
    required String filePath,
  }) {
    return MediaUploadResult._(
      success: true,
      mediaId: mediaId,
      fileUrl: fileUrl,
      filePath: filePath,
      message: 'Upload successful',
    );
  }

  factory MediaUploadResult.failure({required String message}) {
    return MediaUploadResult._(success: false, message: message);
  }
}
