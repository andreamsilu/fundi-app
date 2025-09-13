import 'package:flutter/material.dart';
import '../../../core/config/payment_config.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/payment_logger.dart';
import '../services/payment_service.dart';
import '../widgets/payment_status_widget.dart';
import 'payment_success_screen.dart';
import 'payment_failure_screen.dart';

/// Screen for processing payments
/// Handles payment creation and gateway interaction
class PaymentProcessingScreen extends StatefulWidget {
  final String action;
  final PaymentAction actionData;
  final String? referenceId;
  final Map<String, dynamic>? metadata;

  const PaymentProcessingScreen({
    super.key,
    required this.action,
    required this.actionData,
    this.referenceId,
    this.metadata,
  });

  @override
  State<PaymentProcessingScreen> createState() => _PaymentProcessingScreenState();
}

class _PaymentProcessingScreenState extends State<PaymentProcessingScreen> {
  final PaymentService _paymentService = PaymentService();
  
  bool _isProcessing = false;
  String? _errorMessage;
  String? _transactionId;
  PaymentStatus _currentStatus = PaymentStatus.pending;

  @override
  void initState() {
    super.initState();
    _processPayment();
  }

  Future<void> _processPayment() async {
    setState(() {
      _isProcessing = true;
      _errorMessage = null;
    });

    try {
      PaymentLogger.logPaymentEvent(
        event: 'payment_processing_started',
        transactionId: 'pending',
        data: {
          'action': widget.action,
          'amount': widget.actionData.amount,
          'reference_id': widget.referenceId,
        },
      );

      // Create payment request
      final result = await _paymentService.createPayment(
        action: widget.action,
        referenceId: widget.referenceId,
        metadata: widget.metadata,
      );

      if (result.success && result.transaction != null) {
        setState(() {
          _transactionId = result.transaction!.id.toString();
          _currentStatus = result.transaction!.paymentStatus;
        });

        PaymentLogger.logPaymentSuccess(
          transactionId: _transactionId!,
          action: widget.action,
          amount: widget.actionData.amount,
        );

        // Navigate to success screen
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => PaymentSuccessScreen(
                transaction: result.transaction!,
                actionData: widget.actionData,
              ),
            ),
          );
        }
      } else {
        setState(() {
          _errorMessage = result.message;
          _isProcessing = false;
        });

        PaymentLogger.logPaymentError(
          error: 'Payment creation failed',
          transactionId: 'unknown',
          context: {'message': result.message},
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'An unexpected error occurred';
        _isProcessing = false;
      });

      PaymentLogger.logPaymentError(
        error: 'Payment processing error',
        transactionId: 'unknown',
        exception: e,
      );
    }
  }

  Future<void> _retryPayment() async {
    await _processPayment();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Processing Payment'),
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isProcessing) {
      return _buildProcessingView();
    }

    if (_errorMessage != null) {
      return _buildErrorView();
    }

    return _buildSuccessView();
  }

  Widget _buildProcessingView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Payment action info
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: widget.actionData.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: widget.actionData.color.withOpacity(0.3),
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    widget.actionData.icon,
                    size: 48,
                    color: widget.actionData.color,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.actionData.description,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    PaymentConfig.formatAmount(widget.actionData.amount),
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: widget.actionData.color,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 48),
            
            // Processing animation
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryGreen),
              strokeWidth: 3,
            ),
            
            const SizedBox(height: 24),
            
            const Text(
              'Processing your payment...',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            
            const SizedBox(height: 8),
            
            Text(
              'Please wait while we process your ${widget.actionData.description.toLowerCase()}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            
            if (widget.referenceId != null) ...[
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Reference: ${widget.referenceId}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            
            const SizedBox(height: 24),
            
            const Text(
              'Payment Failed',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            
            const SizedBox(height: 16),
            
            Text(
              _errorMessage ?? 'An unknown error occurred',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 32),
            
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Go Back'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _retryPayment,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryGreen,
                    ),
                    child: const Text('Retry'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.check_circle,
              size: 64,
              color: Colors.green,
            ),
            
            const SizedBox(height: 24),
            
            const Text(
              'Payment Successful!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            
            const SizedBox(height: 16),
            
            Text(
              'Your ${widget.actionData.description.toLowerCase()} has been processed successfully',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 32),
            
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryGreen,
                ),
                child: const Text('Continue'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
