import 'package:flutter/foundation.dart';
import '../models/portfolio_approval_model.dart';
import '../models/work_submission_model.dart';
import '../services/work_approval_service.dart';

/// Provider for managing work approval state and business logic
/// Implements proper separation of concerns for work approval functionality
class WorkApprovalProvider extends ChangeNotifier {
  final WorkApprovalService _workApprovalService;

  // Portfolio items state
  List<PortfolioApprovalModel> _pendingPortfolioItems = [];
  bool _isLoadingPortfolioItems = false;
  bool _isLoadingMorePortfolioItems = false;
  String? _portfolioItemsError;
  bool _hasMorePortfolioItems = true;
  int _portfolioItemsCurrentPage = 1;

  // Work submissions state
  List<WorkSubmissionModel> _pendingWorkSubmissions = [];
  bool _isLoadingWorkSubmissions = false;
  bool _isLoadingMoreWorkSubmissions = false;
  String? _workSubmissionsError;
  bool _hasMoreWorkSubmissions = true;
  int _workSubmissionsCurrentPage = 1;

  // Filter state
  String? _selectedCategory;
  String? _selectedFundiId;
  String? _selectedJobId;

  // Statistics state
  Map<String, dynamic> _statistics = {};
  bool _isLoadingStatistics = false;

  WorkApprovalProvider({WorkApprovalService? workApprovalService})
    : _workApprovalService = workApprovalService ?? WorkApprovalService();

  // Getters for portfolio items state
  List<PortfolioApprovalModel> get pendingPortfolioItems =>
      _pendingPortfolioItems;
  bool get isLoadingPortfolioItems => _isLoadingPortfolioItems;
  bool get isLoadingMorePortfolioItems => _isLoadingMorePortfolioItems;
  String? get portfolioItemsError => _portfolioItemsError;
  bool get hasMorePortfolioItems => _hasMorePortfolioItems;

  // Getters for work submissions state
  List<WorkSubmissionModel> get pendingWorkSubmissions =>
      _pendingWorkSubmissions;
  bool get isLoadingWorkSubmissions => _isLoadingWorkSubmissions;
  bool get isLoadingMoreWorkSubmissions => _isLoadingMoreWorkSubmissions;
  String? get workSubmissionsError => _workSubmissionsError;
  bool get hasMoreWorkSubmissions => _hasMoreWorkSubmissions;

  // Getters for filter state
  String? get selectedCategory => _selectedCategory;
  String? get selectedFundiId => _selectedFundiId;
  String? get selectedJobId => _selectedJobId;

  // Getters for statistics
  Map<String, dynamic> get statistics => _statistics;
  bool get isLoadingStatistics => _isLoadingStatistics;

  /// Initialize work approval data
  Future<void> initialize() async {
    await Future.wait([
      loadPendingPortfolioItems(),
      loadPendingWorkSubmissions(),
      loadStatistics(),
    ]);
  }

  /// Load pending portfolio items with current filters
  Future<void> loadPendingPortfolioItems({bool refresh = false}) async {
    if (refresh) {
      _portfolioItemsCurrentPage = 1;
      _pendingPortfolioItems.clear();
      _hasMorePortfolioItems = true;
    }

    if (_isLoadingPortfolioItems || !_hasMorePortfolioItems) return;

    _isLoadingPortfolioItems = true;
    _portfolioItemsError = null;
    notifyListeners();

    try {
      final result = await _workApprovalService.getPendingPortfolioItems(
        page: _portfolioItemsCurrentPage,
        category: _selectedCategory,
        fundiId: _selectedFundiId,
      );

      if (result['success']) {
        final newItems =
            result['portfolioItems'] as List<PortfolioApprovalModel>;
        if (refresh) {
          _pendingPortfolioItems = newItems;
        } else {
          _pendingPortfolioItems.addAll(newItems);
        }

        final pagination = result['pagination'] as Map<String, dynamic>;
        _hasMorePortfolioItems = pagination['hasNextPage'] ?? false;
        _portfolioItemsCurrentPage++;
      } else {
        _portfolioItemsError = result['message'];
      }
    } catch (e) {
      _portfolioItemsError = 'Failed to load portfolio items: ${e.toString()}';
    } finally {
      _isLoadingPortfolioItems = false;
      notifyListeners();
    }
  }

