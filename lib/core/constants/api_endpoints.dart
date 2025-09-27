import '../config/api_config.dart';

/// API Endpoints Constants
/// This file contains all API endpoints matching the Laravel API routes exactly
class ApiEndpoints {
  // Base API URL - Read from centralized configuration
  static String get baseUrl => ApiConfig.baseUrl;

  // Authentication Endpoints (JWT API)
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String logout = '/auth/logout';
  static const String me = '/auth/me';
  static const String authChangePassword = '/auth/change-password';
  static const String authRefresh = '/auth/refresh';
  // Note: OTP endpoints may not be implemented in JWT API
  static const String authForgotPassword = '/auth/forgot-password';
  static const String authResetPassword = '/auth/reset-password';
  static const String authSendOtp = '/auth/send-otp';
  static const String authVerifyOtp = '/auth/verify-otp';

  // User Management Endpoints
  static const String userMe = '/users/me';
  static const String authProfile = '/users/me/profile';
  static const String updateFundiProfile = '/users/me/fundi-profile';
  static const String getFundiProfile = '/users/fundi/{fundiId}';

  // Category Endpoints
  static const String categories = '/categories';

  // Job Endpoints
  static const String jobs = '/jobs'; // Available jobs (public feed)
  static const String myJobs = '/jobs/my-jobs'; // User's own jobs
  static const String jobById = '/jobs/{id}';
  static const String createJob = '/jobs';
  static const String updateJob = '/jobs/{id}';
  static const String deleteJob = '/jobs/{id}';

  // Job Application Endpoints
  static const String applyToJob = '/jobs/{jobId}/apply';
  static const String myApplications = '/job-applications/my-applications';
  static const String jobApplications = '/jobs/{jobId}/applications';
  static const String updateApplicationStatus = '/job-applications/{id}/status';

  // Helper method for update application status endpoint
  static String getUpdateApplicationStatusEndpoint(String applicationId) {
    return updateApplicationStatus.replaceAll('{id}', applicationId);
  }

  // Portfolio Endpoints
  static const String myPortfolio = '/portfolio/my-portfolio';
  static const String portfolioStatus = '/portfolio/status';
  static const String fundiPortfolio = '/portfolio/{fundiId}';
  static const String createPortfolio = '/portfolio';
  static const String updatePortfolio = '/portfolio/{id}';
  static const String deletePortfolio = '/portfolio/{id}';

  // Payment Endpoints
  static const String payments = '/payments';
  static const String createPayment = '/payments/create';
  static const String cancelPayment = '/payments/cancel';
  static const String currentPlan = '/payments/current-plan';
  static const String paymentPlans = '/payments/plans';
  static const String subscribe = '/payments/subscribe';
  static const String cancelSubscription = '/payments/cancel-subscription';
  static const String paymentHistory = '/payments/history';
  static const String checkPermission = '/payments/check-permission';
  static const String payPerUse = '/payments/pay-per-use';
  static const String userPayments = '/payments/user';
  // Payment Gateway Endpoints - REMOVED (not implemented in API)

  // Notification Endpoints
  static const String notifications = '/notifications';
  static const String markNotificationAsRead = '/notifications/{id}/read';
  static const String deleteNotification = '/notifications/{id}';

  // Messaging Endpoints - REMOVED (not implemented in API)
  static String getChatMessageEndpoint(String chatId, String messageId) =>
      '/chats/$chatId/messages/$messageId';

  // Search Endpoints - REMOVED (not implemented in API)

  // Profile Endpoints
  static String userProfileEndpoint(String userId) => '/users/$userId/profile';
  static String userProfileImageEndpoint(String userId) =>
      '/users/$userId/profile/image';
  static String userProfileSkillsEndpoint(String userId) =>
      '/users/$userId/profile/skills';
  static String userProfileLanguagesEndpoint(String userId) =>
      '/users/$userId/profile/languages';
  static String userProfilePreferencesEndpoint(String userId) =>
      '/users/$userId/profile/preferences';

  // Work Approval Endpoints - Statistics removed (not implemented in API)
  static String getWorkApprovalSubmissionsRequestRevisionEndpoint(
    String submissionId,
  ) => '/work-approval/submissions/$submissionId/request-revision';
  static String getWorkApprovalPortfolioEndpoint(String itemId) =>
      '/work-approval/portfolio/$itemId';
  static String getWorkApprovalSubmissionsEndpoint(String submissionId) =>
      '/work-approval/submissions/$submissionId';

  // Dashboard Endpoints - REMOVED (not implemented in API)
  static const String markAllNotificationsAsRead = '/notifications/read-all';
  static const String clearAllNotifications = '/notifications/clear-all';
  static const String notificationSettings = '/notifications/settings';
  static const String testNotification = '/notifications/test';

  // Settings Endpoints
  static const String settings = '/settings';
  static const String settingsReset = '/settings/reset';
  static const String settingsExport = '/settings/export';
  static const String settingsImport = '/settings/import';
  static const String settingsThemes = '/settings/themes';
  static const String settingsLanguages = '/settings/languages';
  static const String settingsPrivacy = '/settings/privacy';
  static const String settingsNotifications = '/settings/notifications';

  // Work Approval Endpoints
  static const String workApprovalPortfolioPending =
      '/work-approval/portfolio-pending';
  static const String workApprovalSubmissionsPending =
      '/work-approval/submissions-pending';
  static const String workApprovalPortfolioApprove =
      '/work-approval/portfolio/{id}/approve';
  static const String workApprovalPortfolioReject =
      '/work-approval/portfolio/{id}/reject';
  static const String workApprovalSubmissionsApprove =
      '/work-approval/submissions/{id}/approve';
  static const String workApprovalSubmissionsReject =
      '/work-approval/submissions/{id}/reject';

