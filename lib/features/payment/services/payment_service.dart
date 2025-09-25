import '../models/payment_plan_model.dart';
import '../models/user_subscription_model.dart';
import '../models/payment_transaction_model.dart';
import '../../../core/network/api_client.dart';
import '../../../core/utils/logger.dart';
import '../../../core/utils/payment_logger.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/config/payment_config.dart';

/// Payment service for handling payment-related operations
class PaymentService {
  static final PaymentService _instance = PaymentService._internal();
  factory PaymentService() => _instance;
  PaymentService._internal();

  final ApiClient _apiClient = ApiClient();

  /// Get user payments with pagination
  Future<PaymentListResult> getUserPayments({
    int page = 1,
    int limit = 15,
  }) async {
    try {
      Logger.userAction(
        'Getting user payments',
        data: {'page': page, 'limit': limit},
      );

      final response = await _apiClient.get<List<dynamic>>(
        ApiEndpoints.userPayments,
        queryParameters: {'page': page, 'limit': limit},
        fromJson: (data) => data as List<dynamic>,
      );

      if (response.success && response.data != null) {
        final payments = response.data!
            .map(
              (paymentData) => PaymentTransactionModel.fromJson(
                paymentData as Map<String, dynamic>,
              ),
            )
            .toList();

        Logger.userAction(
          'User payments retrieved successfully',
          data: {'count': payments.length},
        );

        return PaymentListResult.success(payments: payments);
      } else {
        Logger.warning('Failed to get user payments: ${response.message}');
        return PaymentListResult.failure(message: response.message);
      }
    } on ApiError catch (e) {
      Logger.error('Get user payments API error', error: e);
      return PaymentListResult.failure(message: e.message);
    } catch (e) {
      Logger.error('Get user payments unexpected error', error: e);
      return PaymentListResult.failure(message: 'An unexpected error occurred');
    }
  }

