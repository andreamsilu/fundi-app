import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/feeds_provider.dart';
import '../widgets/fundi_card.dart';
import '../widgets/fundi_feed_filters.dart';
import 'fundi_profile_screen.dart';

class FundiFeedScreen extends StatefulWidget {
  const FundiFeedScreen({Key? key}) : super(key: key);

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
    await context.read<FeedsProvider>().loadFundis(refresh: true);
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
      appBar: AppBar(
        title: const Text('Find Fundis'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilters(),
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    // Try to get the existing provider, if not available create a new one
    try {
      Provider.of<FeedsProvider>(context, listen: false);
      return Consumer<FeedsProvider>(
        builder: (context, feedsProvider, child) =>
            _buildFundiList(feedsProvider),
      );
    } catch (e) {
      // Provider not available, create a new one
      return ChangeNotifierProvider(
        create: (_) => FeedsProvider()..loadFundis(),
        child: Consumer<FeedsProvider>(
          builder: (context, feedsProvider, child) =>
              _buildFundiList(feedsProvider),
        ),
      );
    }
  }

  Widget _buildFundiList(FeedsProvider feedsProvider) {
    if (feedsProvider.isLoadingFundis && feedsProvider.fundis.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (feedsProvider.fundisError != null && feedsProvider.fundis.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              feedsProvider.fundisError!,
              style: const TextStyle(color: Colors.red),
            ),
            ElevatedButton(
              onPressed: () => feedsProvider.loadFundis(refresh: true),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshFeed,
      child: Column(
        children: [
          if (feedsProvider.searchQuery.isNotEmpty ||
              feedsProvider.selectedSkills.isNotEmpty ||
              feedsProvider.minRating != null)
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
            child: ListView.builder(
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
        ],
      ),
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
