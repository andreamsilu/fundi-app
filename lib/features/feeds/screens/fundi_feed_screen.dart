import 'package:flutter/material.dart';
import '../services/feeds_service.dart';
import '../widgets/fundi_card.dart';
import '../widgets/enhanced_fundi_filters.dart';
import '../widgets/autocomplete_search_field.dart';
import '../models/fundi_model.dart';
import '../../auth/services/auth_service.dart';
import 'comprehensive_fundi_profile_screen.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../../shared/widgets/error_widget.dart';
import '../../../core/utils/payment_gate_helper.dart';

class FundiFeedScreen extends StatefulWidget {
  final bool showAppBar;
  final String? initialSearch;

  const FundiFeedScreen({Key? key, this.showAppBar = false, this.initialSearch})
    : super(key: key);

  @override
  State<FundiFeedScreen> createState() => _FundiFeedScreenState();
}

class _FundiFeedScreenState extends State<FundiFeedScreen> {
  final FeedsService _feedsService = FeedsService();
  final ScrollController _scrollController = ScrollController();

  List<dynamic> _fundis =
      []; // Keep as raw Map to preserve all API fields (profession, stats, badges)
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasMoreData = true;
  int _currentPage = 1;
  String? _error;

  // Filter parameters
  String _searchQuery = '';
  String? _selectedLocation;
  String? _selectedCategory;
  List<String> _selectedSkills = [];
  double? _minRating;
  bool? _isAvailable;
  bool? _isVerified;

  // Advanced filter parameters
  double? _minHourlyRate;
  double? _maxHourlyRate;
  int? _minExperience;
  String _sortBy = 'created_at';
  String _sortOrder = 'desc';

  // Recent searches for autocomplete
  List<String> _recentSearches = [];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    // Set initial search query if provided
    if (widget.initialSearch != null && widget.initialSearch!.isNotEmpty) {
      _searchQuery = widget.initialSearch!;
    }

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

    print('FundiFeedScreen: _loadFundis called with refresh=$refresh');
    print(
      'FundiFeedScreen: Current page: $_currentPage, Current fundis count: ${_fundis.length}',
    );

