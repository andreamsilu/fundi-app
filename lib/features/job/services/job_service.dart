import '../models/job_model.dart';
import '../../../core/network/api_client.dart';
import '../../../core/utils/logger.dart';
import '../../../core/constants/api_endpoints.dart';

/// Job service handling all job-related operations
/// Provides methods for creating, fetching, updating, and managing jobs
class JobService {
  static final JobService _instance = JobService._internal();
  factory JobService() => _instance;
  JobService._internal();

  final ApiClient _apiClient = ApiClient();

  /// Create a new job posting
  Future<JobResult> createJob({
    required String title,
    required String description,
    required String category,
    required String location,
    required double budget,
    required String budgetType,
    required DateTime deadline,
    required List<String> requiredSkills,
    double? latitude,
    double? longitude,
    List<String>? imageUrls,
  }) async {
    try {
      Logger.userAction(
        'Create job attempt',
        data: {'title': title, 'category': category},
      );

      final response = await _apiClient
          .post<Map<String, dynamic>>(ApiEndpoints.createJob, {}, {
            'title': title,
            'description': description,
            'category_id': category,
            'budget': budget,
            'deadline': deadline.toIso8601String(),
            if (latitude != null) 'location_lat': latitude,
            if (longitude != null) 'location_lng': longitude,
          }, fromJson: (data) => data as Map<String, dynamic>);

      if (response.success && response.data != null) {
        final job = JobModel.fromJson(response.data!);

        Logger.userAction('Job created successfully', data: {'jobId': job.id});

        return JobResult.success(job: job, message: response.message);
      } else {
        Logger.warning('Job creation failed: ${response.message}');
        return JobResult.failure(message: response.message);
      }
    } on ApiError catch (e) {
      Logger.error('Create job API error', error: e);
      return JobResult.failure(message: e.message);
    } catch (e) {
      Logger.error('Create job unexpected error', error: e);
      return JobResult.failure(message: 'An unexpected error occurred');
    }
  }

