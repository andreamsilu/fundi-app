import 'package:flutter/material.dart';
import '../../features/portfolio/models/portfolio_model.dart';
import '../../features/portfolio/services/portfolio_service.dart';
import '../utils/logger.dart';

/// Portfolio provider for state management
/// Handles portfolio-related state and operations
class PortfolioProvider extends ChangeNotifier {
  final PortfolioService _portfolioService = PortfolioService();

  List<PortfolioModel> _portfolios = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _errorMessage;
  int _currentPage = 1;
  int _totalPages = 1;
  String? _searchQuery;
  String? _selectedCategory;
  String? _fundiId;

  /// Get portfolios list
  List<PortfolioModel> get portfolios => _portfolios;

  /// Check if loading
  bool get isLoading => _isLoading;

  /// Check if loading more
  bool get isLoadingMore => _isLoadingMore;

  /// Get error message
  String? get errorMessage => _errorMessage;

  /// Get current page
  int get currentPage => _currentPage;

  /// Get total pages
  int get totalPages => _totalPages;

  /// Get search query
  String? get searchQuery => _searchQuery;

  /// Get selected category
  String? get selectedCategory => _selectedCategory;

  /// Get fundi ID
  String? get fundiId => _fundiId;

  /// Load portfolios with filters
  Future<void> loadPortfolios({
    bool refresh = false,
    String? fundiId,
    String? search,
    String? category,
  }) async {
    if (refresh) {
      _currentPage = 1;
      _portfolios.clear();
    }

    _setLoading(true);
    _clearError();

    try {
      final result = await _portfolioService.getPortfolios(
        fundiId: fundiId ?? _fundiId ?? '',
        page: _currentPage,
        category: category,
        search: search,
      );

      if (result.success) {
        if (refresh) {
          _portfolios = result.portfolios;
        } else {
          _portfolios.addAll(result.portfolios);
        }
        _totalPages = result.totalPages;
        _searchQuery = search;
        _selectedCategory = category;
        _fundiId = fundiId;

        Logger.info(
          'Portfolios loaded successfully',
          data: {'count': result.portfolios.length, 'total': result.totalCount},
        );
      } else {
        _setError(result.message);
      }
    } catch (e) {
      Logger.error('Load portfolios error', error: e);
      _setError('Failed to load portfolios');
    } finally {
      _setLoading(false);
    }
  }

  /// Load more portfolios (pagination)
  Future<void> loadMorePortfolios() async {
    if (_isLoadingMore || _currentPage >= _totalPages) return;

    _setLoadingMore(true);

    try {
      _currentPage++;
      final result = await _portfolioService.getPortfolios(
        fundiId: _fundiId ?? '',
        page: _currentPage,
        search: _searchQuery,
        category: _selectedCategory,
      );

      if (result.success) {
        _portfolios.addAll(result.portfolios);
        Logger.info(
          'More portfolios loaded',
          data: {'count': result.portfolios.length},
        );
      } else {
        _currentPage--; // Revert page increment on error
        _setError(result.message);
      }
    } catch (e) {
      Logger.error('Load more portfolios error', error: e);
      _currentPage--; // Revert page increment on error
      _setError('Failed to load more portfolios');
    } finally {
      _setLoadingMore(false);
    }
  }

  /// Create a new portfolio item
  Future<bool> createPortfolio({
    required String fundiId,
    required String title,
    required String description,
    required String category,
    required List<String> skills,
    List<String>? imageUrls,
    List<String>? videoUrls,
    double? budget,
    String? budgetType,
    int? durationDays,
    DateTime? completedAt,
    Map<String, dynamic>? metadata,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _portfolioService.createPortfolio(
        fundiId: fundiId,
        title: title,
        description: description,
        category: category,
        skills: skills,
        imageUrls: imageUrls,
        videoUrls: videoUrls,
        budget: budget,
        budgetType: budgetType,
        durationDays: durationDays,
        completedAt: completedAt,
        metadata: metadata,
      );

      if (result.success && result.portfolio != null) {
        _portfolios.insert(0, result.portfolio!);
        notifyListeners();
        Logger.info(
          'Portfolio created successfully',
          data: {'portfolioId': result.portfolio!.id, 'count': 1},
        );
        return true;
      } else {
        _setError(result.message);
        return false;
      }
    } catch (e) {
      Logger.error('Create portfolio error', error: e);
      _setError('Failed to create portfolio');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Update an existing portfolio item
  Future<bool> updatePortfolio({
    required String portfolioId,
    String? title,
    String? description,
    String? category,
    List<String>? skills,
    List<String>? imageUrls,
    List<String>? videoUrls,
    double? budget,
    String? budgetType,
    int? durationDays,
    DateTime? completedAt,
    Map<String, dynamic>? metadata,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _portfolioService.updatePortfolio(
        portfolioId: portfolioId,
        title: title,
        description: description,
        category: category,
        skills: skills,
        imageUrls: imageUrls,
        videoUrls: videoUrls,
        budget: budget,
        budgetType: budgetType,
        durationDays: durationDays,
        completedAt: completedAt,
        metadata: metadata,
      );

      if (result.success && result.portfolio != null) {
        _updatePortfolioInList(result.portfolio!);
        notifyListeners();
        Logger.info(
          'Portfolio updated successfully',
          data: {'portfolioId': portfolioId},
        );
        return true;
      } else {
        _setError(result.message);
        return false;
      }
    } catch (e) {
      Logger.error('Update portfolio error', error: e);
      _setError('Failed to update portfolio');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Delete a portfolio item
  Future<bool> deletePortfolio(String portfolioId) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _portfolioService.deletePortfolio(portfolioId);

      if (result.success) {
        _portfolios.removeWhere((portfolio) => portfolio.id == portfolioId);
        notifyListeners();
        Logger.info(
          'Portfolio deleted successfully',
          data: {'portfolioId': portfolioId},
        );
        return true;
      } else {
        _setError(result.message);
        return false;
      }
    } catch (e) {
      Logger.error('Delete portfolio error', error: e);
      _setError('Failed to delete portfolio');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Upload media files for portfolio
  Future<bool> uploadMedia({
    required String portfolioId,
    required List<String> filePaths,
    required List<String> fileTypes,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _portfolioService.uploadMedia(
        portfolioId: portfolioId,
        filePaths: filePaths,
        fileTypes: fileTypes,
      );

      if (result.success) {
        Logger.info(
          'Media uploaded successfully',
          data: {'portfolioId': portfolioId},
        );
        return true;
      } else {
        _setError(result.message);
        return false;
      }
    } catch (e) {
      Logger.error('Upload media error', error: e);
      _setError('Failed to upload media');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Get portfolio categories
  Future<List<String>> getCategories() async {
    try {
      return await _portfolioService.getCategories();
    } catch (e) {
      Logger.error('Get categories error', error: e);
      return PortfolioCategory.values.map((e) => e.value).toList();
    }
  }

  /// Clear filters
  void clearFilters() {
    _searchQuery = null;
    _selectedCategory = null;
    notifyListeners();
  }

  /// Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// Set loading more state
  void _setLoadingMore(bool loading) {
    _isLoadingMore = loading;
    notifyListeners();
  }

  /// Set error message
  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  /// Clear error message
  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Clear error manually
  void clearError() {
    _clearError();
  }

  /// Update portfolio in the list
  void _updatePortfolioInList(PortfolioModel updatedPortfolio) {
    final index = _portfolios.indexWhere(
      (portfolio) => portfolio.id == updatedPortfolio.id,
    );
    if (index != -1) {
      _portfolios[index] = updatedPortfolio;
    }
  }
}
