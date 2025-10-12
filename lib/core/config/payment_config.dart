import 'package:flutter/material.dart';
import '../services/pricing_service.dart';

/// Payment configuration for the application
/// ✅ IMPORTANT: Pricing is now fetched from API (admin panel controlled)
/// This file only contains UI metadata (icons, colors, descriptions)
class PaymentConfig {
  // ✅ Payment actions metadata (NO HARDCODED PRICES)
  // Prices are fetched from PricingService which calls API
  static const Map<String, PaymentActionMetadata> actionMetadata = {
    'job_post': PaymentActionMetadata(
      key: 'job_posting',
      description: 'Job Posting Fee',
      icon: Icons.work,
      color: Colors.blue,
      category: 'job',
    ),
    'premium_profile': PaymentActionMetadata(
      key: 'premium_profile',
      description: 'Premium Profile Upgrade',
      icon: Icons.star,
      color: Colors.amber,
      category: 'profile',
    ),
    'featured_job': PaymentActionMetadata(
      key: 'featured_job',
      description: 'Featured Job Listing',
      icon: Icons.featured_play_list,
      color: Colors.purple,
      category: 'job',
    ),
    'fundi_application': PaymentActionMetadata(
      key: 'job_application',
      description: 'Fundi Application Fee',
      icon: Icons.person_add,
      color: Colors.green,
      category: 'application',
    ),
    'subscription_monthly': PaymentActionMetadata(
      key: 'subscription_monthly',
      description: 'Monthly Subscription',
      icon: Icons.subscriptions,
      color: Colors.indigo,
      category: 'subscription',
    ),
    'subscription_yearly': PaymentActionMetadata(
      key: 'subscription_yearly',
      description: 'Yearly Subscription',
      icon: Icons.calendar_today,
      color: Colors.deepPurple,
      category: 'subscription',
    ),
  };

  /// Get payment action with current pricing from API
  static Future<PaymentAction> getAction(String key) async {
    final metadata = actionMetadata[key];
    if (metadata == null) {
      throw ArgumentError('Payment action not found: $key');
    }

    // ✅ Fetch current price from API
    final pricingService = PricingService();
    final price = await pricingService.getPriceFor(metadata.key);

    return PaymentAction(
      key: metadata.key,
      amount: price,
      description: metadata.description,
      icon: metadata.icon,
      color: metadata.color,
      category: metadata.category,
    );
  }

  /// Get all actions with current pricing
  static Future<Map<String, PaymentAction>> getAllActions() async {
    final pricingService = PricingService();
    final pricing = await pricingService.getPricing();

    final actions = <String, PaymentAction>{};
    for (final entry in actionMetadata.entries) {
      final price = pricing.getPrice(entry.value.key);
      actions[entry.key] = PaymentAction(
        key: entry.value.key,
        amount: price,
        description: entry.value.description,
        icon: entry.value.icon,
        color: entry.value.color,
        category: entry.value.category,
      );
    }

    return actions;
  }

  // Currency configuration
  static const String defaultCurrency = 'TZS';
  static const String currencySymbol = 'TSh';

  // Payment limits
  static const double minAmount = 100.0;
  static const double maxAmount = 1000000.0;

  // Timeout settings
  static const Duration paymentTimeout = Duration(minutes: 30);
  static const Duration callbackTimeout = Duration(minutes: 5);

  /// Get all actions by category
  static Future<List<PaymentAction>> getActionsByCategory(
    String category,
  ) async {
    final actions = await getAllActions();
    return actions.values
        .where((action) => action.category == category)
        .toList();
  }

  /// Get all available categories
  static List<String> getCategories() {
    return actionMetadata.values
        .map((action) => action.category)
        .toSet()
        .toList();
  }

  /// Validate payment amount
  static bool isValidAmount(double amount) {
    return amount >= minAmount && amount <= maxAmount;
  }

  /// Format amount with currency
  static String formatAmount(double amount) {
    return '$currencySymbol ${amount.toStringAsFixed(0)}';
  }
}

/// Payment action metadata (UI only - no pricing)
class PaymentActionMetadata {
  final String key;
  final String description;
  final IconData icon;
  final Color color;
  final String category;

  const PaymentActionMetadata({
    required this.key,
    required this.description,
    required this.icon,
    required this.color,
    required this.category,
  });
}

/// Payment action with current pricing (from API)
class PaymentAction {
  final String key;
  final double amount;
  final String description;
  final IconData icon;
  final Color color;
  final String category;

  const PaymentAction({
    required this.key,
    required this.amount,
    required this.description,
    required this.icon,
    required this.color,
    required this.category,
  });

  /// Format amount with currency
  String get formattedAmount {
    return 'TZS ${amount.toStringAsFixed(0)}';
  }
}

/// Payment action display information
class PaymentActionDisplay {
  final String title;
  final String amount;
  final IconData icon;
  final Color color;
  final String category;

  const PaymentActionDisplay({
    required this.title,
    required this.amount,
    required this.icon,
    required this.color,
    required this.category,
  });
}

/// Payment status enumeration
enum PaymentStatus {
  pending('pending', 'Pending', Colors.orange),
  completed('completed', 'Completed', Colors.green),
  failed('failed', 'Failed', Colors.red),
  cancelled('cancelled', 'Cancelled', Colors.grey),
  processing('processing', 'Processing', Colors.blue);

  const PaymentStatus(this.value, this.displayName, this.color);

  final String value;
  final String displayName;
  final Color color;

  static PaymentStatus fromString(String value) {
    return PaymentStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => PaymentStatus.pending,
    );
  }
}

/// Payment gateway types (Updated for ZenoPay)
enum PaymentGateway {
  zenopay('zenopay', 'ZenoPay Mobile Money'),
  mpesa('mpesa', 'M-Pesa'),
  tigopesa('tigopesa', 'Tigo Pesa'),
  airtelmoney('airtelmoney', 'Airtel Money');

  const PaymentGateway(this.value, this.displayName);

  final String value;
  final String displayName;
}
