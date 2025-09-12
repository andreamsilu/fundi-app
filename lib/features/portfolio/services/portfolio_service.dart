import 'dart:io';

import '../../../core/network/api_client.dart';
import '../../../core/utils/logger.dart';
import '../../../core/constants/api_endpoints.dart';
import '../models/portfolio_model.dart';

/// Portfolio service for managing fundi portfolios
/// Handles CRUD operations for portfolio items
class PortfolioService {
  final ApiClient _apiClient = ApiClient();

  /// Get portfolios for a specific fundi
  Future<PortfolioResult> getPortfolios({
    required String fundiId,
    int page = 1,
    int limit = 20,
    String? category,
    String? search,
  }) async {
    try {
      Logger.apiRequest('GET', ApiEndpoints.portfolios);

      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiEndpoints.portfolios,
        queryParameters: {
          'page': page,
          'limit': limit,
          if (category != null) 'category': category,
          if (search != null) 'search': search,
        },
        fromJson: (data) => data as Map<String, dynamic>,
      );

      Logger.apiResponse(
        'GET',
        ApiEndpoints.portfolios,
        response.statusCode,
        response: response.data,
      );

      if (response.success && response.data != null) {
        final data = response.data!;
        final portfolios = (data['portfolios'] as List)
            .map(
              (json) => PortfolioModel.fromJson(json as Map<String, dynamic>),
            )
            .toList();

        return PortfolioResult(
          success: true,
          portfolios: portfolios,
          totalCount: data['total_count'] as int,
          totalPages: data['total_pages'] as int,
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
      Logger.apiError('GET', ApiEndpoints.portfolios, e);
      return PortfolioResult(
        success: false,
        portfolios: [],
        totalCount: 0,
        totalPages: 0,
        message: 'Failed to load portfolios',
      );
    }
  }

  /// Get a specific portfolio by ID
  Future<PortfolioDetailResult> getPortfolio(String portfolioId) async {
    try {
      Logger.apiRequest(
        'GET',
        ApiEndpoints.getPortfolioByIdEndpoint(portfolioId),
      );

      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiEndpoints.getPortfolioByIdEndpoint(portfolioId),
        fromJson: (data) => data as Map<String, dynamic>,
      );

      Logger.apiResponse(
        'GET',
        ApiEndpoints.getPortfolioByIdEndpoint(portfolioId),
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
        'GET',
        ApiEndpoints.getPortfolioByIdEndpoint(portfolioId),
        e,
      );
      return PortfolioDetailResult(
        success: false,
        portfolio: null,
        message: 'Failed to load portfolio',
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

  /// Upload portfolio media files
  Future<MediaUploadResult> uploadMedia({
    required String portfolioId,
    required List<String> filePaths,
    required List<String> fileTypes, // 'image' or 'video'
  }) async {
    try {
      Logger.apiRequest('POST', ApiEndpoints.uploadPortfolioMedia);

      // This would typically involve uploading files to a storage service
      // For now, we'll simulate the upload process
      final response = await _apiClient.post<Map<String, dynamic>>(
        ApiEndpoints.uploadPortfolioMedia,
        {},
        {'file_paths': filePaths, 'file_types': fileTypes},
        fromJson: (data) => data as Map<String, dynamic>,
      );

      Logger.apiResponse(
        'POST',
        ApiEndpoints.uploadPortfolioMedia,
        response.statusCode,
        response: response.data,
      );

      if (response.success && response.data != null) {
        final data = response.data!;
        return MediaUploadResult(
          success: true,
          imageUrls: List<String>.from(data['image_urls'] ?? []),
          videoUrls: List<String>.from(data['video_urls'] ?? []),
          message: response.message,
        );
      } else {
        return MediaUploadResult(
          success: false,
          imageUrls: [],
          videoUrls: [],
          message: response.message,
        );
      }
    } catch (e) {
      Logger.apiError('POST', ApiEndpoints.uploadPortfolioMedia, e);
      return MediaUploadResult(
        success: false,
        imageUrls: [],
        videoUrls: [],
        message: 'Failed to upload media',
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
        return PortfolioCategory.values.map((e) => e.value).toList();
      }
    } catch (e) {
      Logger.apiError('GET', ApiEndpoints.categories, e);
      return PortfolioCategory.values.map((e) => e.value).toList();
    }
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
}

/// Media upload result wrapper
class MediaUploadResult {
  final bool success;
  final List<String> imageUrls;
  final List<String> videoUrls;
  final String message;

  MediaUploadResult({
    required this.success,
    required this.imageUrls,
    required this.videoUrls,
    required this.message,
  });
}
