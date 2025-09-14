import '../../../core/network/api_client.dart';
import '../../../core/constants/api_endpoints.dart';
import '../models/dashboard_model.dart';
import '../../../core/utils/logger.dart';

/// Dashboard service for fetching dashboard statistics and data
/// Handles all dashboard-related API operations
class DashboardService {
  static final DashboardService _instance = DashboardService._internal();
  factory DashboardService() => _instance;
  DashboardService._internal();

  final ApiClient _apiClient = ApiClient();

  /// Get dashboard statistics for the current user
  Future<DashboardResult> getDashboardStats() async {
    try {
      Logger.userAction('Fetch dashboard stats');

      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiEndpoints.dashboardStats,
        fromJson: (data) => data as Map<String, dynamic>,
      );

      if (response.success && response.data != null) {
        final dashboardModel = DashboardModel.fromJson(response.data!);

        Logger.userAction('Dashboard stats loaded successfully');

        return DashboardResult.success(
          dashboard: dashboardModel,
          message: response.message,
        );
      } else {
        Logger.warning('Dashboard stats fetch failed: ${response.message}');
        return DashboardResult.failure(message: response.message);
      }
    } on ApiError catch (e) {
      Logger.error('Dashboard stats API error', error: e);
      return DashboardResult.failure(message: e.message);
    } catch (e) {
      Logger.error('Dashboard stats unexpected error', error: e);
      return DashboardResult.failure(message: 'Failed to load dashboard data');
    }
  }

  /// Get recent activity for the dashboard
  Future<ActivityResult> getRecentActivity({int limit = 10}) async {
    try {
      Logger.userAction('Fetch recent activity');

      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiEndpoints.dashboardActivity,
        queryParameters: {'limit': limit},
        fromJson: (data) => data as Map<String, dynamic>,
      );

      if (response.success && response.data != null) {
        final activities = (response.data!['activities'] as List<dynamic>)
            .map(
              (activity) =>
                  ActivityItem.fromJson(activity as Map<String, dynamic>),
            )
            .toList();

        return ActivityResult.success(
          activities: activities,
          message: response.message,
        );
      } else {
        return ActivityResult.failure(message: response.message);
      }
    } on ApiError catch (e) {
      Logger.error('Recent activity API error', error: e);
      return ActivityResult.failure(message: e.message);
    } catch (e) {
      Logger.error('Recent activity unexpected error', error: e);
      return ActivityResult.failure(message: 'Failed to load recent activity');
    }
  }

  // Static variable to prevent concurrent category fetching
  static Future<CategoryResult>? _categoryFetchFuture;

  /// Get job categories for filtering
  Future<CategoryResult> getJobCategories() async {
    // If there's already a category fetch in progress, return that future
    if (_categoryFetchFuture != null) {
      Logger.info(
        'Category fetch already in progress, returning existing future',
      );
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
  Future<CategoryResult> _fetchJobCategories() async {
    try {
      Logger.userAction('Fetch job categories');

      final response = await _apiClient
          .get<Map<String, dynamic>>(
            ApiEndpoints.categories,
            fromJson: (data) => data as Map<String, dynamic>,
          )
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw ApiError(
                message: 'Request timeout - categories fetch took too long',
                code: 'TIMEOUT',
                statusCode: 408,
              );
            },
          );

      if (response.success && response.data != null) {
        final categories = (response.data!['categories'] as List<dynamic>)
            .map(
              (category) =>
                  JobCategory.fromJson(category as Map<String, dynamic>),
            )
            .toList();

        return CategoryResult.success(
          categories: categories,
          message: response.message,
        );
      } else {
        return CategoryResult.failure(message: response.message);
      }
    } on ApiError catch (e) {
      Logger.error('Job categories API error', error: e);
      return CategoryResult.failure(message: e.message);
    } catch (e) {
      Logger.error('Job categories unexpected error', error: e);

      // Return fallback categories if API fails
      final fallbackCategories = [
        const JobCategory(id: 'plumbing', name: 'Plumbing'),
        const JobCategory(id: 'electrical', name: 'Electrical'),
        const JobCategory(id: 'carpentry', name: 'Carpentry'),
        const JobCategory(id: 'painting', name: 'Painting'),
        const JobCategory(id: 'cleaning', name: 'Cleaning'),
        const JobCategory(id: 'gardening', name: 'Gardening'),
        const JobCategory(id: 'repair', name: 'Repair'),
        const JobCategory(id: 'installation', name: 'Installation'),
        const JobCategory(id: 'other', name: 'Other'),
      ];

      return CategoryResult.success(
        categories: fallbackCategories,
        message: 'Using fallback categories due to API error',
      );
    }
  }
}

/// Dashboard result wrapper
class DashboardResult {
  final bool success;
  final String? message;
  final DashboardModel? dashboard;

  DashboardResult._({required this.success, this.message, this.dashboard});

  factory DashboardResult.success({
    required DashboardModel dashboard,
    String? message,
  }) {
    return DashboardResult._(
      success: true,
      dashboard: dashboard,
      message: message,
    );
  }

  factory DashboardResult.failure({required String message}) {
    return DashboardResult._(success: false, message: message);
  }
}

/// Activity result wrapper
class ActivityResult {
  final bool success;
  final String? message;
  final List<ActivityItem>? activities;

  ActivityResult._({required this.success, this.message, this.activities});

  factory ActivityResult.success({
    required List<ActivityItem> activities,
    String? message,
  }) {
    return ActivityResult._(
      success: true,
      activities: activities,
      message: message,
    );
  }

  factory ActivityResult.failure({required String message}) {
    return ActivityResult._(success: false, message: message);
  }
}

/// Category result wrapper
class CategoryResult {
  final bool success;
  final String? message;
  final List<JobCategory>? categories;

  CategoryResult._({required this.success, this.message, this.categories});

  factory CategoryResult.success({
    required List<JobCategory> categories,
    String? message,
  }) {
    return CategoryResult._(
      success: true,
      categories: categories,
      message: message,
    );
  }

  factory CategoryResult.failure({required String message}) {
    return CategoryResult._(success: false, message: message);
  }
}

/// Activity item model
class ActivityItem {
  final String id;
  final String title;
  final String description;
  final String timeAgo;
  final String type;
  final String? icon;
  final String? color;

  const ActivityItem({
    required this.id,
    required this.title,
    required this.description,
    required this.timeAgo,
    required this.type,
    this.icon,
    this.color,
  });

  factory ActivityItem.fromJson(Map<String, dynamic> json) {
    return ActivityItem(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      timeAgo: json['time_ago'] ?? '',
      type: json['type'] ?? '',
      icon: json['icon'],
      color: json['color'],
    );
  }
}

/// Job category model
class JobCategory {
  final String id;
  final String name;
  final String? description;
  final String? icon;
  final bool isActive;

  const JobCategory({
    required this.id,
    required this.name,
    this.description,
    this.icon,
    this.isActive = true,
  });

  factory JobCategory.fromJson(Map<String, dynamic> json) {
    return JobCategory(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      icon: json['icon'],
      isActive: json['is_active'] ?? true,
    );
  }
}
