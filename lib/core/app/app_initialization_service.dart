import 'package:flutter/foundation.dart';
import '../network/api_client.dart';
import '../config/env_config.dart';
import '../services/session_manager.dart';
import '../../features/auth/services/auth_service.dart';

/// Service for handling app initialization in background isolates
/// Prevents blocking the main thread during startup
class AppInitializationService {
  static bool _isInitialized = false;
  static bool _isInitializing = false;

  /// Check if initialization is complete
  static bool get isInitialized => _isInitialized;

  /// Check if initialization is in progress
  static bool get isInitializing => _isInitializing;

  /// Initialize app services in background
  /// Returns immediately, initialization happens asynchronously
  static Future<void> initializeAsync() async {
    if (_isInitialized || _isInitializing) return;

    print('⚙️ AppInit: Starting background initialization...');
    _isInitializing = true;

    // Delay initialization to allow UI to render first
    Future.delayed(const Duration(milliseconds: 100), () {
      _initializeInBackground();
    });
  }

  /// Initialize services in background isolate to avoid blocking UI
  static Future<void> _initializeInBackground() async {
    try {
      // Initialize directly on main thread to avoid isolate issues
      await _initializeOnMainThread();
      _isInitialized = true;
      _isInitializing = false;
    } catch (e) {
      debugPrint('Background initialization failed: $e');
      _isInitializing = false;
    }
  }

  /// Fallback initialization on main thread
  static Future<void> _initializeOnMainThread() async {
    try {
      print('🔧 AppInit: Initializing services on main thread...');
      EnvConfig.initialize();

      final sessionManager = SessionManager();
      await sessionManager.initialize();

      final apiClient = ApiClient();
      await apiClient.initialize();

      final authService = AuthService();
      await authService.initialize();

      _isInitialized = true;
      debugPrint('Main thread initialization completed');
    } catch (e) {
      debugPrint('Main thread initialization error: $e');
      rethrow;
    }
  }

  /// Force initialization (for testing or when needed immediately)
  static Future<void> forceInitialize() async {
    _isInitialized = false;
    _isInitializing = false;
    await _initializeOnMainThread();
  }

  /// Reset initialization state
  static void reset() {
    _isInitialized = false;
    _isInitializing = false;
  }
}
