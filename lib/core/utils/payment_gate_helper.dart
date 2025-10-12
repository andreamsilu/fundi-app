import 'package:flutter/material.dart';
import '../../features/payment/services/payment_service.dart';
import '../widgets/payment_required_dialog.dart';
import '../utils/logger.dart';

/// Payment Gate Helper
/// Checks if user has permission to perform actions and shows upgrade dialogs
class PaymentGateHelper {
  static final PaymentService _paymentService = PaymentService();

  /// Check if user can perform an action, show payment gate if needed
  /// Returns true if user can proceed, false if payment is required
  static Future<bool> checkAndGate(
    BuildContext context, {
    required String action,
    required String featureName,
    String? jobId,
  }) async {
    try {
      Logger.userAction(
        'Payment gate check',
        data: {'action': action, 'feature': featureName},
      );

      final result = await _paymentService.checkPaymentRequired(
        action: action,
        jobId: jobId,
      );

      if (result.success) {
        // If payment is not required, user can proceed
        if (result.paymentRequired == false) {
          return true;
        }

        // Payment is required - show upgrade dialog
        await PaymentRequiredDialog.show(
          context,
          feature: featureName,
          message: 'You need to upgrade your plan to access this feature.',
          requiredAmount: result.requiredAmount,
          planName: result.plan?.name,
        );

        return false;
      } else {
        // If check fails, assume user can proceed (fail-open approach)
        Logger.warning(
          'Payment check failed, allowing action: ${result.message}',
        );
        return true;
      }
    } catch (e) {
      Logger.error('Payment gate check error', error: e);
      // On error, allow action to proceed
      return true;
    }
  }

  /// Quick check for common actions
  static Future<bool> canPostJob(BuildContext context) {
    return checkAndGate(
      context,
      action: 'post_job',
      featureName: 'Job Posting',
    );
  }

  static Future<bool> canApplyToJob(BuildContext context, String jobId) {
    return checkAndGate(
      context,
      action: 'apply_job',
      featureName: 'Job Application',
      jobId: jobId,
    );
  }

  static Future<bool> canCreatePortfolio(BuildContext context) {
    return checkAndGate(
      context,
      action: 'create_portfolio',
      featureName: 'Portfolio Creation',
    );
  }

  static Future<bool> canSendMessage(BuildContext context) {
    return checkAndGate(
      context,
      action: 'send_message',
      featureName: 'Messaging',
    );
  }

  static Future<bool> canViewFundiProfiles(BuildContext context) {
    return checkAndGate(
      context,
      action: 'view_profiles',
      featureName: 'Browse Fundis',
    );
  }
}




