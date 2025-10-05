import 'package:sentry_flutter/sentry_flutter.dart';
import 'logging_service.dart';
import 'performance_monitor.dart';

/// Sentry metrics configuration
class SentryMetricsConfig {
  static bool _isInitialized = false;

  /// Initializes metrics configuration
  static Future<void> initialize() async {
    if (_isInitialized) {
      LoggingService.instance.info('SentryMetricsConfig already initialized, skipping');
      return;
    }

    try {
      LoggingService.instance.info('Initializing Sentry metrics configuration');

      // Configurar métricas de rendimiento
      _setupPerformanceMetrics();

      // Configurar métricas de uso
      _setupUsageMetrics();

      // Configurar métricas de errores
      _setupErrorMetrics();

      // Configurar métricas de base de datos
      _setupDatabaseMetrics();

      _isInitialized = true;
      LoggingService.instance.info('Sentry metrics configuration initialized successfully');
    } catch (e, stackTrace) {
      LoggingService.instance.error('Failed to initialize Sentry metrics configuration', e, stackTrace, {
        'component': 'sentry_metrics_config',
      });
    }
  }

  /// Configures performance metrics
  static void _setupPerformanceMetrics() {
    LoggingService.instance.setContext('performance_metrics', {
      'app_startup_time': 'tracked',
      'database_operations': 'tracked',
      'import_export_operations': 'tracked',
      'ui_rendering_time': 'tracked',
      'memory_usage': 'tracked',
      'configured_at': DateTime.now().toIso8601String(),
    });
  }

  /// Configures usage metrics
  static void _setupUsageMetrics() {
    LoggingService.instance.setContext('usage_metrics', {
      'sessions_created': 'tracked',
      'exercises_performed': 'tracked',
      'routines_used': 'tracked',
      'imports_exports': 'tracked',
      'settings_changes': 'tracked',
      'configured_at': DateTime.now().toIso8601String(),
    });
  }

  /// Configures error metrics
  static void _setupErrorMetrics() {
    LoggingService.instance.setContext('error_metrics', {
      'error_rate': 'tracked',
      'crash_rate': 'tracked',
      'database_errors': 'tracked',
      'import_export_errors': 'tracked',
      'ui_errors': 'tracked',
      'configured_at': DateTime.now().toIso8601String(),
    });
  }

  /// Configures database metrics
  static void _setupDatabaseMetrics() {
    LoggingService.instance.setContext('database_metrics', {
      'operation_times': 'tracked',
      'operation_counts': 'tracked',
      'error_rates': 'tracked',
      'data_sizes': 'tracked',
      'configured_at': DateTime.now().toIso8601String(),
    });
  }

  /// Records app startup time metric
  static void trackAppStartupTime(int startupTimeMs) {
    try {
      LoggingService.instance.info('App startup time tracked', {
        'startup_time_ms': startupTimeMs,
        'metric_type': 'performance',
        'metric_name': 'app_startup_time',
        'threshold_ms': 3000,
        'is_slow': startupTimeMs > 3000,
      });

      // Enviar transacción a Sentry
      Sentry.addBreadcrumb(
        Breadcrumb(
          message: 'App startup completed',
          category: 'performance.startup',
          level: SentryLevel.info,
          data: {'startup_time_ms': startupTimeMs, 'is_slow': startupTimeMs > 3000},
        ),
      );
    } catch (e) {
      LoggingService.instance.error('Failed to track app startup time: $e');
    }
  }