  /// Get jobs with pagination and filters
  Future<JobListResult> getJobs({
    int page = 1,
    int limit = 20,
    String? category,
    String? location,
    double? minBudget,
    double? maxBudget,
    JobStatus? status,
    String? search,
  }) async {
    try {
      Logger.userAction(
        'Fetch jobs',
        data: {
          'page': page,
          'limit': limit,
          'category': category,
          'location': location,
        },
      );

      final queryParams = <String, dynamic>{'page': page, 'limit': limit};

      if (category != null) queryParams['category'] = category;
      if (location != null) queryParams['location'] = location;
      if (minBudget != null) queryParams['min_budget'] = minBudget;
      if (maxBudget != null) queryParams['max_budget'] = maxBudget;
      if (status != null) queryParams['status'] = status.value;
      if (search != null) queryParams['search'] = search;

      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiEndpoints.jobs,
        queryParameters: queryParams,
        fromJson: (data) => data as Map<String, dynamic>,
      );

      if (response.success && response.data != null) {
        final data = response.data!;
        final jobsData = data['data'] as List<dynamic>;
        final jobs = jobsData
            .map(
              (jobData) => JobModel.fromJson(jobData as Map<String, dynamic>),
            )
            .toList();

        // Pagination data is in the response data object
        final totalCount = data['total'] as int;
        final totalPages = data['last_page'] as int;
        final currentPage = data['current_page'] as int;

        Logger.userAction(
          'Jobs fetched successfully',
          data: {'count': jobs.length, 'total': totalCount},
        );

        return JobListResult.success(
          jobs: jobs,
          totalCount: totalCount,
          totalPages: totalPages,
          currentPage: currentPage,
          message: response.message,
        );
      } else {
        Logger.warning('Fetch jobs failed: ${response.message}');
        return JobListResult.failure(message: response.message);
      }
    } on ApiError catch (e) {
      Logger.error('Fetch jobs API error', error: e);
      return JobListResult.failure(message: e.message);
    } catch (e) {
      Logger.error('Fetch jobs unexpected error', error: e);
      return JobListResult.failure(message: 'An unexpected error occurred');
    }
  }

  /// Get a specific job by ID
  Future<JobResult> getJobById(String jobId) async {
    try {
      Logger.userAction('Fetch job by ID', data: {'jobId': jobId});

      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiEndpoints.getJobByIdEndpoint(jobId),
        fromJson: (data) => data as Map<String, dynamic>,
      );

      if (response.success && response.data != null) {
        final job = JobModel.fromJson(response.data!);

        Logger.userAction('Job fetched successfully', data: {'jobId': jobId});

        return JobResult.success(job: job, message: response.message);
      } else {
        Logger.warning('Fetch job failed: ${response.message}');
        return JobResult.failure(message: response.message);
      }
    } on ApiError catch (e) {
      Logger.error('Fetch job API error', error: e);
      return JobResult.failure(message: e.message);
    } catch (e) {
      Logger.error('Fetch job unexpected error', error: e);
      return JobResult.failure(message: 'An unexpected error occurred');
    }
  }

  /// Update a job
  Future<JobResult> updateJob({
    required String jobId,
    String? title,
    String? description,
    String? category,
    String? location,
    double? budget,
    String? budgetType,
    DateTime? deadline,
    List<String>? requiredSkills,
    double? latitude,
    double? longitude,
    List<String>? imageUrls,
  }) async {
    try {
      Logger.userAction('Update job attempt', data: {'jobId': jobId});

      final data = <String, dynamic>{};
      if (title != null) data['title'] = title;
      if (description != null) data['description'] = description;
      if (category != null) data['category_id'] = category;
      if (budget != null) data['budget'] = budget;
      if (budgetType != null) data['budget_type'] = budgetType;
      if (deadline != null) data['deadline'] = deadline.toIso8601String();
      if (latitude != null) data['location_lat'] = latitude;
      if (longitude != null) data['location_lng'] = longitude;

      final response = await _apiClient.put<Map<String, dynamic>>(
        ApiEndpoints.getUpdateJobEndpoint(jobId),
        {},
        data: data.map((key, value) => MapEntry(key, value.toString())),
        fromJson: (data) => data as Map<String, dynamic>,
      );

      if (response.success && response.data != null) {
        final job = JobModel.fromJson(response.data!);

        Logger.userAction('Job updated successfully', data: {'jobId': jobId});

        return JobResult.success(job: job, message: response.message);
      } else {
        Logger.warning('Job update failed: ${response.message}');
        return JobResult.failure(message: response.message);
      }
    } on ApiError catch (e) {
      Logger.error('Update job API error', error: e);
      return JobResult.failure(message: e.message);
    } catch (e) {
      Logger.error('Update job unexpected error', error: e);
      return JobResult.failure(message: 'An unexpected error occurred');
    }
  }

  /// Delete a job
  Future<JobResult> deleteJob(String jobId) async {
    try {
      Logger.userAction('Delete job attempt', data: {'jobId': jobId});

      final response = await _apiClient.delete<Map<String, dynamic>>(
        ApiEndpoints.getDeleteJobEndpoint(jobId),
        fromJson: (data) => data as Map<String, dynamic>,
      );

      if (response.success) {
        Logger.userAction('Job deleted successfully', data: {'jobId': jobId});

        return JobResult.success(message: response.message);
      } else {
        Logger.warning('Job deletion failed: ${response.message}');
        return JobResult.failure(message: response.message);
      }
    } on ApiError catch (e) {
      Logger.error('Delete job API error', error: e);
      return JobResult.failure(message: e.message);
    } catch (e) {
      Logger.error('Delete job unexpected error', error: e);
      return JobResult.failure(message: 'An unexpected error occurred');
    }
  }

  /// Apply for a job
  Future<ApplicationResult> applyForJob(
    String id, {
    required String jobId,
    required String message,
    required double proposedBudget,
    required String proposedBudgetType,
    required int estimatedDays,
  }) async {
    try {
      Logger.userAction(
        'Apply for job',
        data: {
          'jobId': jobId,
          'proposedBudget': proposedBudget,
          'estimatedDays': estimatedDays,
        },
      );

      final response = await _apiClient.post<Map<String, dynamic>>(
        ApiEndpoints.getApplyToJobEndpoint(jobId),
        {},
        {
          'requirements': {'message': message, 'estimated_days': estimatedDays},
          'budget_breakdown': {
            'labor': proposedBudget * 0.7,
            'materials': proposedBudget * 0.2,
            'transport': proposedBudget * 0.1,
          },
          'estimated_time': estimatedDays * 24, // Convert days to hours
        },
        fromJson: (data) => data as Map<String, dynamic>,
      );

      if (response.success && response.data != null) {
        final application = JobApplicationModel.fromJson(response.data!);

        Logger.userAction(
          'Job application submitted successfully',
          data: {'jobId': jobId, 'applicationId': application.id},
        );

        return ApplicationResult.success(
          application: application,
          message: response.message,
        );
      } else {
        Logger.warning('Job application failed: ${response.message}');
        return ApplicationResult.failure(message: response.message);
      }
    } on ApiError catch (e) {
      Logger.error('Apply for job API error', error: e);
      return ApplicationResult.failure(message: e.message);
    } catch (e) {
      Logger.error('Apply for job unexpected error', error: e);
      return ApplicationResult.failure(message: 'An unexpected error occurred');
    }
  }

  /// Get job applications for a specific job
  Future<ApplicationListResult> getJobApplications(String jobId) async {
    try {
      Logger.userAction('Fetch job applications', data: {'jobId': jobId});

      final response = await _apiClient.get<List<dynamic>>(
        ApiEndpoints.getJobApplicationsEndpoint(jobId),
        fromJson: (data) => data as List<dynamic>,
      );

      if (response.success && response.data != null) {
        final applications = response.data!
            .map(
              (appData) =>
                  JobApplicationModel.fromJson(appData as Map<String, dynamic>),
            )
            .toList();

        Logger.userAction(
          'Job applications fetched successfully',
          data: {'jobId': jobId, 'count': applications.length},
        );

        return ApplicationListResult.success(
          applications: applications,
          message: response.message,
        );
      } else {
        Logger.warning('Fetch job applications failed: ${response.message}');
        return ApplicationListResult.failure(message: response.message);
      }
    } on ApiError catch (e) {
      Logger.error('Fetch job applications API error', error: e);
      return ApplicationListResult.failure(message: e.message);
    } catch (e) {
      Logger.error('Fetch job applications unexpected error', error: e);
      return ApplicationListResult.failure(
        message: 'An unexpected error occurred',
      );
    }
  }

  /// Accept a job application
  Future<ApplicationResult> acceptApplication(
    String jobId,
    String applicationId,
  ) async {
    try {
      Logger.userAction(
        'Accept job application',
        data: {'jobId': jobId, 'applicationId': applicationId},
      );

      final response = await _apiClient.patch<Map<String, dynamic>>(
        ApiEndpoints.getUpdateApplicationStatusEndpoint(applicationId),
        data: {'status': 'accepted'},
        fromJson: (data) => data as Map<String, dynamic>,
      );

      if (response.success && response.data != null) {
        final application = JobApplicationModel.fromJson(response.data!);

        Logger.userAction(
          'Job application accepted successfully',
          data: {'jobId': jobId, 'applicationId': applicationId},
        );

        return ApplicationResult.success(
          application: application,
          message: response.message,
        );
      } else {
        Logger.warning('Accept application failed: ${response.message}');
        return ApplicationResult.failure(message: response.message);
      }
    } on ApiError catch (e) {
      Logger.error('Accept application API error', error: e);
      return ApplicationResult.failure(message: e.message);
    } catch (e) {
      Logger.error('Accept application unexpected error', error: e);
      return ApplicationResult.failure(message: 'An unexpected error occurred');
    }
  }

  /// Reject a job application
  Future<ApplicationResult> rejectApplication(
    String jobId,
    String applicationId,
  ) async {
    try {
      Logger.userAction(
        'Reject job application',
        data: {'jobId': jobId, 'applicationId': applicationId},
      );

      final response = await _apiClient.patch<Map<String, dynamic>>(
        ApiEndpoints.getUpdateApplicationStatusEndpoint(applicationId),
        data: {'status': 'rejected'},
        fromJson: (data) => data as Map<String, dynamic>,
      );

      if (response.success && response.data != null) {
        final application = JobApplicationModel.fromJson(response.data!);

        Logger.userAction(
          'Job application rejected successfully',
          data: {'jobId': jobId, 'applicationId': applicationId},
        );

        return ApplicationResult.success(
          application: application,
          message: response.message,
        );
      } else {
        Logger.warning('Reject application failed: ${response.message}');
        return ApplicationResult.failure(message: response.message);
      }
    } on ApiError catch (e) {
      Logger.error('Reject application API error', error: e);
      return ApplicationResult.failure(message: e.message);
    } catch (e) {
      Logger.error('Reject application unexpected error', error: e);
      return ApplicationResult.failure(message: 'An unexpected error occurred');
    }
  }
}