  // Feeds Endpoints
  static const String feedsFundis = '/feeds/fundis';
  static const String feedsJobs = '/feeds/jobs';
  static const String feedsFundiById = '/feeds/fundis/{id}';
  static const String feedsJobById = '/feeds/jobs/{id}';
  static const String feedsNearbyFundis = '/feeds/nearby-fundis';

  // Rating and Review Endpoints
  static const String createRating = '/ratings';
  static const String myRatings = '/ratings/my-ratings';
  static const String fundiRatings = '/ratings/fundi/{fundiId}';
  static const String updateRating = '/ratings/{id}';
  static const String deleteRating = '/ratings/{id}';

  // Fundi Application Endpoints
  static const String fundiApplications = '/fundi-applications';
  static const String fundiApplicationStatus = '/fundi-applications/status';
  static const String fundiApplicationById = '/fundi-applications/{id}';
  static const String fundiApplicationStatusById =
      '/fundi-applications/{id}/status';
  static const String fundiApplicationRequirements =
      '/fundi-applications/requirements';
  static const String fundiApplicationProgress = '/fundi-applications/progress';
  static const String fundiApplicationSections =
      '/fundi-applications/sections/{sectionName}';
  static const String fundiApplicationSubmitSection =
      '/fundi-applications/sections';
  static const String fundiApplicationSubmit = '/fundi-applications/submit';

  // Helper methods for dynamic endpoints
  static String getFundiProfileEndpoint(String fundiId) {
    return getFundiProfile.replaceAll('{fundiId}', fundiId);
  }

  static String getFundiPortfolioEndpoint(String fundiId) {
    return fundiPortfolio.replaceAll('{fundiId}', fundiId);
  }

  static String getJobByIdEndpoint(String jobId) {
    return jobById.replaceAll('{id}', jobId);
  }

  static String getUpdateJobEndpoint(String jobId) {
    return updateJob.replaceAll('{id}', jobId);
  }

  static String getDeleteJobEndpoint(String jobId) {
    return deleteJob.replaceAll('{id}', jobId);
  }

  static String getApplyToJobEndpoint(String jobId) {
    return applyToJob.replaceAll('{jobId}', jobId);
  }

  static String getJobApplicationsEndpoint(String jobId) {
    return jobApplications.replaceAll('{jobId}', jobId);
  }

  static String getUpdatePortfolioEndpoint(String portfolioId) {
    return updatePortfolio.replaceAll('{id}', portfolioId);
  }

  static String getDeletePortfolioEndpoint(String portfolioId) {
    return deletePortfolio.replaceAll('{id}', portfolioId);
  }

  static String getMarkNotificationAsReadEndpoint(String notificationId) {
    return markNotificationAsRead.replaceAll('{id}', notificationId);
  }

  static String getDeleteNotificationEndpoint(String notificationId) {
    return deleteNotification.replaceAll('{id}', notificationId);
  }

  static String getFundiRatingsEndpoint(String fundiId) {
    return fundiRatings.replaceAll('{fundiId}', fundiId);
  }

  static String getUpdateRatingEndpoint(String ratingId) {
    return updateRating.replaceAll('{id}', ratingId);
  }

  static String getDeleteRatingEndpoint(String ratingId) {
    return deleteRating.replaceAll('{id}', ratingId);
  }

  // Work Approval helper methods
  static String getWorkApprovalPortfolioApproveEndpoint(String portfolioId) {
    return workApprovalPortfolioApprove.replaceAll('{id}', portfolioId);
  }

  static String getWorkApprovalPortfolioRejectEndpoint(String portfolioId) {
    return workApprovalPortfolioReject.replaceAll('{id}', portfolioId);
  }

  static String getWorkApprovalSubmissionsApproveEndpoint(String submissionId) {
    return workApprovalSubmissionsApprove.replaceAll('{id}', submissionId);
  }

  static String getWorkApprovalSubmissionsRejectEndpoint(String submissionId) {
    return workApprovalSubmissionsReject.replaceAll('{id}', submissionId);
  }

  // Feeds helper methods
  static String getFeedsFundiEndpoint(String fundiId) {
    return feedsFundiById.replaceAll('{id}', fundiId);
  }

  static String getFeedsJobEndpoint(String jobId) {
    return feedsJobById.replaceAll('{id}', jobId);
  }

  // Fundi Application helper methods
  static String getFundiApplicationByIdEndpoint(String applicationId) {
    return fundiApplicationById.replaceAll('{id}', applicationId);
  }

  static String getFundiApplicationStatusByIdEndpoint(String applicationId) {
    return fundiApplicationStatusById.replaceAll('{id}', applicationId);
  }

  static String getFundiApplicationSectionsEndpoint(String sectionName) {
    return fundiApplicationSections.replaceAll('{sectionName}', sectionName);
  }

  // Settings helper methods
  static String getSettingsByKeyEndpoint(String key) {
    return '${settings}/$key';
  }

  // Payment Configuration Helper Methods
  /// Get payment configuration endpoint
  static String getPaymentConfigEndpoint() {
    return '/payments/config';
  }

  /// Get payment callback endpoint
  static String getPaymentCallbackEndpoint() {
    return '/payments/callback';
  }

  /// Get payment verification endpoint
  static String getVerifyPaymentEndpoint(String transactionId) {
    return '/payments/verify/$transactionId';
  }

  /// Get payment by ID endpoint
  static String getPaymentByIdEndpoint(String paymentId) {
    return '$payments/$paymentId';
  }

  // Payment status endpoint - REMOVED (not implemented in API)
}
