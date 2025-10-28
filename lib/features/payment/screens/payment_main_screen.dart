import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../../shared/widgets/button_widget.dart';
import '../services/payment_service.dart';
import '../models/payment_plan_model.dart';
import '../models/payment_transaction_model.dart';
import '../models/user_subscription_model.dart';
import 'payment_checkout_screen.dart';
import 'payment_receipt_screen.dart';

/// Consolidated Payment Main Screen with Tabs
/// Combines Plans, History, and Settings in one place
/// Replaces: payment_plans_screen, payment_management_screen, payment_action_screen
class PaymentMainScreen extends StatefulWidget {
  final int initialTab;

  const PaymentMainScreen({super.key, this.initialTab = 0});

  @override
  State<PaymentMainScreen> createState() => _PaymentMainScreenState();
}

class _PaymentMainScreenState extends State<PaymentMainScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final PaymentService _paymentService = PaymentService();

  bool _isLoading = false;
  String? _error;
  List<PaymentPlanModel> _plans = [];
  UserSubscriptionModel? _currentPlan;
  List<PaymentTransactionModel> _transactions = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: widget.initialTab,
    );
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      print('PaymentMainScreen: Loading payment data...');

      final plansResult = await _paymentService.getAvailablePlans();
      print(
        'PaymentMainScreen: Plans result - success: ${plansResult.success}, count: ${plansResult.plans?.length ?? 0}',
      );

      final currentPlanResult = await _paymentService.getCurrentPlan();
      print(
        'PaymentMainScreen: Current plan result - success: ${currentPlanResult.success}, has subscription: ${currentPlanResult.subscription != null}',
      );

      final historyResult = await _paymentService.getPaymentHistory();
      print(
        'PaymentMainScreen: History result - success: ${historyResult.success}, count: ${historyResult.transactions?.length ?? 0}',
      );

      if (mounted) {
        setState(() {
          // Plans
          if (plansResult.success) {
            _plans = plansResult.plans ?? [];
            print('PaymentMainScreen: Loaded ${_plans.length} plans');
          } else {
            print('PaymentMainScreen: Plans failed - ${plansResult.message}');
          }

          // Current plan
          if (currentPlanResult.success) {
            _currentPlan = currentPlanResult.subscription;
            print('PaymentMainScreen: Current plan ID: ${_currentPlan?.id}');
          } else {
            print(
              'PaymentMainScreen: Current plan failed - ${currentPlanResult.message}',
            );
          }

          // History
          if (historyResult.success) {
            _transactions = historyResult.transactions ?? [];
            print(
              'PaymentMainScreen: Loaded ${_transactions.length} transactions',
            );
          } else {
            print(
              'PaymentMainScreen: History failed - ${historyResult.message}',
            );
          }

          _isLoading = false;
          print('PaymentMainScreen: Loading complete');
        });
      }
    } catch (e) {
      print('PaymentMainScreen: Error loading data - $e');
      if (mounted) {
        setState(() {
          _error = 'Failed to load payment data: $e';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _refreshData() async {
    await _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payments'),
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.card_membership), text: 'Plans'),
            Tab(icon: Icon(Icons.history), text: 'History'),
            Tab(icon: Icon(Icons.settings), text: 'Settings'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildPlansTab(), _buildHistoryTab(), _buildSettingsTab()],
      ),
    );
  }

  /// Tab 1: Payment Plans
  Widget _buildPlansTab() {
    if (_isLoading) {
      return const Center(child: LoadingWidget());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(_error!, textAlign: TextAlign.center),
            const SizedBox(height: 24),
            AppButton(
              text: 'Retry',
              onPressed: _refreshData,
              type: ButtonType.secondary,
            ),
          ],
        ),
      );
    }

    final plans = _plans;
    final currentPlan = _currentPlan;

    // Show empty state if no plans
    if (plans.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.payment, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            const Text('No payment plans available'),
            const SizedBox(height: 8),
            Text(
              'Please check back later',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            AppButton(
              text: 'Retry',
              onPressed: _refreshData,
              type: ButtonType.secondary,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshData,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Current Plan Badge (converted to PaymentPlanModel)
            if (currentPlan != null)
              _buildCurrentSubscriptionBadge(currentPlan),

            const SizedBox(height: 16),

            // Plans Grid
            ...plans.map((plan) {
              final isActive = currentPlan?.id == plan.id;
              return _buildPlanCard(plan, isActive);
            }).toList(),
          ],
        ),
      ),
    );
  }

  /// Tab 2: Payment History
  Widget _buildHistoryTab() {
    if (_isLoading) {
      return const Center(child: LoadingWidget());
    }

    final history = _transactions;

    if (history.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            const Text('No payment history'),
            const SizedBox(height: 8),
            Text(
              'Your transactions will appear here',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: history.length,
        itemBuilder: (context, index) {
          return _buildHistoryCard(history[index]);
        },
      ),
    );
  }

  /// Tab 3: Payment Settings
  Widget _buildSettingsTab() {
    final subscription = _currentPlan;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Subscription Status
          if (subscription != null) ...[
            _buildSubscriptionCard(subscription),
            const SizedBox(height: 24),
          ],

          // Quick Actions
          _buildQuickAction(
            'Payment Methods',
            'Manage your payment methods',
            Icons.credit_card,
            () {
              // TODO: Navigate to payment methods
            },
          ),
          const SizedBox(height: 12),
          _buildQuickAction(
            'Billing Information',
            'Update your billing details',
            Icons.receipt,
            () {
              // TODO: Navigate to billing info
            },
          ),
          const SizedBox(height: 12),
          _buildQuickAction(
            'Auto-Renewal',
            'Manage subscription renewal',
            Icons.autorenew,
            () {
              // TODO: Toggle auto-renewal
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentSubscriptionBadge(UserSubscriptionModel subscription) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primaryGreen, AppTheme.accentGreen],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.white),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Active Plan',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
                Text(
                  'Plan #${subscription.paymentPlanId}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Text(
            'Active',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanCard(PaymentPlanModel plan, bool isActive) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: isActive ? 4 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isActive ? AppTheme.primaryGreen : Colors.transparent,
          width: 2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        plan.name,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        plan.description ?? '',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                if (isActive)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'ACTIVE',
                      style: TextStyle(
                        color: AppTheme.primaryGreen,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 16),

            // Price
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${plan.price}',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryGreen,
                  ),
                ),
                const SizedBox(width: 8),
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text(
                    'TZS${plan.billingCycle != null ? '/${plan.billingCycle}' : ''}',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Features
            if (plan.features.isNotEmpty) ...[
              ...plan.features.take(4).map((feature) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.check_circle,
                        color: AppTheme.primaryGreen,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(child: Text(feature)),
                    ],
                  ),
                );
              }).toList(),
              if (plan.features.length > 4)
                TextButton(
                  onPressed: () {
                    // Show all features dialog
                  },
                  child: const Text('View all features'),
                ),
            ],

            const SizedBox(height: 16),

            // Action Button
            if (!isActive)
              SizedBox(
                width: double.infinity,
                child: AppButton(
                  text: 'Subscribe',
                  onPressed: () => _subscribeToPlan(plan),
                  icon: Icons.arrow_forward,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryCard(PaymentTransactionModel payment) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _getStatusColor(payment.status).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            _getStatusIcon(payment.status),
            color: _getStatusColor(payment.status),
          ),
        ),
        title: Text(
          payment.description ?? payment.typeDisplay,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          '${payment.createdAt.day}/${payment.createdAt.month}/${payment.createdAt.year}',
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              payment.formattedAmount,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: _getStatusColor(payment.status).withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                payment.statusDisplay.toUpperCase(),
                style: TextStyle(
                  color: _getStatusColor(payment.status),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        onTap: payment.isCompleted
            ? () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) =>
                        PaymentReceiptScreen(transactionId: payment.id),
                  ),
                );
              }
            : null,
      ),
    );
  }

  Widget _buildSubscriptionCard(UserSubscriptionModel subscription) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.lightGray),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: AppTheme.primaryGreen),
              const SizedBox(width: 8),
              const Text(
                'Subscription Status',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const Divider(height: 20),
          _buildInfoRow('Status', subscription.status.toUpperCase()),
          if (subscription.expiresAt != null)
            _buildInfoRow(
              'Expires On',
              '${subscription.expiresAt!.day}/${subscription.expiresAt!.month}/${subscription.expiresAt!.year}',
            ),
          _buildInfoRow('Days Remaining', '${subscription.daysRemaining} days'),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: AppButton(
              text: 'Cancel Subscription',
              onPressed: _showCancelDialog,
              type: ButtonType.danger,
              size: ButtonSize.small,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAction(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.lightGray.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppTheme.primaryGreen),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600])),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  void _subscribeToPlan(PaymentPlanModel? plan) {
    if (plan == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            PaymentCheckoutScreen(plan: plan, action: 'subscription'),
      ),
    );
  }

  void _showCancelDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Subscription'),
        content: const Text(
          'Are you sure you want to cancel your subscription? You will lose access to premium features.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Keep Subscription'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _cancelSubscription();
            },
            child: const Text('Cancel', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _cancelSubscription() async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      // Cancel subscription via API
      final paymentService = PaymentService();
      final result = await paymentService.cancelSubscription();

      // Close loading indicator
      if (mounted) {
        Navigator.pop(context);
      }

      if (result.success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Subscription cancelled successfully'),
              backgroundColor: Colors.green,
            ),
          );
          // Refresh the payment data
          _loadData();
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      // Close loading indicator if still showing
      if (mounted) {
        Navigator.pop(context);
      }

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

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
      case 'success':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'failed':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
      case 'success':
        return Icons.check_circle;
      case 'pending':
        return Icons.pending;
      case 'failed':
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }
}
