import 'package:flutter/foundation.dart';

/// Configuration for performance optimizations
class PerformanceConfig {
  // Cache settings
  static const Duration cacheValidityDuration = Duration(seconds: 30);
  static const int maxCacheSize = 100;

  // Database settings
  static const int maxConcurrentDbOperations = 5;
  static const Duration dbOperationTimeout = Duration(seconds: 10);

  // UI settings
  static const Duration debounceDelay = Duration(milliseconds: 300);
  static const int maxConcurrentAnimations = 3;

  // Monitoring settings
  static const Duration metricsCollectionInterval = Duration(seconds: 30);
  static const Duration memoryCheckInterval = Duration(seconds: 10);

  // Debug settings
  static bool get enablePerformanceLogging => kDebugMode;
  static bool get enableMemoryMonitoring => kDebugMode;
  static bool get enableCacheLogging => kDebugMode;

  // Optimization flags
  static bool get enableLazyLoading => true;
  static bool get enableParallelInitialization => true;
  static bool get enableBackgroundProcessing => true;
  static bool get enableSmartCaching => true;
}
