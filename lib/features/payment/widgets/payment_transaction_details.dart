import 'package:flutter/material.dart';
import '../models/payment_transaction_model.dart';
import '../../../core/theme/app_theme.dart';

/// Widget for displaying detailed transaction information
class PaymentTransactionDetails extends StatelessWidget {
  final PaymentTransactionModel transaction;

  const PaymentTransactionDetails({
    super.key,
    required this.transaction,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDetailRow('Transaction ID', transaction.id.toString()),
        _buildDetailRow('Amount', transaction.formattedAmount),
        _buildDetailRow('Status', transaction.statusDisplay),
        _buildDetailRow('Type', transaction.typeDisplay),
        if (transaction.gateway != null)
          _buildDetailRow('Payment Method', transaction.gatewayDisplay),
        if (transaction.gatewayReference != null)
          _buildDetailRow('Gateway Reference', transaction.gatewayReference!),
        if (transaction.pesapalTrackingId != null)
          _buildDetailRow('Tracking ID', transaction.pesapalTrackingId!),
        if (transaction.description != null)
          _buildDetailRow('Description', transaction.description!),
        _buildDetailRow('Created', _formatDateTime(transaction.createdAt)),
        if (transaction.paidAt != null)
          _buildDetailRow('Paid At', _formatDateTime(transaction.paidAt!)),
        if (transaction.updatedAt != null)
          _buildDetailRow('Updated', _formatDateTime(transaction.updatedAt!)),
        if (transaction.referenceId != null)
          _buildDetailRow('Reference ID', transaction.referenceId!),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
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
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}

/// Compact transaction details for smaller spaces
class CompactTransactionDetails extends StatelessWidget {
  final PaymentTransactionModel transaction;

  const CompactTransactionDetails({
    super.key,
    required this.transaction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Transaction #${transaction.id}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: transaction.paymentStatus.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  transaction.statusDisplay,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: transaction.paymentStatus.color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                transaction.typeDisplay,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                transaction.formattedAmount,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryGreen,
                ),
              ),
            ],
          ),
          if (transaction.description != null) ...[
            const SizedBox(height: 4),
            Text(
              transaction.description!,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}

/// Transaction status indicator
class TransactionStatusIndicator extends StatelessWidget {
  final PaymentTransactionModel transaction;

  const TransactionStatusIndicator({
    super.key,
    required this.transaction,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: transaction.paymentStatus.color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          transaction.statusDisplay,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: transaction.paymentStatus.color,
          ),
        ),
      ],
    );
  }
}
