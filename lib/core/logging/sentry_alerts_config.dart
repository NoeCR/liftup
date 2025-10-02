import 'package:sentry_flutter/sentry_flutter.dart';
import 'logging_service.dart';

/// Configuración de alertas para Sentry
class SentryAlertsConfig {
  /// Configura alertas automáticas basadas en patrones de error
  static void configureAlerts() {
    try {
      LoggingService.instance.info('Configuring Sentry alerts');
      
      // Configurar breadcrumbs para alertas
      _setupAlertBreadcrumbs();
      
      // Configurar contexto para alertas
      _setupAlertContext();
      
      LoggingService.instance.info('Sentry alerts configured successfully');
    } catch (e, stackTrace) {
      LoggingService.instance.error(
        'Failed to configure Sentry alerts',
        e,
        stackTrace,
        {'component': 'sentry_alerts_config'},
      );
    }
  }

  /// Configura breadcrumbs para alertas
  static void _setupAlertBreadcrumbs() {
    // Breadcrumb para errores críticos de base de datos
    LoggingService.instance.addBreadcrumb(
      'Database critical error detected',
      category: 'alert.database',
      level: SentryLevel.error,
      data: {
        'alert_type': 'database_critical',
        'threshold': 'immediate',
      },
    );

    // Breadcrumb para errores de importación/exportación
    LoggingService.instance.addBreadcrumb(
      'Data import/export error detected',
      category: 'alert.data_management',
      level: SentryLevel.error,
      data: {
        'alert_type': 'data_management',
        'threshold': 'immediate',
      },
    );

    // Breadcrumb para errores de rendimiento
    LoggingService.instance.addBreadcrumb(
      'Performance degradation detected',
      category: 'alert.performance',
      level: SentryLevel.warning,
      data: {
        'alert_type': 'performance',
        'threshold': '1_second',
      },
    );
  }

  /// Configura contexto para alertas
  static void _setupAlertContext() {
    LoggingService.instance.setContext('alerts', {
      'database_critical_threshold': 'immediate',
      'performance_threshold_ms': 1000,
      'data_management_threshold': 'immediate',
      'user_experience_threshold': 'warning',
      'configured_at': DateTime.now().toIso8601String(),
    });
  }

