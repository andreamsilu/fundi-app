import 'package:flutter/material.dart';
import '../../../core/config/payment_config.dart';
import '../../../core/theme/app_theme.dart';
import '../services/payment_service.dart';
import '../widgets/payment_action_card.dart';
import 'payment_processing_screen.dart';

/// Screen for selecting payment actions
/// Shows available payment options based on user needs
class PaymentActionScreen extends StatefulWidget {
  final String? category;
  final String? referenceId;
  final Map<String, dynamic>? metadata;

  const PaymentActionScreen({
    super.key,
    this.category,
    this.referenceId,
    this.metadata,
  });

  @override
  State<PaymentActionScreen> createState() => _PaymentActionScreenState();
}

class _PaymentActionScreenState extends State<PaymentActionScreen> {
  final PaymentService _paymentService = PaymentService();
  List<PaymentAction> _availableActions = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadPaymentActions();
  }

  Future<void> _loadPaymentActions() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Get actions based on category filter
      if (widget.category != null) {
        _availableActions = PaymentConfig.getActionsByCategory(widget.category!);
      } else {
        _availableActions = PaymentConfig.actions.values.toList();
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load payment options';
      });
    }
  }

  Future<void> _selectPaymentAction(PaymentAction action) async {
    try {
      // Find the action key
      final actionKey = PaymentConfig.actions.entries
          .firstWhere((entry) => entry.value == action)
          .key;

      // Navigate to payment processing screen
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PaymentProcessingScreen(
              action: actionKey,
              actionData: action,
              referenceId: widget.referenceId,
              metadata: widget.metadata,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.category != null 
              ? '${widget.category!.toUpperCase()} Payments'
              : 'Payment Options',
        ),
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadPaymentActions,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_availableActions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.payment,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              'No payment options available',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          _buildPaymentActions(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primaryGreen, AppTheme.primaryGreen.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Choose Payment Option',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Select the payment option that best fits your needs',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          if (widget.referenceId != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Reference: ${widget.referenceId}',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPaymentActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Available Options',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _availableActions.length,
          itemBuilder: (context, index) {
            final action = _availableActions[index];
            return PaymentActionCard(
              action: action,
              onTap: () => _selectPaymentAction(action),
            );
          },
        ),
      ],
    );
  }
}