  /// Load more portfolio items (pagination)
  Future<void> loadMorePortfolioItems() async {
    if (_isLoadingMorePortfolioItems || !_hasMorePortfolioItems) return;

    _isLoadingMorePortfolioItems = true;
    notifyListeners();

    try {
      final result = await _workApprovalService.getPendingPortfolioItems(
        page: _portfolioItemsCurrentPage,
        category: _selectedCategory,
        fundiId: _selectedFundiId,
      );

      if (result['success']) {
        final newItems =
            result['portfolioItems'] as List<PortfolioApprovalModel>;
        _pendingPortfolioItems.addAll(newItems);

        final pagination = result['pagination'] as Map<String, dynamic>;
        _hasMorePortfolioItems = pagination['hasNextPage'] ?? false;
        _portfolioItemsCurrentPage++;
      }
    } catch (e) {
      _portfolioItemsError =
          'Failed to load more portfolio items: ${e.toString()}';
    } finally {
      _isLoadingMorePortfolioItems = false;
      notifyListeners();
    }
  }

  /// Load pending work submissions with current filters
  Future<void> loadPendingWorkSubmissions({bool refresh = false}) async {
    if (refresh) {
      _workSubmissionsCurrentPage = 1;
      _pendingWorkSubmissions.clear();
      _hasMoreWorkSubmissions = true;
    }

    if (_isLoadingWorkSubmissions || !_hasMoreWorkSubmissions) return;

    _isLoadingWorkSubmissions = true;
    _workSubmissionsError = null;
    notifyListeners();

    try {
      final result = await _workApprovalService.getPendingWorkSubmissions(
        page: _workSubmissionsCurrentPage,
        jobId: _selectedJobId,
        fundiId: _selectedFundiId,
      );

      if (result['success']) {
        final newSubmissions =
            result['workSubmissions'] as List<WorkSubmissionModel>;
        if (refresh) {
          _pendingWorkSubmissions = newSubmissions;
        } else {
          _pendingWorkSubmissions.addAll(newSubmissions);
        }

        final pagination = result['pagination'] as Map<String, dynamic>;
        _hasMoreWorkSubmissions = pagination['hasNextPage'] ?? false;
        _workSubmissionsCurrentPage++;
      } else {
        _workSubmissionsError = result['message'];
      }
    } catch (e) {
      _workSubmissionsError =
          'Failed to load work submissions: ${e.toString()}';
    } finally {
      _isLoadingWorkSubmissions = false;
      notifyListeners();
    }
  }

  /// Load more work submissions (pagination)
  Future<void> loadMoreWorkSubmissions() async {
    if (_isLoadingMoreWorkSubmissions || !_hasMoreWorkSubmissions) return;

    _isLoadingMoreWorkSubmissions = true;
    notifyListeners();

    try {
      final result = await _workApprovalService.getPendingWorkSubmissions(
        page: _workSubmissionsCurrentPage,
        jobId: _selectedJobId,
        fundiId: _selectedFundiId,
      );

      if (result['success']) {
        final newSubmissions =
            result['workSubmissions'] as List<WorkSubmissionModel>;
        _pendingWorkSubmissions.addAll(newSubmissions);

        final pagination = result['pagination'] as Map<String, dynamic>;
        _hasMoreWorkSubmissions = pagination['hasNextPage'] ?? false;
        _workSubmissionsCurrentPage++;
      }
    } catch (e) {
      _workSubmissionsError =
          'Failed to load more work submissions: ${e.toString()}';
    } finally {
      _isLoadingMoreWorkSubmissions = false;
      notifyListeners();
    }
  }

  /// Load approval statistics
  Future<void> loadStatistics() async {
    _isLoadingStatistics = true;
    notifyListeners();

    try {
      final result = await _workApprovalService.getApprovalStatistics();

      if (result['success']) {
        _statistics = result['statistics'] as Map<String, dynamic>;
      }
    } catch (e) {
      debugPrint('Error loading statistics: ${e.toString()}');
    } finally {
      _isLoadingStatistics = false;
      notifyListeners();
    }
  }

  /// Update category filter
  void updateCategory(String? category) {
    if (_selectedCategory != category) {
      _selectedCategory = category;
      _resetPagination();
      notifyListeners();
    }
  }

  /// Update fundi filter
  void updateFundiId(String? fundiId) {
    if (_selectedFundiId != fundiId) {
      _selectedFundiId = fundiId;
      _resetPagination();
      notifyListeners();
    }
  }

  /// Update job filter
  void updateJobId(String? jobId) {
    if (_selectedJobId != jobId) {
      _selectedJobId = jobId;
      _resetPagination();
      notifyListeners();
    }
  }

  /// Clear all filters
  void clearFilters() {
    _selectedCategory = null;
    _selectedFundiId = null;
    _selectedJobId = null;
    _resetPagination();
    notifyListeners();
  }

