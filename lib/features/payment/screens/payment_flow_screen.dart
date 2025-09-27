import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/config/payment_config.dart';
import '../../../core/utils/payment_logger.dart';
import '../widgets/payment_action_selector.dart';
import '../widgets/payment_form.dart';
import '../widgets/payment_status_widget.dart';
import '../providers/payment_provider.dart';

/// Comprehensive payment flow screen
class PaymentFlowScreen extends StatefulWidget {
  final String? preselectedAction;
  final String? referenceId;
  final Map<String, dynamic>? metadata;

  const PaymentFlowScreen({
    Key? key,
    this.preselectedAction,
    this.referenceId,
    this.metadata,
  }) : super(key: key);

  @override
  State<PaymentFlowScreen> createState() => _PaymentFlowScreenState();
}

class _PaymentFlowScreenState extends State<PaymentFlowScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  List<String> _selectedActions = [];
  String? _errorMessage;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    // Pre-select action if provided
    if (widget.preselectedAction != null &&
        PaymentConfig.getAction(widget.preselectedAction!) != null) {
      _selectedActions = [widget.preselectedAction!];
    }

    PaymentLogger.logPaymentEvent(
      event: 'payment_flow_screen_opened',
      transactionId: 'ui_action',
      data: {
        'screen': 'payment_flow_screen',
        'preselected_action': widget.preselectedAction,
        'reference_id': widget.referenceId,
      },
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  /// Handle payment processing with error handling
  Future<void> _processPayment() async {
    if (_selectedActions.isEmpty) {
      _showError('Please select at least one payment action');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final paymentProvider = Provider.of<PaymentProvider>(
        context,
        listen: false,
      );

      for (String actionId in _selectedActions) {
        final result = await paymentProvider.processPayment(
          paymentType: actionId,
          amount: 0.0, // Default amount, should be provided by user in form
          phoneNumber: '',
          email: '',
          description: 'Payment for ${actionId}',
        );

        if (result != null && result['success'] != true) {
          _showError(result['message'] ?? 'Payment processing failed');
          return;
        }
      }

      // Navigate to success screen
      _navigateToSuccess();
    } catch (e) {
      _showError('An unexpected error occurred. Please try again.');
      PaymentLogger.logPaymentError(
        error: 'Payment processing error',
        transactionId: widget.referenceId ?? 'unknown',
        exception: e,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Show error message
  void _showError(String message) {
    setState(() {
      _errorMessage = message;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  /// Navigate to success screen
  void _navigateToSuccess() {
    Navigator.pushReplacementNamed(
      context,
      '/payment-success',
      arguments: {
        'actions': _selectedActions,
        'referenceId': widget.referenceId,
      },
    );
  }

  void _nextStep() {
    if (_currentStep < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() {
        _currentStep++;
      });
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() {
        _currentStep--;
      });
    }
  }

  void _onActionsChanged(List<String> actions) {
    setState(() {
      _selectedActions = actions;
    });

    PaymentLogger.logPaymentEvent(
      event: 'payment_actions_selected',
      transactionId: 'ui_action',
      data: {
        'screen': 'payment_flow_screen',
        'selected_actions': actions,
        'action_count': actions.length,
      },
    );
  }

  void _onPaymentSubmit(
    String action,
    double amount,
    String? description,
    String? referenceId,
    String? phoneNumber,
    String? email,
    Map<String, dynamic>? metadata,
  ) {
    final provider = context.read<PaymentProvider>();

    // Merge metadata

    PaymentLogger.logPaymentEvent(
      event: 'payment_submit_from_flow',
      transactionId: 'ui_action',
      data: {
        'screen': 'payment_flow_screen',
        'primary_action': action,
        'amount': amount.toString(),
        'reference_id': referenceId,
      },
    );

    provider
        .processPayment(
          paymentType: action,
          amount: amount,
          phoneNumber: phoneNumber ?? '',
          email: email ?? '',
          description: description,
        )
        .then((_) {
          _nextStep(); // Move to status screen
        });
  }

  void _retryPayment() {
    setState(() {
      _currentStep = 1; // Go back to form
    });
    _pageController.animateToPage(
      1,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            PaymentLogger.logPaymentEvent(
              event: 'payment_flow_cancelled',
              transactionId: 'ui_action',
              data: {'screen': 'payment_flow_screen'},
            );
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Column(
        children: [
          // Error banner
          if (_errorMessage != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              color: Colors.red[50],
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.red[600], size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(color: Colors.red[600]),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _errorMessage = null;
                      });
                    },
                    icon: Icon(Icons.close, color: Colors.red[600], size: 20),
                  ),
                ],
              ),
            ),

          // Progress indicator
          _buildProgressIndicator(),

          // Page content
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentStep = index;
                });
              },
              children: [
                // Step 1: Action Selection
                _buildActionSelectionStep(),

                // Step 2: Payment Form
                _buildPaymentFormStep(),

                // Step 3: Payment Status
                _buildPaymentStatusStep(),
              ],
            ),
          ),

          // Navigation buttons
          _buildNavigationButtons(),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          _buildProgressStep(0, 'Select Actions', Icons.list_alt),
          _buildProgressLine(),
          _buildProgressStep(1, 'Payment Details', Icons.payment),
          _buildProgressLine(),
          _buildProgressStep(2, 'Status', Icons.check_circle),
        ],
      ),
    );
  }

  Widget _buildProgressStep(int step, String title, IconData icon) {
    final isActive = _currentStep == step;
    final isCompleted = _currentStep > step;

    return Expanded(
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isActive || isCompleted
                  ? Theme.of(context).primaryColor
                  : Colors.grey[300],
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              color: isActive || isCompleted
                  ? Theme.of(context).primaryColor
                  : Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildProgressLine() {
    return Container(
      height: 2,
      width: 20,
      color: _currentStep > 0
          ? Theme.of(context).primaryColor
          : Colors.grey[300],
    );
  }

  Widget _buildActionSelectionStep() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: PaymentActionSelector(
        selectedActions: _selectedActions,
        onSelectionChanged: _onActionsChanged,
        availableActions: PaymentConfig.actions.values.toList(),
      ),
    );
  }

  Widget _buildPaymentFormStep() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Consumer<PaymentProvider>(
        builder: (context, provider, child) {
          return PaymentForm(
            selectedActions: _selectedActions,
            onSubmit: (action, amount, description, referenceId, metadata) =>
                _onPaymentSubmit(
                  action,
                  amount,
                  description,
                  referenceId,
                  '',
                  '',
                  metadata,
                ),
            isLoading: provider.isLoading,
            error: provider.errorMessage,
          );
        },
      ),
    );
  }

  Widget _buildPaymentStatusStep() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Consumer<PaymentProvider>(
        builder: (context, provider, child) {
          return PaymentStatusWidget(
            transaction: provider.currentTransaction,
            isLoading: provider.isLoading,
            error: provider.errorMessage,
            onRetry: _retryPayment,
            onViewDetails: () {
              PaymentLogger.logPaymentEvent(
                event: 'view_transaction_details',
                transactionId: 'ui_action',
                data: {'screen': 'payment_flow_screen'},
              );
              // TODO: Navigate to transaction details
            },
          );
        },
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _previousStep,
                child: const Text('Previous'),
              ),
            ),

          if (_currentStep > 0) const SizedBox(width: 16),

          Expanded(
            child: ElevatedButton(
              onPressed: _isLoading
                  ? null
                  : (_currentStep == 0 && _selectedActions.isNotEmpty
                        ? _nextStep
                        : _currentStep == 2
                        ? _processPayment
                        : null),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      _currentStep == 0
                          ? 'Continue'
                          : _currentStep == 2
                          ? 'Process Payment'
                          : 'Done',
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
