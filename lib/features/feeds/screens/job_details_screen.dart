import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../services/feeds_service.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../../shared/widgets/error_widget.dart';

class JobDetailsScreen extends StatefulWidget {
  final dynamic job;

  const JobDetailsScreen({Key? key, required this.job}) : super(key: key);

  @override
  State<JobDetailsScreen> createState() => _JobDetailsScreenState();
}

class _JobDetailsScreenState extends State<JobDetailsScreen> {
  final FeedsService _feedsService = FeedsService();
  dynamic _jobDetails;
  bool _isLoading = false;
  bool _isApplying = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _jobDetails = widget.job;
    _loadJobDetails();
  }

  Future<void> _loadJobDetails() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final result = await _feedsService.getJobDetails(widget.job['id']);

      if (result['success']) {
        setState(() {
          _jobDetails = result['job'];
        });
      } else {
        setState(() {
          _error = result['message'] ?? 'Failed to load job details';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to load job details: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _applyForJob() async {
    if (_isApplying) return;

    setState(() {
      _isApplying = true;
    });

    try {
      // TODO: Use JobApplicationService instead of FeedsService
      final result = {
        'success': false,
        'message': 'Job application functionality not implemented',
      };

      if (result['success'] as bool) {
        setState(() {
          _jobDetails['has_applied'] = true;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Application submitted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] as String),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isApplying = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Job Details'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          if (!authProvider.isFundi) {
            return const Center(
              child: Text('Only fundis can view job details'),
            );
          }

          if (_isLoading && _jobDetails == null) {
            return const LoadingWidget();
          }

          if (_error != null && _jobDetails == null) {
            return AppErrorWidget(message: _error!, onRetry: _loadJobDetails);
          }

          final job = _jobDetails ?? widget.job;
          final customer = job['customer'] ?? {};
          final category = job['category'] ?? {};
          final hasApplied = job['has_applied'] ?? false;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Section
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        job['title'] ?? 'Untitled Job',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              category['name'] ?? 'General',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: _getStatusColor(
                                job['status'] ?? 'open',
                              ).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              (job['status'] ?? 'open').toUpperCase(),
                              style: TextStyle(
                                color: _getStatusColor(job['status'] ?? 'open'),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Job Details
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Description
                      const Text(
                        'Job Description',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        job['description'] ?? 'No description provided',
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 16,
                          height: 1.5,
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Budget and Deadline
                      Row(
                        children: [
                          Expanded(
                            child: _buildInfoCard(
                              Icons.attach_money,
                              'Budget',
                              _formatBudget(job['budget'], job['budget_type']),
                              Colors.green,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildInfoCard(
                              Icons.schedule,
                              'Deadline',
                              _formatDeadline(job['deadline']),
                              Colors.blue,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Customer Information
                      const Text(
                        'Customer Information',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[200]!),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              customer['name'] ?? 'Unknown Customer',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (customer['email'] != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                customer['email'],
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                            ],
                            if (customer['phone'] != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                customer['phone'],
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Apply Button
                if (!hasApplied) ...[
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isApplying ? null : _applyForJob,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: _isApplying
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : const Text(
                                'Apply for this Job',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                  ),
                ] else ...[
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green),
                      ),
                      child: const Text(
                        'You have already applied for this job',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoCard(
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _formatBudget(dynamic budget, String? budgetType) {
    if (budget == null) return 'Not specified';

    final amount = budget.toString();
    switch (budgetType) {
      case 'hourly':
        return 'TZS $amount/hour';
      case 'negotiable':
        return 'TZS $amount (Negotiable)';
      default:
        return 'TZS $amount';
    }
  }

  String _formatDeadline(String? deadline) {
    if (deadline == null || deadline.isEmpty) return 'Not specified';

    try {
      final date = DateTime.parse(deadline);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return deadline;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'open':
        return Colors.green;
      case 'in_progress':
        return Colors.blue;
      case 'completed':
        return Colors.grey;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
