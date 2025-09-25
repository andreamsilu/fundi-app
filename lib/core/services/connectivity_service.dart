import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../utils/logger.dart';

/// Service for handling network connectivity and request management
/// Provides connectivity checking, retry logic, and request cancellation
class ConnectivityService {
  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;
  ConnectivityService._internal();

  Timer? _connectivityTimer;
  bool _isConnected = true;
  final List<Completer<bool>> _connectivityCompleters = [];

  /// Check if device has internet connectivity
  Future<bool> isConnected() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (e) {
      Logger.warning('Connectivity check failed: $e');
      return false;
    }
  }

  /// Start periodic connectivity monitoring
  void startConnectivityMonitoring() {
    _connectivityTimer?.cancel();
    _connectivityTimer = Timer.periodic(
      const Duration(seconds: 30),
      (timer) async {
        final connected = await isConnected();
        if (connected != _isConnected) {
          _isConnected = connected;
          Logger.info('Connectivity changed: ${connected ? "Connected" : "Disconnected"}');
          
          // Notify waiting completers
          for (final completer in _connectivityCompleters) {
            if (!completer.isCompleted) {
              completer.complete(connected);
            }
          }
          _connectivityCompleters.clear();
        }
      },
    );
  }

  /// Stop connectivity monitoring
  void stopConnectivityMonitoring() {
    _connectivityTimer?.cancel();
    _connectivityTimer = null;
  }

  /// Wait for connectivity to be restored
  Future<bool> waitForConnectivity({Duration timeout = const Duration(seconds: 30)}) async {
    if (_isConnected) return true;
    
    final completer = Completer<bool>();
    _connectivityCompleters.add(completer);
    
    try {
      return await completer.future.timeout(timeout);
    } catch (e) {
      Logger.warning('Connectivity wait timeout: $e');
      return false;
    }
  }

  /// Get current connectivity status
  bool get isConnectedNow => _isConnected;
}

/// Enhanced API client with connectivity awareness and retry logic
class ConnectivityAwareApiClient {
  final ConnectivityService _connectivityService = ConnectivityService();
  final Map<String, CancelToken> _activeRequests = {};
  
  /// Execute API call with connectivity awareness and retry logic
  Future<T> executeWithRetry<T>(
    Future<T> Function() apiCall, {
    int maxRetries = 3,
    Duration retryDelay = const Duration(seconds: 2),
    String? requestId,
    bool cancelPrevious = true,
  }) async {
    // Cancel previous request if specified
    if (requestId != null && cancelPrevious) {
      _activeRequests[requestId]?.cancel();
    }
    
    // Create cancel token for this request
    final cancelToken = CancelToken();
    if (requestId != null) {
      _activeRequests[requestId] = cancelToken;
    }
    
    int attempts = 0;
    Exception? lastException;
    
    while (attempts < maxRetries) {
      try {
        // Check connectivity before making request
        if (!await _connectivityService.isConnected()) {
          Logger.info('No connectivity, waiting for connection...');
          final connected = await _connectivityService.waitForConnectivity();
          if (!connected) {
            throw Exception('No internet connection available');
          }
        }
        
        // Execute the API call
        final result = await apiCall();
        
        // Clean up successful request
        if (requestId != null) {
          _activeRequests.remove(requestId);
        }
        
        return result;
      } catch (e) {
        attempts++;
        lastException = e is Exception ? e : Exception(e.toString());
        
        Logger.warning('API call attempt $attempts failed: $e');
        
        // Don't retry if request was cancelled
        if (cancelToken.isCancelled) {
          throw Exception('Request was cancelled');
        }
        
        // Don't retry on last attempt
        if (attempts >= maxRetries) {
          break;
        }
        
        // Wait before retry with exponential backoff
        final delay = Duration(
          milliseconds: retryDelay.inMilliseconds * (attempts * 2),
        );
        Logger.info('Retrying in ${delay.inMilliseconds}ms...');
        await Future.delayed(delay);
      }
    }
    
    // Clean up failed request
    if (requestId != null) {
      _activeRequests.remove(requestId);
    }
    
    throw lastException ?? Exception('API call failed after $maxRetries attempts');
  }
  
  /// Cancel a specific request
  void cancelRequest(String requestId) {
    _activeRequests[requestId]?.cancel();
    _activeRequests.remove(requestId);
  }
  
  /// Cancel all active requests
  void cancelAllRequests() {
    for (final token in _activeRequests.values) {
      token.cancel();
    }
    _activeRequests.clear();
  }
  
  /// Get active request count
  int get activeRequestCount => _activeRequests.length;
}

/// Cancel token for request cancellation
class CancelToken {
  bool _isCancelled = false;
  
  bool get isCancelled => _isCancelled;
  
  void cancel() {
    _isCancelled = true;
  }
}

/// Mixin for connectivity-aware widgets
mixin ConnectivityAware {
  final ConnectivityService _connectivityService = ConnectivityService();
  
  /// Check connectivity before making API calls
  Future<bool> ensureConnectivity() async {
    if (!_connectivityService.isConnectedNow) {
      return await _connectivityService.waitForConnectivity();
    }
    return true;
  }
  
  /// Show connectivity error message
  void showConnectivityError(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('No internet connection. Please check your network.'),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 4),
      ),
    );
  }
  
  /// Show connectivity restored message
  void showConnectivityRestored(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Connection restored.'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }
}
