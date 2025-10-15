import '../../../core/config/payment_config.dart';

/// Payment transaction model for mobile app
class PaymentTransactionModel {
  final int id;
  final int userId;
  final int paymentPlanId;
  final String transactionType;
  final String? referenceId;
  final double amount;
  final String currency;
  final String? paymentMethod;
  final String? paymentReference;
  final String status;
  final String? description;
  final Map<String, dynamic>? metadata;
  final DateTime? paidAt;
  final DateTime createdAt;
  final String? gatewayReference;
  final String? pesapalTrackingId;
  final Map<String, dynamic>? callbackData;
  final String? gateway;
  final DateTime? updatedAt;

  const PaymentTransactionModel({
    required this.id,
    required this.userId,
    required this.paymentPlanId,
    required this.transactionType,
    this.referenceId,
    required this.amount,
    required this.currency,
    this.paymentMethod,
    this.paymentReference,
    required this.status,
    this.description,
    this.metadata,
    this.paidAt,
    required this.createdAt,
    this.gatewayReference,
    this.pesapalTrackingId,
    this.callbackData,
    this.gateway,
    this.updatedAt,
  });

  factory PaymentTransactionModel.fromJson(Map<String, dynamic> json) {
    return PaymentTransactionModel(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      paymentPlanId: json['payment_plan_id'] as int,
      transactionType: json['transaction_type'] as String,
      referenceId: json['reference_id'] as String?,
      amount: _parseDouble(json['amount']),
      currency: json['currency'] as String,
      paymentMethod: json['payment_method'] as String?,
      paymentReference: json['payment_reference'] as String?,
      status: json['status'] as String,
      description: json['description'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      paidAt: json['paid_at'] != null
          ? DateTime.parse(json['paid_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      gatewayReference: json['gateway_reference'] as String?,
      pesapalTrackingId: json['pesapal_tracking_id'] as String?,
      callbackData: json['callback_data'] as Map<String, dynamic>?,
      gateway: json['gateway'] as String?,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'payment_plan_id': paymentPlanId,
      'transaction_type': transactionType,
      'reference_id': referenceId,
      'amount': amount,
      'currency': currency,
      'payment_method': paymentMethod,
      'payment_reference': paymentReference,
      'status': status,
      'description': description,
      'metadata': metadata,
      'paid_at': paidAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'gateway_reference': gatewayReference,
      'pesapal_tracking_id': pesapalTrackingId,
      'callback_data': callbackData,
      'gateway': gateway,
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// Check if transaction is completed
  bool get isCompleted => status == 'completed';

  /// Check if transaction is pending
  bool get isPending => status == 'pending';

  /// Check if transaction is in progress
  bool get isInProgress => status == 'processing' || status == 'pending';

  /// Check if transaction failed
  bool get isFailed => status == 'failed';

  /// Check if transaction is refunded
  bool get isRefunded => status == 'refunded';

  /// Get formatted amount
  String get formattedAmount {
    return '$currency ${amount.toStringAsFixed(0)}';
  }

  /// Get status display text
  String get statusDisplay {
    switch (status) {
      case 'completed':
        return 'Completed';
      case 'pending':
        return 'Pending';
      case 'failed':
        return 'Failed';
      case 'refunded':
        return 'Refunded';
      default:
        return 'Unknown';
    }
  }

  /// Get transaction type display
  String get typeDisplay {
    switch (transactionType) {
      case 'subscription':
        return 'Subscription';
      case 'pay_per_use':
        return 'Pay Per Use';
      case 'job_posting':
        return 'Job Posting';
      case 'fundi_application':
        return 'Fundi Application';
      default:
        return 'Payment';
    }
  }

  /// Get payment status enum
  PaymentStatus get paymentStatus => PaymentStatus.fromString(status);

  /// Check if transaction can be retried
  bool get canRetry => status == 'failed' || status == 'cancelled';

  /// Get gateway display name
  String get gatewayDisplay {
    switch (gateway) {
      case 'pesapal':
        return 'Pesapal';
      case 'mpesa':
        return 'M-Pesa';
      case 'bank':
        return 'Bank Transfer';
      default:
        return 'Unknown Gateway';
    }
  }

  /// Get transaction age
  Duration get age => DateTime.now().difference(createdAt);

  /// Check if transaction is stale (older than 1 hour)
  bool get isStale => age.inHours > 1;

  /// Get callback status if available
  String? get callbackStatus => callbackData?['status'] as String?;

  /// Get tracking URL if available
  String? get trackingUrl => callbackData?['tracking_url'] as String?;

  /// Helper method to parse double from dynamic value (handles both String and num)
  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}
