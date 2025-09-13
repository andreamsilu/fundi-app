import 'package:flutter/material.dart';
import '../../../core/config/payment_config.dart';
import '../../../core/utils/payment_logger.dart';

/// Widget for selecting payment actions
class PaymentActionSelector extends StatefulWidget {
  final List<String> selectedActions;
  final Function(List<String>) onSelectionChanged;
  final List<PaymentAction> availableActions;

  const PaymentActionSelector({
    Key? key,
    required this.selectedActions,
    required this.onSelectionChanged,
    required this.availableActions,
  }) : super(key: key);

  @override
  State<PaymentActionSelector> createState() => _PaymentActionSelectorState();
}

class _PaymentActionSelectorState extends State<PaymentActionSelector> {
  List<String> _selectedActions = [];

  @override
  void initState() {
    super.initState();
    _selectedActions = List.from(widget.selectedActions);
  }

  @override
  void didUpdateWidget(PaymentActionSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedActions != widget.selectedActions) {
      _selectedActions = List.from(widget.selectedActions);
    }
  }

  void _toggleAction(String actionId) {
    setState(() {
      if (_selectedActions.contains(actionId)) {
        _selectedActions.remove(actionId);
      } else {
        _selectedActions.add(actionId);
      }
    });

    PaymentLogger.logPaymentEvent(
      event: 'toggle_payment_action',
      transactionId: 'ui_action',
      data: {
        'screen': 'payment_action_selector',
        'action_id': actionId,
        'selected_actions': _selectedActions,
      },
    );

    widget.onSelectionChanged(_selectedActions);
  }

  double _calculateTotal() {
    return _selectedActions
        .map(
          (actionId) => widget.availableActions
              .firstWhere((action) => action.description == actionId)
              .amount,
        )
        .fold(0.0, (sum, amount) => sum + amount);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Payment Actions',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),

        // Group actions by category
        ...PaymentConfig.getCategories().map((category) {
          final categoryActions = widget.availableActions
              .where((action) => action.category == category)
              .toList();

          if (categoryActions.isEmpty) return const SizedBox.shrink();

          return _buildCategorySection(category, categoryActions);
        }).toList(),

        if (_selectedActions.isNotEmpty) ...[
          const SizedBox(height: 24),
          _buildTotalSection(),
        ],
      ],
    );
  }

  Widget _buildCategorySection(String category, List<PaymentAction> actions) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            category,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ),

        ...actions.map((action) => _buildActionTile(action)).toList(),

        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildActionTile(PaymentAction action) {
    final isSelected = _selectedActions.contains(action.description);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => _toggleAction(action.description),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: isSelected
                ? Border.all(color: Theme.of(context).primaryColor, width: 2)
                : null,
            color: isSelected
                ? Theme.of(context).primaryColor.withOpacity(0.1)
                : null,
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: action.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(action.icon, color: action.color, size: 24),
              ),

              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      action.description,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      PaymentConfig.formatAmount(action.amount),
                      style: TextStyle(
                        fontSize: 14,
                        color: action.color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              Checkbox(
                value: isSelected,
                onChanged: (_) => _toggleAction(action.description),
                activeColor: Theme.of(context).primaryColor,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTotalSection() {
    final total = _calculateTotal();

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
            'Payment Summary',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_selectedActions.length} item(s) selected',
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
              Text(
                'TZS ${total.toStringAsFixed(0)}',
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
}