  /// Get user's current payment plan and subscription
  Future<PaymentResult> getCurrentPlan() async {
    try {
      Logger.userAction('Getting current payment plan');

      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiEndpoints.currentPlan,
        fromJson: (data) => data as Map<String, dynamic>,
      );

      if (response.success && response.data != null) {
        final data = response.data!;
        final plan = PaymentPlanModel.fromJson(data['plan']);
        final subscription = data['subscription'] != null
            ? UserSubscriptionModel.fromJson(data['subscription'])
            : null;

        Logger.userAction('Current payment plan retrieved successfully');

        return PaymentResult.success(
          message: 'Current payment plan retrieved successfully',
          plan: plan,
          subscription: subscription,
          isActive: data['is_active'] as bool,
          daysRemaining: data['days_remaining'] as int?,
        );
      } else {
        Logger.warning('Failed to get current plan: ${response.message}');
        return PaymentResult.failure(message: response.message);
      }
    } on ApiError catch (e) {
      Logger.error('Get current plan API error', error: e);
      return PaymentResult.failure(message: e.message);
    } catch (e) {
      Logger.error('Get current plan unexpected error', error: e);
      return PaymentResult.failure(message: 'An unexpected error occurred');
    }
  }

  /// Get all available payment plans
  Future<PaymentPlansResult> getAvailablePlans() async {
    try {
      Logger.userAction('Getting available payment plans');

      final response = await _apiClient.get<List<dynamic>>(
        ApiEndpoints.paymentPlans,
        fromJson: (data) => data as List<dynamic>,
      );

      if (response.success && response.data != null) {
        final plans = response.data!
            .map(
              (json) => PaymentPlanModel.fromJson(json as Map<String, dynamic>),
            )
            .toList();

        Logger.userAction('Available payment plans retrieved successfully');

        return PaymentPlansResult.success(plans: plans);
      } else {
        Logger.warning('Failed to get payment plans: ${response.message}');
        return PaymentPlansResult.failure(message: response.message);
      }
    } on ApiError catch (e) {
      Logger.error('Get payment plans API error', error: e);
      return PaymentPlansResult.failure(message: e.message);
    } catch (e) {
      Logger.error('Get payment plans unexpected error', error: e);
      return PaymentPlansResult.failure(
        message: 'An unexpected error occurred',
      );
    }
  }

  /// Subscribe to a payment plan
  Future<SubscriptionResult> subscribe({
    required int planId,
    int? durationDays,
  }) async {
    try {
      Logger.userAction(
        'Subscribing to payment plan',
        data: {'planId': planId},
      );

      final response = await _apiClient.post<Map<String, dynamic>>(
        ApiEndpoints.subscribe,
        {
          'plan_id': planId.toString(),
          if (durationDays != null) 'duration_days': durationDays.toString(),
        },
        {},
        fromJson: (data) => data as Map<String, dynamic>,
      );

      if (response.success && response.data != null) {
        final data = response.data!;
        final subscription = UserSubscriptionModel.fromJson(
          data['subscription'],
        );
        final transaction = PaymentTransactionModel.fromJson(
          data['transaction'],
        );

        Logger.userAction('Subscription created successfully');

        return SubscriptionResult.success(
          subscription: subscription,
          transaction: transaction,
        );
      } else {
        Logger.warning('Failed to create subscription: ${response.message}');
        return SubscriptionResult.failure(message: response.message);
      }
    } on ApiError catch (e) {
      Logger.error('Create subscription API error', error: e);
      return SubscriptionResult.failure(message: e.message);
    } catch (e) {
      Logger.error('Create subscription unexpected error', error: e);
      return SubscriptionResult.failure(
        message: 'An unexpected error occurred',
      );
    }
  }

  /// Cancel user's subscription
  Future<PaymentResult> cancelSubscription() async {
    try {
      Logger.userAction('Cancelling subscription');

      final response = await _apiClient.post<Map<String, dynamic>>(
        ApiEndpoints.cancelSubscription,
        {},
        {},
        fromJson: (data) => data as Map<String, dynamic>,
      );

      if (response.success && response.data != null) {
        final subscription = UserSubscriptionModel.fromJson(response.data!);

        Logger.userAction('Subscription cancelled successfully');

        return PaymentResult.success(
          message: 'Subscription cancelled successfully',
          subscription: subscription,
        );
      } else {
        Logger.warning('Failed to cancel subscription: ${response.message}');
        return PaymentResult.failure(message: response.message);
      }
    } on ApiError catch (e) {
      Logger.error('Cancel subscription API error', error: e);
      return PaymentResult.failure(message: e.message);
    } catch (e) {
      Logger.error('Cancel subscription unexpected error', error: e);
      return PaymentResult.failure(message: 'An unexpected error occurred');
    }
  }

  /// Get user's payment history
  Future<PaymentHistoryResult> getPaymentHistory({int limit = 50}) async {
    try {
      Logger.userAction('Getting payment history');

      final response = await _apiClient.get<List<dynamic>>(
        '${ApiEndpoints.paymentHistory}?limit=$limit',
        fromJson: (data) => data as List<dynamic>,
      );

      if (response.success && response.data != null) {
        final transactions = response.data!
            .map(
              (json) => PaymentTransactionModel.fromJson(
                json as Map<String, dynamic>,
              ),
            )
            .toList();

        Logger.userAction('Payment history retrieved successfully');

        return PaymentHistoryResult.success(transactions: transactions);
      } else {
        Logger.warning('Failed to get payment history: ${response.message}');
        return PaymentHistoryResult.failure(message: response.message);
      }
    } on ApiError catch (e) {
      Logger.error('Get payment history API error', error: e);
      return PaymentHistoryResult.failure(message: e.message);
    } catch (e) {
      Logger.error('Get payment history unexpected error', error: e);
      return PaymentHistoryResult.failure(
        message: 'An unexpected error occurred',
      );
    }
  }

  /// Check if user can perform specific action
  Future<PermissionResult> checkActionPermission(String action) async {
    try {
      Logger.userAction('Checking action permission', data: {'action': action});

      final response = await _apiClient.post<Map<String, dynamic>>(
        ApiEndpoints.checkPermission,
        {'action': action},
        {},
        fromJson: (data) => data as Map<String, dynamic>,
      );

      if (response.success && response.data != null) {
        final data = response.data!;
        final canPerform = data['can_perform'] as bool;
        final plan = PaymentPlanModel.fromJson(data['plan']);

        Logger.userAction('Action permission checked successfully');

        return PermissionResult.success(
          canPerform: canPerform,
          plan: plan,
          action: action,
        );
      } else {
        Logger.warning('Failed to check permission: ${response.message}');
        return PermissionResult.failure(message: response.message);
      }
    } on ApiError catch (e) {
      Logger.error('Check permission API error', error: e);
      return PermissionResult.failure(message: e.message);
    } catch (e) {
      Logger.error('Check permission unexpected error', error: e);
      return PermissionResult.failure(message: 'An unexpected error occurred');
    }
  }

  /// Check if payment is required for a specific action
  Future<PaymentValidationResult> checkPaymentRequired({
    required String action,
    String? jobId,
  }) async {
    try {
      Logger.userAction(
        'Checking payment requirement',
        data: {'action': action, 'jobId': jobId},
      );

      final response = await _apiClient.post<Map<String, dynamic>>(
        ApiEndpoints.checkPermission,
        {'action': action, if (jobId != null) 'job_id': jobId},
        {},
        fromJson: (data) => data as Map<String, dynamic>,
      );

      if (response.success && response.data != null) {
        final data = response.data!;
        final paymentRequired = data['payment_required'] as bool;
        final requiredAmount = data['required_amount'] as double?;
        final plan = PaymentPlanModel.fromJson(data['plan']);

        Logger.userAction('Payment requirement checked successfully');

        return PaymentValidationResult.success(
          paymentRequired: paymentRequired,
          requiredAmount: requiredAmount,
          plan: plan,
        );
      } else {
        Logger.warning(
          'Failed to check payment requirement: ${response.message}',
        );
        return PaymentValidationResult.failure(message: response.message);
      }
    } on ApiError catch (e) {
      Logger.error('Check payment requirement API error', error: e);
      return PaymentValidationResult.failure(message: e.message);
    } catch (e) {
      Logger.error('Check payment requirement unexpected error', error: e);
      return PaymentValidationResult.failure(
        message: 'An unexpected error occurred',
      );
    }
  }

  /// Process pay-per-use payment
  Future<TransactionResult> processPayPerUse({
    required String action,
    required double amount,
    String? referenceId,
  }) async {
    try {
      Logger.userAction(
        'Processing pay-per-use payment',
        data: {'action': action, 'amount': amount},
      );

      final response = await _apiClient.post<Map<String, dynamic>>(
        ApiEndpoints.payPerUse,
        {
          'action': action,
          'amount': amount.toStringAsFixed(2),
          if (referenceId != null) 'reference_id': referenceId,
        },
        {},
        fromJson: (data) => data as Map<String, dynamic>,
      );

      if (response.success && response.data != null) {
        final transaction = PaymentTransactionModel.fromJson(response.data!);

        Logger.userAction('Pay-per-use payment processed successfully');

        return TransactionResult.success(transaction: transaction);
      } else {
        Logger.warning(
          'Failed to process pay-per-use payment: ${response.message}',
        );
        return TransactionResult.failure(message: response.message);
      }
    } on ApiError catch (e) {
      Logger.error('Process pay-per-use API error', error: e);
      return TransactionResult.failure(message: e.message);
    } catch (e) {
      Logger.error('Process pay-per-use unexpected error', error: e);
      return TransactionResult.failure(message: 'An unexpected error occurred');
    }
  }

  /// Process Pesapal payment
  Future<TransactionResult> processPesapalPayment({
    required String orderId,
    required double amount,
    required String currency,
    required String description,
    required String callbackUrl,
    required String cancelUrl,
  }) async {
    try {
      PaymentLogger.logGatewayInteraction(
        gateway: 'pesapal',
        action: 'process_payment',
        transactionId: orderId,
        requestData: {
          'amount': amount,
          'currency': currency,
          'description': description,
        },
      );

      final response = await _apiClient.post<Map<String, dynamic>>(
        '/payments/pesapal/process',
        {
          'order_id': orderId,
          'amount': amount.toStringAsFixed(2),
          'currency': currency,
          'description': description,
          'callback_url': callbackUrl,
          'cancel_url': cancelUrl,
        },
        {},
        fromJson: (data) => data as Map<String, dynamic>,
      );

      if (response.success && response.data != null) {
        final transaction = PaymentTransactionModel.fromJson(response.data!);

        PaymentLogger.logPaymentSuccess(
          transactionId: transaction.id.toString(),
          action: transaction.transactionType,
          amount: transaction.amount,
          metadata: {'gateway': 'pesapal', 'order_id': orderId},
        );

        return TransactionResult.success(transaction: transaction);
      } else {
        PaymentLogger.logPaymentError(
          error: 'Failed to process Pesapal payment',
          transactionId: orderId,
          context: {'response_message': response.message},
        );
        return TransactionResult.failure(message: response.message);
      }
    } on ApiError catch (e) {
      PaymentLogger.logPaymentError(
        error: 'Pesapal payment API error',
        transactionId: orderId,
        exception: e,
      );
      return TransactionResult.failure(message: e.message);
    } catch (e) {
      PaymentLogger.logPaymentError(
        error: 'Pesapal payment unexpected error',
        transactionId: orderId,
        exception: e,
      );
      return TransactionResult.failure(message: 'An unexpected error occurred');
    }
  }

  /// Create payment request
  Future<TransactionResult> createPayment({
    required String action,
    String? referenceId,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      // Validate action
      final paymentAction = PaymentConfig.getAction(action);
      if (paymentAction == null) {
        PaymentLogger.logPaymentError(
          error: 'Invalid payment action',
          transactionId: 'unknown',
          context: {'action': action},
        );
        return TransactionResult.failure(
          message: 'Invalid payment action: $action',
        );
      }

      // Validate amount
      if (!PaymentConfig.isValidAmount(paymentAction.amount)) {
        PaymentLogger.logPaymentError(
          error: 'Invalid payment amount',
          transactionId: 'unknown',
          context: {'action': action, 'amount': paymentAction.amount},
        );
        return TransactionResult.failure(message: 'Invalid payment amount');
      }

      PaymentLogger.logPaymentCreation(
        transactionId: 'pending',
        action: action,
        amount: paymentAction.amount,
        status: 'pending',
        referenceId: referenceId,
      );

      final response = await _apiClient.post<Map<String, dynamic>>(
        '/payments/create',
        {
          'action': action,
          'amount': paymentAction.amount.toStringAsFixed(2),
          'currency': PaymentConfig.defaultCurrency,
          'description': paymentAction.description,
          if (referenceId != null) 'reference_id': referenceId,
          if (metadata != null) 'metadata': metadata.toString(),
        },
        {},
        fromJson: (data) => data as Map<String, dynamic>,
      );

      if (response.success && response.data != null) {
        final transaction = PaymentTransactionModel.fromJson(response.data!);

        PaymentLogger.logPaymentSuccess(
          transactionId: transaction.id.toString(),
          action: action,
          amount: paymentAction.amount,
          metadata: {
            'reference_id': referenceId,
            'gateway': transaction.gateway,
          },
        );

        return TransactionResult.success(transaction: transaction);
      } else {
        PaymentLogger.logPaymentError(
          error: 'Failed to create payment',
          transactionId: 'unknown',
          context: {'action': action, 'response_message': response.message},
        );
        return TransactionResult.failure(message: response.message);
      }
    } on ApiError catch (e) {
      PaymentLogger.logPaymentError(
        error: 'Create payment API error',
        transactionId: 'unknown',
        exception: e,
        context: {'action': action},
      );
      return TransactionResult.failure(message: e.message);
    } catch (e) {
      PaymentLogger.logPaymentError(
        error: 'Create payment unexpected error',
        transactionId: 'unknown',
        exception: e,
        context: {'action': action},
      );
      return TransactionResult.failure(message: 'An unexpected error occurred');
    }
  }

  // Payment config method - REMOVED (payment config endpoint not implemented in API)

  /// Retry a failed payment
  Future<TransactionResult> retryPayment(String transactionId) async {
    try {
      PaymentLogger.logPaymentEvent(
        event: 'payment_retry',
        transactionId: transactionId,
        data: {'attempt_number': 1, 'reason': 'user_requested'},
      );

      final response = await _apiClient.post<Map<String, dynamic>>(
        '/payments/retry',
        {'transaction_id': transactionId},
        {},
        fromJson: (data) => data as Map<String, dynamic>,
      );

      if (response.success && response.data != null) {
        final transaction = PaymentTransactionModel.fromJson(response.data!);

        PaymentLogger.logPaymentSuccess(
          transactionId: transactionId,
          action: transaction.transactionType,
          amount: transaction.amount,
        );

        return TransactionResult.success(transaction: transaction);
      } else {
        PaymentLogger.logPaymentError(
          error: 'Retry payment failed',
          transactionId: transactionId,
          context: {'message': response.message},
        );
        return TransactionResult.failure(message: response.message);
      }
    } on ApiError catch (e) {
      PaymentLogger.logPaymentError(
        error: 'Retry payment API error',
        transactionId: transactionId,
        exception: e,
      );
      return TransactionResult.failure(message: e.message);
    } catch (e) {
      PaymentLogger.logPaymentError(
        error: 'Retry payment unexpected error',
        transactionId: transactionId,
        exception: e,
      );
      return TransactionResult.failure(message: 'An unexpected error occurred');
    }
  }

  /// Handle payment callback
  Future<TransactionResult> handlePaymentCallback({
    required String transactionId,
    required Map<String, dynamic> callbackData,
  }) async {
    try {
      PaymentLogger.logPaymentCallback(
        transactionId: transactionId,
        status: callbackData['status'] as String? ?? 'unknown',
        callbackData: callbackData,
      );

      final response = await _apiClient.post<Map<String, dynamic>>(
        '/payments/callback',
        {
          'transaction_id': transactionId,
          'callback_data': callbackData.toString(),
        },
        {},
        fromJson: (data) => data as Map<String, dynamic>,
      );

      if (response.success && response.data != null) {
        final transaction = PaymentTransactionModel.fromJson(response.data!);

        PaymentLogger.logPaymentSuccess(
          transactionId: transactionId,
          action: transaction.transactionType,
          amount: transaction.amount,
          metadata: {
            'callback_status': callbackData['status'],
            'gateway': transaction.gateway,
          },
        );

        return TransactionResult.success(transaction: transaction);
      } else {
        PaymentLogger.logPaymentError(
          error: 'Failed to handle payment callback',
          transactionId: transactionId,
          context: {
            'callback_data': callbackData,
            'response_message': response.message,
          },
        );
        return TransactionResult.failure(message: response.message);
      }
    } on ApiError catch (e) {
      PaymentLogger.logPaymentError(
        error: 'Handle payment callback API error',
        transactionId: transactionId,
        exception: e,
        context: {'callback_data': callbackData},
      );
      return TransactionResult.failure(message: e.message);
    } catch (e) {
      PaymentLogger.logPaymentError(
        error: 'Handle payment callback unexpected error',
        transactionId: transactionId,
        exception: e,
        context: {'callback_data': callbackData},
      );
      return TransactionResult.failure(message: 'An unexpected error occurred');
    }
  }
}

