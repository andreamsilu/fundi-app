import 'package:flutter/material.dart';
import '../models/job_model.dart';
import '../services/job_service.dart';
import '../../../shared/widgets/button_widget.dart';
import '../../../shared/widgets/error_widget.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/extensions/string_extensions.dart';
import '../../auth/services/auth_service.dart';
import '../../work_approval/services/work_approval_service.dart';
import '../../work_approval/widgets/work_submission_card.dart';
import '../../work_approval/models/work_submission_model.dart';

/// Job details screen showing comprehensive job information
/// Allows fundis to apply for jobs and customers to manage their jobs
/// Integrates work approval for customers to review submissions
class JobDetailsScreen extends StatefulWidget {
  final JobModel job;

  const JobDetailsScreen({super.key, required this.job});

  @override
  State<JobDetailsScreen> createState() => _JobDetailsScreenState();
}

class _JobDetailsScreenState extends State<JobDetailsScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final WorkApprovalService _workApprovalService = WorkApprovalService();

  bool _isApplying = false;
  String? _errorMessage;
  String? _successMessage;
  bool _hasApplied = false;
  List<WorkSubmissionModel> _workSubmissions = [];

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _checkApplicationStatus();
    _loadWorkSubmissions();
  }

  void _setupAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  Future<void> _checkApplicationStatus() async {
    try {
      final authService = AuthService();

      // Only check if user is a fundi
      if (!(authService.currentUser?.isFundi ?? false)) return;

      final jobService = JobService();
      final hasApplied = await jobService.hasAppliedToJob(widget.job.id);

      if (mounted) {
        setState(() {
          _hasApplied = hasApplied;
        });
      }
    } catch (e) {
      print('Error checking application status: $e');
    }
  }

  /// Load work submissions for this job (for customers)
  Future<void> _loadWorkSubmissions() async {
    try {
      final authService = AuthService();
      if (!(authService.currentUser?.isCustomer ?? false)) return;

      // Get work submissions for this specific job
      final result = await _workApprovalService.getPendingWorkSubmissions(
        jobId: widget.job.id,
      );

      if (result['success'] == true && mounted) {
        final submissions =
            result['workSubmissions'] as List<WorkSubmissionModel>? ?? [];
        setState(() {
          _workSubmissions = submissions;
        });
      }
    } catch (e) {
      print('Error loading work submissions: $e');
    }
  }

  /// Approve work submission
  Future<void> _approveWorkSubmission(String submissionId) async {
    try {
      final result = await _workApprovalService.approveWorkSubmission(
        submissionId: submissionId,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: result['success'] ? Colors.green : Colors.red,
          ),
        );

        if (result['success']) {
          // Show rating dialog after successful approval
          _showRatingDialog(submissionId);
          // Reload submissions
          _loadWorkSubmissions();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to approve work: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Reject work submission
  Future<void> _rejectWorkSubmission(String submissionId, String reason) async {
    try {
      final result = await _workApprovalService.rejectWorkSubmission(
        submissionId: submissionId,
        rejectionReason: reason,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: result['success'] ? Colors.orange : Colors.red,
          ),
        );

        if (result['success']) {
          // Reload submissions
          _loadWorkSubmissions();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to reject work: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Show rating dialog after work approval
  void _showRatingDialog(String submissionId) {
    // TODO: Integrate rating form here
    // For now, just show a placeholder
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rate the Work'),
        content: const Text(
          'Work approved successfully! Rating functionality will be integrated here.',
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

  Future<void> _applyForJob() async {
    setState(() {
      _isApplying = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final result = await JobService().applyForJob(
        widget.job.id,
        jobId: widget.job.id,
        message: 'I am interested in this job and would like to apply.',
        proposedBudget: widget.job.budget,
        proposedBudgetType: widget.job.budgetType,
        estimatedDays: 7, // Default estimate
      );

      if (result.success) {
        setState(() {
          _successMessage = 'Application submitted successfully!';
          _hasApplied = true;
        });
      } else {
        setState(() {
          _errorMessage = result.message;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to apply for job. Please try again.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isApplying = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: CustomScrollView(
            slivers: [
              // App Bar with Job Image
              _buildSliverAppBar(),

              // Job Content
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Messages
                      if (_errorMessage != null) ...[
                        ErrorBanner(
                          message: _errorMessage!,
                          onDismiss: () {
                            setState(() {
                              _errorMessage = null;
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                      ],

                      if (_successMessage != null) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.green.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.green.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.check_circle,
                                color: Colors.green,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _successMessage!,
                                  style: const TextStyle(color: Colors.green),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Job Title and Status
                      _buildJobHeader(),

                      const SizedBox(height: 24),

                      // Job Details
                      _buildJobDetails(),

                      const SizedBox(height: 24),

                      // Customer Information
                      _buildCustomerInfo(),

                      const SizedBox(height: 24),

                      // Work Submissions Section (for customers only)
                      _buildWorkSubmissionsSection(),

                      // Action Buttons
                      _buildActionButtons(),

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build work submissions section for customers
  Widget _buildWorkSubmissionsSection() {
    final authService = AuthService();

    if (!(authService.currentUser?.isCustomer ?? false)) {
      return const SizedBox.shrink();
    }

    if (_workSubmissions.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  Icons.assignment_turned_in,
                  color: context.primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Work Submissions',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.darkGray,
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
              ),
              child: Text(
                '${_workSubmissions.length} Pending',
                style: const TextStyle(
                  color: Colors.orange,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Work submissions list
        ..._workSubmissions.map((submission) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: WorkSubmissionCard(
              workSubmission: submission.toJson(),
              onApprove: () => _approveWorkSubmission(submission.id),
              onReject: (reason) =>
                  _rejectWorkSubmission(submission.id, reason),
            ),
          );
        }).toList(),

        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 250,
      pinned: true,
      backgroundColor: context.primaryColor,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          widget.job.title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Job Image or Placeholder
            if (widget.job.imageUrls != null &&
                widget.job.imageUrls!.isNotEmpty)
              Image.network(
                widget.job.imageUrls!.first,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildImagePlaceholder();
                },
              )
            else
              _buildImagePlaceholder(),

            // Gradient Overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.7),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      color: AppTheme.lightGray,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.work_outline, size: 64, color: AppTheme.mediumGray),
            const SizedBox(height: 8),
            Text(
              'No Image Available',
              style: TextStyle(color: AppTheme.mediumGray, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJobHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                widget.job.title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.darkGray,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: widget.job.status.toColor().withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: widget.job.status.toColor().withValues(alpha: 0.3),
                ),
              ),
              child: Text(
                widget.job.status.displayName,
                style: TextStyle(
                  color: widget.job.status.toColor(),
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(Icons.category_outlined, size: 16, color: AppTheme.mediumGray),
            const SizedBox(width: 4),
            Text(
              widget.job.category ?? 'General',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppTheme.mediumGray),
            ),
            const SizedBox(width: 16),
            Icon(
              Icons.location_on_outlined,
              size: 16,
              color: AppTheme.mediumGray,
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                widget.job.location ?? 'Location not specified',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: AppTheme.mediumGray),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildJobDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Job Details',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.darkGray,
          ),
        ),
        const SizedBox(height: 16),

        // Description
        _buildDetailItem(
          'Description',
          widget.job.description,
          Icons.description_outlined,
        ),

        const SizedBox(height: 16),

        // Budget and Duration Row
        Row(
          children: [
            Expanded(
              child: _buildDetailItem(
                'Budget',
                widget.job.formattedBudget,
                Icons.attach_money,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildDetailItem(
                'Deadline',
                widget.job.formattedTimeRemaining,
                Icons.schedule,
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Posted Date
        _buildDetailItem(
          'Posted',
          '${widget.job.createdAt?.day ?? 0}/${widget.job.createdAt?.month ?? 0}/${widget.job.createdAt?.year ?? 0}',
          Icons.calendar_today,
        ),
      ],
    );
  }

  Widget _buildDetailItem(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.lightGray.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: context.primaryColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.mediumGray,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.darkGray,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Customer Information',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.darkGray,
          ),
        ),
        const SizedBox(height: 16),

        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.lightGray.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 25,
                backgroundColor: context.primaryColor.withValues(alpha: 0.1),
                child: Text(
                  (widget.job.customerName != null &&
                          widget.job.customerName!.isNotEmpty)
                      ? widget.job.customerName![0].toUpperCase()
                      : '',
                  style: TextStyle(
                    color: context.primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.job.customerName ?? '',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.darkGray,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Customer',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.mediumGray,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    final authService = AuthService();
    final bool isCustomer = authService.currentUser?.isCustomer ?? false;
    final bool isFundi = authService.currentUser?.isFundi ?? false;

    if (isCustomer) {
      // Customer actions
      return Column(
        children: [
          AppButton(
            text: 'Edit Job',
            onPressed: () {
              // TODO: Navigate to edit job screen
            },
            type: ButtonType.secondary,
            isFullWidth: true,
            icon: Icons.edit,
          ),
          const SizedBox(height: 12),
          AppButton(
            text: 'View Applications',
            onPressed: () {
              Navigator.pushNamed(
                context,
                '/job-applications',
                arguments: widget.job,
              );
            },
            isFullWidth: true,
            icon: Icons.people,
          ),
        ],
      );
    } else if (isFundi) {
      // Fundi actions
      return Column(
        children: [
          if (_hasApplied) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.green),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'You have applied for this job',
                      style: const TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            AppButton(
              text: _hasApplied ? 'Already Applied' : 'Apply for Job',
              onPressed: _hasApplied
                  ? null
                  : (_isApplying ? null : _applyForJob),
              isLoading: _isApplying,
              isFullWidth: true,
              icon: _hasApplied ? Icons.check_circle : Icons.send,
            ),
            if (_hasApplied)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'You have already applied for this job',
                  style: TextStyle(
                    color: AppTheme.primaryGreen,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
          const SizedBox(height: 12),
          AppButton(
            text: 'Contact Customer',
            onPressed: () {
              // TODO: Navigate to chat with customer
            },
            type: ButtonType.secondary,
            isFullWidth: true,
            icon: Icons.message,
          ),
        ],
      );
    } else {
      // Admin actions
      return Column(
        children: [
          AppButton(
            text: 'View Applications',
            onPressed: () {
              Navigator.pushNamed(
                context,
                '/job-applications',
                arguments: widget.job,
              );
            },
            isFullWidth: true,
            icon: Icons.people,
          ),
          const SizedBox(height: 12),
          AppButton(
            text: 'Manage Job',
            onPressed: () {
              Navigator.pushNamed(
                context,
                '/job-applications',
                arguments: widget.job,
              );
            },
            type: ButtonType.secondary,
            isFullWidth: true,
            icon: Icons.settings,
          ),
        ],
      );
    }
  }
}
