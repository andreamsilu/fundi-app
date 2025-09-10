import 'package:flutter/material.dart';
import '../models/job_model.dart';
import '../services/job_service.dart';
import '../../../core/utils/logger.dart';

/// Job provider for state management
/// Handles job-related state and operations
class JobProvider extends ChangeNotifier {
  final JobService _jobService = JobService();

  List<JobModel> _jobs = [];
  List<JobModel> _myJobs = [];
  List<JobApplicationModel> _applications = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _errorMessage;
  int _currentPage = 1;
  int _totalPages = 1;
  String? _searchQuery;
  String? _selectedCategory;
  String? _selectedLocation;

  /// Get jobs list
  List<JobModel> get jobs => _jobs;

  /// Get my jobs list
  List<JobModel> get myJobs => _myJobs;

  /// Get applications list
  List<JobApplicationModel> get applications => _applications;

  /// Check if loading
  bool get isLoading => _isLoading;

  /// Check if loading more
  bool get isLoadingMore => _isLoadingMore;

  /// Get error message
  String? get errorMessage => _errorMessage;

  /// Get current page
  int get currentPage => _currentPage;

  /// Get total pages
  int get totalPages => _totalPages;

  /// Get search query
  String? get searchQuery => _searchQuery;

  /// Get selected category
  String? get selectedCategory => _selectedCategory;

  /// Get selected location
  String? get selectedLocation => _selectedLocation;

  /// Load jobs with filters
  Future<void> loadJobs({
    bool refresh = false,
    String? search,
    String? category,
    String? location,
  }) async {
    if (refresh) {
      _currentPage = 1;
      _jobs.clear();
    }

    _setLoading(true);
    _clearError();

    try {
      final result = await _jobService.getJobs(
        page: _currentPage,
        search: search,
        category: category,
        location: location,
      );

      if (result.success) {
        if (refresh) {
          _jobs = result.jobs;
        } else {
          _jobs.addAll(result.jobs);
        }
        _totalPages = result.totalPages;
        _searchQuery = search;
        _selectedCategory = category;
        _selectedLocation = location;

        Logger.info(
          'Jobs loaded successfully',
          data: {'count': result.jobs.length, 'total': result.totalCount},
        );
      } else {
        _setError(result.message);
      }
    } catch (e) {
      Logger.error('Load jobs error', error: e);
      _setError('Failed to load jobs');
    } finally {
      _setLoading(false);
    }
  }

  /// Load more jobs (pagination)
  Future<void> loadMoreJobs() async {
    if (_isLoadingMore || _currentPage >= _totalPages) return;

    _setLoadingMore(true);

    try {
      _currentPage++;
      final result = await _jobService.getJobs(
        page: _currentPage,
        search: _searchQuery,
        category: _selectedCategory,
        location: _selectedLocation,
      );

      if (result.success) {
        _jobs.addAll(result.jobs);
        Logger.info('More jobs loaded', data: {'count': result.jobs.length});
      } else {
        _currentPage--; // Revert page increment on error
        _setError(result.message);
      }
    } catch (e) {
      Logger.error('Load more jobs error', error: e);
      _currentPage--; // Revert page increment on error
      _setError('Failed to load more jobs');
    } finally {
      _setLoadingMore(false);
    }
  }

  /// Load my jobs (for current user)
  Future<void> loadMyJobs() async {
    _setLoading(true);
    _clearError();

    try {
      // This would typically be a different endpoint for user's own jobs
      final result = await _jobService.getJobs(
        page: 1,
        limit: 100, // Get all user's jobs
      );

      if (result.success) {
        _myJobs = result.jobs;
        Logger.info(
          'My jobs loaded successfully',
          data: {'count': _myJobs.length},
        );
      } else {
        _setError(result.message);
      }
    } catch (e) {
      Logger.error('Load my jobs error', error: e);
      _setError('Failed to load your jobs');
    } finally {
      _setLoading(false);
    }
  }

  /// Load job applications
  Future<void> loadApplications(String jobId) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _jobService.getJobApplications(jobId);

