/// Payment validation model
class PaymentValidationModel {
  final bool paymentRequired;
  final double? requiredAmount;
  final String? planId;
  final String? planName;
  final String? reason;
  final Map<String, dynamic>? metadata;

  const PaymentValidationModel({
    required this.paymentRequired,
    this.requiredAmount,
    this.planId,
    this.planName,
    this.reason,
    this.metadata,
  });

  factory PaymentValidationModel.fromJson(Map<String, dynamic> json) {
    return PaymentValidationModel(
      paymentRequired: json['payment_required'] ?? false,
      requiredAmount: json['required_amount']?.toDouble(),
      planId: json['plan_id']?.toString(),
      planName: json['plan_name']?.toString(),
      reason: json['reason']?.toString(),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'payment_required': paymentRequired,
      'required_amount': requiredAmount,
      'plan_id': planId,
      'plan_name': planName,
      'reason': reason,
      'metadata': metadata,
    };
  }

  /// Get formatted required amount
  String get formattedRequiredAmount {
    if (requiredAmount == null) return '';
    return 'TZS ${requiredAmount!.toStringAsFixed(0)}';
  }
}
