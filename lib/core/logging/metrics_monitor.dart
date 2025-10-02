import 'dart:async';
import 'dart:io';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'logging_service.dart';
import 'performance_monitor.dart';
import 'sentry_alerts_config.dart';

/// Monitor de métricas en tiempo real
class MetricsMonitor {
  static MetricsMonitor? _instance;
  static MetricsMonitor get instance => _instance ??= MetricsMonitor._();

  MetricsMonitor._();

  Timer? _metricsTimer;
  Timer? _memoryTimer;
  bool _isMonitoring = false;

  /// Inicia el monitoreo de métricas
  void startMonitoring() {
    if (_isMonitoring) return;

    try {
      LoggingService.instance.info('Starting metrics monitoring');
      
      _isMonitoring = true;
      
      // Monitorear métricas cada 30 segundos
      _metricsTimer = Timer.periodic(const Duration(seconds: 30), (_) {
        _collectAndSendMetrics();
      });
      
      // Monitorear memoria cada 10 segundos
      _memoryTimer = Timer.periodic(const Duration(seconds: 10), (_) {
        _monitorMemoryUsage();
      });
      
      LoggingService.instance.info('Metrics monitoring started successfully');
    } catch (e, stackTrace) {
      LoggingService.instance.error(
        'Failed to start metrics monitoring',
        e,
        stackTrace,
        {'component': 'metrics_monitor'},
      );
    }
  }

  /// Detiene el monitoreo de métricas
  void stopMonitoring() {
    if (!_isMonitoring) return;

    try {
      LoggingService.instance.info('Stopping metrics monitoring');
      
      _metricsTimer?.cancel();
      _memoryTimer?.cancel();
      _metricsTimer = null;
      _memoryTimer = null;
      _isMonitoring = false;
      
      LoggingService.instance.info('Metrics monitoring stopped successfully');
    } catch (e, stackTrace) {
      LoggingService.instance.error(
        'Failed to stop metrics monitoring',
        e,
        stackTrace,
        {'component': 'metrics_monitor'},
      );
    }
  }

  /// Recolecta y envía métricas
  void _collectAndSendMetrics() {
    try {
      // Obtener estadísticas de rendimiento
      final performanceStats = PerformanceMonitor.instance.getAllStats();
      
      // Obtener métricas del sistema
      final systemMetrics = _getSystemMetrics();
      
      // Enviar métricas a Sentry
      _sendMetricsToSentry(performanceStats, systemMetrics);
      
      LoggingService.instance.debug('Metrics collected and sent', {
        'performance_operations': performanceStats.length,
        'system_metrics_count': systemMetrics.length,
        'component': 'metrics_monitor',
      });
    } catch (e, stackTrace) {
      LoggingService.instance.error(
        'Failed to collect and send metrics',
        e,
        stackTrace,
        {'component': 'metrics_monitor'},
      );
    }
  }

  /// Monitorea el uso de memoria
  void _monitorMemoryUsage() {
    try {
      final memoryInfo = _getMemoryInfo();
      
      if (memoryInfo['current_memory_mb'] > 100) {
        LoggingService.instance.warning('High memory usage detected', {
          'current_memory_mb': memoryInfo['current_memory_mb'],
          'peak_memory_mb': memoryInfo['peak_memory_mb'],
          'threshold_mb': 100,
          'component': 'metrics_monitor',
        });
        
        // Enviar alerta de memoria
        SentryAlertsConfig.alertMemoryIssue(
          currentMemoryMB: memoryInfo['current_memory_mb'],
          thresholdMB: 100,
          operation: 'background_monitoring',
        );
      }
    } catch (e, stackTrace) {
      LoggingService.instance.error(
        'Failed to monitor memory usage',
        e,
        stackTrace,
        {'component': 'metrics_monitor'},
      );
    }
  }