  /// Apply filters and reload data
  Future<void> applyFilters() async {
    await Future.wait([
      loadPendingPortfolioItems(refresh: true),
      loadPendingWorkSubmissions(refresh: true),
    ]);
  }

  /// Approve a portfolio item
  Future<Map<String, dynamic>> approvePortfolioItem({
    required String itemId,
    String? notes,
  }) async {
    try {
      final result = await _workApprovalService.approvePortfolioItem(
        itemId: itemId,
        notes: notes,
      );

      if (result['success']) {
        // Remove item from pending list
        _pendingPortfolioItems.removeWhere((item) => item.id == itemId);
        notifyListeners();
      }

      return result;
    } catch (e) {
      return {
        'success': false,
        'message': 'Error approving portfolio item: ${e.toString()}',
      };
    }
  }

  /// Reject a portfolio item
  Future<Map<String, dynamic>> rejectPortfolioItem({
    required String itemId,
    required String rejectionReason,
    String? notes,
  }) async {
    try {
      final result = await _workApprovalService.rejectPortfolioItem(
        itemId: itemId,
        rejectionReason: rejectionReason,
        notes: notes,
      );

      if (result['success']) {
        // Remove item from pending list
        _pendingPortfolioItems.removeWhere((item) => item.id == itemId);
        notifyListeners();
      }

      return result;
    } catch (e) {
      return {
        'success': false,
        'message': 'Error rejecting portfolio item: ${e.toString()}',
      };
    }
  }

  /// Approve a work submission
  Future<Map<String, dynamic>> approveWorkSubmission({
    required String submissionId,
    String? notes,
    double? qualityScore,
  }) async {
    try {
      final result = await _workApprovalService.approveWorkSubmission(
        submissionId: submissionId,
        notes: notes,
        qualityScore: qualityScore,
      );

      if (result['success']) {
        // Remove submission from pending list
        _pendingWorkSubmissions.removeWhere(
          (submission) => submission.id == submissionId,
        );
        notifyListeners();
      }

      return result;
    } catch (e) {
      return {
        'success': false,
        'message': 'Error approving work submission: ${e.toString()}',
      };
    }
  }

  /// Reject a work submission
  Future<Map<String, dynamic>> rejectWorkSubmission({
    required String submissionId,
    required String rejectionReason,
    String? notes,
  }) async {
    try {
      final result = await _workApprovalService.rejectWorkSubmission(
        submissionId: submissionId,
        rejectionReason: rejectionReason,
        notes: notes,
      );

      if (result['success']) {
        // Remove submission from pending list
        _pendingWorkSubmissions.removeWhere(
          (submission) => submission.id == submissionId,
        );
        notifyListeners();
      }

      return result;
    } catch (e) {
      return {
        'success': false,
        'message': 'Error rejecting work submission: ${e.toString()}',
      };
    }
  }

  /// Request revision for a work submission
  Future<Map<String, dynamic>> requestWorkSubmissionRevision({
    required String submissionId,
    required String revisionNotes,
    DateTime? deadline,
  }) async {
    try {
      final result = await _workApprovalService.requestWorkSubmissionRevision(
        submissionId: submissionId,
        revisionNotes: revisionNotes,
        deadline: deadline,
      );

      if (result['success']) {
        // Remove submission from pending list (it's now in revision status)
        _pendingWorkSubmissions.removeWhere(
          (submission) => submission.id == submissionId,
        );
        notifyListeners();
      }

      return result;
    } catch (e) {
      return {
        'success': false,
        'message': 'Error requesting revision: ${e.toString()}',
      };
    }
  }

  /// Get portfolio item details
  Future<Map<String, dynamic>> getPortfolioItemDetails(String itemId) async {
    try {
      return await _workApprovalService.getPortfolioItemDetails(itemId);
    } catch (e) {
      return {
        'success': false,
        'portfolioItem': null,
        'message': 'Error fetching portfolio item details: ${e.toString()}',
      };
    }
  }

  /// Get work submission details
  Future<Map<String, dynamic>> getWorkSubmissionDetails(
    String submissionId,
  ) async {
    try {
      return await _workApprovalService.getWorkSubmissionDetails(submissionId);
    } catch (e) {
      return {
        'success': false,
        'workSubmission': null,
        'message': 'Error fetching work submission details: ${e.toString()}',
      };
    }
  }

  /// Refresh all data
  Future<void> refreshAll() async {
    await initialize();
  }

  /// Reset pagination state
  void _resetPagination() {
    _portfolioItemsCurrentPage = 1;
    _workSubmissionsCurrentPage = 1;
    _hasMorePortfolioItems = true;
    _hasMoreWorkSubmissions = true;
  }

  @override
  void dispose() {
    super.dispose();
  }
}
