import 'dart:io';
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
    required int categoryId,
    required String location,
    required double budget,
    required String budgetType,
    required DateTime deadline,
    String urgency = 'medium',
    String? preferredTime,
    List<String>? requiredSkills,
    double? latitude,
    double? longitude,
    List<String>? imageUrls,
  }) async {
    try {
      Logger.userAction(
        'Create job attempt',
        data: {'title': title, 'categoryId': categoryId, 'urgency': urgency},
      );

      final response = await _apiClient.post<Map<String, dynamic>>(
        ApiEndpoints.createJob,
        {},
        {
          'title': title,
          'description': description,
          'location': location,
          'budget': budget,
          'category_id': categoryId,
          'urgency': urgency,
          'deadline': deadline.toIso8601String().split(
            'T',
          )[0], // Format as YYYY-MM-DD
          if (preferredTime != null) 'preferred_time': preferredTime,
          if (latitude != null) 'location_lat': latitude,
          if (longitude != null) 'location_lng': longitude,
          if (requiredSkills != null) 'required_skills': requiredSkills,
          if (imageUrls != null) 'image_urls': imageUrls,
        },
        fromJson: (data) => data as Map<String, dynamic>,
      );

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

  /// Get available jobs (public feed) with pagination and filters
  Future<JobListResult> getAvailableJobs({
    int page = 1,
    int limit = 20,
    String? category,
    String? location,
    double? minBudget,
    double? maxBudget,
    JobStatus? status,
    String? search,
    String? requestId,
  }) async {
    try {
      Logger.userAction(
        'Fetch available jobs',
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
        ApiEndpoints.jobs, // Use /jobs for available jobs (public feed)
        queryParameters: queryParams,
        fromJson: (data) => data as Map<String, dynamic>,
        requestId: requestId,
      );

      if (response.success && response.data != null) {
        final data = response.data!;
        // API now returns a consistent structure: { jobs: [], pagination: {...} }
        final jobsData = (data['jobs'] as List<dynamic>? ?? <dynamic>[]);
        final jobs = jobsData
            .map(
              (jobData) => JobModel.fromJson(jobData as Map<String, dynamic>),
            )
            .toList();

        // Pagination object
        final pagination = (data['pagination'] as Map<String, dynamic>? ?? {});
        final totalCount = (pagination['total'] as int?) ?? jobs.length;
        final totalPages = (pagination['last_page'] as int?) ?? 1;
        final currentPage = (pagination['current_page'] as int?) ?? page;

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

  /// Get user's own jobs (my jobs) with pagination and filters
  Future<JobListResult> getMyJobs({
    int page = 1,
    int limit = 20,
    String? category,
    String? location,
    double? minBudget,
    double? maxBudget,
    JobStatus? status,
    String? search,
    String? requestId,
  }) async {
    try {
      Logger.userAction(
        'Fetch my jobs',
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
        ApiEndpoints.myJobs, // Use /jobs/my-jobs for user's own jobs
        queryParameters: queryParams,
        fromJson: (data) => data as Map<String, dynamic>,
        requestId: requestId,
      );

      if (response.success && response.data != null) {
        final data = response.data!;
        // API now returns a consistent structure: { jobs: [], pagination: {...} }
        final jobsData = (data['jobs'] as List<dynamic>? ?? <dynamic>[]);
        final jobs = jobsData
            .map(
              (jobData) => JobModel.fromJson(jobData as Map<String, dynamic>),
            )
            .toList();

        // Pagination object
        final pagination = (data['pagination'] as Map<String, dynamic>? ?? {});
        final totalCount = (pagination['total'] as int?) ?? jobs.length;
        final totalPages = (pagination['last_page'] as int?) ?? 1;
        final currentPage = (pagination['current_page'] as int?) ?? page;

        Logger.userAction(
          'My jobs fetched successfully',
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
        Logger.warning('Fetch my jobs failed: ${response.message}');
        return JobListResult.failure(message: response.message);
      }
    } on ApiError catch (e) {
      Logger.error('Fetch my jobs API error', error: e);
      return JobListResult.failure(message: e.message);
    } catch (e) {
      Logger.error('Fetch my jobs unexpected error', error: e);
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

  /// Get user's own job applications
  Future<ApplicationListResult> getMyApplications() async {
    try {
      Logger.userAction('Fetch my applications');

      final response = await _apiClient.get<List<dynamic>>(
        ApiEndpoints.myApplications,
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
          'My applications fetched successfully',
          data: {'count': applications.length},
        );

        return ApplicationListResult.success(
          applications: applications,
          message: response.message,
        );
      } else {
        Logger.warning('Fetch my applications failed: ${response.message}');
        return ApplicationListResult.failure(message: response.message);
      }
    } on ApiError catch (e) {
      Logger.error('Fetch my applications API error', error: e);
      return ApplicationListResult.failure(message: e.message);
    } catch (e) {
      Logger.error('Fetch my applications unexpected error', error: e);
      return ApplicationListResult.failure(
        message: 'An unexpected error occurred',
      );
    }
  }

  /// Check if current user has applied to a specific job
  Future<bool> hasAppliedToJob(String jobId) async {
    try {
      final result = await getMyApplications();
      if (result.success) {
        return result.applications.any((app) => app.jobId == jobId);
      }
      return false;
    } catch (e) {
      Logger.error('Check application status error', error: e);
      return false;
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

  /// Upload job media file
  Future<JobMediaUploadResult> uploadJobMedia({
    required String jobId,
    required File file,
    required String mediaType, // 'image' or 'video'
    int? orderIndex,
    Function(int sent, int total)? onProgress,
  }) async {
    try {
      Logger.userAction(
        'Uploading job media',
        data: {'job_id': jobId, 'media_type': mediaType},
      );

      final response = await _apiClient.uploadFile<Map<String, dynamic>>(
        ApiEndpoints.uploadJobMedia,
        file,
        fieldName: 'file',
        additionalData: {
          'job_id': jobId,
          'media_type': mediaType,
          if (orderIndex != null) 'order_index': orderIndex,
        },
        onSendProgress: onProgress,
        fromJson: (data) => data as Map<String, dynamic>,
      );

      if (response.success && response.data != null) {
        Logger.userAction('Job media uploaded successfully');
        return JobMediaUploadResult.success(
          mediaId: response.data!['id'].toString(),
          fileUrl: response.data!['file_url'] as String,
          filePath: response.data!['file_path'] as String,
        );
      } else {
        Logger.warning('Failed to upload job media: ${response.message}');
        return JobMediaUploadResult.failure(message: response.message);
      }
    } on ApiError catch (e) {
      Logger.error('Upload job media API error', error: e);
      return JobMediaUploadResult.failure(message: e.message);
    } catch (e) {
      Logger.error('Upload job media unexpected error', error: e);
      return JobMediaUploadResult.failure(message: 'Upload failed: $e');
    }
  }

  /// Upload multiple job images
  Future<List<JobMediaUploadResult>> uploadJobImages({
    required String jobId,
    required List<File> imageFiles,
    Function(int fileIndex, int sent, int total)? onProgress,
  }) async {
    final results = <JobMediaUploadResult>[];

    for (var i = 0; i < imageFiles.length; i++) {
      final result = await uploadJobMedia(
        jobId: jobId,
        file: imageFiles[i],
        mediaType: 'image',
        orderIndex: i,
        onProgress: onProgress != null
            ? (sent, total) => onProgress(i, sent, total)
            : null,
      );
      results.add(result);
    }

    return results;
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

/// Job media upload result wrapper
class JobMediaUploadResult {
  final bool success;
  final String? mediaId;
  final String? fileUrl;
  final String? filePath;
  final String message;

  JobMediaUploadResult._({
    required this.success,
    this.mediaId,
    this.fileUrl,
    this.filePath,
    required this.message,
  });

  factory JobMediaUploadResult.success({
    required String mediaId,
    required String fileUrl,
    required String filePath,
  }) {
    return JobMediaUploadResult._(
      success: true,
      mediaId: mediaId,
      fileUrl: fileUrl,
      filePath: filePath,
      message: 'Upload successful',
    );
  }

  factory JobMediaUploadResult.failure({required String message}) {
    return JobMediaUploadResult._(success: false, message: message);
  }
}
