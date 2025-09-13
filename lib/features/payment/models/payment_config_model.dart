import 'package:flutter/material.dart';
import '../../../core/config/payment_config.dart';

/// Payment configuration model from backend
class PaymentConfigModel {
  final List<PaymentAction> actions;
  final Map<String, dynamic> settings;
  final String lastUpdated;

  const PaymentConfigModel({
    required this.actions,
    required this.settings,
    required this.lastUpdated,
  });

  factory PaymentConfigModel.fromJson(Map<String, dynamic> json) {
    final actionsJson = json['actions'] as List<dynamic>? ?? [];
    final actions = actionsJson
        .map(
          (actionJson) => PaymentAction(
            amount: (actionJson['amount'] as num).toDouble(),
            description: actionJson['description'] as String,
            icon: Icons.work, // Default icon, should be mapped from server
            color: Colors.blue, // Default color, should be mapped from server
            category: actionJson['category'] as String,
          ),
        )
        .toList();

    return PaymentConfigModel(
      actions: actions,
      settings: json['settings'] as Map<String, dynamic>? ?? {},
      lastUpdated: json['last_updated'] ?? DateTime.now().toIso8601String(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'actions': actions
          .map(
            (action) => {
              'amount': action.amount,
              'description': action.description,
              'category': action.category,
            },
          )
          .toList(),
      'settings': settings,
      'last_updated': lastUpdated,
    };
  }

  /// Get action by description (since PaymentAction doesn't have ID)
  PaymentAction? getAction(String actionDescription) {
    try {
      return actions.firstWhere(
        (action) => action.description == actionDescription,
      );
    } catch (e) {
      return null;
    }
  }

  /// Get actions by category
  List<PaymentAction> getActionsByCategory(String category) {
    return actions.where((action) => action.category == category).toList();
  }

  /// Get all categories
  List<String> getAllCategories() {
    return actions.map((action) => action.category).toSet().toList();
  }

  /// Check if configuration is stale (older than 1 hour)
  bool get isStale {
    try {
      final lastUpdate = DateTime.parse(lastUpdated);
      final now = DateTime.now();
      return now.difference(lastUpdate).inHours >= 1;
    } catch (e) {
      return true; // If we can't parse the date, consider it stale
    }
  }

  /// Merge with default configuration
  PaymentConfigModel mergeWithDefaults() {
    final defaultActions = PaymentConfig.actions.values.toList();
    final mergedActions = <PaymentAction>[];

    // Add default actions
    for (final defaultAction in defaultActions) {
      final serverAction = getAction(defaultAction.description);
      mergedActions.add(serverAction ?? defaultAction);
    }

    // Add any new server actions not in defaults
    for (final serverAction in actions) {
      if (!defaultActions.any(
        (action) => action.description == serverAction.description,
      )) {
        mergedActions.add(serverAction);
      }
    }

    return PaymentConfigModel(
      actions: mergedActions,
      settings: settings,
      lastUpdated: lastUpdated,
    );
  }
}