  /// Records database operation metric
  static void trackDatabaseOperation({
    required String operation,
    required int durationMs,
    required bool success,
    String? error,
    Map<String, dynamic>? context,
  }) {
    try {
      LoggingService.instance.info('Database operation tracked', {
        'operation': operation,
        'duration_ms': durationMs,
        'success': success,
        'error': error,
        'metric_type': 'database',
        'metric_name': 'database_operation',
        'threshold_ms': 1000,
        'is_slow': durationMs > 1000,
        ...?context,
      });

      // Enviar breadcrumb a Sentry
      Sentry.addBreadcrumb(
        Breadcrumb(
          message: 'Database operation: $operation',
          category: 'database.operation',
          level: success ? SentryLevel.info : SentryLevel.error,
          data: {
            'operation': operation,
            'duration_ms': durationMs,
            'success': success,
            'error': error,
            'is_slow': durationMs > 1000,
          },
        ),
      );
    } catch (e) {
      LoggingService.instance.error('Failed to track database operation: $e');
    }
  }

  /// Records import/export operation metric
  static void trackImportExportOperation({
    required String operation,
    required String fileType,
    required int durationMs,
    required bool success,
    required int dataSize,
    String? error,
    Map<String, dynamic>? context,
  }) {
    try {
      LoggingService.instance.info('Import/Export operation tracked', {
        'operation': operation,
        'file_type': fileType,
        'duration_ms': durationMs,
        'success': success,
        'data_size': dataSize,
        'error': error,
        'metric_type': 'data_management',
        'metric_name': 'import_export_operation',
        'threshold_ms': 5000,
        'is_slow': durationMs > 5000,
        'data_size_mb': (dataSize / 1024 / 1024).toStringAsFixed(2),
        ...?context,
      });

      // Enviar breadcrumb a Sentry
      Sentry.addBreadcrumb(
        Breadcrumb(
          message: 'Import/Export operation: $operation',
          category: 'data_management.operation',
          level: success ? SentryLevel.info : SentryLevel.error,
          data: {
            'operation': operation,
            'file_type': fileType,
            'duration_ms': durationMs,
            'success': success,
            'data_size': dataSize,
            'error': error,
            'is_slow': durationMs > 5000,
          },
        ),
      );
    } catch (e) {
      LoggingService.instance.error('Failed to track import/export operation: $e');
    }
  }

  /// Records workout session metric
  static void trackWorkoutSession({
    required String sessionId,
    required int durationMs,
    required int exerciseCount,
    required int setCount,
    required bool completed,
    Map<String, dynamic>? context,
  }) {
    try {
      LoggingService.instance.info('Workout session tracked', {
        'session_id': sessionId,
        'duration_ms': durationMs,
        'exercise_count': exerciseCount,
        'set_count': setCount,
        'completed': completed,
        'metric_type': 'usage',
        'metric_name': 'workout_session',
        'duration_minutes': (durationMs / 60000).toStringAsFixed(1),
        ...?context,
      });

      // Enviar breadcrumb a Sentry
      Sentry.addBreadcrumb(
        Breadcrumb(
          message: 'Workout session: $sessionId',
          category: 'usage.workout_session',
          level: completed ? SentryLevel.info : SentryLevel.warning,
          data: {
            'session_id': sessionId,
            'duration_ms': durationMs,
            'exercise_count': exerciseCount,
            'set_count': setCount,
            'completed': completed,
          },
        ),
      );
    } catch (e) {
      LoggingService.instance.error('Failed to track workout session: $e');
    }
  }

  /// Records memory usage metric
  static void trackMemoryUsage({
    required int currentMemoryMB,
    required int peakMemoryMB,
    required String operation,
    Map<String, dynamic>? context,
  }) {
    try {
      LoggingService.instance.info('Memory usage tracked', {
        'current_memory_mb': currentMemoryMB,
        'peak_memory_mb': peakMemoryMB,
        'operation': operation,
        'metric_type': 'performance',
        'metric_name': 'memory_usage',
        'threshold_mb': 100,
        'is_high': currentMemoryMB > 100,
        ...?context,
      });

      // Enviar breadcrumb a Sentry
      Sentry.addBreadcrumb(
        Breadcrumb(
          message: 'Memory usage: ${currentMemoryMB}MB during $operation',
          category: 'performance.memory',
          level: currentMemoryMB > 100 ? SentryLevel.warning : SentryLevel.info,
          data: {
            'current_memory_mb': currentMemoryMB,
            'peak_memory_mb': peakMemoryMB,
            'operation': operation,
            'is_high': currentMemoryMB > 100,
          },
        ),
      );
    } catch (e) {
      LoggingService.instance.error('Failed to track memory usage: $e');
    }
  }

