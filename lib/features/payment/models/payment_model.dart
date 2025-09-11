/// Payment model representing payment transactions
class PaymentModel {
  final String id;
  final String userId;
  final double amount;
  final String paymentType;
  final PaymentStatus status;
  final String? pesapalReference;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  const PaymentModel({
    required this.id,
    required this.userId,
    required this.amount,
    required this.paymentType,
    required this.status,
    this.pesapalReference,
    this.metadata,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Get formatted amount
  String get formattedAmount {
    final currency = 'TZS';
    if (amount >= 1000000) {
      return '$currency ${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '$currency ${(amount / 1000).toStringAsFixed(1)}K';
    } else {
      return '$currency ${amount.toStringAsFixed(0)}';
    }
  }

  /// Check if payment is completed
  bool get isCompleted => status == PaymentStatus.completed;

  /// Check if payment is pending
  bool get isPending => status == PaymentStatus.pending;

  /// Check if payment failed
  bool get isFailed => status == PaymentStatus.failed;

  /// Create PaymentModel from JSON
  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      amount: (json['amount'] as num).toDouble(),
      paymentType: json['payment_type'] as String,
      status: PaymentStatus.fromString(json['status'] as String),
      pesapalReference: json['pesapal_reference'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// Convert PaymentModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'amount': amount,
      'payment_type': paymentType,
      'status': status.value,
      'pesapal_reference': pesapalReference,
      'metadata': metadata,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Create a copy with updated fields
  PaymentModel copyWith({
    String? id,
    String? userId,
    double? amount,
    String? paymentType,
    PaymentStatus? status,
    String? pesapalReference,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PaymentModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      amount: amount ?? this.amount,
      paymentType: paymentType ?? this.paymentType,
      status: status ?? this.status,
      pesapalReference: pesapalReference ?? this.pesapalReference,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PaymentModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'PaymentModel(id: $id, amount: $formattedAmount, status: $status)';
  }
}

/// Payment status enumeration
enum PaymentStatus {
  pending('pending'),
  completed('completed'),
  failed('failed');

  const PaymentStatus(this.value);
  final String value;

  static PaymentStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'pending':
        return PaymentStatus.pending;
      case 'completed':
        return PaymentStatus.completed;
      case 'failed':
        return PaymentStatus.failed;
      default:
        throw ArgumentError('Invalid payment status: $value');
    }
  }

  String get displayName {
    switch (this) {
      case PaymentStatus.pending:
        return 'Pending';
      case PaymentStatus.completed:
        return 'Completed';
      case PaymentStatus.failed:
        return 'Failed';
    }
  }
}

/// Payment type enumeration
enum PaymentType {
  subscription('subscription'),
  applicationFee('application_fee'),
  jobPosting('job_posting');

  const PaymentType(this.value);
  final String value;

  static PaymentType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'subscription':
        return PaymentType.subscription;
      case 'application_fee':
        return PaymentType.applicationFee;
      case 'job_posting':
        return PaymentType.jobPosting;
      default:
        throw ArgumentError('Invalid payment type: $value');
    }
  }

  String get displayName {
    switch (this) {
      case PaymentType.subscription:
        return 'Subscription';
      case PaymentType.applicationFee:
        return 'Application Fee';
      case PaymentType.jobPosting:
        return 'Job Posting';
    }
  }
}

/// Payment requirements model
class PaymentRequirementsModel {
  final bool paymentsEnabled;
  final String paymentModel;
  final bool subscriptionEnabled;
  final double subscriptionFee;
  final String subscriptionPeriod;
  final bool jobApplicationFeeEnabled;
  final double jobApplicationFee;
  final bool jobPostingFeeEnabled;
  final double jobPostingFee;
  final bool hasActiveSubscription;
  final DateTime? subscriptionExpiresAt;

  const PaymentRequirementsModel({
    required this.paymentsEnabled,
    required this.paymentModel,
    required this.subscriptionEnabled,
    required this.subscriptionFee,
    required this.subscriptionPeriod,
    required this.jobApplicationFeeEnabled,
    required this.jobApplicationFee,
    required this.jobPostingFeeEnabled,
    required this.jobPostingFee,
    required this.hasActiveSubscription,
    this.subscriptionExpiresAt,
  });

