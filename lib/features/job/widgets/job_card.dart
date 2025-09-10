import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/job_model.dart';
import '../../../core/theme/app_theme.dart';

/// Reusable job card widget for displaying job information
/// Features consistent styling and interactive elements
class JobCard extends StatefulWidget {
  final JobModel job;
  final VoidCallback? onTap;
  final VoidCallback? onApply;
  final bool showApplyButton;
  final bool isCompact;

  const JobCard({
    super.key,
    required this.job,
    this.onTap,
    this.onApply,
    this.showApplyButton = true,
    this.isCompact = false,
  });

  @override
  State<JobCard> createState() => _JobCardState();
}

class _JobCardState extends State<JobCard> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    _animationController.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    _animationController.reverse();
  }

  void _handleTapCancel() {
    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with title and status
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.job.title,
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(fontWeight: FontWeight.w600),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              _buildStatusChip(),
                            ],
                          ),
                        ),
                        if (widget.job.customerImageUrl != null)
                          _buildCustomerAvatar(),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Category and location
                    Row(
                      children: [
                        Icon(
                          Icons.category_outlined,
                          size: 16,
                          color: AppTheme.mediumGray,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          widget.job.category,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppTheme.mediumGray),
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
                            widget.job.location,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: AppTheme.mediumGray),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),

                    if (!widget.isCompact) ...[
                      const SizedBox(height: 12),

                      // Description
                      Text(
                        widget.job.description,
                        style: Theme.of(context).textTheme.bodyMedium,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: 12),

                      // Skills
                      if (widget.job.requiredSkills.isNotEmpty)
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children:
                              widget.job.requiredSkills.take(3).map((skill) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppTheme.lightGreen.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: AppTheme.lightGreen,
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    skill,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodySmall?.copyWith(
                                      color: AppTheme.primaryGreen,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                );
                              }).toList(),
                        ),

                      const SizedBox(height: 12),
                    ],

                    // Footer with budget and deadline
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Budget',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: AppTheme.mediumGray),
                              ),
                              Text(
                                widget.job.formattedBudget,
                                style: Theme.of(
                                  context,
                                ).textTheme.titleMedium?.copyWith(
                                  color: AppTheme.primaryGreen,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Deadline',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: AppTheme.mediumGray),
                            ),
                            Text(
                              widget.job.formattedTimeRemaining,
                              style: Theme.of(
                                context,
                              ).textTheme.bodySmall?.copyWith(
                                color:
                                    widget.job.isDeadlinePassed
                                        ? AppTheme.errorColor
                                        : AppTheme.mediumGray,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    // Apply button
                    if (widget.showApplyButton && widget.job.isOpen) ...[
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: widget.onApply,
                          icon: const Icon(Icons.send, size: 18),
                          label: const Text('Apply Now'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: context.accentColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusChip() {
    Color backgroundColor;
    Color textColor;

    switch (widget.job.status) {
      case JobStatus.open:
        backgroundColor = AppTheme.successColor.withValues(alpha: 0.1);
        textColor = AppTheme.successColor;
        break;
      case JobStatus.inProgress:
        backgroundColor = AppTheme.infoColor.withValues(alpha: 0.1);
        textColor = AppTheme.infoColor;
        break;
      case JobStatus.completed:
        backgroundColor = AppTheme.mediumGray.withValues(alpha: 0.1);
        textColor = AppTheme.mediumGray;
        break;
      case JobStatus.cancelled:
        backgroundColor = AppTheme.errorColor.withValues(alpha: 0.1);
        textColor = AppTheme.errorColor;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        widget.job.status.displayName,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: textColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildCustomerAvatar() {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppTheme.lightGray, width: 2),
      ),
      child: ClipOval(
        child: CachedNetworkImage(
          imageUrl: widget.job.customerImageUrl!,
          fit: BoxFit.cover,
          placeholder:
              (context, url) => Container(
                color: AppTheme.lightGray,
                child: const Icon(Icons.person, color: AppTheme.mediumGray),
              ),
          errorWidget:
              (context, url, error) => Container(
                color: AppTheme.lightGray,
                child: const Icon(Icons.person, color: AppTheme.mediumGray),
              ),
        ),
      ),
    );
  }
}

/// Compact job card for list views
class CompactJobCard extends StatelessWidget {
  final JobModel job;
  final VoidCallback? onTap;

  const CompactJobCard({super.key, required this.job, this.onTap});

  @override
  Widget build(BuildContext context) {
    return JobCard(
      job: job,
      onTap: onTap,
      showApplyButton: false,
      isCompact: true,
    );
  }
}



