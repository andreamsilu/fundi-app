import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_theme.dart';

/// Animated card widget with smooth hover and tap effects
/// Provides consistent card styling with animations across the app
class AnimatedCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;
  final double? elevation;
  final BorderRadius? borderRadius;
  final Duration animationDuration;
  final bool enableHoverEffect;
  final bool enableTapEffect;

  const AnimatedCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.elevation,
    this.borderRadius,
    this.animationDuration = const Duration(milliseconds: 200),
    this.enableHoverEffect = true,
    this.enableTapEffect = true,
  });

  @override
  State<AnimatedCard> createState() => _AnimatedCardState();
}

class _AnimatedCardState extends State<AnimatedCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;
  late Animation<Color?> _colorAnimation;

  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _elevationAnimation =
        Tween<double>(
          begin: widget.elevation ?? 2.0,
          end: (widget.elevation ?? 2.0) + 4.0,
        ).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeInOut,
          ),
        );

    _colorAnimation =
        ColorTween(
          begin: widget.backgroundColor ?? AppTheme.white,
          end: AppTheme.lightGreen.withValues(alpha: 0.1),
        ).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeInOut,
          ),
        );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (widget.enableTapEffect && widget.onTap != null) {
      setState(() {
        _isPressed = true;
      });
    }
  }

  void _onTapUp(TapUpDetails details) {
    if (widget.enableTapEffect && widget.onTap != null) {
      setState(() {
        _isPressed = false;
      });
    }
  }

  void _onTapCancel() {
    if (widget.enableTapEffect && widget.onTap != null) {
      setState(() {
        _isPressed = false;
      });
    }
  }

  void _onHoverEnter(PointerEnterEvent event) {
    if (widget.enableHoverEffect) {
      setState(() {
      });
      _animationController.forward();
    }
  }

  void _onHoverExit(PointerExitEvent event) {
    if (widget.enableHoverEffect) {
      setState(() {
      });
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: _onHoverEnter,
      onExit: _onHoverExit,
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Transform.scale(
              scale: _isPressed ? 0.98 : _scaleAnimation.value,
              child: Container(
                margin: widget.margin ?? const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _colorAnimation.value,
                  borderRadius:
                      widget.borderRadius ?? BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: _elevationAnimation.value * 2,
                      offset: Offset(0, _elevationAnimation.value),
                    ),
                  ],
                ),
                child: Padding(
                  padding: widget.padding ?? const EdgeInsets.all(16),
                  child: widget.child,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Specialized job card with job-specific styling
class JobCard extends StatelessWidget {
  final String title;
  final String description;
  final String location;
  final double budget;
  final String budgetType;
  final String category;
  final String status;
  final String? imageUrl;
  final VoidCallback? onTap;
  final VoidCallback? onApply;
  final bool showApplyButton;
  final bool isMyJob;

  const JobCard({
    super.key,
    required this.title,
    required this.description,
    required this.location,
    required this.budget,
    required this.budgetType,
    required this.category,
    required this.status,
    this.imageUrl,
    this.onTap,
    this.onApply,
    this.showApplyButton = false,
    this.isMyJob = false,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with image and status
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Job image
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: AppTheme.lightGray,
                ),
                child: imageUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.work_outline,
                              color: AppTheme.mediumGray,
                              size: 32,
                            );
                          },
                        ),
                      )
                    : Icon(
                        Icons.work_outline,
                        color: AppTheme.mediumGray,
                        size: 32,
                      ),
              ),
              const SizedBox(width: 12),
              // Title and status
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    _buildStatusChip(context, status),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Description
          Text(
            description,
            style: Theme.of(context).textTheme.bodyMedium,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          // Location and budget
          Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                size: 16,
                color: AppTheme.mediumGray,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  location,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              Text(
                '${_formatBudget(budget)} $budgetType',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppTheme.primaryGreen,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Category and action button
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.lightGreen.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  category,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.primaryGreen,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const Spacer(),
              if (showApplyButton && !isMyJob)
                ElevatedButton(
                  onPressed: onApply,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accentGreen,
                    foregroundColor: AppTheme.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Apply'),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context, String status) {
    Color backgroundColor;
    Color textColor;

    switch (status.toLowerCase()) {
      case 'pending':
        backgroundColor = AppTheme.warningColor.withValues(alpha: 0.2);
        textColor = AppTheme.warningColor;
        break;
      case 'in progress':
        backgroundColor = AppTheme.infoColor.withValues(alpha: 0.2);
        textColor = AppTheme.infoColor;
        break;
      case 'completed':
        backgroundColor = AppTheme.successColor.withValues(alpha: 0.2);
        textColor = AppTheme.successColor;
        break;
      case 'rejected':
        backgroundColor = AppTheme.errorColor.withValues(alpha: 0.2);
        textColor = AppTheme.errorColor;
        break;
      default:
        backgroundColor = AppTheme.mediumGray.withValues(alpha: 0.2);
        textColor = AppTheme.mediumGray;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.toUpperCase(),
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: textColor,
          fontWeight: FontWeight.w600,
          fontSize: 10,
        ),
      ),
    );
  }

  String _formatBudget(double budget) {
    if (budget >= 1000000) {
      return '${(budget / 1000000).toStringAsFixed(1)}M';
    } else if (budget >= 1000) {
      return '${(budget / 1000).toStringAsFixed(1)}K';
    } else {
      return budget.toStringAsFixed(0);
    }
  }
}