/// Payment result wrapper
class PaymentResult {
  final bool success;
  final String message;
  final PaymentPlanModel? plan;
  final UserSubscriptionModel? subscription;
  final bool? isActive;
  final int? daysRemaining;

  PaymentResult._({
    required this.success,
    required this.message,
    this.plan,
    this.subscription,
    this.isActive,
    this.daysRemaining,
  });

  factory PaymentResult.success({
    required String message,
    PaymentPlanModel? plan,
    UserSubscriptionModel? subscription,
    bool? isActive,
    int? daysRemaining,
  }) {
    return PaymentResult._(
      success: true,
      message: message,
      plan: plan,
      subscription: subscription,
      isActive: isActive,
      daysRemaining: daysRemaining,
    );
  }

  factory PaymentResult.failure({required String message}) {
    return PaymentResult._(success: false, message: message);
  }
}

/// Payment plans result wrapper
class PaymentPlansResult {
  final bool success;
  final String message;
  final List<PaymentPlanModel>? plans;

  PaymentPlansResult._({
    required this.success,
    required this.message,
    this.plans,
  });

  factory PaymentPlansResult.success({required List<PaymentPlanModel> plans}) {
    return PaymentPlansResult._(
      success: true,
      message: 'Payment plans retrieved successfully',
      plans: plans,
    );
  }

