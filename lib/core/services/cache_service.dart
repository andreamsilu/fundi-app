import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/logger.dart';

/// Service for caching API responses and data
/// Provides memory and disk caching with TTL support
class CacheService {
  static final CacheService _instance = CacheService._internal();
  factory CacheService() => _instance;
  CacheService._internal();

  static const String _cachePrefix = 'cache_';
  static const String _timestampPrefix = 'timestamp_';
  
  // Memory cache for frequently accessed data
  final Map<String, dynamic> _memoryCache = {};
  final Map<String, DateTime> _memoryTimestamps = {};

  /// Cache data with TTL
  Future<void> setCache(
    String key,
    dynamic data, {
    Duration ttl = const Duration(hours: 1),
  }) async {
    try {
      final cacheKey = '$_cachePrefix$key';
      final timestampKey = '$_timestampPrefix$key';
      final timestamp = DateTime.now().add(ttl);
      
      // Store in memory cache
      _memoryCache[cacheKey] = data;
      _memoryTimestamps[cacheKey] = timestamp;
      
      // Store in disk cache
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(cacheKey, jsonEncode(data));
      await prefs.setString(timestampKey, timestamp.toIso8601String());
      
      Logger.info('Cached data for key: $key with TTL: ${ttl.inMinutes} minutes');
    } catch (e) {
      Logger.error('Failed to cache data for key: $key', error: e);
    }
  }

  /// Get cached data
  Future<T?> getCache<T>(String key) async {
    try {
      final cacheKey = '$_cachePrefix$key';
      final timestampKey = '$_timestampPrefix$key';
      
      // Check memory cache first
      if (_memoryCache.containsKey(cacheKey)) {
        final timestamp = _memoryTimestamps[cacheKey];
        if (timestamp != null && DateTime.now().isBefore(timestamp)) {
          Logger.info('Cache hit (memory) for key: $key');
          return _memoryCache[cacheKey] as T?;
        } else {
          // Expired, remove from memory
          _memoryCache.remove(cacheKey);
          _memoryTimestamps.remove(cacheKey);
        }
      }
      
      // Check disk cache
      final prefs = await SharedPreferences.getInstance();
      final cachedData = prefs.getString(cacheKey);
      final timestampStr = prefs.getString(timestampKey);
      
      if (cachedData != null && timestampStr != null) {
        final timestamp = DateTime.parse(timestampStr);
        if (DateTime.now().isBefore(timestamp)) {
          // Cache is valid, load into memory
          final data = jsonDecode(cachedData);
          _memoryCache[cacheKey] = data;
          _memoryTimestamps[cacheKey] = timestamp;
          
          Logger.info('Cache hit (disk) for key: $key');
          return data as T?;
        } else {
          // Expired, remove from disk
          await prefs.remove(cacheKey);
          await prefs.remove(timestampKey);
        }
      }
      
      Logger.info('Cache miss for key: $key');
      return null;
    } catch (e) {
      Logger.error('Failed to get cache for key: $key', error: e);
      return null;
    }
  }

  /// Check if cache exists and is valid
  Future<bool> hasValidCache(String key) async {
    try {
      final cacheKey = '$_cachePrefix$key';
      final timestampKey = '$_timestampPrefix$key';
      
      // Check memory cache first
      if (_memoryCache.containsKey(cacheKey)) {
        final timestamp = _memoryTimestamps[cacheKey];
        return timestamp != null && DateTime.now().isBefore(timestamp);
      }
      
      // Check disk cache
      final prefs = await SharedPreferences.getInstance();
      final timestampStr = prefs.getString(timestampKey);
      
      if (timestampStr != null) {
        final timestamp = DateTime.parse(timestampStr);
        return DateTime.now().isBefore(timestamp);
      }
      
      return false;
    } catch (e) {
      Logger.error('Failed to check cache validity for key: $key', error: e);
      return false;
    }
  }

  /// Remove cache entry
  Future<void> removeCache(String key) async {
    try {
      final cacheKey = '$_cachePrefix$key';
      final timestampKey = '$_timestampPrefix$key';
      
      // Remove from memory
      _memoryCache.remove(cacheKey);
      _memoryTimestamps.remove(cacheKey);
      
      // Remove from disk
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(cacheKey);
      await prefs.remove(timestampKey);
      
      Logger.info('Removed cache for key: $key');
    } catch (e) {
      Logger.error('Failed to remove cache for key: $key', error: e);
    }
  }

  /// Clear all cache
  Future<void> clearAllCache() async {
    try {
      // Clear memory cache
      _memoryCache.clear();
      _memoryTimestamps.clear();
      
      // Clear disk cache
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      
      for (final key in keys) {
        if (key.startsWith(_cachePrefix) || key.startsWith(_timestampPrefix)) {
          await prefs.remove(key);
        }
      }
      
      Logger.info('Cleared all cache');
    } catch (e) {
      Logger.error('Failed to clear cache', error: e);
    }
  }

  /// Get cache statistics
  Map<String, dynamic> getCacheStats() {
    return {
      'memoryCacheSize': _memoryCache.length,
      'memoryCacheKeys': _memoryCache.keys.toList(),
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  /// Cache API response with automatic TTL
  Future<void> cacheApiResponse(
    String endpoint,
    dynamic response, {
    Duration ttl = const Duration(minutes: 30),
  }) async {
    await setCache('api_$endpoint', response, ttl: ttl);
  }

  /// Get cached API response
  Future<T?> getCachedApiResponse<T>(String endpoint) async {
    return await getCache<T>('api_$endpoint');
  }

  /// Check if API response is cached
  Future<bool> hasCachedApiResponse(String endpoint) async {
    return await hasValidCache('api_$endpoint');
  }
}
