import '../../../core/network/api_client.dart';
import '../../../core/constants/api_endpoints.dart';
import '../models/portfolio_approval_model.dart';
import '../models/work_submission_model.dart';

/// Service class for handling work approval-related API operations
/// Implements proper separation of concerns for work approval functionality
class WorkApprovalService {
  final ApiClient _apiClient;

  WorkApprovalService({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  /// Get paginated list of pending portfolio items
  ///
  /// Parameters:
  /// - page: Page number for pagination
  /// - limit: Number of items per page
  /// - category: Filter by category
  /// - fundiId: Filter by specific fundi
  Future<Map<String, dynamic>> getPendingPortfolioItems({
    int page = 1,
    int limit = 20,
    String? category,
    String? fundiId,
  }) async {
    try {
      // Build query parameters
      final queryParams = <String, dynamic>{'page': page, 'limit': limit};

      if (category != null && category.isNotEmpty) {
        queryParams['category'] = category;
      }
      if (fundiId != null && fundiId.isNotEmpty) {
        queryParams['fundiId'] = fundiId;
      }

      final response = await _apiClient.get(
        ApiEndpoints.workApprovalPortfolioPending,
        queryParameters: queryParams,
      );

      if (response.success && response.data != null) {
        final List<dynamic> portfolioData = response.data['data'] ?? [];
        final portfolioItems = portfolioData
            .map((json) => PortfolioApprovalModel.fromJson(json))
            .toList();

        return {
          'success': true,
          'portfolioItems': portfolioItems,
          'pagination': response.data['pagination'] ?? {},
          'message': 'Portfolio items fetched successfully',
        };
      } else {
        return {
          'success': false,
          'portfolioItems': <PortfolioApprovalModel>[],
          'pagination': {},
          'message': response.message,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'portfolioItems': <PortfolioApprovalModel>[],
        'pagination': {},
        'message': 'Error fetching portfolio items: ${e.toString()}',
      };
    }
  }

  /// Get paginated list of pending work submissions
  ///
  /// Parameters:
  /// - page: Page number for pagination
  /// - limit: Number of items per page
  /// - jobId: Filter by specific job
  /// - fundiId: Filter by specific fundi
  Future<Map<String, dynamic>> getPendingWorkSubmissions({
    int page = 1,
    int limit = 20,
    String? jobId,
    String? fundiId,
  }) async {
    try {
      // Build query parameters
      final queryParams = <String, dynamic>{'page': page, 'limit': limit};

      if (jobId != null && jobId.isNotEmpty) {
        queryParams['jobId'] = jobId;
      }
      if (fundiId != null && fundiId.isNotEmpty) {
        queryParams['fundiId'] = fundiId;
      }

      final response = await _apiClient.get(
        ApiEndpoints.workApprovalSubmissionsPending,
        queryParameters: queryParams,
      );

      if (response.success && response.data != null) {
        final List<dynamic> submissionData = response.data['data'] ?? [];
        final workSubmissions = submissionData
            .map((json) => WorkSubmissionModel.fromJson(json))
            .toList();

        return {
          'success': true,
          'workSubmissions': workSubmissions,
          'pagination': response.data['pagination'] ?? {},
          'message': 'Work submissions fetched successfully',
        };
      } else {
        return {
          'success': false,
          'workSubmissions': <WorkSubmissionModel>[],
          'pagination': {},
          'message': response.message,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'workSubmissions': <WorkSubmissionModel>[],
        'pagination': {},
        'message': 'Error fetching work submissions: ${e.toString()}',
      };
    }
  }

  /// Approve a portfolio item
  ///
  /// Parameters:
  /// - itemId: ID of the portfolio item to approve
  /// - notes: Optional approval notes
  Future<Map<String, dynamic>> approvePortfolioItem({
    required String itemId,
    String? notes,
  }) async {
    try {
      final requestData = <String, dynamic>{};
      if (notes != null && notes.isNotEmpty) {
        requestData['notes'] = notes;
      }

      final response = await _apiClient.post(
        ApiEndpoints.getWorkApprovalPortfolioApproveEndpoint(itemId),
        {},
        requestData.cast<String, String>(),
      );

      if (response.success) {
        return {'success': true, 'message': response.message};
      } else {
        return {'success': false, 'message': response.message};
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error approving portfolio item: ${e.toString()}',
      };
    }
  }

  /// Reject a portfolio item
  ///
  /// Parameters:
  /// - itemId: ID of the portfolio item to reject
  /// - rejectionReason: Reason for rejection
  /// - notes: Optional additional notes
  Future<Map<String, dynamic>> rejectPortfolioItem({
    required String itemId,
    required String rejectionReason,
    String? notes,
  }) async {
    try {
      final requestData = <String, dynamic>{
        'rejection_reason': rejectionReason,
      };
      if (notes != null && notes.isNotEmpty) {
        requestData['notes'] = notes;
      }

      final response = await _apiClient.post(
        ApiEndpoints.getWorkApprovalPortfolioRejectEndpoint(itemId),
        {},
        requestData,
      );

      if (response.success) {
        return {'success': true, 'message': response.message};
      } else {
        return {'success': false, 'message': response.message};
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error rejecting portfolio item: ${e.toString()}',
      };
    }
  }

  /// Approve a work submission
  ///
  /// Parameters:
  /// - submissionId: ID of the work submission to approve
  /// - notes: Optional approval notes
  /// - qualityScore: Quality score (1-10)
  Future<Map<String, dynamic>> approveWorkSubmission({
    required String submissionId,
    String? notes,
    double? qualityScore,
  }) async {
    try {
      final requestData = <String, dynamic>{};
      if (notes != null && notes.isNotEmpty) {
        requestData['notes'] = notes;
      }
      if (qualityScore != null) {
        requestData['quality_score'] = qualityScore;
      }

      final response = await _apiClient.post(
        ApiEndpoints.getWorkApprovalSubmissionsApproveEndpoint(submissionId),
        {},
        requestData,
      );

      if (response.success) {
        return {'success': true, 'message': response.message};
      } else {
        return {
          'success': false,
          'message': response.message,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error approving work submission: ${e.toString()}',
      };
    }
  }

  /// Reject a work submission
  ///
  /// Parameters:
  /// - submissionId: ID of the work submission to reject
  /// - rejectionReason: Reason for rejection
  /// - notes: Optional additional notes
  Future<Map<String, dynamic>> rejectWorkSubmission({
    required String submissionId,
    required String rejectionReason,
    String? notes,
  }) async {
    try {
      final requestData = <String, dynamic>{
        'rejection_reason': rejectionReason,
      };
      if (notes != null && notes.isNotEmpty) {
        requestData['notes'] = notes;
      }

      final response = await _apiClient.post(
        ApiEndpoints.getWorkApprovalSubmissionsRejectEndpoint(submissionId),
        {},
        requestData,
      );

      if (response.success) {
        return {
          'success': true,
          'message':
              response.message,
        };
      } else {
        return {
          'success': false,
          'message': response.message,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error rejecting work submission: ${e.toString()}',
      };
    }
  }

  /// Request revision for a work submission
  ///
  /// Parameters:
  /// - submissionId: ID of the work submission
  /// - revisionNotes: Detailed revision notes
  /// - deadline: Optional deadline for revision
  Future<Map<String, dynamic>> requestWorkSubmissionRevision({
    required String submissionId,
    required String revisionNotes,
    DateTime? deadline,
  }) async {
    try {
      final requestData = <String, dynamic>{'revision_notes': revisionNotes};
      if (deadline != null) {
        requestData['deadline'] = deadline.toIso8601String();
      }

      final response = await _apiClient.post(
        ApiEndpoints.getWorkApprovalSubmissionsRequestRevisionEndpoint(
          submissionId,
        ),
        {},
        requestData,
      );

      if (response.success) {
        return {
          'success': true,
          'message': response.message,
        };
      } else {
        return {
          'success': false,
          'message': response.message,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error requesting revision: ${e.toString()}',
      };
    }
  }

  /// Get detailed portfolio item information
  ///
  /// Parameters:
  /// - itemId: ID of the portfolio item
  Future<Map<String, dynamic>> getPortfolioItemDetails(String itemId) async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.getWorkApprovalPortfolioEndpoint(itemId),
      );

      if (response.success && response.data != null) {
        final portfolioItem = PortfolioApprovalModel.fromJson(response.data);
        return {
          'success': true,
          'portfolioItem': portfolioItem,
          'message': 'Portfolio item details fetched successfully',
        };
      } else {
        return {
          'success': false,
          'portfolioItem': null,
          'message':
              response.message,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'portfolioItem': null,
        'message': 'Error fetching portfolio item details: ${e.toString()}',
      };
    }
  }

  /// Get detailed work submission information
  ///
  /// Parameters:
  /// - submissionId: ID of the work submission
  Future<Map<String, dynamic>> getWorkSubmissionDetails(
    String submissionId,
  ) async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.getWorkApprovalSubmissionsEndpoint(submissionId),
      );

      if (response.success && response.data != null) {
        final workSubmission = WorkSubmissionModel.fromJson(response.data);
        return {
          'success': true,
          'workSubmission': workSubmission,
          'message': 'Work submission details fetched successfully',
        };
      } else {
        return {
          'success': false,
          'workSubmission': null,
          'message':
              response.message,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'workSubmission': null,
        'message': 'Error fetching work submission details: ${e.toString()}',
      };
    }
  }

  // Approval statistics method - REMOVED (work approval statistics endpoint not implemented in API)
}
