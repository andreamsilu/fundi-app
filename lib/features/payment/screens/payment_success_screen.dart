import 'package:flutter/material.dart';
import '../../../core/config/payment_config.dart';
import '../../../core/theme/app_theme.dart';
import '../models/payment_transaction_model.dart';
import '../widgets/payment_transaction_details.dart';
import 'payment_management_screen.dart';

/// Screen displayed after successful payment
/// Shows transaction details and next steps
class PaymentSuccessScreen extends StatelessWidget {
  final PaymentTransactionModel transaction;
  final PaymentAction actionData;

  const PaymentSuccessScreen({
    super.key,
    required this.transaction,
    required this.actionData,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Successful'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildSuccessHeader(),
            const SizedBox(height: 24),
            _buildTransactionDetails(),
            const SizedBox(height: 24),
            _buildNextSteps(),
            const SizedBox(height: 32),
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green, Colors.green.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Icon(Icons.check_circle, size: 64, color: Colors.white),
          const SizedBox(height: 16),
          const Text(
            'Payment Successful!',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            actionData.description,
            style: const TextStyle(fontSize: 16, color: Colors.white70),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Text(
              transaction.formattedAmount,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionDetails() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Transaction Details',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            PaymentTransactionDetails(transaction: transaction),
          ],
        ),
      ),
    );
  }

  Widget _buildNextSteps() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'What\'s Next?',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildNextStepItem(
              icon: Icons.receipt,
              title: 'Receipt Sent',
              description: 'A receipt has been sent to your email',
            ),
            const SizedBox(height: 12),
            _buildNextStepItem(
              icon: Icons.notifications,
              title: 'Confirmation',
              description: 'You will receive a confirmation notification',
            ),
            const SizedBox(height: 12),
            _buildNextStepItem(
              icon: _getNextStepIcon(),
              title: _getNextStepTitle(),
              description: _getNextStepDescription(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNextStepItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppTheme.primaryGreen.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(icon, color: AppTheme.primaryGreen, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                description,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        // Primary Action - Smart Navigation
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => _handleSmartNavigation(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryGreen,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: Text(
              _getActionButtonText(),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => _showTransactionDetails(context),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('View Transaction Details'),
          ),
        ),
      ],
    );
  }

  void _showTransactionDetails(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Transaction Details'),
        content: SingleChildScrollView(
          child: PaymentTransactionDetails(transaction: transaction),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  IconData _getNextStepIcon() {
    switch (actionData.category) {
      case 'job':
        return Icons.work;
      case 'profile':
        return Icons.person;
      case 'application':
        return Icons.assignment;
      case 'subscription':
        return Icons.subscriptions;
      default:
        return Icons.check;
    }
  }

  String _getNextStepTitle() {
    switch (actionData.category) {
      case 'job':
        return 'Job Posted';
      case 'profile':
        return 'Profile Updated';
      case 'application':
        return 'Application Submitted';
      case 'subscription':
        return 'Subscription Active';
      default:
        return 'Action Completed';
    }
  }

  String _getNextStepDescription() {
    switch (actionData.category) {
      case 'job':
        return 'Your job is now live and visible to fundis';
      case 'profile':
        return 'Your profile has been upgraded with premium features';
      case 'application':
        return 'Your application has been submitted for review';
      case 'subscription':
        return 'Your subscription is now active and ready to use';
      default:
        return 'Your action has been completed successfully';
    }
  }

  /// Smart navigation based on transaction type
  void _handleSmartNavigation(BuildContext context) {
    final transactionType = transaction.transactionType.toLowerCase();
    final metadata = transaction.metadata;

    // Subscription payment - go to subscription management
    if (transactionType.contains('subscription') ||
        metadata?['plan_id'] != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const PaymentManagementScreen(),
        ),
      );
    }
    // Job-related payment - go to My Jobs
    else if (transactionType.contains('job') ||
        transactionType.contains('post') ||
        metadata?['job_id'] != null) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/dashboard',
        (route) => false,
      );
    }
    // Payment history for other payments
    else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const PaymentManagementScreen(),
        ),
      );
    }
  }

  /// Get button text based on transaction type
  String _getActionButtonText() {
    final transactionType = transaction.transactionType.toLowerCase();

    if (transactionType.contains('subscription')) {
      return 'View My Subscription';
    } else if (transactionType.contains('job')) {
      return 'View My Jobs';
    } else {
      return 'View Payment History';
    }
  }
}