    // Check if user is authenticated using AuthService directly
    try {
      final authService = AuthService();
      final isAuthenticated = authService.isAuthenticated;
      print('FundiFeedScreen: User authenticated: $isAuthenticated');
      if (!isAuthenticated) {
        print('FundiFeedScreen: User not authenticated, cannot load fundis');
        setState(() {
          _error = 'Please log in to view fundis';
          _isLoading = false;
        });
        return;
      }
    } catch (e) {
      print('FundiFeedScreen: Error checking authentication: $e');
      setState(() {
        _error = 'Authentication error. Please log in again.';
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
      if (refresh) {
        _currentPage = 1;
        _fundis.clear();
        _hasMoreData = true;
        print('FundiFeedScreen: Refresh mode - cleared fundis list');
      }
    });

    try {
      print('FundiFeedScreen: Calling API with page=$_currentPage');
      final result = await _feedsService.getFundis(
        page: _currentPage,
        limit: 15,
        searchQuery: _searchQuery.isNotEmpty ? _searchQuery : null,
        location: _selectedLocation,
        category: _selectedCategory,
        skills: _selectedSkills.isNotEmpty ? _selectedSkills : null,
        minRating: _minRating,
        isAvailable: _isAvailable,
        isVerified: _isVerified,
        minHourlyRate: _minHourlyRate,
        maxHourlyRate: _maxHourlyRate,
        minExperience: _minExperience,
        sortBy: _sortBy,
        sortOrder: _sortOrder,
        useCache: false, // Temporarily disable cache to test
      );

      print('FundiFeedScreen: Full API response: $result');
      print('FundiFeedScreen: API response success: ${result['success']}');
      print('FundiFeedScreen: API response message: ${result['message']}');
      print(
        'FundiFeedScreen: API response fundis count: ${result['fundis']?.length ?? 'null'}',
      );

      if (result['success'] == true) {
        final fundisData = result['fundis'] as List<dynamic>;
        print('FundiFeedScreen: Received ${fundisData.length} fundis from API');

        // Keep raw Map data to preserve profession, stats, badges from API
        final newFundis = fundisData.map((json) {
          return json as Map<String, dynamic>;
        }).toList();

        print(
          'FundiFeedScreen: Parsed ${newFundis.length} fundis successfully',
        );

        setState(() {
          if (refresh) {
            _fundis = newFundis;
            print(
              'FundiFeedScreen: Refresh mode - set _fundis to ${newFundis.length} items',
            );
          } else {
            _fundis.addAll(newFundis);
            print(
              'FundiFeedScreen: Load more - added ${newFundis.length} items, total: ${_fundis.length}',
            );
          }
          _hasMoreData = newFundis.length == 15;
          _currentPage++;
          print(
            'FundiFeedScreen: Updated _hasMoreData: $_hasMoreData, _currentPage: $_currentPage',
          );
        });
      } else {
        print('FundiFeedScreen: API returned error: ${result['message']}');
        setState(() {
          _error = result['message'];
        });
      }
    } catch (e) {
      print('FundiFeedScreen: Exception occurred: $e');
      setState(() {
        _error = 'Failed to load fundis: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
      print(
        'FundiFeedScreen: _loadFundis completed. Final fundis count: ${_fundis.length}',
      );
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
    print('FundiFeedScreen: _refreshFeed called');
    await _loadFundis(refresh: true);
  }

  void _applyFilters(Map<String, dynamic> filters) {
    setState(() {
      _searchQuery = filters['search'] ?? '';
      _selectedLocation = filters['location'];
      _selectedCategory = filters['category'];
      _selectedSkills = List<String>.from(filters['skills'] ?? []);
      _minRating = filters['min_rating'];
      _isAvailable = filters['is_available'];
      _isVerified = filters['is_verified'];

      // Advanced filters
      _minHourlyRate = filters['min_hourly_rate'];
      _maxHourlyRate = filters['max_hourly_rate'];
      _minExperience = filters['min_experience'];
      _sortBy = filters['sort_by'] ?? 'created_at';
      _sortOrder = filters['sort_order'] ?? 'desc';
    });

    // Add to recent searches
    if (_searchQuery.isNotEmpty && !_recentSearches.contains(_searchQuery)) {
      _recentSearches.insert(0, _searchQuery);
      if (_recentSearches.length > 5) {
        _recentSearches = _recentSearches.take(5).toList();
      }
    }

    _loadFundis(refresh: true);
  }

  void _navigateToFundiProfile(dynamic fundi) async {
    try {
      if (fundi == null) {
        throw Exception('Fundi data is null');
      }

      // Check if user can view fundi profiles (payment gate)
      final canView = await PaymentGateHelper.canViewFundiProfiles(context);
      
      if (!canView) {
        print('FundiFeedScreen: Payment required for viewing fundi profiles');
        return;
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ComprehensiveFundiProfileScreen(fundi: fundi),
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
    print(
      'FundiFeedScreen: Building widget - isLoading: $_isLoading, fundis count: ${_fundis.length}, error: $_error',
    );

    return Scaffold(
      appBar: widget.showAppBar
          ? AppBar(
              title: const Text('Find Fundis'),
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              iconTheme: const IconThemeData(color: Colors.white),
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
    print(
      'FundiFeedScreen: _buildBody - isLoading: $_isLoading, fundis count: ${_fundis.length}, error: $_error',
    );

    if (_isLoading && _fundis.isEmpty) {
      print('FundiFeedScreen: Showing loading widget');
      return const LoadingWidget(message: 'Loading fundis...');
    }

    if (_error != null && _fundis.isEmpty) {
      print('FundiFeedScreen: Showing error widget with message: $_error');
      return AppErrorWidget(
        message: _error!,
        onRetry: () => _loadFundis(refresh: true),
      );
    }

    // Show empty state if no fundis and not loading
    if (_fundis.isEmpty && !_isLoading) {
      print('FundiFeedScreen: Showing empty state');
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No fundis found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your search or filters',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _loadFundis(refresh: true),
              child: const Text('Refresh'),
            ),
          ],
        ),
      );
    }

    print(
      'FundiFeedScreen: Showing main content with ${_fundis.length} fundis',
    );

    return RefreshIndicator(
      onRefresh: _refreshFeed,
      child: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            child: AutocompleteSearchField(
              hintText: 'Search fundis by name, skills, or location',
              initialValue: _searchQuery,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
                if (value.isEmpty) {
                  _loadFundis(refresh: true);
                }
              },
              onSubmitted: (value) {
                if (value.isNotEmpty) {
                  _loadFundis(refresh: true);
                }
              },
              recentSearches: _recentSearches,
              onSuggestionSelected: (suggestion) {
                setState(() {
                  _searchQuery = suggestion;
                });
                _loadFundis(refresh: true);
              },
            ),
          ),

          // Active Filters
          if (_searchQuery.isNotEmpty ||
              _selectedLocation != null ||
              _selectedSkills.isNotEmpty ||
              _minRating != null ||
              _isAvailable != null ||
              _isVerified != null)
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
                  if (_isAvailable == true)
                    Chip(
                      label: const Text('Available'),
                      onDeleted: () {
                        setState(() {
                          _isAvailable = null;
                        });
                        _loadFundis(refresh: true);
                      },
                    ),
                  if (_isVerified == true)
                    Chip(
                      label: const Text('Verified'),
                      onDeleted: () {
                        setState(() {
                          _isVerified = null;
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
      builder: (context) => EnhancedFundiFilters(
        currentFilters: {
          'search': _searchQuery,
          'location': _selectedLocation,
          'category': _selectedCategory,
          'skills': _selectedSkills,
          'min_rating': _minRating,
          'is_available': _isAvailable,
          'is_verified': _isVerified,
          'hourly_rate_range': _minHourlyRate != null && _maxHourlyRate != null
              ? RangeValues(_minHourlyRate!, _maxHourlyRate!)
              : null,
          'min_experience': _minExperience,
          'sort_by': _sortBy,
          'sort_order': _sortOrder,
        },
        onApplyFilters: _applyFilters,
        recentSearches: _recentSearches,
      ),
    );
  }
}
