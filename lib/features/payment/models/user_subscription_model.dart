/// User subscription model for mobile app
class UserSubscriptionModel {
  final int id;
  final int userId;
  final int paymentPlanId;
  final String status;
  final DateTime startsAt;
  final DateTime? expiresAt;
  final DateTime? cancelledAt;
  final Map<String, dynamic>? metadata;

  const UserSubscriptionModel({
    required this.id,
    required this.userId,
    required this.paymentPlanId,
    required this.status,
    required this.startsAt,
    this.expiresAt,
    this.cancelledAt,
    this.metadata,
  });

  factory UserSubscriptionModel.fromJson(Map<String, dynamic> json) {
    return UserSubscriptionModel(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      paymentPlanId: json['payment_plan_id'] as int,
      status: json['status'] as String,
      startsAt: DateTime.parse(json['starts_at'] as String),
      expiresAt: json['expires_at'] != null 
          ? DateTime.parse(json['expires_at'] as String) 
          : null,
      cancelledAt: json['cancelled_at'] != null 
          ? DateTime.parse(json['cancelled_at'] as String) 
          : null,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'payment_plan_id': paymentPlanId,
      'status': status,
      'starts_at': startsAt.toIso8601String(),
      'expires_at': expiresAt?.toIso8601String(),
      'cancelled_at': cancelledAt?.toIso8601String(),
      'metadata': metadata,
    };
  }

  /// Check if subscription is active
  bool get isActive {
    return status == 'active' && 
           (expiresAt == null || expiresAt!.isAfter(DateTime.now()));
  }

  /// Check if subscription is expired
  bool get isExpired {
    return expiresAt != null && expiresAt!.isBefore(DateTime.now());
  }

  /// Check if subscription is cancelled
  bool get isCancelled {
    return status == 'cancelled' || cancelledAt != null;
  }

  /// Get days remaining until expiration
  int get daysRemaining {
    if (expiresAt == null) return 0;
    final now = DateTime.now();
    final difference = expiresAt!.difference(now).inDays;
    return difference > 0 ? difference : 0;
  }

  /// Get status display text
  String get statusDisplay {
    switch (status) {
      case 'active':
        return 'Active';
      case 'expired':
        return 'Expired';
      case 'cancelled':
        return 'Cancelled';
      case 'pending':
        return 'Pending';
      default:
        return 'Unknown';
    }
  }
}
