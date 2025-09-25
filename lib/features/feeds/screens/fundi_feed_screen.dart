import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/feeds_provider.dart';
import '../widgets/fundi_card.dart';
import '../widgets/fundi_feed_filters.dart';
import 'fundi_profile_screen.dart';

class FundiFeedScreen extends StatefulWidget {
  final bool showAppBar;

  const FundiFeedScreen({Key? key, this.showAppBar = false}) : super(key: key);

  @override
  State<FundiFeedScreen> createState() => _FundiFeedScreenState();
}

class _FundiFeedScreenState extends State<FundiFeedScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    // Initialize feeds data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        final feedsProvider = Provider.of<FeedsProvider>(
          context,
          listen: false,
        );
        feedsProvider.loadFundis();
      } catch (e) {
        print('FeedsProvider not available, creating new instance: $e');
        // If provider is not available, we'll handle it in the build method
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      context.read<FeedsProvider>().loadMoreFundis();
    }
  }

  Future<void> _refreshFeed() async {
    try {
      final provider = Provider.of<FeedsProvider>(context, listen: false);
      await provider.loadFundis(refresh: true);
    } catch (_) {
      // Provider not found at this context; ignore to avoid crash
    }
  }

  void _applyFilters(Map<String, dynamic> filters) {
    final provider = context.read<FeedsProvider>();

    // Update filters in provider
    provider.updateSearchQuery(filters['search'] ?? '');
    provider.updateLocation(filters['location']);
    provider.updateSkills(filters['skills'] ?? []);
    provider.updateMinRating(filters['min_rating']);

    // Apply filters and reload data
    provider.applyFilters();
  }

  void _navigateToFundiProfile(dynamic fundi) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => FundiProfileScreen(fundi: fundi)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.showAppBar
          ? AppBar(
              title: const Text('Find Fundis'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.filter_list),
                  onPressed: () => _showFilters(),
                ),
              ],
            )
          : null,
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    // Try to get the existing provider, if not available create a new one
    try {
      Provider.of<FeedsProvider>(context, listen: false);
      return Selector<FeedsProvider, ({List<dynamic> fundis, bool isLoading, bool isLoadingMore, String? error})>(
        selector: (context, provider) => (
          fundis: provider.fundis,
          isLoading: provider.isLoadingFundis,
          isLoadingMore: provider.isLoadingMoreFundis,
          error: provider.fundisError,
        ),
        builder: (context, data, child) => _buildFundiList(data),
      );
    } catch (e) {
      // Provider not available, create a new one
      return ChangeNotifierProvider(
        create: (_) => FeedsProvider()..loadFundis(),
        child: Selector<FeedsProvider, ({List<dynamic> fundis, bool isLoading, bool isLoadingMore, String? error})>(
          selector: (context, provider) => (
            fundis: provider.fundis,
            isLoading: provider.isLoadingFundis,
            isLoadingMore: provider.isLoadingMoreFundis,
            error: provider.fundisError,
          ),
          builder: (context, data, child) => _buildFundiList(data),
        ),
      );
    }
  }

  Widget _buildFundiList(({List<dynamic> fundis, bool isLoading, bool isLoadingMore, String? error}) data) {
    if (data.isLoading && data.fundis.isEmpty) {
      // Show shimmer list while loading
      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 8,
        itemBuilder: (context, index) => const Padding(
          padding: EdgeInsets.only(bottom: 12),
          child: ShimmerJobCard(),
        ),
      );
    }

    // If there's an error and no data, show the error explicitly
    if (data.error != null && data.fundis.isEmpty) {
      return RefreshIndicator(
        onRefresh: () {
          final provider = Provider.of<FeedsProvider>(context, listen: false);
          provider.loadFundis(refresh: true);
        },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24),
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, color: Colors.red[400], size: 42),
                const SizedBox(height: 12),
                Text(
                  data.error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red, fontSize: 14),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    final provider = Provider.of<FeedsProvider>(context, listen: false);
                    provider.loadFundis(refresh: true);
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          ],
        ),
      );
    }

    // If no error but list is empty after load, show friendly empty state
    if (!data.isLoading && data.fundis.isEmpty) {
      return RefreshIndicator(
        onRefresh: () {
          final provider = Provider.of<FeedsProvider>(context, listen: false);
          provider.loadFundis(refresh: true);
        },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24),
          children: const [
            SizedBox(height: 80),
            Icon(Icons.handyman_outlined, size: 42, color: Colors.grey),
            SizedBox(height: 12),
            Text(
              'No fundis found. Try adjusting filters or pull to refresh.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Note: Filter chips would need provider access for searchQuery, selectedSkills, etc.
        // For now, keeping this section as-is since it requires provider methods
          Container(
            padding: const EdgeInsets.all(16),
            child: Wrap(
              spacing: 8,
              children: [
                if (feedsProvider.searchQuery.isNotEmpty)
                  Chip(
                    label: Text('Search: ${feedsProvider.searchQuery}'),
                    onDeleted: () {
                      feedsProvider.updateSearchQuery('');
                      feedsProvider.applyFilters();
                    },
                  ),
                if (feedsProvider.selectedSkills.isNotEmpty)
                  Chip(
                    label: Text(
                      'Skills: ${feedsProvider.selectedSkills.length}',
                    ),
                    onDeleted: () {
                      feedsProvider.updateSkills([]);
                      feedsProvider.applyFilters();
                    },
                  ),
                if (feedsProvider.minRating != null)
                  Chip(
                    label: Text('Rating: ${feedsProvider.minRating!}+'),
                    onDeleted: () {
                      feedsProvider.updateMinRating(null);
                      feedsProvider.applyFilters();
                    },
                  ),
              ],
            ),
          ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => feedsProvider.loadFundis(refresh: true),
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount:
                  feedsProvider.fundis.length +
                  (feedsProvider.isLoadingMoreFundis ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == feedsProvider.fundis.length) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                final fundi = feedsProvider.fundis[index];
                return FundiCard(
                  fundi: fundi,
                  onTap: () => _navigateToFundiProfile(fundi),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  void _showFilters() {
    try {
      final feedsProvider = context.read<FeedsProvider>();
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (context) => FundiFeedFilters(
          currentFilters: {
            'search': feedsProvider.searchQuery,
            'location': feedsProvider.selectedLocation,
            'skills': feedsProvider.selectedSkills,
            'min_rating': feedsProvider.minRating,
          },
          onApplyFilters: _applyFilters,
        ),
      );
    } catch (e) {
      // Provider not available, show error
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Filters not available at the moment'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
