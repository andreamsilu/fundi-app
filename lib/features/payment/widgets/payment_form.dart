import 'package:flutter/material.dart';
import '../../../core/config/payment_config.dart';
import '../../../core/utils/payment_logger.dart';

/// Payment form widget with dynamic configuration
class PaymentForm extends StatefulWidget {
  final List<String> selectedActions;
  final Function(
    String action,
    double amount,
    String? description,
    String? referenceId,
    Map<String, dynamic>? metadata,
  )
  onSubmit;
  final bool isLoading;
  final String? error;

  const PaymentForm({
    Key? key,
    required this.selectedActions,
    required this.onSubmit,
    this.isLoading = false,
    this.error,
  }) : super(key: key);

  @override
  State<PaymentForm> createState() => _PaymentFormState();
}

class _PaymentFormState extends State<PaymentForm> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _referenceIdController = TextEditingController();

  double _totalAmount = 0.0;
  String _primaryAction = '';

  @override
  void initState() {
    super.initState();
    _calculateAmounts();
  }

  @override
  void didUpdateWidget(PaymentForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedActions != widget.selectedActions) {
      _calculateAmounts();
    }
  }

  Future<void> _calculateAmounts() async {
    _totalAmount = 0.0;
    for (final actionId in widget.selectedActions) {
      try {
        final action = await PaymentConfig.getAction(actionId);
        _totalAmount += action.amount;
      } catch (e) {
        // Skip invalid actions
      }
    }
    if (mounted) {
      setState(() {
        _primaryAction = widget.selectedActions.isNotEmpty
            ? widget.selectedActions.first
            : '';
      });
    }
  }

  void _submitPayment() {
    if (!_formKey.currentState!.validate()) {
      PaymentLogger.logPaymentEvent(
        event: 'payment_form_validation_failed',
        transactionId: 'ui_action',
        data: {'screen': 'payment_form'},
      );
      return;
    }

    if (widget.selectedActions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one payment action'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final metadata = {
      'selected_actions': widget.selectedActions,
      'action_count': widget.selectedActions.length,
      'form_submitted_at': DateTime.now().toIso8601String(),
    };

    PaymentLogger.logPaymentEvent(
      event: 'payment_form_submit',
      transactionId: 'ui_action',
      data: {
        'screen': 'payment_form',
        'primary_action': _primaryAction,
        'total_amount': _totalAmount,
        'action_count': widget.selectedActions.length,
      },
    );

    widget.onSubmit(
      _primaryAction,
      _totalAmount,
      _descriptionController.text.trim().isNotEmpty
          ? _descriptionController.text.trim()
          : null,
      _referenceIdController.text.trim().isNotEmpty
          ? _referenceIdController.text.trim()
          : null,
      metadata,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Selected actions summary
          if (widget.selectedActions.isNotEmpty) ...[
            _buildActionsSummary(),
            const SizedBox(height: 24),
          ],

          // Description field
          TextFormField(
            controller: _descriptionController,
            decoration: const InputDecoration(
              labelText: 'Description (Optional)',
              hintText: 'Add a description for this payment',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.description),
            ),
            maxLines: 3,
            validator: (value) {
              if (value != null && value.length > 500) {
                return 'Description must be less than 500 characters';
              }
              return null;
            },
          ),

          const SizedBox(height: 16),

          // Reference ID field
          TextFormField(
            controller: _referenceIdController,
            decoration: const InputDecoration(
              labelText: 'Reference ID (Optional)',
              hintText: 'Add a reference ID for tracking',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.tag),
            ),
            validator: (value) {
              if (value != null && value.length > 100) {
                return 'Reference ID must be less than 100 characters';
              }
              return null;
            },
          ),

          const SizedBox(height: 24),

          // Error display
          if (widget.error != null) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error, color: Colors.red),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.error!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Submit button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: widget.isLoading ? null : _submitPayment,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: widget.isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.payment),
                        const SizedBox(width: 8),
                        Text(
                          'Pay TZS ${_totalAmount.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionsSummary() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).primaryColor.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Selected Actions',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),

          // Display total amount only (individual action details shown during calculation)
          const Text(
            'Payment actions will be processed',
            style: TextStyle(fontSize: 14),
          ),

          const Divider(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Amount',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(
                'TZS ${_totalAmount.toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _referenceIdController.dispose();
    super.dispose();
  }
}
