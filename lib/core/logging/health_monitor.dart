import 'dart:async';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'logging_service.dart';
import 'performance_monitor.dart';
import 'metrics_monitor.dart';
import 'sentry_alerts_config.dart';

/// Monitor de salud de la aplicación
class HealthMonitor {
  static HealthMonitor? _instance;
  static HealthMonitor get instance => _instance ??= HealthMonitor._();

  HealthMonitor._();

  Timer? _healthTimer;
  bool _isMonitoring = false;
  Map<String, dynamic> _healthMetrics = {};
  int _errorCount = 0;
  int _warningCount = 0;
  DateTime? _lastHealthCheck;

  /// Inicia el monitoreo de salud
  void startMonitoring() {
    if (_isMonitoring) return;

    try {
      LoggingService.instance.info('Starting health monitoring');

      _isMonitoring = true;
      _errorCount = 0;
      _warningCount = 0;
      _lastHealthCheck = DateTime.now();

      // Monitorear salud cada 60 segundos
      _healthTimer = Timer.periodic(const Duration(seconds: 60), (_) {
        _performHealthCheck();
      });

      LoggingService.instance.info('Health monitoring started successfully');
    } catch (e, stackTrace) {
      LoggingService.instance.error(
        'Failed to start health monitoring',
        e,
        stackTrace,
        {'component': 'health_monitor'},
      );
    }
  }

  /// Detiene el monitoreo de salud
  void stopMonitoring() {
    if (!_isMonitoring) return;

    try {
      LoggingService.instance.info('Stopping health monitoring');

      _healthTimer?.cancel();
      _healthTimer = null;
      _isMonitoring = false;

      LoggingService.instance.info('Health monitoring stopped successfully');
    } catch (e, stackTrace) {
      LoggingService.instance.error(
        'Failed to stop health monitoring',
        e,
        stackTrace,
        {'component': 'health_monitor'},
      );
    }
  }

  /// Realiza una verificación de salud
  void _performHealthCheck() {
    try {
      _lastHealthCheck = DateTime.now();

      // Recolectar métricas de salud
      final healthMetrics = _collectHealthMetrics();

      // Evaluar el estado de salud
      final healthStatus = _evaluateHealthStatus(healthMetrics);

      // Actualizar métricas
      _healthMetrics = healthMetrics;

      // Enviar reporte de salud
      _sendHealthReport(healthStatus, healthMetrics);

      LoggingService.instance.debug('Health check completed', {
        'health_status': healthStatus['status'],
        'error_count': _errorCount,
        'warning_count': _warningCount,
        'component': 'health_monitor',
      });
    } catch (e, stackTrace) {
      LoggingService.instance.error(
        'Failed to perform health check',
        e,
        stackTrace,
        {'component': 'health_monitor'},
      );
    }
  }

