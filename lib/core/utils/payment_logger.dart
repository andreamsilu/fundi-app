import '../utils/logger.dart';

/// Specialized logger for payment-related events
/// Provides structured logging for payment operations
class PaymentLogger {
  static const String _tag = 'Payment';
  
  /// Log payment event
  static void logPaymentEvent({
    required String event,
    required String transactionId,
    Map<String, dynamic>? data,
    String? userId,
  }) {
    Logger.userAction(
      '$_tag Event: $event',
      data: {
        'transaction_id': transactionId,
        'user_id': userId,
        'timestamp': DateTime.now().toIso8601String(),
        'event_type': 'payment_event',
        ...?data,
      },
    );
  }
  
  /// Log payment error
  static void logPaymentError({
    required String error,
    required String transactionId,
    Object? exception,
    String? userId,
    Map<String, dynamic>? context,
  }) {
    Logger.error(
      '$_tag Error: $error',
      error: exception,
    );
  }
  
  /// Log payment success
  static void logPaymentSuccess({
    required String transactionId,
    required String action,
    required double amount,
    String? userId,
    Map<String, dynamic>? metadata,
  }) {
    Logger.userAction(
      '$_tag Success: Payment completed',
      data: {
        'transaction_id': transactionId,
        'user_id': userId,
        'action': action,
        'amount': amount,
        'timestamp': DateTime.now().toIso8601String(),
        'event_type': 'payment_success',
        ...?metadata,
      },
    );
  }
  
  /// Log payment creation
  static void logPaymentCreation({
    required String transactionId,
    required String action,
    required double amount,
    required String status,
    String? userId,
    String? referenceId,
  }) {
    Logger.userAction(
      '$_tag Creation: Payment request created',
      data: {
        'transaction_id': transactionId,
        'user_id': userId,
        'action': action,
        'amount': amount,
        'status': status,
        'reference_id': referenceId,
        'timestamp': DateTime.now().toIso8601String(),
        'event_type': 'payment_creation',
      },
    );
  }
  
  /// Log payment callback
  static void logPaymentCallback({
    required String transactionId,
    required String status,
    required Map<String, dynamic> callbackData,
    String? userId,
  }) {
    Logger.userAction(
      '$_tag Callback: Payment callback received',
      data: {
        'transaction_id': transactionId,
        'user_id': userId,
        'callback_status': status,
        'callback_data': callbackData,
        'timestamp': DateTime.now().toIso8601String(),
        'event_type': 'payment_callback',
      },
    );
  }
  
  /// Log payment validation
  static void logPaymentValidation({
    required String transactionId,
    required bool isValid,
    required String validationType,
    String? errorMessage,
    String? userId,
  }) {
    Logger.userAction(
      '$_tag Validation: $validationType validation ${isValid ? 'passed' : 'failed'}',
      data: {
        'transaction_id': transactionId,
        'user_id': userId,
        'is_valid': isValid,
        'validation_type': validationType,
        'error_message': errorMessage,
        'timestamp': DateTime.now().toIso8601String(),
        'event_type': 'payment_validation',
      },
    );
  }
  
  /// Log payment retry
  static void logPaymentRetry({
    required String transactionId,
    required int attemptNumber,
    required String reason,
    String? userId,
  }) {
    Logger.warning(
      '$_tag Retry: Payment retry attempt $attemptNumber',
      data: {
        'transaction_id': transactionId,
        'user_id': userId,
        'attempt_number': attemptNumber,
        'retry_reason': reason,
        'timestamp': DateTime.now().toIso8601String(),
        'event_type': 'payment_retry',
      },
    );
  }
  
  /// Log payment timeout
  static void logPaymentTimeout({
    required String transactionId,
    required Duration timeoutDuration,
    String? userId,
  }) {
    Logger.warning(
      '$_tag Timeout: Payment request timed out',
      data: {
        'transaction_id': transactionId,
        'user_id': userId,
        'timeout_duration_ms': timeoutDuration.inMilliseconds,
        'timestamp': DateTime.now().toIso8601String(),
        'event_type': 'payment_timeout',
      },
    );
  }
  
  /// Log payment gateway interaction
  static void logGatewayInteraction({
    required String gateway,
    required String action,
    required String transactionId,
    Map<String, dynamic>? requestData,
    Map<String, dynamic>? responseData,
    String? userId,
  }) {
    Logger.userAction(
      '$_tag Gateway: $gateway $action',
      data: {
        'transaction_id': transactionId,
        'user_id': userId,
        'gateway': gateway,
        'action': action,
        'request_data': requestData,
        'response_data': responseData,
        'timestamp': DateTime.now().toIso8601String(),
        'event_type': 'gateway_interaction',
      },
    );
  }
  
  /// Log payment configuration change
  static void logConfigChange({
    required String configKey,
    required dynamic oldValue,
    required dynamic newValue,
    String? userId,
  }) {
    Logger.userAction(
      '$_tag Config: Configuration changed',
      data: {
        'user_id': userId,
        'config_key': configKey,
        'old_value': oldValue,
        'new_value': newValue,
        'timestamp': DateTime.now().toIso8601String(),
        'event_type': 'config_change',
      },
    );
  }
}
