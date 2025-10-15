import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/button_widget.dart';
import '../../../shared/widgets/input_widget.dart';
import '../models/payment_plan_model.dart';
import '../services/payment_service.dart';
import 'payment_receipt_screen.dart';

/// Simplified Payment Checkout Screen
/// Handles all payment flows in one unified screen
/// Replaces: payment_flow_screen, payment_form_screen, payment_processing_screen,
///           payment_success_screen, payment_failure_screen
class PaymentCheckoutScreen extends StatefulWidget {
  final PaymentPlanModel? plan;
  final String action; // 'subscription', 'deposit', 'withdrawal'
  final Map<String, dynamic>? metadata;

  const PaymentCheckoutScreen({
    super.key,
    this.plan,
    required this.action,
    this.metadata,
  });

  @override
  State<PaymentCheckoutScreen> createState() => _PaymentCheckoutScreenState();
}

class _PaymentCheckoutScreenState extends State<PaymentCheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _amountController = TextEditingController();

  String _paymentMethod = 'mobile_money';
  bool _isProcessing = false;
  String? _error;
  bool _paymentComplete = false;
  String? _transactionId;

  @override
  void initState() {
    super.initState();
    if (widget.plan != null) {
      _amountController.text = widget.plan!.price.toString();
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _processPayment() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isProcessing = true;
      _error = null;
    });

    try {
      print(
        'PaymentCheckoutScreen: Processing payment - action: ${widget.action}',
      );
      final paymentService = PaymentService();

      // Handle different payment actions
      if (widget.action == 'subscription' && widget.plan != null) {
        print('PaymentCheckoutScreen: Subscribing to plan ${widget.plan!.id}');
        // Subscribe to a plan
        final result = await paymentService.subscribe(planId: widget.plan!.id);

        print(
          'PaymentCheckoutScreen: Subscribe result - success: ${result.success}',
        );
        if (result.success && result.subscription != null) {
          print(
            'PaymentCheckoutScreen: Subscription successful - ID: ${result.subscription!.id}',
          );
          setState(() {
            _paymentComplete = true;
            _transactionId = result.subscription!.id.toString();
          });
        } else {
          print(
            'PaymentCheckoutScreen: Subscription failed - ${result.message}',
          );
          setState(() {
            _error = result.message;
          });
        }
      } else {
        // Pay-per-use payment
        final amount = double.parse(_amountController.text.trim());
        print(
          'PaymentCheckoutScreen: Pay-per-use payment - action: ${widget.action}, amount: $amount',
        );

        final result = await paymentService.processPayPerUse(
          action: widget.action,
          amount: amount,
          referenceId: widget.metadata?['reference_id'],
        );

        print(
          'PaymentCheckoutScreen: Pay-per-use result - success: ${result.success}',
        );
        if (result.success && result.transaction != null) {
          print(
            'PaymentCheckoutScreen: Payment successful - ID: ${result.transaction!.id}',
          );
          setState(() {
            _paymentComplete = true;
            _transactionId = result.transaction!.id.toString();
          });
        } else {
          print('PaymentCheckoutScreen: Payment failed - ${result.message}');
          setState(() {
            _error = result.message;
          });
        }
      }
    } catch (e) {
      print('PaymentCheckoutScreen: Payment error - $e');
      setState(() {
        _error = 'Payment failed: $e';
      });
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
      ),
      body: _paymentComplete ? _buildSuccessView() : _buildCheckoutForm(),
    );
  }

  Widget _buildCheckoutForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order Summary
            if (widget.plan != null) _buildOrderSummary(),

            const SizedBox(height: 24),

            // Payment Method
            Text(
              'Payment Method',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildPaymentMethodSelector(),

            const SizedBox(height: 24),

            // Phone Number
            AppInputField(
              label: 'Phone Number',
              hint: '0712345678',
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              prefixIcon: const Icon(Icons.phone),
              isRequired: true,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your phone number';
                }
                if (value.length < 10) {
                  return 'Please enter a valid phone number';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Amount (only if not subscription)
            if (widget.plan == null) ...[
              AppInputField(
                label: 'Amount (TZS)',
                hint: '10000',
                controller: _amountController,
                keyboardType: TextInputType.number,
                prefixIcon: const Icon(Icons.attach_money),
                isRequired: true,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter amount';
                  }
                  final amount = double.tryParse(value);
                  if (amount == null || amount <= 0) {
                    return 'Enter a valid amount';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
            ],

            // Error Message
            if (_error != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _error!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Pay Button
            SizedBox(
              width: double.infinity,
              child: AppButton(
                text: _isProcessing
                    ? 'Processing...'
                    : 'Pay ${_amountController.text} TZS',
                onPressed: _isProcessing ? null : _processPayment,
                isLoading: _isProcessing,
                size: ButtonSize.large,
                icon: Icons.payment,
              ),
            ),

            const SizedBox(height: 16),

            // Security Note
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.security, color: Colors.blue[700], size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Your payment is secure and encrypted',
                      style: TextStyle(color: Colors.blue[700], fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                size: 80,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Payment Successful!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              'Transaction ID: ${_transactionId ?? 'N/A'}',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: AppButton(
                text: 'Done',
                onPressed: () {
                  Navigator.pop(context);
                  if (widget.action == 'subscription') {
                    Navigator.pop(context); // Go back to main screen
                  }
                },
                icon: Icons.check,
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: _transactionId != null
                  ? () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => PaymentReceiptScreen(
                            transactionId: int.parse(_transactionId!),
                          ),
                        ),
                      );
                    }
                  : null,
              child: const Text('View Receipt'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryGreen.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primaryGreen.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Order Summary',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const Divider(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Plan'),
              Text(
                widget.plan!.name,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Billing Cycle'),
              Text(
                widget.plan!.billingCycle ?? 'One-time',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const Divider(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                '${widget.plan!.price} TZS',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryGreen,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodSelector() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.lightGray),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          RadioListTile<String>(
            title: Row(
              children: [
                Icon(Icons.phone_android, color: AppTheme.primaryGreen),
                const SizedBox(width: 12),
                const Expanded(child: Text('Mobile Money (M-Pesa, Tigo Pesa)')),
              ],
            ),
            value: 'mobile_money',
            groupValue: _paymentMethod,
            onChanged: (value) {
              setState(() => _paymentMethod = value!);
            },
          ),
          const Divider(height: 1),
          RadioListTile<String>(
            title: Row(
              children: [
                Icon(Icons.credit_card, color: AppTheme.primaryGreen),
                const SizedBox(width: 12),
                const Expanded(child: Text('Credit/Debit Card')),
              ],
            ),
            value: 'card',
            groupValue: _paymentMethod,
            onChanged: (value) {
              setState(() => _paymentMethod = value!);
            },
          ),
        ],
      ),
    );
  }
}
