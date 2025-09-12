import '../../../core/network/api_client.dart';
import '../../../core/constants/api_endpoints.dart';
import '../models/fundi_application_model.dart';
import '../../../core/utils/logger.dart';

/// Service for handling fundi application operations
/// Manages API calls for fundi application submission and status checking
class FundiApplicationService {
  final ApiClient _apiClient = ApiClient();

  /// Submit a new fundi application
  Future<FundiApplicationResult> submitApplication({
    required String fullName,
    required String phoneNumber,
    required String email,
    required String nidaNumber,
    required String vetaCertificate,
    required String location,
    required String bio,
    required List<String> skills,
    required List<String> languages,
    required List<String> portfolioImages,
  }) async {
    try {
      Logger.info('Submitting fundi application for: $fullName');

      final requestData = {
        'full_name': fullName,
        'phone_number': phoneNumber,
        'email': email,
        'nida_number': nidaNumber,
        'veta_certificate': vetaCertificate,
        'location': location,
        'bio': bio,
        'skills': skills,
        'languages': languages,
        'portfolio_images': portfolioImages,
      };

      final response = await _apiClient.post(
        ApiEndpoints.fundiApplications,
        {},
        requestData,
      );

      if (response.statusCode == 201) {
        final application = FundiApplicationModel.fromJson(response.data);
        Logger.info('Fundi application submitted successfully');
        return FundiApplicationResult.success(
          application: application,
          message: 'Application submitted successfully',
        );
      } else {
        final errorMessage =
            response.data['message'] ?? 'Failed to submit application';
        Logger.error('Fundi application submission failed: $errorMessage');
        return FundiApplicationResult.error(message: errorMessage);
      }
    } catch (e) {
      Logger.error('Fundi application submission error', error: e);
      return FundiApplicationResult.error(
        message: 'Network error. Please check your connection and try again.',
      );
    }
  }

  /// Get current user's fundi application status
  Future<FundiApplicationResult> getApplicationStatus() async {
    try {
      Logger.info('Fetching fundi application status');

      final response = await _apiClient.get(
        ApiEndpoints.fundiApplicationStatus,
      );

      if (response.statusCode == 200) {
        if (response.data != null) {
          final application = FundiApplicationModel.fromJson(response.data);
          Logger.info('Fundi application status retrieved successfully');
          return FundiApplicationResult.success(
            application: application,
            message: 'Application status retrieved',
          );
        } else {
          Logger.info('No fundi application found');
          return FundiApplicationResult.success(
            message: 'No application found',
          );
        }
      } else {
        final errorMessage =
            response.data['message'] ?? 'Failed to get application status';
        Logger.error('Failed to get fundi application status: $errorMessage');
        return FundiApplicationResult.error(message: errorMessage);
      }
    } catch (e) {
      Logger.error('Fundi application status error', error: e);
      return FundiApplicationResult.error(
        message: 'Network error. Please check your connection and try again.',
      );
    }
  }

  /// Get all fundi applications (for admin)
  Future<FundiApplicationListResult> getAllApplications({
    int page = 1,
    int limit = 20,
    ApplicationStatus? status,
  }) async {
    try {
      Logger.info('Fetching all fundi applications');

      final queryParams = <String, dynamic>{'page': page, 'limit': limit};

      if (status != null) {
        queryParams['status'] = status.value;
      }

      final response = await _apiClient.get(
        ApiEndpoints.fundiApplications,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final applications = (response.data['data'] as List)
            .map((json) => FundiApplicationModel.fromJson(json))
            .toList();

        Logger.info('Fundi applications retrieved successfully');
        return FundiApplicationListResult.success(
          applications: applications,
          totalCount: response.data['total'] ?? applications.length,
          currentPage: response.data['current_page'] ?? page,
          totalPages: response.data['last_page'] ?? 1,
          message: 'Applications retrieved successfully',
        );
      } else {
        final errorMessage =
            response.data['message'] ?? 'Failed to get applications';
        Logger.error('Failed to get fundi applications: $errorMessage');
        return FundiApplicationListResult.error(message: errorMessage);
      }
    } catch (e) {
      Logger.error('Fundi applications fetch error', error: e);
      return FundiApplicationListResult.error(
        message: 'Network error. Please check your connection and try again.',
      );
    }
  }

