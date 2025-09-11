import 'package:flutter/material.dart';
import '../models/payment_model.dart';
import '../services/payment_service.dart';
import '../../../core/utils/logger.dart';

/// Payment provider for state management
class PaymentProvider extends ChangeNotifier {
  final PaymentService _paymentService = PaymentService();

  List<PaymentModel> _payments = [];
  PaymentRequirementsModel? _paymentRequirements;
  bool _isLoading = false;
  String? _errorMessage;

  /// Get payments list
  List<PaymentModel> get payments => _payments;

  /// Get payment requirements
  PaymentRequirementsModel? get paymentRequirements => _paymentRequirements;

  /// Check if loading
  bool get isLoading => _isLoading;

  /// Get error message
  String? get errorMessage => _errorMessage;

  /// Check if payments are enabled
  bool get paymentsEnabled => _paymentRequirements?.paymentsEnabled ?? false;

  /// Check if platform is in free mode
  bool get isFreeMode => _paymentRequirements?.isFreeMode ?? true;

  /// Check if user has active subscription
  bool get hasActiveSubscription => _paymentRequirements?.hasActiveSubscription ?? false;

  /// Initialize payment provider
  Future<void> initialize() async {
    _setLoading(true);
    try {
      await loadPaymentRequirements();
      await loadPayments();
      Logger.info('Payment provider initialized');
    } catch (e) {
      Logger.error('Payment provider initialization error', error: e);
      _setError('Failed to initialize payment system');
    } finally {
      _setLoading(false);
    }
  }

  /// Load user payments
  Future<void> loadPayments({int page = 1, int limit = 15}) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _paymentService.getUserPayments(
        page: page,
        limit: limit,
      );

      if (response.success && response.data != null) {
        if (page == 1) {
          _payments = response.data!;
        } else {
          _payments.addAll(response.data!);
        }
        notifyListeners();
        Logger.info('Payments loaded successfully');
      } else {
        _setError(response.message);
      }
    } catch (e) {
      Logger.error('Load payments error', error: e);
      _setError('An error occurred while loading payments');
    } finally {
      _setLoading(false);
    }
  }

  /// Load payment requirements
  Future<void> loadPaymentRequirements() async {
    try {
      final response = await _paymentService.getPaymentRequirements();

      if (response.success && response.data != null) {
        _paymentRequirements = response.data!;
        notifyListeners();
        Logger.info('Payment requirements loaded successfully');
      } else {
        Logger.warning('Failed to load payment requirements: ${response.message}');
      }
    } catch (e) {
      Logger.error('Load payment requirements error', error: e);
    }
  }

  /// Check if payment is required for specific action
  Future<PaymentValidationModel?> checkPaymentRequired({
    required String action,
    String? jobId,
  }) async {
    try {
      final response = await _paymentService.checkPaymentRequired(
        action: action,
        jobId: jobId,
      );

      if (response.success && response.data != null) {
        return response.data!;
      } else {
        _setError(response.message);
        return null;
      }
    } catch (e) {
      Logger.error('Check payment required error', error: e);
      _setError('An error occurred while checking payment requirements');
      return null;
    }
  }

  /// Process payment
  Future<Map<String, dynamic>?> processPayment({
    required double amount,
    required String paymentType,
    required String phoneNumber,
    required String email,
    String? description,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _paymentService.processPesapalPayment(
        amount: amount,
        paymentType: paymentType,
        phoneNumber: phoneNumber,
        email: email,
        description: description,
      );

      if (response.success && response.data != null) {
        // Reload payments to include the new payment
        await loadPayments();
        Logger.info('Payment processed successfully');
        return response.data!;
      } else {
        _setError(response.message);
        return null;
      }
    } catch (e) {
      Logger.error('Process payment error', error: e);
      _setError('An error occurred while processing payment');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  /// Verify payment status
  Future<PaymentModel?> verifyPaymentStatus({
    required String pesapalReference,
  }) async {
    try {
      final response = await _paymentService.verifyPaymentStatus(
        pesapalReference: pesapalReference,
      );

      if (response.success && response.data != null) {
        // Update the payment in the list
        final index = _payments.indexWhere((p) => p.pesapalReference == pesapalReference);
        if (index != -1) {
          _payments[index] = response.data!;
          notifyListeners();
        }
        Logger.info('Payment status verified successfully');
        return response.data!;
      } else {
        _setError(response.message);
        return null;
      }
    } catch (e) {
      Logger.error('Verify payment status error', error: e);
      _setError('An error occurred while verifying payment');
      return null;
    }
  }

  /// Get payment by ID
  PaymentModel? getPaymentById(String id) {
    try {
      return _payments.firstWhere((payment) => payment.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get payments by type
  List<PaymentModel> getPaymentsByType(String paymentType) {
    return _payments.where((payment) => payment.paymentType == paymentType).toList();
  }

  /// Get completed payments
  List<PaymentModel> get completedPayments {
    return _payments.where((payment) => payment.isCompleted).toList();
  }

  /// Get pending payments
  List<PaymentModel> get pendingPayments {
    return _payments.where((payment) => payment.isPending).toList();
  }

  /// Get failed payments
  List<PaymentModel> get failedPayments {
    return _payments.where((payment) => payment.isFailed).toList();
  }

  /// Get total amount paid
  double get totalAmountPaid {
    return completedPayments.fold(0.0, (sum, payment) => sum + payment.amount);
  }

  /// Refresh payments
  Future<void> refreshPayments() async {
    await loadPayments();
  }

  /// Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// Set error message
  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  /// Clear error message
  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Clear error manually
  void clearError() {
    _clearError();
  }
}
