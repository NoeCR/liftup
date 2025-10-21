import 'dart:async';
import 'performance_config.dart';
import '../logging/logging.dart';

/// Smart cache service with automatic cleanup and memory management
class SmartCacheService {
  static SmartCacheService? _instance;
  static SmartCacheService get instance => _instance ??= SmartCacheService._();

  SmartCacheService._();

  final Map<String, _CacheEntry> _cache = {};
  Timer? _cleanupTimer;
  bool _isInitialized = false;

  /// Initialize the cache service
  void initialize() {
    if (_isInitialized) return;

    _isInitialized = true;

    // Start periodic cleanup
    _cleanupTimer = Timer.periodic(const Duration(minutes: 5), (_) => _cleanupExpiredEntries());

    if (PerformanceConfig.enableCacheLogging) {
      LoggingService.instance.debug('SmartCacheService initialized');
    }
  }

  /// Get cached value
  T? get<T>(String key) {
    final entry = _cache[key];
    if (entry == null) return null;

    // Check if expired
    if (entry.isExpired) {
      _cache.remove(key);
      return null;
    }

    // Update access time
    entry.lastAccessed = DateTime.now();
    entry.accessCount++;

    if (PerformanceConfig.enableCacheLogging) {
      LoggingService.instance.debug('Cache hit for key: $key');
    }

    return entry.value as T?;
  }

  /// Set cached value
  void set<T>(String key, T value, {Duration? ttl}) {
    final entry = _CacheEntry(
      value: value,
      createdAt: DateTime.now(),
      ttl: ttl ?? PerformanceConfig.cacheValidityDuration,
    );

    _cache[key] = entry;

    // Check cache size limit
    if (_cache.length > PerformanceConfig.maxCacheSize) {
      _evictOldestEntries();
    }

    if (PerformanceConfig.enableCacheLogging) {
      LoggingService.instance.debug('Cache set for key: $key');
    }
  }

  /// Remove cached value
  void remove(String key) {
    _cache.remove(key);

    if (PerformanceConfig.enableCacheLogging) {
      LoggingService.instance.debug('Cache removed for key: $key');
    }
  }

  /// Clear all cache
  void clear() {
    _cache.clear();

    if (PerformanceConfig.enableCacheLogging) {
      LoggingService.instance.debug('Cache cleared');
    }
  }

  /// Get cache statistics
  Map<String, dynamic> getStats() {
    final totalEntries = _cache.length;
    final expiredEntries = _cache.values.where((e) => e.isExpired).length;
    final totalAccesses = _cache.values.fold(0, (sum, e) => sum + e.accessCount);

    return {
      'total_entries': totalEntries,
      'expired_entries': expiredEntries,
      'active_entries': totalEntries - expiredEntries,
      'total_accesses': totalAccesses,
      'average_accesses': totalEntries > 0 ? totalAccesses / totalEntries : 0,
      'cache_hit_rate': totalAccesses > 0 ? (totalAccesses - expiredEntries) / totalAccesses : 0,
    };
  }

  /// Cleanup expired entries
  void _cleanupExpiredEntries() {
    final expiredKeys = _cache.entries.where((entry) => entry.value.isExpired).map((entry) => entry.key).toList();

    for (final key in expiredKeys) {
      _cache.remove(key);
    }

    if (PerformanceConfig.enableCacheLogging && expiredKeys.isNotEmpty) {
      LoggingService.instance.debug('Cleaned up ${expiredKeys.length} expired cache entries');
    }
  }

  /// Evict oldest entries when cache is full
  void _evictOldestEntries() {
    final sortedEntries = _cache.entries.toList()..sort((a, b) => a.value.lastAccessed.compareTo(b.value.lastAccessed));

    final entriesToRemove = (sortedEntries.length * 0.2).ceil();
    for (int i = 0; i < entriesToRemove; i++) {
      _cache.remove(sortedEntries[i].key);
    }

    if (PerformanceConfig.enableCacheLogging) {
      LoggingService.instance.debug('Evicted $entriesToRemove oldest cache entries');
    }
  }

  /// Dispose the cache service
  void dispose() {
    _cleanupTimer?.cancel();
    _cleanupTimer = null;
    _cache.clear();
    _isInitialized = false;

    if (PerformanceConfig.enableCacheLogging) {
      LoggingService.instance.debug('SmartCacheService disposed');
    }
  }
}

/// Internal cache entry
class _CacheEntry {
  final dynamic value;
  final DateTime createdAt;
  final Duration ttl;
  DateTime lastAccessed;
  int accessCount;

  _CacheEntry({required this.value, required this.createdAt, required this.ttl})
    : lastAccessed = createdAt,
      accessCount = 0;

  bool get isExpired => DateTime.now().difference(createdAt) > ttl;
}
