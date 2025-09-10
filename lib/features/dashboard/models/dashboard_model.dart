/// Dashboard model for managing dashboard data and statistics
class DashboardModel {
  final int totalJobs;
  final int activeJobs;
  final int completedJobs;
  final int pendingApplications;
  final double totalEarnings;
  final double averageRating;
  final List<Map<String, dynamic>> recentActivity;
  final Map<String, int> jobStatsByCategory;
  final Map<String, int> monthlyStats;

  const DashboardModel({
    required this.totalJobs,
    required this.activeJobs,
    required this.completedJobs,
    required this.pendingApplications,
    required this.totalEarnings,
    required this.averageRating,
    required this.recentActivity,
    required this.jobStatsByCategory,
    required this.monthlyStats,
  });

  /// Create DashboardModel from JSON
  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    return DashboardModel(
      totalJobs: json['totalJobs'] ?? 0,
      activeJobs: json['activeJobs'] ?? 0,
      completedJobs: json['completedJobs'] ?? 0,
      pendingApplications: json['pendingApplications'] ?? 0,
      totalEarnings: (json['totalEarnings'] ?? 0.0).toDouble(),
      averageRating: (json['averageRating'] ?? 0.0).toDouble(),
      recentActivity: List<Map<String, dynamic>>.from(
        json['recentActivity'] ?? [],
      ),
      jobStatsByCategory: Map<String, int>.from(
        json['jobStatsByCategory'] ?? {},
      ),
      monthlyStats: Map<String, int>.from(json['monthlyStats'] ?? {}),
    );
  }

  /// Convert DashboardModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'totalJobs': totalJobs,
      'activeJobs': activeJobs,
      'completedJobs': completedJobs,
      'pendingApplications': pendingApplications,
      'totalEarnings': totalEarnings,
      'averageRating': averageRating,
      'recentActivity': recentActivity,
      'jobStatsByCategory': jobStatsByCategory,
      'monthlyStats': monthlyStats,
    };
  }

  /// Create empty DashboardModel
  factory DashboardModel.empty() {
    return const DashboardModel(
      totalJobs: 0,
      activeJobs: 0,
      completedJobs: 0,
      pendingApplications: 0,
      totalEarnings: 0.0,
      averageRating: 0.0,
      recentActivity: [],
      jobStatsByCategory: {},
      monthlyStats: {},
    );
  }

  /// Copy with new values
  DashboardModel copyWith({
    int? totalJobs,
    int? activeJobs,
    int? completedJobs,
    int? pendingApplications,
    double? totalEarnings,
    double? averageRating,
    List<Map<String, dynamic>>? recentActivity,
    Map<String, int>? jobStatsByCategory,
    Map<String, int>? monthlyStats,
  }) {
    return DashboardModel(
      totalJobs: totalJobs ?? this.totalJobs,
      activeJobs: activeJobs ?? this.activeJobs,
      completedJobs: completedJobs ?? this.completedJobs,
      pendingApplications: pendingApplications ?? this.pendingApplications,
      totalEarnings: totalEarnings ?? this.totalEarnings,
      averageRating: averageRating ?? this.averageRating,
      recentActivity: recentActivity ?? this.recentActivity,
      jobStatsByCategory: jobStatsByCategory ?? this.jobStatsByCategory,
      monthlyStats: monthlyStats ?? this.monthlyStats,
    );
  }
}