      if (result.success) {
        _applications = result.applications;
        Logger.info(
          'Applications loaded successfully',
          data: {'count': _applications.length},
        );
      } else {
        _setError(result.message);
      }
    } catch (e) {
      Logger.error('Load applications error', error: e);
      _setError('Failed to load applications');
    } finally {
      _setLoading(false);
    }
  }

  /// Create a new job
  Future<bool> createJob({
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
    _setLoading(true);
    _clearError();

    try {
      final result = await _jobService.createJob(
        title: title,
        description: description,
        category: category,
        location: location,
        budget: budget,
        budgetType: budgetType,
        deadline: deadline,
        requiredSkills: requiredSkills,
        latitude: latitude,
        longitude: longitude,
        imageUrls: imageUrls,
      );

      if (result.success && result.job != null) {
        _jobs.insert(0, result.job!);
        _myJobs.insert(0, result.job!);
        notifyListeners();
        Logger.info(
          'Job created successfully',
          data: {'jobId': result.job!.id.toString(), 'count': 1},
        );
        return true;
      } else {
        _setError(result.message);
        return false;
      }
    } catch (e) {
      Logger.error('Create job error', error: e);
      _setError('Failed to create job');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Apply for a job
  Future<bool> applyForJob({
    required String id,
    required String jobId,
    required String message,
    required double proposedBudget,
    required String proposedBudgetType,
    required int estimatedDays,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _jobService.applyForJob(
        id,
        jobId: id,
        message: message,
        proposedBudget: proposedBudget,
        proposedBudgetType: proposedBudgetType,
        estimatedDays: estimatedDays,
      );

      if (result.success) {
        Logger.info(
          'Job application submitted successfully',
          data: {'jobId': id},
        );
        return true;
      } else {
        _setError(result.message);
        return false;
      }
    } catch (e) {
      Logger.error('Apply for job error', error: e);
      _setError('Failed to apply for job');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Accept a job application
  Future<bool> acceptApplication(String jobId, String applicationId) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _jobService.acceptApplication(jobId, applicationId);

      if (result.success) {
        // Update the application in the list
        final index = _applications.indexWhere(
          (app) => app.id == applicationId,
        );
        if (index != -1) {
          _applications[index] = result.application!;
          notifyListeners();
        }

        Logger.info(
          'Application accepted successfully',
          data: {'applicationId': applicationId},
        );
        return true;
      } else {
        _setError(result.message);
        return false;
      }
    } catch (e) {
      Logger.error('Accept application error', error: e);
      _setError('Failed to accept application');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Reject a job application
  Future<bool> rejectApplication(String jobId, String applicationId) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _jobService.rejectApplication(jobId, applicationId);

      if (result.success) {
        // Update the application in the list
        final index = _applications.indexWhere(
          (app) => app.id == applicationId,
        );
        if (index != -1) {
          _applications[index] = result.application!;
          notifyListeners();
        }

        Logger.info(
          'Application rejected successfully',
          data: {'applicationId': applicationId},
        );
        return true;
      } else {
        _setError(result.message);
        return false;
      }
    } catch (e) {
      Logger.error('Reject application error', error: e);
      _setError('Failed to reject application');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Update job
  Future<bool> updateJob({
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
    _setLoading(true);
    _clearError();

    try {
      final result = await _jobService.updateJob(
        jobId: jobId,
        title: title,
        description: description,
        category: category,
        location: location,
        budget: budget,
        budgetType: budgetType,
        deadline: deadline,
        requiredSkills: requiredSkills,
        latitude: latitude,
        longitude: longitude,
        imageUrls: imageUrls,
      );

      if (result.success && result.job != null) {
        // Update job in both lists
        _updateJobInList(_jobs, result.job!);
        _updateJobInList(_myJobs, result.job!);
        notifyListeners();

        Logger.info('Job updated successfully', data: {'jobId': jobId});
        return true;
      } else {
        _setError(result.message);
        return false;
      }
    } catch (e) {
      Logger.error('Update job error', error: e);
      _setError('Failed to update job');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Delete job
  Future<bool> deleteJob(String jobId) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _jobService.deleteJob(jobId);

      if (result.success) {
        // Remove job from both lists
        _jobs.removeWhere((job) => job.id == jobId);
        _myJobs.removeWhere((job) => job.id == jobId);
        notifyListeners();

        Logger.info('Job deleted successfully', data: {'jobId': jobId});
        return true;
      } else {
        _setError(result.message);
        return false;
      }
    } catch (e) {
      Logger.error('Delete job error', error: e);
      _setError('Failed to delete job');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Clear filters
  void clearFilters() {
    _searchQuery = null;
    _selectedCategory = null;
    _selectedLocation = null;
    notifyListeners();
  }

  /// Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// Set loading more state
  void _setLoadingMore(bool loading) {
    _isLoadingMore = loading;
    notifyListeners();
  }

  /// Set error message
  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  /// Clear error message
  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Clear error manually
  void clearError() {
    _clearError();
  }

  /// Update job in a list
  void _updateJobInList(List<JobModel> list, JobModel updatedJob) {
    final index = list.indexWhere((job) => job.id == updatedJob.id);
    if (index != -1) {
      list[index] = updatedJob;
    }
  }
}
