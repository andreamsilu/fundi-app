import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Payment Required Dialog
/// Shows when a feature requires payment or subscription upgrade
class PaymentRequiredDialog extends StatelessWidget {
  final String feature;
  final String message;
  final double? requiredAmount;
  final String? planName;

  const PaymentRequiredDialog({
    super.key,
    required this.feature,
    this.message = 'This feature requires an active subscription or payment.',
    this.requiredAmount,
    this.planName,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Icon(Icons.lock_outline, color: AppTheme.primaryGreen, size: 28),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Subscription Required',
              style: TextStyle(fontSize: 20),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(message, style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.lightGray,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.star, color: Colors.amber, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Feature: $feature',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                if (requiredAmount != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Amount: TZS ${requiredAmount!.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppTheme.primaryGreen,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
                if (planName != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Recommended Plan: $planName',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton.icon(
          onPressed: () {
            Navigator.pop(context);
            Navigator.pushNamed(context, '/payment-plans');
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryGreen,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
          icon: const Icon(Icons.upgrade, size: 20),
          label: const Text('View Plans'),
        ),
      ],
    );
  }

  /// Show payment required dialog
  static Future<void> show(
    BuildContext context, {
    required String feature,
    String? message,
    double? requiredAmount,
    String? planName,
  }) async {
    return showDialog(
      context: context,
      builder: (context) => PaymentRequiredDialog(
        feature: feature,
        message: message ?? 'This feature requires an active subscription.',
        requiredAmount: requiredAmount,
        planName: planName,
      ),
    );
  }
}




