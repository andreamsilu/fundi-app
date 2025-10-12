import 'package:flutter/foundation.dart';
import '../models/payment_transaction_model.dart';
import '../models/payment_plan_model.dart';
import '../models/user_subscription_model.dart';
import '../services/payment_service.dart';
import '../../../core/config/payment_config.dart';
import '../../../core/utils/payment_logger.dart';

/// Provider for managing payment state and operations
class PaymentProvider extends ChangeNotifier {
  final PaymentService _paymentService = PaymentService();

  // State variables
  List<PaymentTransactionModel> _transactions = [];
  Map<String, PaymentAction> _availableActions = {};
  List<PaymentPlanModel> _availablePlans = [];
  PaymentPlanModel? _currentPlan;
  UserSubscriptionModel? _currentSubscription;
  bool _isLoading = false;
  String? _errorMessage;
  PaymentTransactionModel? _currentTransaction;

  // Getters
  List<PaymentTransactionModel> get transactions => _transactions;
  Map<String, PaymentAction> get availableActions => _availableActions;
  List<PaymentPlanModel> get availablePlans => _availablePlans;
  PaymentPlanModel? get currentPlan => _currentPlan;
  UserSubscriptionModel? get currentSubscription => _currentSubscription;
  bool get isLoading => _isLoading;
  String? get error => _errorMessage;
  String? get errorMessage => _errorMessage;
  PaymentTransactionModel? get currentTransaction => _currentTransaction;

  // Payment actions by category
  List<PaymentAction> getActionsByCategory(String category) {
    return _availableActions.values
        .where((action) => action.category == category)
        .toList();
  }

  // Recent transactions
  List<PaymentTransactionModel> get recentTransactions {
    return _transactions.where((txn) => txn.age.inDays <= 7).toList();
  }

  // Pending transactions
  List<PaymentTransactionModel> get pendingTransactions {
    return _transactions.where((txn) => txn.isInProgress).toList();
  }

  // Failed transactions
  List<PaymentTransactionModel> get failedTransactions {
    return _transactions.where((txn) => txn.canRetry).toList();
  }

  /// Initialize payment provider
  Future<void> initialize() async {
    await Future.wait([loadPaymentActions(), loadPaymentHistory()]);
  }

  /// Load available payment actions
  Future<void> loadPaymentActions() async {
    try {
      _setLoading(true);
      _clearError();

      PaymentLogger.logPaymentEvent(
        event: 'load_payment_actions',
        transactionId: 'provider_init',
      );

      // For now, use static configuration
      // In the future, this could fetch from backend
      _availableActions = Map.from(await PaymentConfig.getAllActions());

      PaymentLogger.logPaymentEvent(
        event: 'payment_actions_loaded',
        transactionId: 'provider_init',
        data: {'action_count': _availableActions.length},
      );

      notifyListeners();
    } catch (e) {
      _setError('Failed to load payment actions: ${e.toString()}');
      PaymentLogger.logPaymentError(
        error: 'Load payment actions failed',
        transactionId: 'provider_init',
        exception: e,
      );
    } finally {
      _setLoading(false);
    }
  }

  /// Load payment history
  Future<void> loadPaymentHistory() async {
    try {
      _setLoading(true);
      _clearError();

      PaymentLogger.logPaymentEvent(
        event: 'load_payment_history',
        transactionId: 'provider_init',
      );

      final result = await _paymentService.getPaymentHistory();

      if (result.success) {
        _transactions = result.transactions ?? [];

        PaymentLogger.logPaymentEvent(
          event: 'payment_history_loaded',
          transactionId: 'provider_init',
          data: {'transaction_count': _transactions.length},
        );
      } else {
        _setError(result.message);
        PaymentLogger.logPaymentError(
          error: 'Load payment history failed',
          transactionId: 'provider_init',
          context: {'message': result.message},
        );
      }

      notifyListeners();
    } catch (e) {
      _setError('Failed to load payment history: ${e.toString()}');
      PaymentLogger.logPaymentError(
        error: 'Load payment history failed',
        transactionId: 'provider_init',
        exception: e,
      );
    } finally {
      _setLoading(false);
    }
  }

  /// Load payments (alias for loadPaymentHistory)
  Future<void> loadPayments({int page = 1}) async {
    await loadPaymentHistory();
  }

  /// Refresh payments (alias for refresh)
  Future<void> refreshPayments() async {
    await refresh();
  }

