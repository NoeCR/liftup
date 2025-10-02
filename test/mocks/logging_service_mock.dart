import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:liftup/core/logging/logging_service.dart';
import 'package:liftup/core/logging/performance_monitor.dart';

/// Mock para LoggingService que simula todas las operaciones de logging
/// sin enviar datos reales a Sentry o otros servicios externos
class MockLoggingService extends Mock implements LoggingService {
  static MockLoggingService? _instance;

  static MockLoggingService getInstance() {
    _instance ??= MockLoggingService._();
    return _instance!;
  }

  MockLoggingService._();

  // Lista para almacenar logs capturados durante las pruebas
  final List<LogEntry> _capturedLogs = [];

  // Configurar el mock para que simule el comportamiento real
  void setupMockBehavior() {
    // Mock de todos los métodos de logging
    when(() => debug(any(), any())).thenAnswer((invocation) {
      _capturedLogs.add(
        LogEntry(
          level: LogLevel.debug,
          message: invocation.positionalArguments[0] as String,
          data: invocation.positionalArguments[1] as Map<String, dynamic>?,
          timestamp: DateTime.now(),
        ),
      );
    });

    when(() => info(any(), any())).thenAnswer((invocation) {
      _capturedLogs.add(
        LogEntry(
          level: LogLevel.info,
          message: invocation.positionalArguments[0] as String,
          data: invocation.positionalArguments[1] as Map<String, dynamic>?,
          timestamp: DateTime.now(),
        ),
      );
    });

    when(() => warning(any(), any())).thenAnswer((invocation) {
      _capturedLogs.add(
        LogEntry(
          level: LogLevel.warning,
          message: invocation.positionalArguments[0] as String,
          data: invocation.positionalArguments[1] as Map<String, dynamic>?,
          timestamp: DateTime.now(),
        ),
      );
    });

    when(() => error(any(), any(), any())).thenAnswer((invocation) {
      _capturedLogs.add(
        LogEntry(
          level: LogLevel.error,
          message: invocation.positionalArguments[0] as String,
          data: invocation.positionalArguments[1] as Map<String, dynamic>?,
          timestamp: DateTime.now(),
          error: invocation.positionalArguments[2] as Object?,
        ),
      );
    });

    when(() => fatal(any(), any(), any())).thenAnswer((invocation) {
      _capturedLogs.add(
        LogEntry(
          level: LogLevel.fatal,
          message: invocation.positionalArguments[0] as String,
          data: invocation.positionalArguments[1] as Map<String, dynamic>?,
          timestamp: DateTime.now(),
          error: invocation.positionalArguments[2] as Object?,
        ),
      );
    });
  }

  // Métodos para verificar logs capturados
  List<LogEntry> getCapturedLogs() => List.unmodifiable(_capturedLogs);

  List<LogEntry> getLogsByLevel(LogLevel level) {
    return _capturedLogs.where((log) => log.level == level).toList();
  }

  List<LogEntry> getLogsByMessage(String message) {
    return _capturedLogs.where((log) => log.message.contains(message)).toList();
  }

  bool hasLogWithMessage(String message) {
    return _capturedLogs.any((log) => log.message.contains(message));
  }

  bool hasLogWithLevel(LogLevel level) {
    return _capturedLogs.any((log) => log.level == level);
  }

  // Limpiar logs capturados
  void clearCapturedLogs() {
    _capturedLogs.clear();
  }

  // Verificar que se llamó un método específico
  void verifyLogCall(LogLevel level, String message) {
    // Para simplificar, solo verificamos que se capturó el log
    // En un test real, podrías implementar un sistema de tracking más sofisticado
    expect(hasLogWithMessage(message), isTrue);
    expect(hasLogWithLevel(level), isTrue);
  }
}

/// Mock para PerformanceMonitor
class MockPerformanceMonitor extends Mock implements PerformanceMonitor {
  static MockPerformanceMonitor? _instance;

  static MockPerformanceMonitor getInstance() {
    _instance ??= MockPerformanceMonitor._();
    return _instance!;
  }

  MockPerformanceMonitor._();

  final List<PerformanceEntry> _capturedMetrics = [];

  void setupMockBehavior() {
    when(
      () => monitorAsync(any(), any(), context: any(named: 'context')),
    ).thenAnswer((invocation) async {
      final operation = invocation.positionalArguments[0] as String;
      final function =
          invocation.positionalArguments[1] as Future<dynamic> Function();
      final context =
          invocation.namedArguments[#context] as Map<String, dynamic>?;

      final startTime = DateTime.now();
      final result = await function();
      final endTime = DateTime.now();
      final duration = endTime.difference(startTime).inMilliseconds;

      _capturedMetrics.add(
        PerformanceEntry(
          operation: operation,
          duration: duration,
          context: context,
          timestamp: startTime,
        ),
      );

      return result;
    });

    when(
      () => monitorSync(any(), any(), context: any(named: 'context')),
    ).thenAnswer((invocation) {
      final operation = invocation.positionalArguments[0] as String;
      final function = invocation.positionalArguments[1] as dynamic Function();
      final context =
          invocation.namedArguments[#context] as Map<String, dynamic>?;

      final startTime = DateTime.now();
      final result = function();
      final endTime = DateTime.now();
      final duration = endTime.difference(startTime).inMilliseconds;

      _capturedMetrics.add(
        PerformanceEntry(
          operation: operation,
          duration: duration,
          context: context,
          timestamp: startTime,
        ),
      );

      return result;
    });
  }

  List<PerformanceEntry> getCapturedMetrics() =>
      List.unmodifiable(_capturedMetrics);

  void clearCapturedMetrics() {
    _capturedMetrics.clear();
  }
}

/// Clases de datos para capturar logs y métricas
class LogEntry {
  final LogLevel level;
  final String message;
  final Map<String, dynamic>? data;
  final DateTime timestamp;
  final Object? error;
  final int? duration;

  LogEntry({
    required this.level,
    required this.message,
    this.data,
    required this.timestamp,
    this.error,
    this.duration,
  });
}

class PerformanceEntry {
  final String operation;
  final int duration;
  final Map<String, dynamic>? context;
  final DateTime timestamp;

  PerformanceEntry({
    required this.operation,
    required this.duration,
    this.context,
    required this.timestamp,
  });
}

enum LogLevel { debug, info, warning, error, fatal, performance }
