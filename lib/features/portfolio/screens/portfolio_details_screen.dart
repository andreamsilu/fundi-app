import 'package:flutter/material.dart';
import '../models/portfolio_model.dart';
import '../services/portfolio_service.dart';
import '../../../shared/widgets/button_widget.dart';
import '../../../shared/widgets/error_widget.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/services/auth_service.dart';

/// Portfolio details screen showing comprehensive portfolio information
/// Displays images, videos, and project details
class PortfolioDetailsScreen extends StatefulWidget {
  final PortfolioModel portfolio;

  const PortfolioDetailsScreen({super.key, required this.portfolio});

  @override
  State<PortfolioDetailsScreen> createState() => _PortfolioDetailsScreenState();
}

class _PortfolioDetailsScreenState extends State<PortfolioDetailsScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  String? _errorMessage;
  int _currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: CustomScrollView(
            slivers: [
              // App Bar with Portfolio Image
              _buildSliverAppBar(),

              // Portfolio Content
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Error Message
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

                      // Portfolio Header
                      _buildPortfolioHeader(),

                      const SizedBox(height: 24),

                      // Portfolio Details
                      _buildPortfolioDetails(),

                      const SizedBox(height: 24),

                      // Fundi Information
                      _buildFundiInfo(),

                      const SizedBox(height: 24),

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

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      backgroundColor: context.primaryColor,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          widget.portfolio.title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Portfolio Image or Placeholder
            if (widget.portfolio.images.isNotEmpty)
              PageView.builder(
                onPageChanged: (index) {
                  setState(() {
                    _currentImageIndex = index;
                  });
                },
                itemCount: widget.portfolio.images.length,
                itemBuilder: (context, index) {
                  return Image.network(
                    widget.portfolio.images[index],
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return _buildImagePlaceholder();
                    },
                  );
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

            // Image Indicators
            if (widget.portfolio.images.length > 1)
              Positioned(
                bottom: 16,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    widget.portfolio.images.length,
                    (index) => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _currentImageIndex == index
                            ? Colors.white
                            : Colors.white.withValues(alpha: 0.5),
                        shape: BoxShape.circle,
                      ),
                    ),
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

  Widget _buildPortfolioHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                widget.portfolio.title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.darkGray,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: context.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: context.primaryColor.withValues(alpha: 0.3),
                ),
              ),
              child: Text(
                widget.portfolio.category,
                style: TextStyle(
                  color: context.primaryColor,
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
            Icon(
              Icons.location_on_outlined,
              size: 16,
              color: AppTheme.mediumGray,
            ),
            const SizedBox(width: 4),
            Text(
              widget.portfolio.location ?? '',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppTheme.mediumGray),
            ),
            const SizedBox(width: 16),
            Icon(Icons.calendar_today, size: 16, color: AppTheme.mediumGray),
            const SizedBox(width: 4),
            Text(
              '${widget.portfolio.createdAt?.day ?? 0}/${widget.portfolio.createdAt?.month ?? 0}/${widget.portfolio.createdAt?.year ?? 0}',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppTheme.mediumGray),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPortfolioDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Project Details',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.darkGray,
          ),
        ),
        const SizedBox(height: 16),

        // Description
        _buildDetailItem(
          'Description',
          widget.portfolio.description,
          Icons.description_outlined,
        ),

        const SizedBox(height: 16),

        // Media Count
        _buildDetailItem(
          'Media',
          '${widget.portfolio.images.length} photos',
          Icons.photo_library_outlined,
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

  Widget _buildFundiInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Fundi Information',
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
                  widget.portfolio.fundiName?.substring(0, 1).toUpperCase() ??
                      'F',
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
                      widget.portfolio.fundiName ?? 'Unknown Fundi',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.darkGray,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Fundi',
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
    // Use AuthService directly instead of Provider
    final authService = AuthService();
    final user = authService.currentUser;
    final isFundi = authService.currentUser?.isFundi ?? false;

    if (isFundi && user?.id == widget.portfolio.fundiId) {
      // Portfolio owner actions
      return Column(
        children: [
          AppButton(
            text: 'Edit Portfolio',
            onPressed: () {
              _showEditDialog();
            },
            type: ButtonType.secondary,
            isFullWidth: true,
            icon: Icons.edit,
          ),
          const SizedBox(height: 12),
          AppButton(
            text: 'Delete Portfolio',
            onPressed: () {
              _showDeleteConfirmation();
            },
            type: ButtonType.danger,
            isFullWidth: true,
            icon: Icons.delete,
          ),
        ],
      );
    } else {
      // Other user actions
      return Column(
        children: [
          AppButton(
            text: 'Contact Fundi',
            onPressed: () {
              // TODO: Navigate to chat with fundi
            },
            isFullWidth: true,
            icon: Icons.message,
          ),
          const SizedBox(height: 12),
          AppButton(
            text: 'View More Work',
            onPressed: () {
              // Navigate to fundi's profile (portfolio is part of profile)
              Navigator.pushNamed(
                context,
                '/profile',
                arguments: {'userId': widget.portfolio.fundiId},
              );
            },
            type: ButtonType.secondary,
            isFullWidth: true,
            icon: Icons.work_outline,
          ),
        ],
      );
    }
  }

  void _showEditDialog() {
    final TextEditingController titleController = TextEditingController(
      text: widget.portfolio.title,
    );
    final TextEditingController descriptionController = TextEditingController(
      text: widget.portfolio.description,
    );
    final TextEditingController budgetController = TextEditingController(
      text: widget.portfolio.budget?.toString() ?? '',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Portfolio'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
                maxLines: 1,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: budgetController,
                decoration: const InputDecoration(
                  labelText: 'Budget (TZS)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _updatePortfolio(
                title: titleController.text,
                description: descriptionController.text,
                budget: double.tryParse(budgetController.text),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _updatePortfolio({
    required String title,
    required String description,
    double? budget,
  }) async {
    if (title.isEmpty || description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Title and description are required'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _errorMessage = null;
    });

    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      // Update portfolio via API
      final portfolioService = PortfolioService();
      final result = await portfolioService.updatePortfolio(
        portfolioId: widget.portfolio.id.toString(),
        title: title,
        description: description,
        skills: widget.portfolio.skillsUsed,
        budget: budget,
        durationDays: widget.portfolio.durationHours > 0
            ? (widget.portfolio.durationHours / 24).ceil()
            : null,
      );

      // Close loading indicator
      if (mounted) {
        Navigator.pop(context);
      }

      if (result.success && result.portfolio != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Portfolio updated successfully'),
              backgroundColor: Colors.green,
            ),
          );
          // Refresh the screen with updated data
          setState(() {
            // Update widget.portfolio would require making it mutable
            // For now, just show success - user can navigate back and refresh
          });
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

      setState(() {
        _errorMessage = 'Failed to update portfolio. Please try again.';
      });

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

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Portfolio'),
        content: const Text(
          'Are you sure you want to delete this portfolio? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deletePortfolio();
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _deletePortfolio() async {
    setState(() {
      _errorMessage = null;
    });

    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      // Delete portfolio via API
      final portfolioService = PortfolioService();
      final result = await portfolioService.deletePortfolio(
        widget.portfolio.id.toString(),
      );

      // Close loading indicator
      if (mounted) {
        Navigator.pop(context);
      }

      if (result.success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Portfolio deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
          // Navigate back to portfolio list
          Navigator.pop(context, true); // Return true to indicate deletion
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

      setState(() {
        _errorMessage = 'Failed to delete portfolio. Please try again.';
      });

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
}
