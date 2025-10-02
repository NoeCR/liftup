import 'package:flutter_test/flutter_test.dart';
import 'package:liftup/core/logging/performance_monitor.dart';

void main() {
  group('PerformanceMonitor', () {
    late PerformanceMonitor performanceMonitor;

    setUp(() {
      performanceMonitor = PerformanceMonitor.instance;
      performanceMonitor.clearStats(); // Limpiar estadísticas antes de cada test
    });

    test('should initialize successfully', () {
      expect(performanceMonitor, isNotNull);
    });

    test('should start and end operation', () {
      final operationId = performanceMonitor.startOperation('test_operation');
      expect(operationId, isNotEmpty);
      
      expect(() => performanceMonitor.endOperation(operationId), returnsNormally);
    });

    test('should monitor async operation', () async {
      final result = await performanceMonitor.monitorAsync(
        'test_async_operation',
        () async {
          await Future.delayed(Duration(milliseconds: 10));
          return 'test_result';
        },
      );
      
      expect(result, equals('test_result'));
    });

    test('should monitor sync operation', () {
      final result = performanceMonitor.monitorSync(
        'test_sync_operation',
        () => 'test_result',
      );
      
      expect(result, equals('test_result'));
    });

    test('should handle operation errors', () async {
      expect(() async {
        await performanceMonitor.monitorAsync(
          'test_error_operation',
          () async {
            throw Exception('Test error');
          },
        );
      }, throwsException);
    });

    test('should get operation stats', () {
      final operationId = performanceMonitor.startOperation('test_stats_operation');
      performanceMonitor.endOperation(operationId);
      
      final stats = performanceMonitor.getOperationStats('test');
      expect(stats['operation_name'], equals('test'));
      expect(stats['count'], equals(1));
      expect(stats['average_ms'], isA<int>());
    });

    test('should get all stats', () {
      final operationId = performanceMonitor.startOperation('test_all_stats_operation');
      performanceMonitor.endOperation(operationId);
      
      final allStats = performanceMonitor.getAllStats();
      expect(allStats, isA<Map<String, Map<String, dynamic>>>());
      expect(allStats.containsKey('test'), isTrue);
    });

    test('should clear stats', () {
      final operationId = performanceMonitor.startOperation('test_clear_operation');
      performanceMonitor.endOperation(operationId);
      
      performanceMonitor.clearStats();
      final stats = performanceMonitor.getOperationStats('test');
      expect(stats['count'], equals(0));
    });

    test('should send performance report', () {
      expect(() => performanceMonitor.sendPerformanceReport(), returnsNormally);
    });
  });
}
