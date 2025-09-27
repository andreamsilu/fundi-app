import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Performance utilities for optimizing mobile app performance
class PerformanceUtils {
  /// Debounce function to limit function calls
  static Timer? _debounceTimer;
  
  /// Debounce a function call by the specified duration
  static void debounce(
    Duration delay,
    VoidCallback callback, {
    bool cancelPrevious = true,
  }) {
    if (cancelPrevious && _debounceTimer?.isActive == true) {
      _debounceTimer?.cancel();
    }
    
    _debounceTimer = Timer(delay, callback);
  }

  /// Throttle function to limit function calls to once per duration
  static DateTime? _lastThrottleCall;
  
  /// Throttle a function call to once per duration
  static bool throttle(Duration duration, VoidCallback callback) {
    final now = DateTime.now();
    
    if (_lastThrottleCall == null || 
        now.difference(_lastThrottleCall!) >= duration) {
      _lastThrottleCall = now;
      callback();
      return true;
    }
    
    return false;
  }

  /// Check if we should prefetch more items based on scroll position
  static bool shouldPrefetch(
    ScrollController scrollController,
    double threshold, {
    int currentItemCount = 0,
    int totalItems = 0,
  }) {
    if (currentItemCount >= totalItems) return false;
    
    final position = scrollController.position;
    final pixels = position.pixels;
    final maxScrollExtent = position.maxScrollExtent;
    
    // Prefetch when scrolled past threshold
    return pixels >= maxScrollExtent * threshold;
  }

  /// Optimize list item key for better performance
  static String generateListItemKey(String prefix, dynamic id) {
    return '${prefix}_${id}';
  }

  /// Check if widget should be const
  static bool canBeConst(dynamic widget) {
    // This is a helper for manual optimization
    // In practice, use const constructors where possible
    return widget != null;
  }

  /// Memory usage optimization for large lists
  static const int maxListItemsInMemory = 50;
  
  /// Check if we should limit list items in memory
  static bool shouldLimitMemory(int currentCount) {
    return currentCount > maxListItemsInMemory;
  }

  /// Batch operations for better performance
  static Future<List<T>> batchProcess<T>(
    List<T> items,
    Future<T> Function(T item) processor, {
    int batchSize = 10,
  }) async {
    final results = <T>[];
    
    for (int i = 0; i < items.length; i += batchSize) {
      final batch = items.skip(i).take(batchSize);
      final batchResults = await Future.wait(
        batch.map(processor),
      );
      results.addAll(batchResults);
    }
    
    return results;
  }

  /// Optimize image loading for lists
  static const Map<String, dynamic> imageLoadingConfig = {
    'maxWidth': 400,
    'maxHeight': 400,
    'quality': 85,
    'cacheDuration': Duration(hours: 24),
  };

  /// Check if we're in debug mode for performance logging
  static bool get isDebugMode => kDebugMode;
  
  /// Log performance metrics in debug mode
  static void logPerformance(String operation, Duration duration) {
    if (isDebugMode) {
      debugPrint('Performance: $operation took ${duration.inMilliseconds}ms');
    }
  }

  /// Measure execution time of a function
  static Future<T> measureExecution<T>(
    Future<T> Function() function,
    String operationName,
  ) async {
    final stopwatch = Stopwatch()..start();
    try {
      final result = await function();
      return result;
    } finally {
      stopwatch.stop();
      logPerformance(operationName, stopwatch.elapsed);
    }
  }
}

/// Mixin for performance-optimized widgets
mixin PerformanceOptimized {
  /// Debounce search input
  void debounceSearch(
    String query,
    VoidCallback onSearch, {
    Duration delay = const Duration(milliseconds: 300),
  }) {
    PerformanceUtils.debounce(delay, onSearch);
  }

  /// Throttle scroll events
  bool throttleScroll(VoidCallback onScroll) {
    return PerformanceUtils.throttle(
      const Duration(milliseconds: 100),
      onScroll,
    );
  }

  /// Check if we should load more items
  bool shouldLoadMore(
    ScrollController scrollController, {
    double threshold = 0.7,
    int currentCount = 0,
    int totalCount = 0,
  }) {
    return PerformanceUtils.shouldPrefetch(
      scrollController,
      threshold,
      currentItemCount: currentCount,
      totalItems: totalCount,
    );
  }
}
