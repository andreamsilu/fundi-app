import 'package:flutter/material.dart';

/// Payment configuration for the application
/// Centralizes all payment-related settings and actions
class PaymentConfig {
  // Payment actions configuration
  static const Map<String, PaymentAction> actions = {
    'job_post': PaymentAction(
      amount: 1000,
      description: 'Job Posting Fee',
      icon: Icons.work,
      color: Colors.blue,
      category: 'job',
    ),
    'premium_profile': PaymentAction(
      amount: 500,
      description: 'Premium Profile Upgrade',
      icon: Icons.star,
      color: Colors.amber,
      category: 'profile',
    ),
    'featured_job': PaymentAction(
      amount: 2000,
      description: 'Featured Job Listing',
      icon: Icons.featured_play_list,
      color: Colors.purple,
      category: 'job',
    ),
    'fundi_application': PaymentAction(
      amount: 200,
      description: 'Fundi Application Fee',
      icon: Icons.person_add,
      color: Colors.green,
      category: 'application',
    ),
    'subscription_monthly': PaymentAction(
      amount: 5000,
      description: 'Monthly Subscription',
      icon: Icons.subscriptions,
      color: Colors.indigo,
      category: 'subscription',
    ),
    'subscription_yearly': PaymentAction(
      amount: 50000,
      description: 'Yearly Subscription',
      icon: Icons.calendar_today,
      color: Colors.deepPurple,
      category: 'subscription',
    ),
  };

  // Currency configuration
  static const String defaultCurrency = 'TZS';
  static const String currencySymbol = 'TSh';

  // Payment gateway configuration
  static const String pesapalEnvironment = 'sandbox'; // or 'production'
  static const String callbackUrl = '/payments/callback';
  static const String cancelUrl = '/payments/cancel';

  // Payment gateway URLs are provided by backend config; no hardcoded URLs here
  static const Map<String, String> samplePaymentUrls = {};

  // Payment endpoints (configured via backend .env)
  static const Map<String, String> paymentEndpoints = {
    'create_payment': '/payments/create',
    'payment_config': '/payments/config',
    'payment_callback': '/payments/callback',
    'payment_status': '/payments/status',
    'pesapal_process': '/payments/pesapal/process',
    'mpesa_process': '/payments/mpesa/process',
    'payment_history': '/payments/history',
    'payment_retry': '/payments/retry',
  };

  // Payment limits
  static const double minAmount = 100.0;
  static const double maxAmount = 1000000.0;

  // Timeout settings
  static const Duration paymentTimeout = Duration(minutes: 30);
  static const Duration callbackTimeout = Duration(minutes: 5);

  /// Get payment action by key
  static PaymentAction? getAction(String key) {
    return actions[key];
  }

  /// Get all actions by category
  static List<PaymentAction> getActionsByCategory(String category) {
    return actions.values
        .where((action) => action.category == category)
        .toList();
  }

  /// Get all available categories
  static List<String> getCategories() {
    return actions.values.map((action) => action.category).toSet().toList();
  }

  /// Validate payment amount
  static bool isValidAmount(double amount) {
    return amount >= minAmount && amount <= maxAmount;
  }

  /// Format amount with currency
  static String formatAmount(double amount) {
    return '$currencySymbol ${amount.toStringAsFixed(0)}';
  }

  /// Get payment action display info
  static PaymentActionDisplay getActionDisplay(String key) {
    final action = getAction(key);
    if (action == null) {
      throw ArgumentError('Payment action not found: $key');
    }

    return PaymentActionDisplay(
      title: action.description,
      amount: formatAmount(action.amount),
      icon: action.icon,
      color: action.color,
      category: action.category,
    );
  }
}

/// Payment action configuration
class PaymentAction {
  final double amount;
  final String description;
  final IconData icon;
  final Color color;
  final String category;

  const PaymentAction({
    required this.amount,
    required this.description,
    required this.icon,
    required this.color,
    required this.category,
  });
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

/// Payment gateway types
enum PaymentGateway {
  pesapal('pesapal', 'Pesapal'),
  mpesa('mpesa', 'M-Pesa'),
  bank('bank', 'Bank Transfer');

  const PaymentGateway(this.value, this.displayName);

  final String value;
  final String displayName;
}
