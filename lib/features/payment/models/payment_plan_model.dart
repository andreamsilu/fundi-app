/// Payment plan model for mobile app
class PaymentPlanModel {
  final int id;
  final String name;
  final String type;
  final String? description;
  final double price;
  final String? billingCycle;
  final List<String> features;
  final Map<String, dynamic>? limits;
  final bool isActive;
  final bool isDefault;

  const PaymentPlanModel({
    required this.id,
    required this.name,
    required this.type,
    this.description,
    required this.price,
    this.billingCycle,
    required this.features,
    this.limits,
    required this.isActive,
    required this.isDefault,
  });

  factory PaymentPlanModel.fromJson(Map<String, dynamic> json) {
    return PaymentPlanModel(
      id: json['id'] as int,
      name: json['name'] as String,
      type: json['type'] as String,
      description: json['description'] as String?,
      price: _parseDouble(json['price']),
      billingCycle: json['billing_cycle'] as String?,
      features: List<String>.from(json['features'] ?? []),
      limits: json['limits'] as Map<String, dynamic>?,
      isActive: json['is_active'] == true,
      isDefault: json['is_default'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'description': description,
      'price': price,
      'billing_cycle': billingCycle,
      'features': features,
      'limits': limits,
      'is_active': isActive,
      'is_default': isDefault,
    };
  }

  /// Check if this is a free plan
  bool get isFree => type == 'free';

  /// Check if this is a subscription plan
  bool get isSubscription => type == 'subscription';

  /// Check if this is a pay-per-use plan
  bool get isPayPerUse => type == 'pay_per_use';

  /// Get formatted price
  String get formattedPrice {
    if (isFree) return 'Free';
    return 'TZS ${price.toStringAsFixed(0)}';
  }

  /// Get billing cycle display
  String get billingCycleDisplay {
    if (billingCycle == null) return '';
    switch (billingCycle) {
      case 'monthly':
        return '/month';
      case 'yearly':
        return '/year';
      default:
        return '';
    }
  }

  /// Get full price display
  String get fullPriceDisplay {
    if (isFree) return 'Free';
    return 'TZS ${price.toStringAsFixed(0)}$billingCycleDisplay';
  }

  /// Helper method to parse double from dynamic value (handles both String and num)
  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}
