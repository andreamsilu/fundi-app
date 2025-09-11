import 'package:flutter/material.dart';
import '../models/job_application_model.dart';

/// Job application card widget for displaying job application information
class JobApplicationCard extends StatelessWidget {
  final JobApplicationModel application;
  final VoidCallback? onTap;
  final VoidCallback? onWithdraw;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;
  final bool showActions;

  const JobApplicationCard({
    super.key,
    required this.application,
    this.onTap,
    this.onWithdraw,
    this.onAccept,
    this.onReject,
    this.showActions = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Job title and fundi name
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          application.jobTitle,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'by ${application.fundiName}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Status badge
                  _buildStatusBadge(context),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Application details
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Applied ${application.formattedAppliedAt}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              
              if (application.proposedBudget != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.attach_money,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Budget: ${application.formattedProposedBudget}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
              
              if (application.coverLetter.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  'Cover Letter',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  application.coverLetter,
                  style: Theme.of(context).textTheme.bodyMedium,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              
              const SizedBox(height: 12),
              
              // Footer row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Application ID
                  Text(
                    'ID: ${application.id}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[500],
                    ),
                  ),
                  
                  // Action buttons
                  if (showActions) ...[
                    Row(
                      children: [
                        if (application.status == JobApplicationStatus.pending) ...[
                          TextButton(
                            onPressed: onWithdraw,
                            child: const Text('Withdraw'),
                          ),
                        ],
                        if (application.status == JobApplicationStatus.accepted) ...[
                          TextButton(
                            onPressed: onAccept,
                            child: const Text('Accept'),
                          ),
                        ],
                        if (application.status == JobApplicationStatus.rejected) ...[
                          TextButton(
                            onPressed: onReject,
                            child: const Text('Reject'),
                          ),
                        ],
                      ],
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context) {
    Color backgroundColor;
    Color textColor;
    
    switch (application.status) {
      case JobApplicationStatus.pending:
        backgroundColor = Colors.orange[100]!;
        textColor = Colors.orange[800]!;
        break;
      case JobApplicationStatus.accepted:
        backgroundColor = Colors.green[100]!;
        textColor = Colors.green[800]!;
        break;
      case JobApplicationStatus.rejected:
        backgroundColor = Colors.red[100]!;
        textColor = Colors.red[800]!;
        break;
      case JobApplicationStatus.withdrawn:
        backgroundColor = Colors.grey[100]!;
        textColor = Colors.grey[800]!;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        application.status.displayName,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// Job application list widget
class JobApplicationListWidget extends StatelessWidget {
  final List<JobApplicationModel> applications;
  final VoidCallback? onTap;
  final VoidCallback? onWithdraw;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;
  final bool showActions;
  final bool isLoading;
  final VoidCallback? onRefresh;

  const JobApplicationListWidget({
    super.key,
    required this.applications,
    this.onTap,
    this.onWithdraw,
    this.onAccept,
    this.onReject,
    this.showActions = false,
    this.isLoading = false,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading && applications.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (applications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.assignment_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No applications found',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Your job applications will appear here',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            if (onRefresh != null) ...[
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: onRefresh,
                child: const Text('Refresh'),
              ),
            ],
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh ?? () async {},
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: applications.length,
        itemBuilder: (context, index) {
          final application = applications[index];
          return JobApplicationCard(
            application: application,
            onTap: onTap,
            onWithdraw: onWithdraw,
            onAccept: onAccept,
            onReject: onReject,
            showActions: showActions,
          );
        },
      ),
    );
  }
}

/// Job application status filter widget
class JobApplicationStatusFilter extends StatelessWidget {
  final JobApplicationStatus? selectedStatus;
  final Function(JobApplicationStatus?) onStatusChanged;

  const JobApplicationStatusFilter({
    super.key,
    this.selectedStatus,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          // All statuses
          _buildFilterChip(
            context,
            'All',
            null,
            selectedStatus == null,
          ),
          
          // Individual statuses
          ...JobApplicationStatus.values.map((status) =>
            _buildFilterChip(
              context,
              status.displayName,
              status,
              selectedStatus == status,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    BuildContext context,
    String label,
    JobApplicationStatus? status,
    bool isSelected,
  ) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          onStatusChanged(selected ? status : null);
        },
      ),
    );
  }
}
