import 'package:flutter_test/flutter_test.dart';
import 'package:liftup/core/logging/logging_service.dart';

void main() {
  group('LoggingService', () {
    late LoggingService loggingService;

    setUp(() {
      loggingService = LoggingService.instance;
      loggingService.initialize(enableConsoleLogging: false, enableSentryLogging: false);
    });

    test('should initialize successfully', () {
      expect(loggingService, isNotNull);
    });

    test('should log debug messages', () {
      expect(() => loggingService.debug('Test debug message'), returnsNormally);
    });

    test('should log info messages', () {
      expect(() => loggingService.info('Test info message'), returnsNormally);
    });

    test('should log warning messages', () {
      expect(() => loggingService.warning('Test warning message'), returnsNormally);
    });

    test('should log error messages', () {
      expect(() => loggingService.error('Test error message'), returnsNormally);
    });

    test('should log fatal messages', () {
      expect(() => loggingService.fatal('Test fatal message'), returnsNormally);
    });

    test('should log with context', () {
      expect(() => loggingService.info('Test message', {'user_id': '123', 'action': 'test'}), returnsNormally);
    });

    test('should log errors with stack trace', () {
      try {
        throw Exception('Test exception');
      } catch (e, stackTrace) {
        expect(() => loggingService.error('Test error', e, stackTrace), returnsNormally);
      }
    });

    test('should add breadcrumbs', () {
      expect(() => loggingService.addBreadcrumb('Test breadcrumb'), returnsNormally);
    });

    test('should set user context', () {
      expect(() => loggingService.setUserContext(userId: 'test_user', username: 'test_username'), returnsNormally);
    });

    test('should set tags', () {
      expect(() => loggingService.setTag('test_tag', 'test_value'), returnsNormally);
    });

    test('should set context', () {
      expect(() => loggingService.setContext('test_context', {'key': 'value'}), returnsNormally);
    });
  });
}
