import '../config/env_config.dart';

/// API Endpoints Constants
/// This file contains all API endpoints matching the Laravel API routes exactly
class ApiEndpoints {
  // Base API URL - Read from environment configuration
  static String get baseUrl => EnvConfig.apiBaseUrl;

  // Authentication Endpoints
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String logout = '/auth/logout';
  static const String me = '/auth/me';
  static const String tokenInfo = '/auth/token-info';
  static const String authProfile = '/auth/profile';
  static const String authChangePassword = '/auth/change-password';
  static const String authForgotPassword = '/auth/forgot-password';
  static const String authSendOtp = '/auth/send-otp';
  static const String authVerifyOtp = '/auth/verify-otp';
  static const String authResetPassword = '/auth/reset-password';

  // User Management Endpoints
  static const String userMe = '/users/me';
  static const String updateFundiProfile = '/users/me/fundi-profile';
  static const String getFundiProfile = '/fundi/{id}';
  static const String userProfile = '/users/{id}/profile';
  static const String userProfileImage = '/users/{id}/profile/image';
  static const String userProfileSkills = '/users/{id}/profile/skills';
  static const String userProfileLanguages = '/users/{id}/profile/languages';
  static const String userProfilePreferences =
      '/users/{id}/profile/preferences';

  // Category Endpoints
  static const String categories = '/categories';

  // Job Endpoints
  static const String jobs = '/jobs';
  static const String jobById = '/jobs/{id}';
  static const String createJob = '/jobs';
  static const String updateJob = '/jobs/{id}';
  static const String deleteJob = '/jobs/{id}';

  // Job Application Endpoints
  static const String applyToJob = '/jobs/{job_id}/apply';
  static const String myApplications = '/my-applications';
  static const String jobApplications = '/jobs/{job_id}/applications';
  static const String updateApplicationStatus = '/applications/{id}/status';
  static const String deleteApplication = '/applications/{id}';

  // Portfolio Endpoints
  static const String portfolios = '/portfolios';
  static const String portfolioById = '/portfolios/{id}';
  static const String fundiPortfolio = '/portfolio/{fundi_id}';
  static const String createPortfolio = '/portfolio';
  static const String updatePortfolio = '/portfolio/{id}';
  static const String deletePortfolio = '/portfolio/{id}';
  static const String uploadPortfolioMedia = '/portfolio-media';

  // Payment Endpoints
  static const String payments = '/payments';
  static const String createPayment = '/payments';
  static const String paymentRequirements = '/payments/requirements';
  static const String checkPaymentRequired = '/payments/check-required';
  static const String paymentVerification = '/payments/verify/{reference}';

  // Notification Endpoints
  static const String notifications = '/notifications';
  static const String markNotificationAsRead = '/notifications/{id}/read';
  static const String deleteNotification = '/notifications/{id}';
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
  static const String workApprovalPortfolio = '/work-approval/portfolio/{id}';
  static const String workApprovalPortfolioApprove =
      '/work-approval/portfolio/{id}/approve';
  static const String workApprovalPortfolioReject =
      '/work-approval/portfolio/{id}/reject';
  static const String workApprovalSubmissions =
      '/work-approval/submissions/{id}';
  static const String workApprovalSubmissionsApprove =
      '/work-approval/submissions/{id}/approve';
  static const String workApprovalSubmissionsReject =
      '/work-approval/submissions/{id}/reject';
  static const String workApprovalSubmissionsRequestRevision =
      '/work-approval/submissions/{id}/request-revision';
  static const String workApprovalStatistics = '/work-approval/statistics';

  // Feeds Endpoints
  static const String apiFundis = '/api/fundis';
  static const String apiJobs = '/api/jobs';
  static const String apiJobsCategories = '/api/jobs/categories';
  static const String apiSkills = '/api/skills';
  static const String apiLocations = '/api/locations';
  static const String apiJobsRequestFundi = '/api/jobs/request-fundi';
  static const String apiJobsApply = '/api/jobs/apply';

  // Search Endpoints
  static const String search = '/search';
  static const String searchSuggestions = '/search/suggestions';
  static const String searchPopular = '/search/popular';
  static const String searchFilters = '/search/filters';
  static const String searchAnalytics = '/search/analytics';

  // Messaging/Chat Endpoints
  static const String chats = '/chats';
  static const String chatMessages = '/chats/{id}/messages';
  static const String chatMessagesRead = '/chats/{id}/messages/read';
  static const String chatMessage = '/chats/{id}/messages/{messageId}';
  static const String messageUpload = '/messages/upload';

  // Rating and Review Endpoints
  static const String createRating = '/ratings';
  static const String myRatings = '/ratings/my-ratings';
  static const String fundiRatings = '/ratings/fundi/{fundiId}';
  static const String updateRating = '/ratings/{id}';
  static const String deleteRating = '/ratings/{id}';

  // File Upload Endpoints
  static const String uploadPortfolioMediaFile = '/upload/portfolio-media';
  static const String uploadJobMediaFile = '/upload/job-media';
  static const String uploadProfileDocument = '/upload/profile-document';
  static const String deleteMedia = '/upload/media/{id}';
  static const String getMediaUrl = '/upload/media/{id}/url';