  /// Obtiene métricas del sistema
  Map<String, dynamic> _getSystemMetrics() {
    try {
      final memoryInfo = _getMemoryInfo();
      final performanceStats = PerformanceMonitor.instance.getAllStats();
      
      return {
        'memory': memoryInfo,
        'performance': {
          'total_operations': performanceStats.length,
          'operations': performanceStats.keys.toList(),
        },
        'timestamp': DateTime.now().toIso8601String(),
        'platform': Platform.operatingSystem,
      };
    } catch (e) {
      LoggingService.instance.error('Failed to get system metrics: $e');
      return {};
    }
  }

  /// Obtiene información de memoria
  Map<String, dynamic> _getMemoryInfo() {
    try {
      // En Flutter, no tenemos acceso directo a la memoria del sistema
      // Pero podemos usar ProcessInfo para obtener información básica
      final processInfo = ProcessInfo.currentRss;
      final memoryMB = (processInfo / 1024 / 1024).round();
      
      return {
        'current_memory_mb': memoryMB,
        'peak_memory_mb': memoryMB, // En Flutter no tenemos acceso al peak real
        'memory_unit': 'MB',
        'timestamp': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      LoggingService.instance.error('Failed to get memory info: $e');
      return {
        'current_memory_mb': 0,
        'peak_memory_mb': 0,
        'error': e.toString(),
      };
    }
  }

  /// Envía métricas a Sentry
  void _sendMetricsToSentry(
    Map<String, dynamic> performanceStats,
    Map<String, dynamic> systemMetrics,
  ) {
    try {
      // Enviar breadcrumb con métricas
      Sentry.addBreadcrumb(Breadcrumb(
        message: 'Metrics report',
        category: 'metrics.report',
        level: SentryLevel.info,
        data: {
          'performance_operations_count': performanceStats.length,
          'memory_mb': systemMetrics['memory']?['current_memory_mb'] ?? 0,
          'timestamp': DateTime.now().toIso8601String(),
        },
      ));
      
      // Enviar contexto de métricas
      LoggingService.instance.setContext('metrics_report', {
        'performance_stats': performanceStats,
        'system_metrics': systemMetrics,
        'report_timestamp': DateTime.now().toIso8601String(),
      });
      
      LoggingService.instance.debug('Metrics sent to Sentry', {
        'performance_operations': performanceStats.length,
        'memory_mb': systemMetrics['memory']?['current_memory_mb'] ?? 0,
        'component': 'metrics_monitor',
      });
    } catch (e, stackTrace) {
      LoggingService.instance.error(
        'Failed to send metrics to Sentry',
        e,
        stackTrace,
        {'component': 'metrics_monitor'},
      );
    }
  }

  /// Obtiene estadísticas de monitoreo
  Map<String, dynamic> getMonitoringStats() {
    try {
      final performanceStats = PerformanceMonitor.instance.getAllStats();
      final memoryInfo = _getMemoryInfo();
      
      return {
        'is_monitoring': _isMonitoring,
        'performance_operations': performanceStats.length,
        'memory_info': memoryInfo,
        'monitoring_started_at': _isMonitoring ? DateTime.now().toIso8601String() : null,
        'component': 'metrics_monitor',
      };
    } catch (e) {
      LoggingService.instance.error('Failed to get monitoring stats: $e');
      return {
        'is_monitoring': _isMonitoring,
        'error': e.toString(),
      };
    }
  }

  /// Fuerza la recolección de métricas
  void forceMetricsCollection() {
    try {
      LoggingService.instance.info('Forcing metrics collection');
      _collectAndSendMetrics();
      LoggingService.instance.info('Forced metrics collection completed');
    } catch (e, stackTrace) {
      LoggingService.instance.error(
        'Failed to force metrics collection',
        e,
        stackTrace,
        {'component': 'metrics_monitor'},
      );
    }
  }

  /// Verifica si el monitoreo está activo
  bool get isMonitoring => _isMonitoring;

  /// Obtiene el estado del monitoreo
  Map<String, dynamic> getMonitoringStatus() {
    return {
      'is_monitoring': _isMonitoring,
      'metrics_timer_active': _metricsTimer?.isActive ?? false,
      'memory_timer_active': _memoryTimer?.isActive ?? false,
      'component': 'metrics_monitor',
    };
  }
}