/// Job result wrapper
class JobResult {
  final bool success;
  final String message;
  final JobModel? job;

  JobResult._({required this.success, required this.message, this.job});

  factory JobResult.success({required String message, JobModel? job}) {
    return JobResult._(success: true, message: message, job: job);
  }

  factory JobResult.failure({required String message}) {
    return JobResult._(success: false, message: message);
  }
}

/// Job list result wrapper
class JobListResult {
  final bool success;
  final String message;
  final List<JobModel> jobs;
  final int totalCount;
  final int totalPages;
  final int currentPage;

  JobListResult._({
    required this.success,
    required this.message,
    required this.jobs,
    required this.totalCount,
    required this.totalPages,
    required this.currentPage,
  });

  factory JobListResult.success({
    required String message,
    required List<JobModel> jobs,
    required int totalCount,
    required int totalPages,
    required int currentPage,
  }) {
    return JobListResult._(
      success: true,
      message: message,
      jobs: jobs,
      totalCount: totalCount,
      totalPages: totalPages,
      currentPage: currentPage,
    );
  }

  factory JobListResult.failure({required String message}) {
    return JobListResult._(
      success: false,
      message: message,
      jobs: [],
      totalCount: 0,
      totalPages: 0,
      currentPage: 0,
    );
  }
}

/// Application result wrapper
class ApplicationResult {
  final bool success;
  final String message;
  final JobApplicationModel? application;

  ApplicationResult._({
    required this.success,
    required this.message,
    this.application,
  });

  factory ApplicationResult.success({
    required String message,
    JobApplicationModel? application,
  }) {
    return ApplicationResult._(
      success: true,
      message: message,
      application: application,
    );
  }

  factory ApplicationResult.failure({required String message}) {
    return ApplicationResult._(success: false, message: message);
  }
}

/// Application list result wrapper
class ApplicationListResult {
  final bool success;
  final String message;
  final List<JobApplicationModel> applications;

  ApplicationListResult._({
    required this.success,
    required this.message,
    required this.applications,
  });

  factory ApplicationListResult.success({
    required String message,
    required List<JobApplicationModel> applications,
  }) {
    return ApplicationListResult._(
      success: true,
      message: message,
      applications: applications,
    );
  }

  factory ApplicationListResult.failure({required String message}) {
    return ApplicationListResult._(
      success: false,
      message: message,
      applications: [],
    );
  }
}
