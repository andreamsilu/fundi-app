import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../../shared/widgets/error_widget.dart';
import '../models/job_model.dart';
import '../models/job_application_model.dart' as app_model;
import '../services/job_service.dart';
import '../widgets/job_application_card.dart';
import 'application_details_screen.dart';

/// Job Applications Screen
/// Shows all applications for a specific job
/// Allows customers and admins to view and manage applications
class JobApplicationsScreen extends StatefulWidget {
  final JobModel job;

  const JobApplicationsScreen({super.key, required this.job});

  @override
  State<JobApplicationsScreen> createState() => _JobApplicationsScreenState();
}

class _JobApplicationsScreenState extends State<JobApplicationsScreen> {
  final JobService _jobService = JobService();
  List<app_model.JobApplicationModel> _applications = [];
  bool _isLoading = true;
  String? _errorMessage;
  app_model.JobApplicationStatus? _selectedStatus;

  @override
  void initState() {
    super.initState();
    _loadApplications();
  }

  Future<void> _loadApplications() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _jobService.getJobApplications(widget.job.id);
      if (mounted) {
        if (result.success) {
          setState(() {
            _applications = result.applications
                .map((app) => app as app_model.JobApplicationModel)
                .toList();
            _isLoading = false;
          });
        } else {
          setState(() {
            _errorMessage = 'Failed to load applications';
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  List<app_model.JobApplicationModel> get _filteredApplications {
    if (_selectedStatus == null) {
      return _applications;
    }
    return _applications.where((app) => app.status == _selectedStatus).toList();
  }

  Future<void> _handleStatusChange(
    app_model.JobApplicationModel application,
    app_model.JobApplicationStatus newStatus,
  ) async {
    try {
      // TODO: Implement status change API call
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Application ${newStatus.displayName.toLowerCase()}'),
          backgroundColor: AppTheme.primaryGreen,
        ),
      );
      await _loadApplications();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update application: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _viewApplicationDetails(app_model.JobApplicationModel application) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ApplicationDetailsScreen(
          applicationId: application.id,
          jobId: widget.job.id,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Applications for ${widget.job.title}'),
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // Job Info Card
          _buildJobInfoCard(),

          // Status Filter
          JobApplicationStatusFilter(
            selectedStatus: _selectedStatus,
            onStatusChanged: (status) {
              setState(() => _selectedStatus = status);
            },
          ),

          const SizedBox(height: 8),

          // Applications List
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildJobInfoCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryGreen.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primaryGreen.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.work, color: AppTheme.primaryGreen, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.job.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.darkGray,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '${_applications.length} ${_applications.length == 1 ? 'Application' : 'Applications'}',
                  style: TextStyle(fontSize: 14, color: AppTheme.mediumGray),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: LoadingWidget());
    }

    if (_errorMessage != null) {
      return Center(
        child: AppErrorWidget(
          message: _errorMessage!,
          onRetry: _loadApplications,
        ),
      );
    }

    if (_applications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.assignment_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            const Text(
              'No applications yet',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Applications will appear here when fundis apply',
              style: TextStyle(color: AppTheme.mediumGray),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    final filteredApps = _filteredApplications;

    if (filteredApps.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.filter_list_off, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No ${_selectedStatus?.displayName.toLowerCase() ?? ''} applications',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                setState(() => _selectedStatus = null);
              },
              child: const Text('Clear Filter'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadApplications,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: filteredApps.length,
        itemBuilder: (context, index) {
          final application = filteredApps[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: JobApplicationCard(
              application: application,
              onTap: () => _viewApplicationDetails(application),
              onAccept:
                  application.status == app_model.JobApplicationStatus.pending
                  ? () => _handleStatusChange(
                      application,
                      app_model.JobApplicationStatus.accepted,
                    )
                  : null,
              onReject:
                  application.status == app_model.JobApplicationStatus.pending
                  ? () => _handleStatusChange(
                      application,
                      app_model.JobApplicationStatus.rejected,
                    )
                  : null,
              showActions: true,
            ),
          );
        },
      ),
    );
  }
}
