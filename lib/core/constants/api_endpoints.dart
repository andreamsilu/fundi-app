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

  // User Management Endpoints
  static const String userMe = '/users/me';
  static const String updateFundiProfile = '/users/me/fundi-profile';
  static const String getFundiProfile = '/fundi/{id}';

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

  // Notification Endpoints
  static const String notifications = '/notifications';
  static const String markNotificationAsRead = '/notifications/{id}/read';
  static const String deleteNotification = '/notifications/{id}';

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

  // Helper methods for dynamic endpoints
  static String getFundiProfileEndpoint(String fundiId) {
    return getFundiProfile.replaceAll('{id}', fundiId);
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


}