  // Fundi Application Endpoints
  static const String fundiApplications = '/fundi-applications';
  static const String fundiApplicationStatus = '/fundi-applications/status';
  static const String fundiApplicationById = '/fundi-applications/{id}';
  static const String fundiApplicationStatusById =
      '/fundi-applications/{id}/status';

  // Dashboard Endpoints
  static const String dashboardStats = '/dashboard/stats';
  static const String dashboardActivity = '/dashboard/activity';

  // Helper methods for dynamic endpoints
  static String getFundiProfileEndpoint(String fundiId) {
    return getFundiProfile.replaceAll('{id}', fundiId);
  }

  // Profile helper methods
  static String userProfileEndpoint(String userId) {
    return userProfile.replaceAll('{id}', userId);
  }

  static String userProfileImageEndpoint(String userId) {
    return userProfileImage.replaceAll('{id}', userId);
  }

  static String userProfileSkillsEndpoint(String userId) {
    return userProfileSkills.replaceAll('{id}', userId);
  }

  static String userProfileLanguagesEndpoint(String userId) {
    return userProfileLanguages.replaceAll('{id}', userId);
  }

  static String userProfilePreferencesEndpoint(String userId) {
    return userProfilePreferences.replaceAll('{id}', userId);
  }

  static String getFundiPortfolioEndpoint(String fundiId) {
    return fundiPortfolio.replaceAll('{fundi_id}', fundiId);
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
    return applyToJob.replaceAll('{job_id}', jobId);
  }

  static String getJobApplicationsEndpoint(String jobId) {
    return jobApplications.replaceAll('{job_id}', jobId);
  }

  static String getUpdateApplicationStatusEndpoint(String applicationId) {
    return updateApplicationStatus.replaceAll('{id}', applicationId);
  }

  static String getDeleteApplicationEndpoint(String applicationId) {
    return deleteApplication.replaceAll('{id}', applicationId);
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

  static String getDeleteMediaEndpoint(String mediaId) {
    return deleteMedia.replaceAll('{id}', mediaId);
  }

  static String getMediaUrlEndpoint(String mediaId) {
    return getMediaUrl.replaceAll('{id}', mediaId);
  }

  // Work Approval helper methods
  static String getWorkApprovalPortfolioEndpoint(String portfolioId) {
    return workApprovalPortfolio.replaceAll('{id}', portfolioId);
  }

  static String getWorkApprovalPortfolioApproveEndpoint(String portfolioId) {
    return workApprovalPortfolioApprove.replaceAll('{id}', portfolioId);
  }

  static String getWorkApprovalPortfolioRejectEndpoint(String portfolioId) {
    return workApprovalPortfolioReject.replaceAll('{id}', portfolioId);
  }

  static String getWorkApprovalSubmissionsEndpoint(String submissionId) {
    return workApprovalSubmissions.replaceAll('{id}', submissionId);
  }

  static String getWorkApprovalSubmissionsApproveEndpoint(String submissionId) {
    return workApprovalSubmissionsApprove.replaceAll('{id}', submissionId);
  }

  static String getWorkApprovalSubmissionsRejectEndpoint(String submissionId) {
    return workApprovalSubmissionsReject.replaceAll('{id}', submissionId);
  }

  static String getWorkApprovalSubmissionsRequestRevisionEndpoint(
    String submissionId,
  ) {
    return workApprovalSubmissionsRequestRevision.replaceAll(
      '{id}',
      submissionId,
    );
  }

  // Feeds helper methods
  static String getFundiEndpoint(String fundiId) {
    return '$apiFundis/$fundiId';
  }

  static String getJobEndpoint(String jobId) {
    return '$apiJobs/$jobId';
  }

  // Messaging helper methods
  static String getChatMessagesEndpoint(String chatId) {
    return chatMessages.replaceAll('{id}', chatId);
  }

  static String getChatMessagesReadEndpoint(String chatId) {
    return chatMessagesRead.replaceAll('{id}', chatId);
  }

  static String getChatMessageEndpoint(String chatId, String messageId) {
    return chatMessage
        .replaceAll('{id}', chatId)
        .replaceAll('{messageId}', messageId);
  }

  // Portfolio helper methods
  static String getPortfolioByIdEndpoint(String portfolioId) {
    return portfolioById.replaceAll('{id}', portfolioId);
  }

  // Payment helper methods
  static String getPaymentVerificationEndpoint(String reference) {
    return paymentVerification.replaceAll('{reference}', reference);
  }

  // Fundi Application helper methods
  static String getFundiApplicationByIdEndpoint(String applicationId) {
    return fundiApplicationById.replaceAll('{id}', applicationId);
  }

  static String getFundiApplicationStatusByIdEndpoint(String applicationId) {
    return fundiApplicationStatusById.replaceAll('{id}', applicationId);
  }

  // Settings helper methods
  static String getSettingsByKeyEndpoint(String key) {
    return '${settings}/$key';
  }
}