  /// Records error metric
  static void trackError({
    required String errorType,
    required String component,
    required String severity,
    required bool isRecoverable,
    Map<String, dynamic>? context,
  }) {
    try {
      LoggingService.instance.info('Error tracked', {
        'error_type': errorType,
        'component': component,
        'severity': severity,
        'is_recoverable': isRecoverable,
        'metric_type': 'error',
        'metric_name': 'error_occurrence',
        'timestamp': DateTime.now().toIso8601String(),
        ...?context,
      });

      // Enviar breadcrumb a Sentry
      Sentry.addBreadcrumb(
        Breadcrumb(
          message: 'Error: $errorType in $component',
          category: 'error.occurrence',
          level:
              severity == 'critical'
                  ? SentryLevel.fatal
                  : severity == 'high'
                  ? SentryLevel.error
                  : severity == 'medium'
                  ? SentryLevel.warning
                  : SentryLevel.info,
          data: {
            'error_type': errorType,
            'component': component,
            'severity': severity,
            'is_recoverable': isRecoverable,
          },
        ),
      );
    } catch (e) {
      LoggingService.instance.error('Failed to track error: $e');
    }
  }

  /// Records feature usage metric
  static void trackFeatureUsage({
    required String feature,
    required String action,
    required bool success,
    Map<String, dynamic>? context,
  }) {
    try {
      LoggingService.instance.info('Feature usage tracked', {
        'feature': feature,
        'action': action,
        'success': success,
        'metric_type': 'usage',
        'metric_name': 'feature_usage',
        'timestamp': DateTime.now().toIso8601String(),
        ...?context,
      });

      // Enviar breadcrumb a Sentry
      Sentry.addBreadcrumb(
        Breadcrumb(
          message: 'Feature usage: $action in $feature',
          category: 'usage.feature',
          level: success ? SentryLevel.info : SentryLevel.warning,
          data: {'feature': feature, 'action': action, 'success': success},
        ),
      );
    } catch (e) {
      LoggingService.instance.error('Failed to track feature usage: $e');
    }
  }

  /// Retrieves performance statistics from PerformanceMonitor
  static Map<String, dynamic> getPerformanceStats() {
    try {
      final stats = PerformanceMonitor.instance.getAllStats();

      LoggingService.instance.info('Performance stats retrieved', {
        'total_operations': stats.length,
        'operations': stats.keys.toList(),
        'metric_type': 'performance',
        'metric_name': 'performance_stats_summary',
      });

      return stats;
    } catch (e) {
      LoggingService.instance.error('Failed to get performance stats: $e');
      return {};
    }
  }

  /// Sends metrics report to Sentry
  static void sendMetricsReport() {
    try {
      final performanceStats = getPerformanceStats();

      LoggingService.instance.info('Sending metrics report to Sentry', {
        'performance_operations_count': performanceStats.length,
        'report_timestamp': DateTime.now().toIso8601String(),
        'metric_type': 'report',
        'metric_name': 'metrics_report',
      });

      // Enviar breadcrumb con resumen de métricas
      Sentry.addBreadcrumb(
        Breadcrumb(
          message: 'Metrics report sent',
          category: 'metrics.report',
          level: SentryLevel.info,
          data: {
            'performance_operations_count': performanceStats.length,
            'report_timestamp': DateTime.now().toIso8601String(),
          },
        ),
      );
    } catch (e) {
      LoggingService.instance.error('Failed to send metrics report: $e');
    }
  }
}
