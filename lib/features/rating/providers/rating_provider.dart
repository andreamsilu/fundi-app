import 'package:flutter/material.dart';
import '../models/rating_model.dart';
import '../services/rating_service.dart';
import '../../../core/utils/logger.dart';

/// Rating provider for state management
class RatingProvider extends ChangeNotifier {
  final RatingService _ratingService = RatingService();

  List<RatingModel> _myRatings = [];
  FundiRatingSummary? _fundiRatingSummary;
  bool _isLoading = false;
  String? _errorMessage;

  /// Get my ratings list
  List<RatingModel> get myRatings => _myRatings;

  /// Get fundi rating summary
  FundiRatingSummary? get fundiRatingSummary => _fundiRatingSummary;

  /// Check if loading
  bool get isLoading => _isLoading;

  /// Get error message
  String? get errorMessage => _errorMessage;

  /// Load my ratings
  Future<void> loadMyRatings({int page = 1, int limit = 15}) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _ratingService.getMyRatings(
        page: page,
        limit: limit,
      );

      if (response.success && response.data != null) {
        if (page == 1) {
          _myRatings = response.data!;
        } else {
          _myRatings.addAll(response.data!);
        }
        notifyListeners();
        Logger.info('My ratings loaded successfully');
      } else {
        _setError(response.message);
      }
    } catch (e) {
      Logger.error('Load my ratings error', error: e);
      _setError('An error occurred while loading your ratings');
    } finally {
      _setLoading(false);
    }
  }

  /// Load fundi ratings
  Future<void> loadFundiRatings({
    required String fundiId,
    int page = 1,
    int limit = 15,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _ratingService.getFundiRatings(
        fundiId: fundiId,
        page: page,
        limit: limit,
      );

      if (response.success && response.data != null) {
        _fundiRatingSummary = response.data!;
        notifyListeners();
        Logger.info('Fundi ratings loaded successfully');
      } else {
        _setError(response.message);
      }
    } catch (e) {
      Logger.error('Load fundi ratings error', error: e);
      _setError('An error occurred while loading fundi ratings');
    } finally {
      _setLoading(false);
    }
  }

  /// Create rating
  Future<bool> createRating({
    required String fundiId,
    required String jobId,
    required int rating,
    String? review,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _ratingService.createRating(
        fundiId: fundiId,
        jobId: jobId,
        rating: rating,
        review: review,
      );

      if (response.success && response.data != null) {
        // Add to my ratings list
        _myRatings.insert(0, response.data!);
        notifyListeners();
        Logger.info('Rating created successfully');
        return true;
      } else {
        _setError(response.message);
        return false;
      }
    } catch (e) {
      Logger.error('Create rating error', error: e);
      _setError('An error occurred while creating rating');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Update rating
  Future<bool> updateRating({
    required String ratingId,
    int? rating,
    String? review,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _ratingService.updateRating(
        ratingId: ratingId,
        rating: rating,
        review: review,
      );

      if (response.success && response.data != null) {
        // Update in my ratings list
        final index = _myRatings.indexWhere((r) => r.id == ratingId);
        if (index != -1) {
          _myRatings[index] = response.data!;
          notifyListeners();
        }
        Logger.info('Rating updated successfully');
        return true;
      } else {
        _setError(response.message);
        return false;
      }
    } catch (e) {
      Logger.error('Update rating error', error: e);
      _setError('An error occurred while updating rating');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Delete rating
  Future<bool> deleteRating({
    required String ratingId,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _ratingService.deleteRating(ratingId: ratingId);

      if (response.success) {
        // Remove from my ratings list
        _myRatings.removeWhere((r) => r.id == ratingId);
        notifyListeners();
        Logger.info('Rating deleted successfully');
        return true;
      } else {
        _setError(response.message);
        return false;
      }
    } catch (e) {
      Logger.error('Delete rating error', error: e);
      _setError('An error occurred while deleting rating');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Get rating by ID
  RatingModel? getRatingById(String id) {
    try {
      return _myRatings.firstWhere((rating) => rating.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get ratings by fundi ID
  List<RatingModel> getRatingsByFundiId(String fundiId) {
    return _myRatings.where((rating) => rating.fundiId == fundiId).toList();
  }

  /// Get ratings by job ID
  List<RatingModel> getRatingsByJobId(String jobId) {
    return _myRatings.where((rating) => rating.jobId == jobId).toList();
  }

  /// Get average rating for a fundi
  double getAverageRatingForFundi(String fundiId) {
    final ratings = getRatingsByFundiId(fundiId);
    if (ratings.isEmpty) return 0.0;
    
    final total = ratings.fold(0, (sum, rating) => sum + rating.rating);
    return total / ratings.length;
  }

  /// Get total ratings count for a fundi
  int getTotalRatingsForFundi(String fundiId) {
    return getRatingsByFundiId(fundiId).length;
  }

  /// Get rating distribution for a fundi
  List<RatingDistribution> getRatingDistributionForFundi(String fundiId) {
    final ratings = getRatingsByFundiId(fundiId);
    if (ratings.isEmpty) return [];

    final distribution = <int, int>{};
    for (int i = 1; i <= 5; i++) {
      distribution[i] = 0;
    }

    for (final rating in ratings) {
      distribution[rating.rating] = (distribution[rating.rating] ?? 0) + 1;
    }

    return distribution.entries.map((entry) {
      final percentage = ratings.isNotEmpty 
          ? (entry.value / ratings.length) * 100 
          : 0.0;
      return RatingDistribution(
        rating: entry.key,
        count: entry.value,
        percentage: percentage,
      );
    }).toList();
  }

  /// Refresh my ratings
  Future<void> refreshMyRatings() async {
    await loadMyRatings();
  }

  /// Refresh fundi ratings
  Future<void> refreshFundiRatings(String fundiId) async {
    await loadFundiRatings(fundiId: fundiId);
  }

  /// Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
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
}