  /// Recolecta métricas de salud
  Map<String, dynamic> _collectHealthMetrics() {
    try {
      final performanceStats = PerformanceMonitor.instance.getAllStats();
      final monitoringStats = MetricsMonitor.instance.getMonitoringStats();

      return {
        'performance': {
          'total_operations': performanceStats.length,
          'slow_operations': _countSlowOperations(performanceStats),
          'failed_operations': _countFailedOperations(performanceStats),
        },
        'monitoring': {
          'is_monitoring': monitoringStats['is_monitoring'] ?? false,
          'memory_mb':
              monitoringStats['memory_info']?['current_memory_mb'] ?? 0,
        },
        'errors': {
          'error_count': _errorCount,
          'warning_count': _warningCount,
          'error_rate': _calculateErrorRate(),
        },
        'timestamp': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      LoggingService.instance.error('Failed to collect health metrics: $e');
      return {
        'error': e.toString(),
        'timestamp': DateTime.now().toIso8601String(),
      };
    }
  }

  /// Evalúa el estado de salud
  Map<String, dynamic> _evaluateHealthStatus(Map<String, dynamic> metrics) {
    try {
      final performance = metrics['performance'] ?? {};
      final monitoring = metrics['monitoring'] ?? {};
      final errors = metrics['errors'] ?? {};

      final totalOperations = performance['total_operations'] ?? 0;
      final slowOperations = performance['slow_operations'] ?? 0;
      final failedOperations = performance['failed_operations'] ?? 0;
      final errorCount = errors['error_count'] ?? 0;
      final warningCount = errors['warning_count'] ?? 0;
      final memoryMB = monitoring['memory_mb'] ?? 0;

      // Calcular puntuación de salud (0-100)
      int healthScore = 100;

      // Penalizar por operaciones lentas
      if (totalOperations > 0) {
        final slowRate = slowOperations / totalOperations;
        if (slowRate > 0.1) healthScore -= 20; // Más del 10% son lentas
        if (slowRate > 0.3) healthScore -= 30; // Más del 30% son lentas
      }

      // Penalizar por operaciones fallidas
      if (totalOperations > 0) {
        final failureRate = failedOperations / totalOperations;
        if (failureRate > 0.05) healthScore -= 25; // Más del 5% fallan
        if (failureRate > 0.15) healthScore -= 40; // Más del 15% fallan
      }

      // Penalizar por errores
      if (errorCount > 10) healthScore -= 15;
      if (errorCount > 50) healthScore -= 25;

      // Penalizar por uso de memoria
      if (memoryMB > 150) healthScore -= 10;
      if (memoryMB > 200) healthScore -= 20;

      // Determinar estado
      String status;
      String severity;

      if (healthScore >= 90) {
        status = 'excellent';
        severity = 'low';
      } else if (healthScore >= 70) {
        status = 'good';
        severity = 'low';
      } else if (healthScore >= 50) {
        status = 'fair';
        severity = 'medium';
      } else if (healthScore >= 30) {
        status = 'poor';
        severity = 'high';
      } else {
        status = 'critical';
        severity = 'critical';
      }

      return {
        'status': status,
        'severity': severity,
        'health_score': healthScore,
        'total_operations': totalOperations,
        'slow_operations': slowOperations,
        'failed_operations': failedOperations,
        'error_count': errorCount,
        'warning_count': warningCount,
        'memory_mb': memoryMB,
        'timestamp': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      LoggingService.instance.error('Failed to evaluate health status: $e');
      return {
        'status': 'unknown',
        'severity': 'high',
        'health_score': 0,
        'error': e.toString(),
        'timestamp': DateTime.now().toIso8601String(),
      };
    }
  }

  /// Cuenta operaciones lentas
  int _countSlowOperations(Map<String, dynamic> performanceStats) {
    int count = 0;
    for (final entry in performanceStats.entries) {
      final stats = entry.value as Map<String, dynamic>;
      final avgDuration = stats['avg_duration_ms'] ?? 0;
      if (avgDuration > 1000) count++; // Más de 1 segundo
    }
    return count;
  }

  /// Cuenta operaciones fallidas
  int _countFailedOperations(Map<String, dynamic> performanceStats) {
    int count = 0;
    for (final entry in performanceStats.entries) {
      final stats = entry.value as Map<String, dynamic>;
      final errorCount = stats['error_count'] ?? 0;
      if (errorCount > 0) count++;
    }
    return count;
  }

  /// Calcula la tasa de errores
  double _calculateErrorRate() {
    final totalEvents = _errorCount + _warningCount;
    if (totalEvents == 0) return 0.0;
    return _errorCount / totalEvents;
  }

  /// Envía reporte de salud
  void _sendHealthReport(
    Map<String, dynamic> healthStatus,
    Map<String, dynamic> healthMetrics,
  ) {
    try {
      final status = healthStatus['status'] as String;
      final severity = healthStatus['severity'] as String;
      final healthScore = healthStatus['health_score'] as int;

      // Determinar nivel de log
      SentryLevel logLevel;
      if (severity == 'critical') {
        logLevel = SentryLevel.fatal;
      } else if (severity == 'high') {
        logLevel = SentryLevel.error;
      } else if (severity == 'medium') {
        logLevel = SentryLevel.warning;
      } else {
        logLevel = SentryLevel.info;
      }

      // Enviar breadcrumb de salud
      Sentry.addBreadcrumb(
        Breadcrumb(
          message: 'Health check: $status (Score: $healthScore)',
          category: 'health.check',
          level: logLevel,
          data: healthStatus,
        ),
      );

      // Enviar contexto de salud
      LoggingService.instance.setContext('health_status', {
        'status': status,
        'severity': severity,
        'health_score': healthScore,
        'metrics': healthMetrics,
        'last_check': DateTime.now().toIso8601String(),
      });

      // Enviar alerta si es necesario
      if (severity == 'critical' || severity == 'high') {
        SentryAlertsConfig.alertUserExperienceIssue(
          issue: 'Application health degraded',
          component: 'health_monitor',
          impact: 'Performance and stability issues detected',
          context: healthStatus,
        );
      }

      LoggingService.instance.debug('Health report sent', {
        'status': status,
        'severity': severity,
        'health_score': healthScore,
        'component': 'health_monitor',
      });
    } catch (e, stackTrace) {
      LoggingService.instance.error(
        'Failed to send health report',
        e,
        stackTrace,
        {'component': 'health_monitor'},
      );
    }
  }

  /// Registra un error
  void recordError() {
    _errorCount++;
    LoggingService.instance.debug('Error recorded', {
      'error_count': _errorCount,
      'component': 'health_monitor',
    });
  }

  /// Registra una advertencia
  void recordWarning() {
    _warningCount++;
    LoggingService.instance.debug('Warning recorded', {
      'warning_count': _warningCount,
      'component': 'health_monitor',
    });
  }

  /// Obtiene el estado de salud actual
  Map<String, dynamic> getCurrentHealthStatus() {
    return {
      'is_monitoring': _isMonitoring,
      'last_health_check': _lastHealthCheck?.toIso8601String(),
      'error_count': _errorCount,
      'warning_count': _warningCount,
      'health_metrics': _healthMetrics,
      'component': 'health_monitor',
    };
  }

  /// Fuerza una verificación de salud
  void forceHealthCheck() {
    try {
      LoggingService.instance.info('Forcing health check');
      _performHealthCheck();
      LoggingService.instance.info('Forced health check completed');
    } catch (e, stackTrace) {
      LoggingService.instance.error(
        'Failed to force health check',
        e,
        stackTrace,
        {'component': 'health_monitor'},
      );
    }
  }

  /// Verifica si el monitoreo está activo
  bool get isMonitoring => _isMonitoring;

  /// Obtiene el estado del monitoreo
  Map<String, dynamic> getMonitoringStatus() {
    return {
      'is_monitoring': _isMonitoring,
      'health_timer_active': _healthTimer?.isActive ?? false,
      'last_health_check': _lastHealthCheck?.toIso8601String(),
      'error_count': _errorCount,
      'warning_count': _warningCount,
      'component': 'health_monitor',
    };
  }
}
