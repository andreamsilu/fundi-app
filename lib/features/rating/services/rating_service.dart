import '../../../core/network/api_client.dart';
import '../../../core/utils/logger.dart';
import '../../../core/constants/api_endpoints.dart';
import '../models/rating_model.dart';

/// Rating service for handling rating-related API calls
class RatingService {
  final ApiClient _apiClient = ApiClient();

  /// Create a rating and review
  Future<ApiResponse<RatingModel>> createRating({
    required String fundiId,
    required String jobId,
    required int rating,
    String? review,
  }) async {
    try {
      final response = await _apiClient.post(ApiEndpoints.createRating, {
        'fundi_id': fundiId,
        'job_id': jobId,
        'rating': rating.toString(),
        'review': review ?? '',
      }, {});

      if (response.success) {
        final rating = RatingModel.fromJson(response.data['data']);
        return ApiResponse<RatingModel>(
          success: true,
          data: rating,
          message: response.data['message'],
        );
      } else {
        return ApiResponse<RatingModel>(
          success: false,
          message: response.data['message'] ?? 'Failed to create rating',
        );
      }
    } catch (e) {
      Logger.error('Create rating error', error: e);
      return ApiResponse<RatingModel>(
        success: false,
        message: 'An error occurred while creating rating',
      );
    }
  }

  /// Get fundi's ratings and reviews
  Future<ApiResponse<FundiRatingSummary>> getFundiRatings({
    required String fundiId,
    int page = 1,
    int limit = 15,
  }) async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.getFundiRatingsEndpoint(fundiId),
        queryParameters: {'page': page, 'limit': limit},
      );

      if (response.success) {
        final summary = FundiRatingSummary.fromJson(response.data['data']);
        return ApiResponse<FundiRatingSummary>(
          success: true,
          data: summary,
          message: response.data['message'],
        );
      } else {
        return ApiResponse<FundiRatingSummary>(
          success: false,
          message: response.data['message'] ?? 'Failed to fetch fundi ratings',
        );
      }
    } catch (e) {
      Logger.error('Get fundi ratings error', error: e);
      return ApiResponse<FundiRatingSummary>(
        success: false,
        message: 'An error occurred while fetching fundi ratings',
      );
    }
  }

  /// Get customer's ratings given
  Future<ApiResponse<List<RatingModel>>> getMyRatings({
    int page = 1,
    int limit = 15,
  }) async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.myRatings,
        queryParameters: {'page': page, 'limit': limit},
      );

      if (response.success) {
        final List<dynamic> ratingsData = response.data['data']['data'] ?? [];
        final ratings = ratingsData
            .map((json) => RatingModel.fromJson(json))
            .toList();

        return ApiResponse<List<RatingModel>>(
          success: true,
          data: ratings,
          message: response.data['message'],
        );
      } else {
        return ApiResponse<List<RatingModel>>(
          success: false,
          message: response.data['message'] ?? 'Failed to fetch your ratings',
        );
      }
    } catch (e) {
      Logger.error('Get my ratings error', error: e);
      return ApiResponse<List<RatingModel>>(
        success: false,
        message: 'An error occurred while fetching your ratings',
      );
    }
  }

  /// Update rating and review
  Future<ApiResponse<RatingModel>> updateRating({
    required String ratingId,
    int? rating,
    String? review,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (rating != null) data['rating'] = rating;
      if (review != null) data['review'] = review;

      final response = await _apiClient.put(
        ApiEndpoints.getUpdateRatingEndpoint(ratingId),
        {},
        data: data,
      );

      if (response.success) {
        final rating = RatingModel.fromJson(response.data['data']);
        return ApiResponse<RatingModel>(
          success: true,
          data: rating,
          message: response.data['message'],
        );
      } else {
        return ApiResponse<RatingModel>(
          success: false,
          message: response.data['message'] ?? 'Failed to update rating',
        );
      }
    } catch (e) {
      Logger.error('Update rating error', error: e);
      return ApiResponse<RatingModel>(
        success: false,
        message: 'An error occurred while updating rating',
      );
    }
  }

  /// Delete rating and review
  Future<ApiResponse<bool>> deleteRating({required String ratingId}) async {
    try {
      final response = await _apiClient.delete(
        ApiEndpoints.getDeleteRatingEndpoint(ratingId),
      );

      if (response.success) {
        return ApiResponse<bool>(
          success: true,
          data: true,
          message: response.data['message'],
        );
      } else {
        return ApiResponse<bool>(
          success: false,
          message: response.data['message'] ?? 'Failed to delete rating',
        );
      }
    } catch (e) {
      Logger.error('Delete rating error', error: e);
      return ApiResponse<bool>(
        success: false,
        message: 'An error occurred while deleting rating',
      );
    }
  }
}

/// Generic API response wrapper
class ApiResponse<T> {
  final bool success;
  final T? data;
  final String message;
  final int? statusCode;

  const ApiResponse({
    required this.success,
    this.data,
    required this.message,
    this.statusCode,
  });
}
