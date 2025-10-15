import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../../../shared/widgets/button_widget.dart';
import '../../../core/network/api_client.dart';
import '../../../core/utils/logger.dart';

/// Payment Receipt Screen
/// Displays detailed receipt information for a completed payment transaction
class PaymentReceiptScreen extends StatefulWidget {
  final int transactionId;

  const PaymentReceiptScreen({Key? key, required this.transactionId})
    : super(key: key);

  @override
  State<PaymentReceiptScreen> createState() => _PaymentReceiptScreenState();
}

class _PaymentReceiptScreenState extends State<PaymentReceiptScreen> {
  final ApiClient _apiClient = ApiClient();
  bool _isLoading = true;
  Map<String, dynamic>? _receiptData;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadReceipt();
  }

  /// Load receipt data from API
  Future<void> _loadReceipt() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        '/payments/receipt/${widget.transactionId}',
        fromJson: (data) => data as Map<String, dynamic>,
      );

      if (!mounted) return;

      if (response.success && response.data != null) {
        setState(() {
          _receiptData = response.data;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = response.message;
          _isLoading = false;
        });
      }
    } on ApiError catch (e) {
      Logger.error('Error loading receipt', error: e);
      if (!mounted) return;

      setState(() {
        _errorMessage = e.message;
        _isLoading = false;
      });
    } catch (e) {
      Logger.error('Error loading receipt', error: e);
      if (!mounted) return;

      setState(() {
        _errorMessage = 'An error occurred while loading the receipt';
        _isLoading = false;
      });
    }
  }

  /// Format currency
  String _formatCurrency(dynamic amount, String currency) {
    if (amount == null) return '';
    final numAmount = amount is String
        ? double.tryParse(amount) ?? 0
        : amount.toDouble();
    return '$currency ${NumberFormat('#,##0.00').format(numAmount)}';
  }

  /// Format date time
  String _formatDateTime(String? dateTime) {
    if (dateTime == null) return 'N/A';
    try {
      final date = DateTime.parse(dateTime);
      return DateFormat('dd MMM yyyy, hh:mm a').format(date);
    } catch (e) {
      return 'N/A';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Payment Receipt'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _receiptData != null ? _shareReceipt : null,
            tooltip: 'Share Receipt',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading receipt...'),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              AppButton(
                text: 'Try Again',
                onPressed: _loadReceipt,
                icon: Icons.refresh,
                isFullWidth: true,
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildReceiptCard(),
            const SizedBox(height: 16),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildReceiptCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Success Icon
            Center(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  size: 64,
                  color: Colors.green,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Receipt Number
            Center(
              child: Column(
                children: [
                  const Text(
                    'PAYMENT RECEIPT',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _receiptData?['receipt_number'] ?? '',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Amount
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  const Text(
                    'Amount Paid',
                    style: TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatCurrency(
                      _receiptData?['amount'],
                      _receiptData?['currency'] ?? 'TZS',
                    ),
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            const Divider(),
            const SizedBox(height: 16),

            // Transaction Details
            const Text(
              'Transaction Details',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            _buildDetailRow(
              'Transaction ID',
              _receiptData?['transaction_reference'] ?? 'N/A',
            ),
            _buildDetailRow(
              'Payment Reference',
              _receiptData?['payment_reference'] ?? 'N/A',
            ),
            if (_receiptData?['gateway_reference'] != null &&
                _receiptData!['gateway_reference'].toString().isNotEmpty)
              _buildDetailRow(
                'Gateway Reference',
                _receiptData!['gateway_reference'],
              ),
            _buildDetailRow(
              'Payment Method',
              _receiptData?['payment_method']?.toString().toUpperCase() ??
                  'N/A',
            ),
            _buildDetailRow(
              'Payment Type',
              _formatPaymentType(_receiptData?['payment_type']),
            ),
            _buildDetailRow(
              'Status',
              _receiptData?['status']?.toString().toUpperCase() ?? 'N/A',
              valueColor: Colors.green,
            ),

            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),

            // Customer Details
            const Text(
              'Customer Details',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            _buildDetailRow('Name', _receiptData?['user']?['name'] ?? 'N/A'),
            _buildDetailRow('Email', _receiptData?['user']?['email'] ?? 'N/A'),
            if (_receiptData?['user']?['phone'] != null &&
                _receiptData!['user']['phone'].toString().isNotEmpty)
              _buildDetailRow('Phone', _receiptData!['user']['phone']),

            if (_receiptData?['payment_plan'] != null) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),

              // Payment Plan Details
              const Text(
                'Payment Plan',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              _buildDetailRow(
                'Plan Name',
                _receiptData!['payment_plan']['name'] ?? 'N/A',
              ),
              if (_receiptData!['payment_plan']['description'] != null)
                _buildDetailRow(
                  'Description',
                  _receiptData!['payment_plan']['description'],
                ),
            ],

            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),

            // Dates
            const Text(
              'Timeline',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            _buildDetailRow(
              'Transaction Date',
              _formatDateTime(_receiptData?['created_at']),
            ),
            _buildDetailRow(
              'Payment Date',
              _formatDateTime(_receiptData?['paid_at']),
            ),

            if (_receiptData?['description'] != null &&
                _receiptData!['description'].toString().isNotEmpty) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),

              const Text(
                'Description',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                _receiptData!['description'],
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              ),
            ],

            const SizedBox(height: 24),

            // Footer
            Center(
              child: Text(
                'Thank you for your payment!',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: valueColor ?? Colors.black87,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  String _formatPaymentType(String? type) {
    if (type == null) return 'N/A';
    return type
        .split('_')
        .map((word) {
          return word[0].toUpperCase() + word.substring(1).toLowerCase();
        })
        .join(' ');
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: AppButton(
            text: 'Download PDF',
            onPressed: _downloadPDF,
            icon: Icons.download,
            type: ButtonType.secondary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: AppButton(
            text: 'Close',
            onPressed: () => Navigator.of(context).pop(),
            icon: Icons.close,
            type: ButtonType.primary,
          ),
        ),
      ],
    );
  }

  void _shareReceipt() {
    // TODO: Implement share functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Share functionality coming soon')),
    );
  }

  /// Download receipt as PDF
  Future<void> _downloadPDF() async {
    if (_receiptData == null) return;

    try {
      // Show loading
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Generating PDF...')),
      );

      // Create PDF document
      final pdf = pw.Document();

      // Add receipt content
      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Header
                pw.Text(
                  'PAYMENT RECEIPT',
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 20),
                pw.Divider(),
                pw.SizedBox(height: 20),

                // Transaction Details
                _buildPdfRow('Transaction ID', _receiptData!['id']?.toString() ?? 'N/A'),
                _buildPdfRow('Status', _receiptData!['status']?.toString().toUpperCase() ?? 'N/A'),
                _buildPdfRow('Amount', '${_receiptData!['currency']} ${_receiptData!['amount']}'),
                _buildPdfRow('Payment Method', _receiptData!['payment_method']?.toString().toUpperCase() ?? 'N/A'),
                _buildPdfRow('Date', _formatDate(_receiptData!['created_at'])),
                
                if (_receiptData!['payment_reference'] != null)
                  _buildPdfRow('Reference', _receiptData!['payment_reference']),
                
                if (_receiptData!['description'] != null)
                  _buildPdfRow('Description', _receiptData!['description']),

                pw.SizedBox(height: 30),
                pw.Divider(),
                pw.SizedBox(height: 10),

                // Footer
                pw.Text(
                  'Generated on ${DateFormat('dd MMM yyyy, HH:mm').format(DateTime.now())}',
                  style: const pw.TextStyle(fontSize: 10, color: PdfColor.fromInt(0xFF808080)),
                ),
                pw.Text(
                  'Fundi App - Your Trusted Service Platform',
                  style: const pw.TextStyle(fontSize: 10, color: PdfColor.fromInt(0xFF808080)),
                ),
              ],
            );
          },
        ),
      );

      // Get directory to save file
      final directory = await getApplicationDocumentsDirectory();
      final fileName = 'receipt_${widget.transactionId}_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final file = File('${directory.path}/$fileName');

      // Save PDF file
      await file.writeAsBytes(await pdf.save());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Receipt saved to: ${file.path}'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'OK',
              textColor: Colors.white,
              onPressed: () {},
            ),
          ),
        );
      }

      Logger.userAction('Receipt downloaded', data: {'transactionId': widget.transactionId, 'path': file.path});
    } catch (e) {
      Logger.error('Receipt download failed', error: e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to download receipt: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Helper to build PDF row
  pw.Widget _buildPdfRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 150,
            child: pw.Text(
              '$label:',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.Expanded(
            child: pw.Text(value),
          ),
        ],
      ),
    );
  }

  /// Format date helper
  String _formatDate(dynamic date) {
    if (date == null) return 'N/A';
    try {
      final DateTime dt = date is DateTime ? date : DateTime.parse(date.toString());
      return DateFormat('dd MMM yyyy, HH:mm').format(dt);
    } catch (e) {
      return date.toString();
    }
  }
}
