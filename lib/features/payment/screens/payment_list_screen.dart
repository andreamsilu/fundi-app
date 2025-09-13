import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/payment_provider.dart';
import '../models/payment_transaction_model.dart';
import '../widgets/payment_transaction_details.dart';

/// Payment list screen showing user's payment history
class PaymentListScreen extends StatefulWidget {
  const PaymentListScreen({super.key});

  @override
  State<PaymentListScreen> createState() => _PaymentListScreenState();
}

class _PaymentListScreenState extends State<PaymentListScreen> {
  final ScrollController _scrollController = ScrollController();
  int _currentPage = 1;
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PaymentProvider>().loadPayments();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      _loadMorePayments();
    }
  }

  Future<void> _loadMorePayments() async {
    if (_isLoadingMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    _currentPage++;
    await context.read<PaymentProvider>().loadPayments(page: _currentPage);

    setState(() {
      _isLoadingMore = false;
    });
  }

  Future<void> _refreshPayments() async {
    _currentPage = 1;
    await context.read<PaymentProvider>().refreshPayments();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshPayments,
          ),
        ],
      ),
      body: Consumer<PaymentProvider>(
        builder: (context, paymentProvider, child) {
          if (paymentProvider.isLoading && paymentProvider.payments.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (paymentProvider.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    paymentProvider.errorMessage!,
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      paymentProvider.clearError();
                      _refreshPayments();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (paymentProvider.payments.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.payment_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No payments found',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your payment history will appear here',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _refreshPayments,
            child: Column(
              children: [
                // Payment summary
                _buildPaymentSummary(
                  totalAmount: paymentProvider.totalAmountPaid,
                  completedPayments: paymentProvider.completedPayments.length,
                  pendingPayments: paymentProvider.pendingPayments.length,
                  failedPayments: paymentProvider.failedPayments.length,
                ),
                
                // Payment list
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: paymentProvider.payments.length + (_isLoadingMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == paymentProvider.payments.length) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }

                      final payment = paymentProvider.payments[index];
                      return _buildPaymentCard(
                        payment: payment,
                        onTap: () => _showPaymentDetails(context, payment),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showPaymentDetails(BuildContext context, PaymentTransactionModel payment) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => PaymentDetailsSheet(payment: payment),
    );
  }

  Widget _buildPaymentSummary({
    required double totalAmount,
    required int completedPayments,
    required int pendingPayments,
    required int failedPayments,
  }) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Payment Summary',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildSummaryItem('Total Paid', _formatAmount(totalAmount), Colors.green),
              ),
              Expanded(
                child: _buildSummaryItem('Completed', completedPayments.toString(), Colors.green),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildSummaryItem('Pending', pendingPayments.toString(), Colors.orange),
              ),
              Expanded(
                child: _buildSummaryItem('Failed', failedPayments.toString(), Colors.red),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentCard({
    required PaymentTransactionModel payment,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: payment.paymentStatus.color.withOpacity(0.1),
          child: Icon(
            Icons.payment,
            color: payment.paymentStatus.color,
          ),
        ),
        title: Text(payment.typeDisplay),
        subtitle: Text(payment.description ?? 'No description'),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              payment.formattedAmount,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              payment.statusDisplay,
              style: TextStyle(
                fontSize: 12,
                color: payment.paymentStatus.color,
              ),
            ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }

  String _formatAmount(double amount) {
    if (amount >= 1000000) {
      return 'TZS ${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return 'TZS ${(amount / 1000).toStringAsFixed(1)}K';
    } else {
      return 'TZS ${amount.toStringAsFixed(0)}';
    }
  }
}

/// Payment details bottom sheet
class PaymentDetailsSheet extends StatelessWidget {
  final PaymentTransactionModel payment;

  const PaymentDetailsSheet({
    super.key,
    required this.payment,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          // Payment details
          Text(
            'Payment Details',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          
          _buildDetailRow('Amount', payment.formattedAmount),
          _buildDetailRow('Type', payment.typeDisplay),
          _buildDetailRow('Status', payment.statusDisplay),
          _buildDetailRow('Reference', payment.gatewayReference ?? 'N/A'),
          _buildDetailRow('Date', _formatDate(payment.createdAt)),
          
          const SizedBox(height: 24),
          
          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ),
              if (payment.isInProgress) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _verifyPayment(context),
                    child: const Text('Verify'),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} at ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _verifyPayment(BuildContext context) {
    // Implement payment verification
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Payment verification initiated'),
      ),
    );
  }
}