  /// Process payment
  Future<Map<String, dynamic>?> processPayment({
    required double amount,
    required String paymentType,
    required String phoneNumber,
    required String email,
    String? description,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      final result = await _paymentService.createPayment(
        action: paymentType,
        metadata: {
          'phone_number': phoneNumber,
          'email': email,
          'description': description,
        },
      );

      if (result.success && result.transaction != null) {
        _currentTransaction = result.transaction;
        _transactions.insert(0, result.transaction!);

        notifyListeners();

        return {
          'pesapal_reference': result.transaction!.gatewayReference ?? 'N/A',
          'amount': result.transaction!.amount,
          'transaction_id': result.transaction!.id,
        };
      } else {
        _setError(result.message);
        notifyListeners();
        return null;
      }
    } catch (e) {
      _setError('Failed to process payment: ${e.toString()}');
      notifyListeners();
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // Getters for payment list screen
  List<PaymentTransactionModel> get payments => _transactions;
  List<PaymentTransactionModel> get completedPayments =>
      _transactions.where((txn) => txn.isCompleted).toList();
  List<PaymentTransactionModel> get pendingPayments =>
      _transactions.where((txn) => txn.isInProgress).toList();
  List<PaymentTransactionModel> get failedPayments =>
      _transactions.where((txn) => txn.canRetry).toList();
  double get totalAmountPaid => _transactions
      .where((txn) => txn.isCompleted)
      .fold(0.0, (sum, txn) => sum + txn.amount);

  /// Create a new payment
  Future<TransactionResult> createPayment({
    required String action,
    String? referenceId,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      PaymentLogger.logPaymentEvent(
        event: 'create_payment_started',
        transactionId: 'pending',
        data: {'action': action, 'reference_id': referenceId},
      );

      final result = await _paymentService.createPayment(
        action: action,
        referenceId: referenceId,
        metadata: metadata,
      );

      if (result.success && result.transaction != null) {
        _currentTransaction = result.transaction;
        _transactions.insert(0, result.transaction!);

        PaymentLogger.logPaymentSuccess(
          transactionId: result.transaction!.id.toString(),
          action: action,
          amount: result.transaction!.amount,
        );
      } else {
        _setError(result.message);
        PaymentLogger.logPaymentError(
          error: 'Create payment failed',
          transactionId: 'pending',
          context: {'message': result.message},
        );
      }

      notifyListeners();
      return result;
    } catch (e) {
      final error = 'Failed to create payment: ${e.toString()}';
      _setError(error);
      PaymentLogger.logPaymentError(
        error: 'Create payment failed',
        transactionId: 'pending',
        exception: e,
      );

      notifyListeners();
      return TransactionResult.failure(message: error);
    } finally {
      _setLoading(false);
    }
  }

  /// Retry a failed payment
  Future<TransactionResult> retryPayment(String transactionId) async {
    try {
      _setLoading(true);
      _clearError();

      PaymentLogger.logPaymentRetry(
        transactionId: transactionId,
        attemptNumber: 1,
        reason: 'user_requested',
      );

      final result = await _paymentService.retryPayment(transactionId);

      if (result.success && result.transaction != null) {
        // Update transaction in list
        final index = _transactions.indexWhere(
          (txn) => txn.id.toString() == transactionId,
        );
        if (index != -1) {
          _transactions[index] = result.transaction!;
        }

        PaymentLogger.logPaymentSuccess(
          transactionId: transactionId,
          action: result.transaction!.transactionType,
          amount: result.transaction!.amount,
        );
      } else {
        _setError(result.message);
        PaymentLogger.logPaymentError(
          error: 'Retry payment failed',
          transactionId: transactionId,
          context: {'message': result.message},
        );
      }

      notifyListeners();
      return result;
    } catch (e) {
      final error = 'Failed to retry payment: ${e.toString()}';
      _setError(error);
      PaymentLogger.logPaymentError(
        error: 'Retry payment failed',
        transactionId: transactionId,
        exception: e,
      );

      notifyListeners();
      return TransactionResult.failure(message: error);
    } finally {
      _setLoading(false);
    }
  }

  /// Refresh payment data
  Future<void> refresh() async {
    await Future.wait([loadPaymentActions(), loadPaymentHistory()]);
  }

  /// Clear current transaction
  void clearCurrentTransaction() {
    _currentTransaction = null;
    notifyListeners();
  }

  /// Clear error message
  void clearError() {
    _clearError();
    notifyListeners();
  }

  // Private helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
  }

  void _setError(String error) {
    _errorMessage = error;
  }

  void _clearError() {
    _errorMessage = null;
  }

  /// Load available payment plans
  Future<void> loadAvailablePlans() async {
    try {
      _setLoading(true);
      _clearError();

      final result = await _paymentService.getAvailablePlans();

      if (result.success && result.plans != null) {
        _availablePlans = result.plans!;
      } else {
        _setError(result.message);
      }

      notifyListeners();
    } catch (e) {
      _setError('Failed to load payment plans: ${e.toString()}');
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  /// Load current plan and subscription
  Future<void> loadCurrentPlan() async {
    try {
      _setLoading(true);
      _clearError();

      final result = await _paymentService.getCurrentPlan();

      if (result.success) {
        _currentPlan = result.plan;
        _currentSubscription = result.subscription;
      } else {
        _setError(result.message);
      }

      notifyListeners();
    } catch (e) {
      _setError('Failed to load current plan: ${e.toString()}');
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  /// Cancel current subscription
  Future<PaymentResult> cancelSubscription() async {
    try {
      _setLoading(true);
      _clearError();

      final result = await _paymentService.cancelSubscription();

      if (result.success) {
        _currentSubscription = result.subscription;
      } else {
        _setError(result.message);
      }

      notifyListeners();
      return result;
    } catch (e) {
      final error = 'Failed to cancel subscription: ${e.toString()}';
      _setError(error);
      notifyListeners();
      return PaymentResult.failure(message: error);
    } finally {
      _setLoading(false);
    }
  }
}