  factory PaymentPlansResult.failure({required String message}) {
    return PaymentPlansResult._(success: false, message: message);
  }
}

/// Subscription result wrapper
class SubscriptionResult {
  final bool success;
  final String message;
  final UserSubscriptionModel? subscription;
  final PaymentTransactionModel? transaction;

  SubscriptionResult._({
    required this.success,
    required this.message,
    this.subscription,
    this.transaction,
  });

  factory SubscriptionResult.success({
    required UserSubscriptionModel subscription,
    required PaymentTransactionModel transaction,
  }) {
    return SubscriptionResult._(
      success: true,
      message: 'Subscription created successfully',
      subscription: subscription,
      transaction: transaction,
    );
  }

  factory SubscriptionResult.failure({required String message}) {
    return SubscriptionResult._(success: false, message: message);
  }
}

/// Payment history result wrapper
class PaymentHistoryResult {
  final bool success;
  final String message;
  final List<PaymentTransactionModel>? transactions;

  PaymentHistoryResult._({
    required this.success,
    required this.message,
    this.transactions,
  });

  factory PaymentHistoryResult.success({
    required List<PaymentTransactionModel> transactions,
  }) {
    return PaymentHistoryResult._(
      success: true,
      message: 'Payment history retrieved successfully',
      transactions: transactions,
    );
  }

