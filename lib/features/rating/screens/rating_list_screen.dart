import 'package:flutter/material.dart';
import 'package:fundi/features/rating/screens/rating_form_screen.dart';
import 'package:fundi/features/rating/models/rating_model.dart';
import 'package:provider/provider.dart';
import '../providers/rating_provider.dart';
import '../widgets/star_rating_widget.dart';

/// Rating list screen showing fundi's ratings and reviews
class RatingListScreen extends StatefulWidget {
  final String fundiId;
  final String fundiName;
  final String? fundiImageUrl;

  const RatingListScreen({
    super.key,
    required this.fundiId,
    required this.fundiName,
    this.fundiImageUrl,
  });

  @override
  State<RatingListScreen> createState() => _RatingListScreenState();
}

class _RatingListScreenState extends State<RatingListScreen> {
  final ScrollController _scrollController = ScrollController();
  int _currentPage = 1;
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RatingProvider>().loadFundiRatings(fundiId: widget.fundiId);
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
      _loadMoreRatings();
    }
  }

  Future<void> _loadMoreRatings() async {
    if (_isLoadingMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    _currentPage++;
    await context.read<RatingProvider>().loadFundiRatings(
      fundiId: widget.fundiId,
      page: _currentPage,
    );

    setState(() {
      _isLoadingMore = false;
    });
  }

  Future<void> _refreshRatings() async {
    _currentPage = 1;
    await context.read<RatingProvider>().refreshFundiRatings(widget.fundiId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.fundiName} - Ratings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshRatings,
          ),
        ],
      ),
      body: Consumer<RatingProvider>(
        builder: (context, ratingProvider, child) {
          if (ratingProvider.isLoading && ratingProvider.fundiRatingSummary == null) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (ratingProvider.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    ratingProvider.errorMessage!,
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      ratingProvider.clearError();
                      _refreshRatings();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final summary = ratingProvider.fundiRatingSummary;
          if (summary == null) {
            return const Center(
              child: Text('No rating data available'),
            );
          }

          return RefreshIndicator(
            onRefresh: _refreshRatings,
            child: Column(
              children: [
                // Rating summary
                RatingSummaryWidget(
                  averageRating: summary.averageRating,
                  totalRatings: summary.totalRatings,
                ),
                
                // Ratings list
                Expanded(
                  child: summary.recentRatings.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(16),
                          itemCount: summary.recentRatings.length + (_isLoadingMore ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index == summary.recentRatings.length) {
                              return const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(16),
                                  child: CircularProgressIndicator(),
                                  ),
                              );
                            }

                            final rating = summary.recentRatings[index].toJson() ?? {};
                            return RatingCard(
                              rating: rating,
                              showJobTitle: true,
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.star_outline,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No ratings yet',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'This fundi hasn\'t received any ratings yet',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// My ratings screen showing user's given ratings
class MyRatingsScreen extends StatefulWidget {
  const MyRatingsScreen({super.key});

  @override
  State<MyRatingsScreen> createState() => _MyRatingsScreenState();
}

class _MyRatingsScreenState extends State<MyRatingsScreen> {
  final ScrollController _scrollController = ScrollController();
  int _currentPage = 1;
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RatingProvider>().loadMyRatings();
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
      _loadMoreRatings();
    }
  }

  Future<void> _loadMoreRatings() async {
    if (_isLoadingMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    _currentPage++;
    await context.read<RatingProvider>().loadMyRatings(page: _currentPage);

    setState(() {
      _isLoadingMore = false;
    });
  }

  Future<void> _refreshRatings() async {
    _currentPage = 1;
    await context.read<RatingProvider>().refreshMyRatings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Ratings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshRatings,
          ),
        ],
      ),
      body: Consumer<RatingProvider>(
        builder: (context, ratingProvider, child) {
          if (ratingProvider.isLoading && ratingProvider.myRatings.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (ratingProvider.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    ratingProvider.errorMessage!,
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      ratingProvider.clearError();
                      _refreshRatings();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (ratingProvider.myRatings.isEmpty) {
            return _buildEmptyState();
          }

          return RefreshIndicator(
            onRefresh: _refreshRatings,
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: ratingProvider.myRatings.length + (_isLoadingMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == ratingProvider.myRatings.length) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                final rating = ratingProvider.myRatings[index].toJson() ?? {};
                return RatingCard(
                  rating: rating,
                  showJobTitle: true,
                  onTap: () => _editRating(context, rating),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.star_outline,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No ratings given',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'You haven\'t rated any fundis yet',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _editRating(BuildContext context, Map<String, dynamic> rating) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RatingFormScreen(
            fundiId: rating['fundiId'] ?? '',
          fundiName: rating['fundiName'] ?? '',
          fundiImageUrl: rating['fundiImageUrl'] ?? '',
          jobId: rating['jobId'] ?? '',
          jobTitle: rating['jobTitle'] ?? '',
          existingRating: RatingModel.fromJson(rating),
          ),
      ),
    ).then((success) {
      if (success == true) {
        _refreshRatings();
      }
    });
  }
}