  /// Update application status (for admin)
  Future<FundiApplicationResult> updateApplicationStatus({
    required String applicationId,
    required ApplicationStatus status,
    String? rejectionReason,
  }) async {
    try {
      Logger.info('Updating fundi application status: $applicationId');

      final requestData = {
        'status': status.value,
        if (rejectionReason != null) 'rejection_reason': rejectionReason,
      };

      final response = await _apiClient.patch(
        ApiEndpoints.getFundiApplicationStatusByIdEndpoint(applicationId),
        data: requestData,
      );

      if (response.statusCode == 200) {
        final application = FundiApplicationModel.fromJson(response.data);
        Logger.info('Fundi application status updated successfully');
        return FundiApplicationResult.success(
          application: application,
          message: 'Application status updated successfully',
        );
      } else {
        final errorMessage =
            response.data['message'] ?? 'Failed to update application status';
        Logger.error(
          'Failed to update fundi application status: $errorMessage',
        );
        return FundiApplicationResult.error(message: errorMessage);
      }
    } catch (e) {
      Logger.error('Fundi application status update error', error: e);
      return FundiApplicationResult.error(
        message: 'Network error. Please check your connection and try again.',
      );
    }
  }

  /// Delete fundi application
  Future<FundiApplicationResult> deleteApplication(String applicationId) async {
    try {
      Logger.info('Deleting fundi application: $applicationId');

      final response = await _apiClient.delete(
        ApiEndpoints.getFundiApplicationByIdEndpoint(applicationId),
      );

      if (response.statusCode == 200) {
        Logger.info('Fundi application deleted successfully');
        return FundiApplicationResult.success(
          message: 'Application deleted successfully',
        );
      } else {
        final errorMessage =
            response.data['message'] ?? 'Failed to delete application';
        Logger.error('Failed to delete fundi application: $errorMessage');
        return FundiApplicationResult.error(message: errorMessage);
      }
    } catch (e) {
      Logger.error('Fundi application deletion error', error: e);
      return FundiApplicationResult.error(
        message: 'Network error. Please check your connection and try again.',
      );
    }
  }
}

/// Result class for fundi application operations
class FundiApplicationResult {
  final bool success;
  final String message;
  final FundiApplicationModel? application;

  const FundiApplicationResult._({
    required this.success,
    required this.message,
    this.application,
  });

  factory FundiApplicationResult.success({
    required String message,
    FundiApplicationModel? application,
  }) {
    return FundiApplicationResult._(
      success: true,
      message: message,
      application: application,
    );
  }

  factory FundiApplicationResult.error({required String message}) {
    return FundiApplicationResult._(success: false, message: message);
  }
}

/// Result class for fundi application list operations
class FundiApplicationListResult {
  final bool success;
  final String message;
  final List<FundiApplicationModel> applications;
  final int totalCount;
  final int currentPage;
  final int totalPages;

  const FundiApplicationListResult._({
    required this.success,
    required this.message,
    required this.applications,
    required this.totalCount,
    required this.currentPage,
    required this.totalPages,
  });

  factory FundiApplicationListResult.success({
    required List<FundiApplicationModel> applications,
    required int totalCount,
    required int currentPage,
    required int totalPages,
    required String message,
  }) {
    return FundiApplicationListResult._(
      success: true,
      message: message,
      applications: applications,
      totalCount: totalCount,
      currentPage: currentPage,
      totalPages: totalPages,
    );
  }

  factory FundiApplicationListResult.error({required String message}) {
    return FundiApplicationListResult._(
      success: false,
      message: message,
      applications: [],
      totalCount: 0,
      currentPage: 1,
      totalPages: 1,
    );
  }
}
