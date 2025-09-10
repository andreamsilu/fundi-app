import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/portfolio_model.dart';
import '../services/portfolio_service.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../../shared/widgets/error_widget.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/providers/auth_provider.dart';

/// Portfolio gallery screen showing all portfolio items
/// Allows viewing, filtering, and managing portfolio items
class PortfolioGalleryScreen extends StatefulWidget {
  const PortfolioGalleryScreen({super.key});

  @override
  State<PortfolioGalleryScreen> createState() => _PortfolioGalleryScreenState();
}

class _PortfolioGalleryScreenState extends State<PortfolioGalleryScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  bool _isLoading = false;
  String? _errorMessage;
  List<PortfolioModel> _portfolios = [];
  String _selectedCategory = 'All';
  String _searchQuery = '';

  final List<String> _categories = [
    'All',
    'Plumbing',
    'Electrical',
    'Carpentry',
    'Painting',
    'Cleaning',
    'Gardening',
    'Repair',
    'Installation',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadPortfolios();
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

  Future<void> _loadPortfolios({bool refresh = false}) async {
    if (refresh) {
      setState(() {
        _portfolios.clear();
      });
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await PortfolioService().getPortfolios(
        fundiId: '', // TODO: Get from current user context
        category: _selectedCategory == 'All' ? null : _selectedCategory,
        search: _searchQuery.isEmpty ? null : _searchQuery,
      );

      if (result.success) {
        setState(() {
          _portfolios = result.portfolios;
        });
      } else {
        setState(() {
          _errorMessage = result.message;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load portfolios. Please try again.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _onCategoryChanged(String category) {
    setState(() {
      _selectedCategory = category;
    });
    _loadPortfolios(refresh: true);
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
    _loadPortfolios(refresh: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Portfolio Gallery'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              if (authProvider.isFundi) {
                return IconButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/create-portfolio');
                  },
                  icon: const Icon(Icons.add),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Column(
            children: [
              // Search and Filter Section
              _buildSearchAndFilter(),

              // Content
              Expanded(child: _buildContent()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Search Bar
          TextField(
            onChanged: _onSearchChanged,
            decoration: InputDecoration(
              hintText: 'Search portfolios...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppTheme.mediumGray),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppTheme.mediumGray),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AppTheme.accentGreen,
                  width: 2,
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Category Filter
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = _selectedCategory == category;

                return Container(
                  margin: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        _onCategoryChanged(category);
                      }
                    },
                    selectedColor: context.primaryColor.withValues(alpha: 0.1),
                    checkmarkColor: context.primaryColor,
                    labelStyle: TextStyle(
                      color: isSelected
                          ? context.primaryColor
                          : AppTheme.mediumGray,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: LoadingWidget(message: 'Loading portfolios...', size: 50),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: ErrorBanner(
          message: _errorMessage!,
          onDismiss: () {
            setState(() {
              _errorMessage = null;
            });
          },
        ),
      );
    }

    if (_portfolios.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.work_outline, size: 64, color: AppTheme.mediumGray),
            const SizedBox(height: 16),
            Text(
              'No portfolios found',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(color: AppTheme.mediumGray),
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your search or filters',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppTheme.mediumGray),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _loadPortfolios(refresh: true),
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.8,
        ),
        itemCount: _portfolios.length,
        itemBuilder: (context, index) {
          return _buildPortfolioCard(_portfolios[index]);
        },
      ),
    );
  }

  Widget _buildPortfolioCard(PortfolioModel portfolio) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/portfolio-details',
          arguments: portfolio,
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Expanded(
              flex: 3,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: portfolio.images.isNotEmpty
                    ? Image.network(
                        portfolio.images.first,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return _buildImagePlaceholder();
                        },
                      )
                    : _buildImagePlaceholder(),
              ),
            ),

            // Content
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      portfolio.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.darkGray,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 4),

                    // Category
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: context.primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        portfolio.category,
                        style: TextStyle(
                          color: context.primaryColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                    const Spacer(),

                    // Location and Date
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 12,
                          color: AppTheme.mediumGray,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            portfolio.location ?? 'No location',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: AppTheme.mediumGray),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 4),

                    Text(
                      '${portfolio.createdAt.day}/${portfolio.createdAt.month}/${portfolio.createdAt.year}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.mediumGray,
                      ),
                    ),
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
      width: double.infinity,
      color: AppTheme.lightGray,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.work_outline, size: 32, color: AppTheme.mediumGray),
            const SizedBox(height: 4),
            Text(
              'No Image',
              style: TextStyle(color: AppTheme.mediumGray, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
