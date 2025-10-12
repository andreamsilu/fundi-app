import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Navigation State Manager
/// Manages navigation state, history, and user preferences
class NavigationStateManager extends ChangeNotifier {
  static final NavigationStateManager _instance =
      NavigationStateManager._internal();
  factory NavigationStateManager() => _instance;
  NavigationStateManager._internal();

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // Navigation state
  String? _lastViewedJobId;
  String? _lastViewedFundiId;
  int? _lastDashboardTabIndex;
  List<String> _recentJobSearches = [];
  List<String> _recentFundiSearches = [];
  Map<String, dynamic> _savedFilters = {};

  // Getters
  String? get lastViewedJobId => _lastViewedJobId;
  String? get lastViewedFundiId => _lastViewedFundiId;
  int? get lastDashboardTabIndex => _lastDashboardTabIndex;
  List<String> get recentJobSearches => List.unmodifiable(_recentJobSearches);
  List<String> get recentFundiSearches =>
      List.unmodifiable(_recentFundiSearches);
  Map<String, dynamic> get savedFilters => Map.unmodifiable(_savedFilters);

  /// Initialize navigation state from storage
  Future<void> initialize() async {
    try {
      // Load saved state from secure storage
      _lastViewedJobId = await _storage.read(key: 'last_viewed_job_id');
      _lastViewedFundiId = await _storage.read(key: 'last_viewed_fundi_id');

      final tabIndex = await _storage.read(key: 'last_dashboard_tab');
      _lastDashboardTabIndex = tabIndex != null ? int.tryParse(tabIndex) : null;

      // Load recent searches (limited to 10)
      final jobSearches = await _storage.read(key: 'recent_job_searches');
      if (jobSearches != null) {
        _recentJobSearches = jobSearches.split('|').take(10).toList();
      }

      final fundiSearches = await _storage.read(key: 'recent_fundi_searches');
      if (fundiSearches != null) {
        _recentFundiSearches = fundiSearches.split('|').take(10).toList();
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Navigation state initialization error: $e');
    }
  }

  /// Save last viewed job
  Future<void> saveLastViewedJob(String jobId) async {
    _lastViewedJobId = jobId;
    await _storage.write(key: 'last_viewed_job_id', value: jobId);
    notifyListeners();
  }

  /// Save last viewed fundi
  Future<void> saveLastViewedFundi(String fundiId) async {
    _lastViewedFundiId = fundiId;
    await _storage.write(key: 'last_viewed_fundi_id', value: fundiId);
    notifyListeners();
  }

  /// Save dashboard tab index
  Future<void> saveDashboardTab(int tabIndex) async {
    _lastDashboardTabIndex = tabIndex;
    await _storage.write(key: 'last_dashboard_tab', value: tabIndex.toString());
    notifyListeners();
  }

  /// Add recent job search
  Future<void> addJobSearch(String query) async {
    if (query.isEmpty || _recentJobSearches.contains(query)) return;

    _recentJobSearches.insert(0, query);
    if (_recentJobSearches.length > 10) {
      _recentJobSearches = _recentJobSearches.take(10).toList();
    }

    await _storage.write(
      key: 'recent_job_searches',
      value: _recentJobSearches.join('|'),
    );
    notifyListeners();
  }

  /// Add recent fundi search
  Future<void> addFundiSearch(String query) async {
    if (query.isEmpty || _recentFundiSearches.contains(query)) return;

    _recentFundiSearches.insert(0, query);
    if (_recentFundiSearches.length > 10) {
      _recentFundiSearches = _recentFundiSearches.take(10).toList();
    }

    await _storage.write(
      key: 'recent_fundi_searches',
      value: _recentFundiSearches.join('|'),
    );
    notifyListeners();
  }

  /// Save filter preferences
  Future<void> saveFilters(String key, Map<String, dynamic> filters) async {
    _savedFilters[key] = filters;
    // Note: We're not persisting filters to storage for now
    // Can be added later if needed
    notifyListeners();
  }

  /// Get saved filters for a key
  Map<String, dynamic>? getSavedFilters(String key) {
    return _savedFilters[key] as Map<String, dynamic>?;
  }

  /// Clear recent searches
  Future<void> clearRecentSearches() async {
    _recentJobSearches.clear();
    _recentFundiSearches.clear();
    await _storage.delete(key: 'recent_job_searches');
    await _storage.delete(key: 'recent_fundi_searches');
    notifyListeners();
  }

  /// Clear all navigation state
  Future<void> clearAll() async {
    _lastViewedJobId = null;
    _lastViewedFundiId = null;
    _lastDashboardTabIndex = null;
    _recentJobSearches.clear();
    _recentFundiSearches.clear();
    _savedFilters.clear();

    await _storage.delete(key: 'last_viewed_job_id');
    await _storage.delete(key: 'last_viewed_fundi_id');
    await _storage.delete(key: 'last_dashboard_tab');
    await _storage.delete(key: 'recent_job_searches');
    await _storage.delete(key: 'recent_fundi_searches');

    notifyListeners();
  }

  /// Get quick access items (recently viewed)
  List<Map<String, String>> getQuickAccessItems() {
    final List<Map<String, String>> items = [];

    if (_lastViewedJobId != null) {
      items.add({
        'type': 'job',
        'id': _lastViewedJobId!,
        'label': 'Last viewed job',
      });
    }

    if (_lastViewedFundiId != null) {
      items.add({
        'type': 'fundi',
        'id': _lastViewedFundiId!,
        'label': 'Last viewed fundi',
      });
    }

    return items;
  }
}
