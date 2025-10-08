import 'dart:async';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'logging_service.dart';

/// Servicio para monitorear el rendimiento de operaciones críticas
class PerformanceMonitor {
  static PerformanceMonitor? _instance;
  static PerformanceMonitor get instance =>
      _instance ??= PerformanceMonitor._();

  PerformanceMonitor._();

  final Map<String, DateTime> _startTimes = {};
  final Map<String, List<Duration>> _operationTimes = {};

  /// Inicia el monitoreo de una operación
  String startOperation(String operationName, {Map<String, dynamic>? context}) {
    final operationId =
        '${operationName}_${DateTime.now().millisecondsSinceEpoch}';
    _startTimes[operationId] = DateTime.now();

    LoggingService.instance.debug('Started operation: $operationName', {
      'operation_id': operationId,
      ...?context,
    });

    // Añadir breadcrumb para Sentry
    LoggingService.instance.addBreadcrumb(
      'Started operation: $operationName',
      category: 'performance',
      level: SentryLevel.info,
      data: {'operation_id': operationId, ...?context},
    );

    return operationId;
  }

  /// Finaliza el monitoreo de una operación
  void endOperation(String operationId, {Map<String, dynamic>? context}) {
    final startTime = _startTimes.remove(operationId);
    if (startTime == null) {
      LoggingService.instance.warning('Operation not found: $operationId');
      return;
    }

    final duration = DateTime.now().difference(startTime);
    final operationName = operationId.split('_').first;

    // Almacenar tiempo de operación
    _operationTimes.putIfAbsent(operationName, () => []).add(duration);

    LoggingService.instance.info('Completed operation: $operationName', {
      'operation_id': operationId,
      'duration_ms': duration.inMilliseconds,
      'duration_seconds': duration.inSeconds,
      ...?context,
    });

    // Añadir breadcrumb para Sentry
    LoggingService.instance.addBreadcrumb(
      'Completed operation: $operationName',
      category: 'performance',
      level: SentryLevel.info,
      data: {
        'operation_id': operationId,
        'duration_ms': duration.inMilliseconds,
        ...?context,
      },
    );

    // Enviar métrica a Sentry si la operación es lenta
    if (duration.inMilliseconds > 1000) {
      _sendSlowOperationMetric(operationName, duration, context);
    }
  }

  /// Envía métrica de operación lenta a Sentry
  void _sendSlowOperationMetric(
    String operationName,
    Duration duration,
    Map<String, dynamic>? context,
  ) {
    try {
      Sentry.addBreadcrumb(
        Breadcrumb(
          message: 'Slow operation detected: $operationName',
          category: 'performance.warning',
          level: SentryLevel.warning,
          data: {
            'operation_name': operationName,
            'duration_ms': duration.inMilliseconds,
            'threshold_ms': 1000,
            ...?context,
          },
          timestamp: DateTime.now(),
        ),
      );
    } catch (e) {
      LoggingService.instance.warning(
        'Failed to send slow operation metric: $e',
      );
    }
  }

  /// Obtiene estadísticas de rendimiento para una operación
  Map<String, dynamic> getOperationStats(String operationName) {
    final times = _operationTimes[operationName];
    if (times == null || times.isEmpty) {
      return {
        'operation_name': operationName,
        'count': 0,
        'average_ms': 0,
        'min_ms': 0,
        'max_ms': 0,
      };
    }

    final totalMs = times.map((d) => d.inMilliseconds).reduce((a, b) => a + b);
    final minMs = times
        .map((d) => d.inMilliseconds)
        .reduce((a, b) => a < b ? a : b);
    final maxMs = times
        .map((d) => d.inMilliseconds)
        .reduce((a, b) => a > b ? a : b);

    return {
      'operation_name': operationName,
      'count': times.length,
      'average_ms': (totalMs / times.length).round(),
      'min_ms': minMs,
      'max_ms': maxMs,
      'total_ms': totalMs,
    };
  }

  /// Obtiene estadísticas de todas las operaciones
  Map<String, Map<String, dynamic>> getAllStats() {
    final stats = <String, Map<String, dynamic>>{};
    for (final operationName in _operationTimes.keys) {
      stats[operationName] = getOperationStats(operationName);
    }
    return stats;
  }

  /// Limpia las estadísticas de rendimiento
  void clearStats() {
    _operationTimes.clear();
    LoggingService.instance.info('Performance statistics cleared');
  }

  /// Monitorea una operación asíncrona
  Future<T> monitorAsync<T>(
    String operationName,
    Future<T> Function() operation, {
    Map<String, dynamic>? context,
  }) async {
    final operationId = startOperation(operationName, context: context);

    try {
      final result = await operation();
      endOperation(operationId, context: context);
      return result;
    } catch (e, stackTrace) {
      endOperation(
        operationId,
        context: {...?context, 'error': e.toString(), 'failed': true},
      );

      LoggingService.instance.error(
        'Operation failed: $operationName',
        e,
        stackTrace,
        context,
      );
      rethrow;
    }
  }

  /// Monitorea una operación síncrona
  T monitorSync<T>(
    String operationName,
    T Function() operation, {
    Map<String, dynamic>? context,
  }) {
    final operationId = startOperation(operationName, context: context);

    try {
      final result = operation();
      endOperation(operationId, context: context);
      return result;
    } catch (e, stackTrace) {
      endOperation(
        operationId,
        context: {...?context, 'error': e.toString(), 'failed': true},
      );

      LoggingService.instance.error(
        'Operation failed: $operationName',
        e,
        stackTrace,
        context,
      );
      rethrow;
    }
  }

  /// Envía estadísticas de rendimiento a Sentry
  void sendPerformanceReport() {
    try {
      final stats = getAllStats();
      if (stats.isEmpty) return;

      LoggingService.instance.info('Sending performance report', {
        'operations_count': stats.length,
        'total_operations': stats.values.fold(
          0,
          (sum, stat) => sum + (stat['count'] as int),
        ),
      });

      // Enviar cada estadística como un evento personalizado
      for (final entry in stats.entries) {
        final operationName = entry.key;
        final stat = entry.value;

        Sentry.addBreadcrumb(
          Breadcrumb(
            message: 'Performance stats: $operationName',
            category: 'performance.stats',
            level: SentryLevel.info,
            data: stat,
            timestamp: DateTime.now(),
          ),
        );
      }
    } catch (e) {
      LoggingService.instance.error('Failed to send performance report: $e');
    }
  }
}