  factory PaymentHistoryResult.failure({required String message}) {
    return PaymentHistoryResult._(success: false, message: message);
  }
}

/// Permission result wrapper
class PermissionResult {
  final bool success;
  final String message;
  final bool? canPerform;
  final PaymentPlanModel? plan;
  final String? action;

  PermissionResult._({
    required this.success,
    required this.message,
    this.canPerform,
    this.plan,
    this.action,
  });

  factory PermissionResult.success({
    required bool canPerform,
    required PaymentPlanModel plan,
    required String action,
  }) {
    return PermissionResult._(
      success: true,
      message: 'Permission checked successfully',
      canPerform: canPerform,
      plan: plan,
      action: action,
    );
  }

  factory PermissionResult.failure({required String message}) {
    return PermissionResult._(success: false, message: message);
  }
}

/// Payment list result wrapper
class PaymentListResult {
  final bool success;
  final String message;
  final List<PaymentTransactionModel>? payments;

  PaymentListResult._({
    required this.success,
    required this.message,
    this.payments,
  });

  factory PaymentListResult.success({
    required List<PaymentTransactionModel> payments,
  }) {
    return PaymentListResult._(
      success: true,
      message: 'Payments retrieved successfully',
      payments: payments,
    );
  }

  factory PaymentListResult.failure({required String message}) {
    return PaymentListResult._(success: false, message: message);
  }
}

