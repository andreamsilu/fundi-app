import 'package:flutter/material.dart';
import '../services/feeds_service.dart';
import '../widgets/fundi_card.dart';
import '../widgets/fundi_feed_filters.dart';
import '../models/fundi_model.dart';
import 'fundi_profile_screen.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../../shared/widgets/error_widget.dart';

class FundiFeedScreen extends StatefulWidget {
  final bool showAppBar;

  const FundiFeedScreen({Key? key, this.showAppBar = false}) : super(key: key);

  @override
  State<FundiFeedScreen> createState() => _FundiFeedScreenState();
}

class _FundiFeedScreenState extends State<FundiFeedScreen> {
  final FeedsService _feedsService = FeedsService();
  final ScrollController _scrollController = ScrollController();

  List<FundiModel> _fundis = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasMoreData = true;
  int _currentPage = 1;
  String? _error;

  // Filter parameters
  String _searchQuery = '';
  String? _selectedLocation;
  List<String> _selectedSkills = [];
  double? _minRating;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadFundis();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      _loadMoreFundis();
    }
  }

  Future<void> _loadFundis({bool refresh = false}) async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _error = null;
      if (refresh) {
        _currentPage = 1;
        _fundis.clear();
        _hasMoreData = true;
      }
    });

    try {
      final result = await _feedsService.getFundis(
        page: _currentPage,
        limit: 15,
        searchQuery: _searchQuery.isNotEmpty ? _searchQuery : null,
        location: _selectedLocation,
        skills: _selectedSkills.isNotEmpty ? _selectedSkills : null,
        minRating: _minRating,
      );

      if (result['success']) {
        final fundisData = result['fundis'] as List<dynamic>;
        final newFundis = fundisData.map((json) {
          try {
            // Parse fundi data safely
            final jsonMap = json as Map<String, dynamic>;
            return FundiModel.fromJson(jsonMap);
          } catch (e) {
            print('Error parsing fundi: $e');
            print('Problematic JSON: $json');
            print('Error type: ${e.runtimeType}');
            if (e.toString().contains('bool')) {
              print('Boolean parsing error detected!');
            }
            // Return a default fundi model to prevent crashes
            return FundiModel.empty();
          }
        }).toList();

        setState(() {
          if (refresh) {
            _fundis = newFundis;
          } else {
            _fundis.addAll(newFundis);
          }
          _hasMoreData = newFundis.length == 15;
          _currentPage++;
        });
      } else {
        setState(() {
          _error = result['message'];
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to load fundis: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMoreFundis() async {
    if (_isLoadingMore || !_hasMoreData) return;

    setState(() {
      _isLoadingMore = true;
    });

    await _loadFundis();

    setState(() {
      _isLoadingMore = false;
    });
  }

  Future<void> _refreshFeed() async {
    await _loadFundis(refresh: true);
  }

  void _applyFilters(Map<String, dynamic> filters) {
    setState(() {
      _searchQuery = filters['search'] ?? '';
      _selectedLocation = filters['location'];
      _selectedSkills = List<String>.from(filters['skills'] ?? []);
      _minRating = filters['min_rating'];
    });
    _loadFundis(refresh: true);
  }

  void _navigateToFundiProfile(dynamic fundi) {
    try {
      if (fundi == null) {
        throw Exception('Fundi data is null');
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FundiProfileScreen(fundi: fundi),
        ),
      );
    } catch (e) {
      print('Error navigating to fundi profile: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading fundi profile: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.showAppBar
          ? AppBar(
              title: const Text('Find Fundis'),
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
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
    if (_isLoading && _fundis.isEmpty) {
      return const LoadingWidget();
    }

    if (_error != null && _fundis.isEmpty) {
      return AppErrorWidget(
        message: _error!,
        onRetry: () => _loadFundis(refresh: true),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshFeed,
      child: Column(
        children: [
          if (_searchQuery.isNotEmpty ||
              _selectedLocation != null ||
              _selectedSkills.isNotEmpty ||
              _minRating != null)
            Container(
              padding: const EdgeInsets.all(16),
              child: Wrap(
                spacing: 8,
                children: [
                  if (_searchQuery.isNotEmpty)
                    Chip(
                      label: Text('Search: $_searchQuery'),
                      onDeleted: () {
                        setState(() {
                          _searchQuery = '';
                        });
                        _loadFundis(refresh: true);
                      },
                    ),
                  if (_selectedLocation != null)
                    Chip(
                      label: Text('Location: $_selectedLocation'),
                      onDeleted: () {
                        setState(() {
                          _selectedLocation = null;
                        });
                        _loadFundis(refresh: true);
                      },
                    ),
                  if (_selectedSkills.isNotEmpty)
                    Chip(
                      label: Text('Skills: ${_selectedSkills.length}'),
                      onDeleted: () {
                        setState(() {
                          _selectedSkills.clear();
                        });
                        _loadFundis(refresh: true);
                      },
                    ),
                  if (_minRating != null)
                    Chip(
                      label: Text('Rating: ${_minRating!.toStringAsFixed(1)}+'),
                      onDeleted: () {
                        setState(() {
                          _minRating = null;
                        });
                        _loadFundis(refresh: true);
                      },
                    ),
                ],
              ),
            ),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _fundis.length + (_isLoadingMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _fundis.length) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                final fundi = _fundis[index];
                return FundiCard(
                  fundi: fundi,
                  onTap: () {
                    try {
                      _navigateToFundiProfile(fundi);
                    } catch (e) {
                      print('Error navigating to fundi profile: $e');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Error loading fundi profile: ${e.toString()}',
                          ),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showFilters() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => FundiFeedFilters(
        currentFilters: {
          'search': _searchQuery,
          'location': _selectedLocation,
          'skills': _selectedSkills,
          'min_rating': _minRating,
        },
        onApplyFilters: _applyFilters,
      ),
    );
  }
}