  /// Check if platform is in free mode
  bool get isFreeMode => !paymentsEnabled || 
      (!subscriptionEnabled && !jobApplicationFeeEnabled && !jobPostingFeeEnabled);

  /// Check if subscription is required
  bool get isSubscriptionRequired => paymentsEnabled && subscriptionEnabled;

  /// Check if job application fee is required
  bool get isJobApplicationFeeRequired => paymentsEnabled && jobApplicationFeeEnabled;

  /// Check if job posting fee is required
  bool get isJobPostingFeeRequired => paymentsEnabled && jobPostingFeeEnabled;

  /// Get subscription fee amount
  double get getSubscriptionFee => subscriptionFee;

  /// Get job application fee amount
  double get getJobApplicationFee => jobApplicationFee;

  /// Get job posting fee amount
  double get getJobPostingFee => jobPostingFee;

  /// Create PaymentRequirementsModel from JSON
  factory PaymentRequirementsModel.fromJson(Map<String, dynamic> json) {
    return PaymentRequirementsModel(
      paymentsEnabled: json['payments_enabled'] as bool? ?? false,
      paymentModel: json['payment_model'] as String? ?? 'free',
      subscriptionEnabled: json['subscription_enabled'] as bool? ?? false,
      subscriptionFee: (json['subscription_fee'] as num?)?.toDouble() ?? 0.0,
      subscriptionPeriod: json['subscription_period'] as String? ?? 'monthly',
      jobApplicationFeeEnabled: json['job_application_fee_enabled'] as bool? ?? false,
      jobApplicationFee: (json['job_application_fee'] as num?)?.toDouble() ?? 0.0,
      jobPostingFeeEnabled: json['job_posting_fee_enabled'] as bool? ?? false,
      jobPostingFee: (json['job_posting_fee'] as num?)?.toDouble() ?? 0.0,
      hasActiveSubscription: json['has_active_subscription'] as bool? ?? false,
      subscriptionExpiresAt: json['subscription_expires_at'] != null
          ? DateTime.parse(json['subscription_expires_at'] as String)
          : null,
    );
  }

  /// Convert PaymentRequirementsModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'payments_enabled': paymentsEnabled,
      'payment_model': paymentModel,
      'subscription_enabled': subscriptionEnabled,
      'subscription_fee': subscriptionFee,
      'subscription_period': subscriptionPeriod,
      'job_application_fee_enabled': jobApplicationFeeEnabled,
      'job_application_fee': jobApplicationFee,
      'job_posting_fee_enabled': jobPostingFeeEnabled,
      'job_posting_fee': jobPostingFee,
      'has_active_subscription': hasActiveSubscription,
      'subscription_expires_at': subscriptionExpiresAt?.toIso8601String(),
    };
  }
}

/// Payment validation result model
class PaymentValidationModel {
  final bool allowed;
  final bool feeRequired;
  final double feeAmount;
  final String paymentType;
  final String reason;

  const PaymentValidationModel({
    required this.allowed,
    required this.feeRequired,
    required this.feeAmount,
    required this.paymentType,
    required this.reason,
  });

  /// Create PaymentValidationModel from JSON
  factory PaymentValidationModel.fromJson(Map<String, dynamic> json) {
    return PaymentValidationModel(
      allowed: json['allowed'] as bool? ?? false,
      feeRequired: json['fee_required'] as bool? ?? false,
      feeAmount: (json['fee_amount'] as num?)?.toDouble() ?? 0.0,
      paymentType: json['payment_type'] as String? ?? 'subscription',
      reason: json['reason'] as String? ?? 'Payment required',
    );
  }

  /// Convert PaymentValidationModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'allowed': allowed,
      'fee_required': feeRequired,
      'fee_amount': feeAmount,
      'payment_type': paymentType,
      'reason': reason,
    };
  }
}
