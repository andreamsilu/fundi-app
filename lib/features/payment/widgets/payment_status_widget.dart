import 'package:flutter/material.dart';
import '../models/payment_transaction_model.dart';
import '../../../core/config/payment_config.dart';
import '../../../core/utils/payment_logger.dart';
import '../screens/payment_receipt_screen.dart';

/// Widget for displaying payment status and transaction details
class PaymentStatusWidget extends StatelessWidget {
  final PaymentTransactionModel? transaction;
  final bool isLoading;
  final String? error;
  final VoidCallback? onRetry;
  final VoidCallback? onViewDetails;

  const PaymentStatusWidget({
    Key? key,
    this.transaction,
    this.isLoading = false,
    this.error,
    this.onRetry,
    this.onViewDetails,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return _buildLoadingState();
    }

    if (error != null) {
      return _buildErrorState(context);
    }

    if (transaction == null) {
      return _buildEmptyState(context);
    }

    return _buildTransactionState(context);
  }

  Widget _buildLoadingState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: const Column(
        children: [
          SizedBox(
            height: 24,
            width: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          SizedBox(height: 12),
          Text(
            'Processing payment...',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.error, color: Colors.red),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Payment Failed',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.red,
                  ),
                ),
              ),
              if (onRetry != null)
                TextButton(
                  onPressed: () {
                    PaymentLogger.logPaymentEvent(
                      event: 'payment_retry',
                      transactionId: 'ui_action',
                      data: {'screen': 'payment_status_widget'},
                    );
                    onRetry!();
                  },
                  child: const Text('Retry'),
                ),
            ],
          ),
          if (error != null) ...[
            const SizedBox(height: 8),
            Text(error!, style: const TextStyle(color: Colors.red)),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: const Column(
        children: [
          Icon(Icons.payment, size: 48, color: Colors.grey),
          SizedBox(height: 12),
          Text(
            'No payment information available',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionState(BuildContext context) {
    final statusColor = _getStatusColor(transaction!.paymentStatus);
    final statusIcon = _getStatusIcon(transaction!.paymentStatus);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: statusColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status header
          Row(
            children: [
              Icon(statusIcon, color: statusColor, size: 24),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  transaction!.statusDisplay,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ),
              if (onViewDetails != null)
                IconButton(
                  onPressed: () {
                    PaymentLogger.logPaymentEvent(
                      event: 'view_payment_details',
                      transactionId: 'ui_action',
                      data: {
                        'screen': 'payment_status_widget',
                        'transaction_id': transaction!.id,
                      },
                    );
                    onViewDetails!();
                  },
                  icon: const Icon(Icons.info_outline),
                ),
            ],
          ),

          const SizedBox(height: 12),

          // Transaction details
          _buildDetailRow('Transaction ID', transaction!.id.toString()),
          _buildDetailRow('Amount', transaction!.formattedAmount),
          _buildDetailRow('Action', transaction!.typeDisplay),

          if (transaction!.referenceId != null)
            _buildDetailRow('Reference ID', transaction!.referenceId!),

          if (transaction!.gatewayReference != null)
            _buildDetailRow(
              'Gateway Reference',
              transaction!.gatewayReference!,
            ),

          if (transaction!.pesapalTrackingId != null)
            _buildDetailRow(
              'Pesapal Tracking ID',
              transaction!.pesapalTrackingId!,
            ),

          _buildDetailRow('Created', _formatDateTime(transaction!.createdAt)),

          if (transaction!.paidAt != null)
            _buildDetailRow('Paid At', _formatDateTime(transaction!.paidAt!)),

          // Action buttons based on status
          const SizedBox(height: 16),
          _buildActionButtons(context),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    final buttons = <Widget>[];

    switch (transaction!.status) {
      case 'pending':
        buttons.add(
          ElevatedButton.icon(
            onPressed: () {
              PaymentLogger.logPaymentEvent(
                event: 'check_payment_status',
                transactionId: 'ui_action',
                data: {
                  'screen': 'payment_status_widget',
                  'transaction_id': transaction!.id,
                },
              );
              _checkPaymentStatus(context);
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Check Status'),
          ),
        );
        break;

      case 'completed':
        buttons.add(
          ElevatedButton.icon(
            onPressed: () {
              PaymentLogger.logPaymentEvent(
                event: 'view_receipt',
                transactionId: 'ui_action',
                data: {
                  'screen': 'payment_status_widget',
                  'transaction_id': transaction!.id,
                },
              );
              // Navigate to receipt screen
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) =>
                      PaymentReceiptScreen(transactionId: transaction!.id),
                ),
              );
            },
            icon: const Icon(Icons.receipt),
            label: const Text('View Receipt'),
          ),
        );
        break;

      case 'failed':
        buttons.addAll([
          ElevatedButton.icon(
            onPressed: () {
              PaymentLogger.logPaymentEvent(
                event: 'retry_payment',
                transactionId: 'ui_action',
                data: {
                  'screen': 'payment_status_widget',
                  'transaction_id': transaction!.id,
                },
              );
              _retryPayment(context);
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
          const SizedBox(width: 8),
          OutlinedButton.icon(
            onPressed: () {
              PaymentLogger.logPaymentEvent(
                event: 'contact_support',
                transactionId: 'ui_action',
                data: {
                  'screen': 'payment_status_widget',
                  'transaction_id': transaction!.id,
                },
              );
              _contactSupport(context);
            },
            icon: const Icon(Icons.support_agent),
            label: const Text('Contact Support'),
          ),
        ]);
        break;

      case 'cancelled':
        buttons.add(
          ElevatedButton.icon(
            onPressed: () {
              PaymentLogger.logPaymentEvent(
                event: 'start_new_payment',
                transactionId: 'ui_action',
                data: {
                  'screen': 'payment_status_widget',
                  'previous_transaction_id': transaction!.id,
                },
              );
              _startNewPayment(context);
            },
            icon: const Icon(Icons.payment),
            label: const Text('Start New Payment'),
          ),
        );
        break;
    }

    if (buttons.isEmpty) return const SizedBox.shrink();

    return Wrap(spacing: 8, runSpacing: 8, children: buttons);
  }

  Color _getStatusColor(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.pending:
        return Colors.orange;
      case PaymentStatus.completed:
        return Colors.green;
      case PaymentStatus.failed:
        return Colors.red;
      case PaymentStatus.cancelled:
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.pending:
        return Icons.hourglass_empty;
      case PaymentStatus.completed:
        return Icons.check_circle;
      case PaymentStatus.failed:
        return Icons.error;
      case PaymentStatus.cancelled:
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  void _retryPayment(BuildContext context) {
    // Navigate to payment checkout to retry the payment
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Retry Payment'),
        content: const Text('Would you like to retry this payment?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Navigate to payment flow screen with the same payment details
              Navigator.of(context).pushNamed(
                '/payment-checkout',
                arguments: {
                  'amount': transaction?.amount ?? 0,
                  'payment_type': transaction?.paymentType ?? 'subscription',
                  'reference_id': transaction?.referenceId,
                },
              );
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  void _checkPaymentStatus(BuildContext context) async {
    if (transaction?.id == null) return;

    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      // Check status via ZenoPay service
      final zenoPayService = ZenoPayService();
      final orderId =
          transaction!.metadata?['order_id'] ??
          transaction!.paymentReference ??
          transaction!.id.toString();

      final result = await zenoPayService.checkPaymentStatus(orderId);

      // Close loading indicator
      if (context.mounted) {
        Navigator.pop(context);
      }

      if (context.mounted) {
        if (result.isCompleted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Payment completed successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        } else if (result.isPending) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Payment is still pending. Please wait...'),
              backgroundColor: Colors.orange,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Payment status: ${result.paymentStatus}'),
              backgroundColor: Colors.blue,
            ),
          );
        }
      }
    } catch (e) {
      // Close loading indicator if still showing
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error checking status: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _contactSupport(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Contact Support'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Need help with your payment?'),
            const SizedBox(height: 16),
            const Text('Email: support@fundiapp.com'),
            const SizedBox(height: 8),
            const Text('Phone: +255 XXX XXX XXX'),
            const SizedBox(height: 16),
            if (transaction != null)
              Text(
                'Reference: ${transaction!.paymentReference ?? transaction!.id}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
          ],
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

  void _startNewPayment(BuildContext context) {
    // Navigate to payment plans screen
    Navigator.of(context).pushNamed('/payment-plans');
  }
}