/// Payment validation result wrapper
class PaymentValidationResult {
  final bool success;
  final String message;
  final bool? paymentRequired;
  final double? requiredAmount;
  final PaymentPlanModel? plan;

  PaymentValidationResult._({
    required this.success,
    required this.message,
    this.paymentRequired,
    this.requiredAmount,
    this.plan,
  });

  factory PaymentValidationResult.success({
    required bool paymentRequired,
    double? requiredAmount,
    PaymentPlanModel? plan,
  }) {
    return PaymentValidationResult._(
      success: true,
      message: 'Payment validation completed successfully',
      paymentRequired: paymentRequired,
      requiredAmount: requiredAmount,
      plan: plan,
    );
  }

  factory PaymentValidationResult.failure({required String message}) {
    return PaymentValidationResult._(success: false, message: message);
  }
}

/// Transaction result wrapper
class TransactionResult {
  final bool success;
  final String message;
  final PaymentTransactionModel? transaction;

  TransactionResult._({
    required this.success,
    required this.message,
    this.transaction,
  });

  factory TransactionResult.success({
    required PaymentTransactionModel transaction,
  }) {
    return TransactionResult._(
      success: true,
      message: 'Transaction processed successfully',
      transaction: transaction,
    );
  }

  factory TransactionResult.failure({required String message}) {
    return TransactionResult._(success: false, message: message);
  }
}

/// Payment configuration result wrapper
class PaymentConfigResult {
  final bool success;
  final String message;
  final Map<String, dynamic>? actions;
  final String? currency;
  final Map<String, dynamic>? limits;

  PaymentConfigResult._({
    required this.success,
    required this.message,
    this.actions,
    this.currency,
    this.limits,
  });

  factory PaymentConfigResult.success({
    required Map<String, dynamic> actions,
    required String currency,
    required Map<String, dynamic> limits,
  }) {
    return PaymentConfigResult._(
      success: true,
      message: 'Payment configuration retrieved successfully',
      actions: actions,
      currency: currency,
      limits: limits,
    );
  }

  factory PaymentConfigResult.failure({required String message}) {
    return PaymentConfigResult._(success: false, message: message);
  }
}