  /// Envía alerta personalizada para errores críticos de base de datos
  static void alertDatabaseCritical({
    required String operation,
    required String error,
    Map<String, dynamic>? context,
  }) {
    try {
      LoggingService.instance.fatal('Database critical error', {
        'operation': operation,
        'error': error,
        'alert_type': 'database_critical',
        'severity': 'critical',
        'requires_immediate_attention': true,
        ...?context,
      });

      // Añadir breadcrumb específico
      LoggingService.instance.addBreadcrumb(
        'Database critical error: $operation',
        category: 'alert.database.critical',
        level: SentryLevel.fatal,
        data: {
          'operation': operation,
          'error': error,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      LoggingService.instance.error('Failed to send database critical alert: $e');
    }
  }

  /// Envía alerta para errores de rendimiento
  static void alertPerformanceIssue({
    required String operation,
    required int durationMs,
    required int thresholdMs,
    Map<String, dynamic>? context,
  }) {
    try {
      final severity = durationMs > thresholdMs * 2 ? 'high' : 'medium';
      
      LoggingService.instance.warning('Performance issue detected', {
        'operation': operation,
        'duration_ms': durationMs,
        'threshold_ms': thresholdMs,
        'exceeded_by': durationMs - thresholdMs,
        'exceeded_by_percentage': ((durationMs - thresholdMs) / thresholdMs * 100).round(),
        'alert_type': 'performance',
        'severity': severity,
        ...?context,
      });

      // Añadir breadcrumb específico
      LoggingService.instance.addBreadcrumb(
        'Performance issue: $operation took ${durationMs}ms',
        category: 'alert.performance',
        level: SentryLevel.warning,
        data: {
          'operation': operation,
          'duration_ms': durationMs,
          'threshold_ms': thresholdMs,
          'severity': severity,
        },
      );
    } catch (e) {
      LoggingService.instance.error('Failed to send performance alert: $e');
    }
  }

  /// Envía alerta para errores de importación/exportación
  static void alertDataManagementError({
    required String operation,
    required String error,
    required String fileType,
    Map<String, dynamic>? context,
  }) {
    try {
      LoggingService.instance.error('Data management error', {
        'operation': operation,
        'error': error,
        'file_type': fileType,
        'alert_type': 'data_management',
        'severity': 'high',
        'user_impact': 'data_loss_risk',
        ...?context,
      });

      // Añadir breadcrumb específico
      LoggingService.instance.addBreadcrumb(
        'Data management error: $operation',
        category: 'alert.data_management',
        level: SentryLevel.error,
        data: {
          'operation': operation,
          'error': error,
          'file_type': fileType,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      LoggingService.instance.error('Failed to send data management alert: $e');
    }
  }

  /// Envía alerta para errores de experiencia de usuario
  static void alertUserExperienceIssue({
    required String issue,
    required String component,
    required String impact,
    Map<String, dynamic>? context,
  }) {
    try {
      LoggingService.instance.warning('User experience issue detected', {
        'issue': issue,
        'component': component,
        'impact': impact,
        'alert_type': 'user_experience',
        'severity': 'medium',
        'user_affected': true,
        ...?context,
      });

      // Añadir breadcrumb específico
      LoggingService.instance.addBreadcrumb(
        'UX issue: $issue in $component',
        category: 'alert.user_experience',
        level: SentryLevel.warning,
        data: {
          'issue': issue,
          'component': component,
          'impact': impact,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      LoggingService.instance.error('Failed to send UX alert: $e');
    }
  }

  /// Envía alerta para errores de configuración
  static void alertConfigurationError({
    required String configType,
    required String error,
    required bool isCritical,
    Map<String, dynamic>? context,
  }) {
    try {
      final level = isCritical ? LogLevel.fatal : LogLevel.error;
      final sentryLevel = isCritical ? SentryLevel.fatal : SentryLevel.error;
      
      if (level == LogLevel.fatal) {
        LoggingService.instance.fatal('Configuration error', null, null, {
          'config_type': configType,
          'error': error,
          'is_critical': isCritical,
          'alert_type': 'configuration',
          'severity': isCritical ? 'critical' : 'high',
          'system_impact': isCritical ? 'system_unstable' : 'feature_limited',
          ...?context,
        });
      } else {
        LoggingService.instance.error('Configuration error', null, null, {
          'config_type': configType,
          'error': error,
          'is_critical': isCritical,
          'alert_type': 'configuration',
          'severity': isCritical ? 'critical' : 'high',
          'system_impact': isCritical ? 'system_unstable' : 'feature_limited',
          ...?context,
        });
      }

      // Añadir breadcrumb específico
      LoggingService.instance.addBreadcrumb(
        'Configuration error: $configType',
        category: 'alert.configuration',
        level: sentryLevel,
        data: {
          'config_type': configType,
          'error': error,
          'is_critical': isCritical,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      LoggingService.instance.error('Failed to send configuration alert: $e');
    }
  }

  /// Envía alerta para errores de memoria
  static void alertMemoryIssue({
    required int currentMemoryMB,
    required int thresholdMB,
    required String operation,
    Map<String, dynamic>? context,
  }) {
    try {
      final severity = currentMemoryMB > thresholdMB * 1.5 ? 'high' : 'medium';
      
      LoggingService.instance.warning('Memory usage issue detected', {
        'current_memory_mb': currentMemoryMB,
        'threshold_mb': thresholdMB,
        'operation': operation,
        'usage_percentage': (currentMemoryMB / thresholdMB * 100).round(),
        'alert_type': 'memory',
        'severity': severity,
        'potential_crash_risk': currentMemoryMB > thresholdMB * 1.5,
        ...?context,
      });

      // Añadir breadcrumb específico
      LoggingService.instance.addBreadcrumb(
        'Memory issue: ${currentMemoryMB}MB used during $operation',
        category: 'alert.memory',
        level: SentryLevel.warning,
        data: {
          'current_memory_mb': currentMemoryMB,
          'threshold_mb': thresholdMB,
          'operation': operation,
          'severity': severity,
        },
      );
    } catch (e) {
      LoggingService.instance.error('Failed to send memory alert: $e');
    }
  }
}
