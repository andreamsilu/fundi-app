import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../../shared/widgets/error_widget.dart';
import '../providers/portfolio_provider.dart';
import '../models/portfolio_model.dart';
import 'portfolio_gallery_screen.dart';
import 'portfolio_creation_screen.dart';

/// Portfolio screen for viewing and managing portfolios
class PortfolioScreen extends StatefulWidget {
  const PortfolioScreen({super.key});

  @override
  State<PortfolioScreen> createState() => _PortfolioScreenState();
}

class _PortfolioScreenState extends State<PortfolioScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

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
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _loadPortfolios() async {
    final portfolioProvider = Provider.of<PortfolioProvider>(
      context,
      listen: false,
    );
    await portfolioProvider.loadPortfolios();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Portfolio'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PortfolioCreationScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Consumer<PortfolioProvider>(
          builder: (context, portfolioProvider, child) {
            if (portfolioProvider.isLoading) {
              return const Center(
                child: LoadingWidget(
                  message: 'Loading portfolios...',
                  size: 50,
                ),
              );
            }

            if (portfolioProvider.errorMessage != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ErrorBanner(
                      message: portfolioProvider.errorMessage!,
                      onDismiss: () {
                        portfolioProvider.clearError();
                      },
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadPortfolios,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            if (portfolioProvider.portfolios.isEmpty) {
              return _buildEmptyState();
            }

            return _buildPortfolioGrid(portfolioProvider.portfolios);
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.work_outline, size: 64, color: AppTheme.mediumGray),
          const SizedBox(height: 16),
          Text(
            'No Portfolio Items',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(color: AppTheme.mediumGray),
          ),
          const SizedBox(height: 8),
          Text(
            'Start building your portfolio by adding your best work',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppTheme.mediumGray),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PortfolioCreationScreen(),
                ),
              );
            },
            icon: const Icon(Icons.add),
            label: const Text('Add Portfolio Item'),
          ),
        ],
      ),
    );
  }

  Widget _buildPortfolioGrid(List<PortfolioModel> portfolios) {
    return RefreshIndicator(
      onRefresh: _loadPortfolios,
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.8,
        ),
        itemCount: portfolios.length,
        itemBuilder: (context, index) {
          final portfolio = portfolios[index];
          return _buildPortfolioCard(portfolio);
        },
      ),
    );
  }

  Widget _buildPortfolioCard(PortfolioModel portfolio) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                PortfolioGalleryScreen(portfolioId: portfolio.id),
          ),
        );
      },
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Portfolio Image
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                  image: portfolio.images.isNotEmpty
                      ? DecorationImage(
                          image: NetworkImage(portfolio.images.first),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: portfolio.images.isEmpty
                    ? Container(
                        decoration: BoxDecoration(
                          color: AppTheme.lightGray,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(12),
                          ),
                        ),
                        child: const Icon(
                          Icons.image,
                          size: 40,
                          color: AppTheme.mediumGray,
                        ),
                      )
                    : null,
              ),
            ),
            // Portfolio Info
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      portfolio.title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      portfolio.description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.mediumGray,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Icon(
                          Icons.visibility,
                          size: 14,
                          color: AppTheme.mediumGray,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${portfolio.metadata?['views'] ?? 0} views',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppTheme.mediumGray),
                        ),
                        const Spacer(),
                        if (portfolio.images.length > 1)
                          Icon(
                            Icons.photo_library,
                            size: 14,
                            color: AppTheme.mediumGray,
                          ),
                      ],
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
}
