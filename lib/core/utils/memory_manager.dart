import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../features/job/providers/job_provider.dart';
import '../../features/portfolio/providers/portfolio_provider.dart';

/// Memory management utility to prevent app stacking and memory leaks
class MemoryManager {
  static final MemoryManager _instance = MemoryManager._internal();
  factory MemoryManager() => _instance;
  MemoryManager._internal();

  bool _isInitialized = false;
  final List<ChangeNotifier> _providers = [];

  /// Initialize memory management
  void initialize() {
    if (_isInitialized) return;
    _isInitialized = true;
  }

  /// Clear all provider states to prevent stacking
  void clearAllStates(BuildContext context) {
    try {
      // Clear other provider states
      final jobProvider = Provider.of<JobProvider>(context, listen: false);
      jobProvider.clearState();

      final portfolioProvider = Provider.of<PortfolioProvider>(
        context,
        listen: false,
      );
      portfolioProvider.clearState();
    } catch (e) {
      // Ignore errors if providers are not available
    }
  }

  /// Clear navigation stack and reset to home
  void clearNavigationStack(BuildContext context) {
    Navigator.of(
      context,
    ).pushNamedAndRemoveUntil('/dashboard', (route) => false);
  }

  /// Check if app is in a clean state
  bool isCleanState() {
    return _providers.isEmpty;
  }

  /// Force garbage collection (use sparingly)
  void forceGC() {
    // This is a placeholder - actual GC is handled by Dart runtime
    _providers.clear();
  }

  /// Dispose all resources
  void dispose() {
    for (final provider in _providers) {
      provider.dispose();
    }
    _providers.clear();
    _isInitialized = false;
  }
}
