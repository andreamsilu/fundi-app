import 'package:flutter/foundation.dart';

/// Utility for monitoring and debugging app startup performance
/// Helps identify bottlenecks during app launch
class StartupPerformance {
  static final Map<String, DateTime> _milestones = {};
  static final List<Map<String, dynamic>> _durations = [];

  /// Mark a milestone in the startup process
  static void markMilestone(String name) {
    _milestones[name] = DateTime.now();
    if (kDebugMode) {
      debugPrint('🚀 Startup Milestone: $name');
    }
  }

  /// Calculate duration between two milestones
  static Duration? calculateDuration(
    String startMilestone,
    String endMilestone,
  ) {
    final start = _milestones[startMilestone];
    final end = _milestones[endMilestone];

    if (start != null && end != null) {
      final duration = end.difference(start);
      _durations.add({
        'start': startMilestone,
        'end': endMilestone,
        'duration': duration,
        'milliseconds': duration.inMilliseconds,
      });

      if (kDebugMode) {
        debugPrint(
          '⏱️  Duration: $startMilestone → $endMilestone: ${duration.inMilliseconds}ms',
        );
      }

      return duration;
    }
    return null;
  }

  /// Log performance summary
  static void logPerformanceSummary() {
    if (!kDebugMode) return;

    debugPrint('\n📊 STARTUP PERFORMANCE SUMMARY');
    debugPrint('================================');

    for (final duration in _durations) {
      final start = duration['start'] as String;
      final end = duration['end'] as String;
      final ms = duration['milliseconds'] as int;

      String status = '';
      if (ms < 100) {
        status = '✅ FAST';
      } else if (ms < 500) {
        status = '⚠️  MODERATE';
      } else {
        status = '❌ SLOW';
      }

      debugPrint('$start → $end: ${ms}ms $status');
    }

    // Calculate total startup time
    final firstMilestone = _milestones.values.isNotEmpty
        ? _milestones.values.reduce((a, b) => a.isBefore(b) ? a : b)
        : null;
    final lastMilestone = _milestones.values.isNotEmpty
        ? _milestones.values.reduce((a, b) => a.isAfter(b) ? a : b)
        : null;

    if (firstMilestone != null && lastMilestone != null) {
      final totalDuration = lastMilestone.difference(firstMilestone);
      debugPrint('================================');
      debugPrint('TOTAL STARTUP TIME: ${totalDuration.inMilliseconds}ms');

      if (totalDuration.inMilliseconds > 2000) {
        debugPrint('⚠️  WARNING: Startup time is over 2 seconds!');
        debugPrint('💡 Consider optimizing heavy operations or using isolates');
      } else if (totalDuration.inMilliseconds > 1000) {
        debugPrint('⚠️  Startup time is moderate, consider optimization');
      } else {
        debugPrint('✅ Startup time is good!');
      }
    }

    debugPrint('================================\n');
  }

  /// Check if running in profile mode
  static bool get isProfileMode => kProfileMode;

  /// Check if running in release mode
  static bool get isReleaseMode => kReleaseMode;

  /// Get all milestones
  static Map<String, DateTime> get milestones => Map.unmodifiable(_milestones);

  /// Get all durations
  static List<Map<String, dynamic>> get durations =>
      List.unmodifiable(_durations);

  /// Clear all performance data
  static void clear() {
    _milestones.clear();
    _durations.clear();
  }
}
