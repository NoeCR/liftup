import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../test_helpers/test_setup.dart';
import '../../mocks/logging_service_mock.dart';

void main() {
  group('LoggingService Tests', () {
    late MockLoggingService mockLoggingService;

    setUpAll(() {
      TestSetup.initialize();
      mockLoggingService = TestSetup.mockLoggingService;
    });

    setUp(() {
      TestSetup.cleanup();
    });

    group('Logging Methods', () {
      test('should log debug messages', () {
        // Arrange
        const message = 'Debug test message';
        const data = {'component': 'test', 'action': 'debug_log'};

        // Act
        mockLoggingService.debug(message, data);

        // Assert
        verify(() => mockLoggingService.debug(message, data)).called(1);
        expect(mockLoggingService.hasLogWithMessage(message), isTrue);
        expect(mockLoggingService.hasLogWithLevel(LogLevel.debug), isTrue);

        final debugLogs = mockLoggingService.getLogsByLevel(LogLevel.debug);
        expect(debugLogs.length, equals(1));
        expect(debugLogs.first.message, equals(message));
        expect(debugLogs.first.data, equals(data));
      });

      test('should log info messages', () {
        // Arrange
        const message = 'Info test message';
        const data = {'component': 'test', 'action': 'info_log'};

        // Act
        mockLoggingService.info(message, data);

        // Assert
        verify(() => mockLoggingService.info(message, data)).called(1);
        expect(mockLoggingService.hasLogWithMessage(message), isTrue);
        expect(mockLoggingService.hasLogWithLevel(LogLevel.info), isTrue);

        final infoLogs = mockLoggingService.getLogsByLevel(LogLevel.info);
        expect(infoLogs.length, equals(1));
        expect(infoLogs.first.message, equals(message));
        expect(infoLogs.first.data, equals(data));
      });

      test('should log warning messages', () {
        // Arrange
        const message = 'Warning test message';
        const data = {'component': 'test', 'action': 'warning_log'};

        // Act
        mockLoggingService.warning(message, data);

        // Assert
        verify(() => mockLoggingService.warning(message, data)).called(1);
        expect(mockLoggingService.hasLogWithMessage(message), isTrue);
        expect(mockLoggingService.hasLogWithLevel(LogLevel.warning), isTrue);

        final warningLogs = mockLoggingService.getLogsByLevel(LogLevel.warning);
        expect(warningLogs.length, equals(1));
        expect(warningLogs.first.message, equals(message));
        expect(warningLogs.first.data, equals(data));
      });

      test('should log error messages', () {
        // Arrange
        const message = 'Error test message';
        const data = {'component': 'test', 'action': 'error_log'};

        // Act
        mockLoggingService.error(message, data, StackTrace.current);

        // Assert
        verify(() => mockLoggingService.error(message, data, any())).called(1);
        expect(mockLoggingService.hasLogWithMessage(message), isTrue);
        expect(mockLoggingService.hasLogWithLevel(LogLevel.error), isTrue);

        final errorLogs = mockLoggingService.getLogsByLevel(LogLevel.error);
        expect(errorLogs.length, equals(1));
        expect(errorLogs.first.message, equals(message));
        expect(errorLogs.first.data, equals(data));
        expect(errorLogs.first.error, isNotNull);
      });

      test('should log fatal messages', () {
        // Arrange
        const message = 'Fatal test message';
        const data = {'component': 'test', 'action': 'fatal_log'};

        // Act
        mockLoggingService.fatal(message, data, StackTrace.current);

        // Assert
        verify(() => mockLoggingService.fatal(message, data, any())).called(1);
        expect(mockLoggingService.hasLogWithMessage(message), isTrue);
        expect(mockLoggingService.hasLogWithLevel(LogLevel.fatal), isTrue);

        final fatalLogs = mockLoggingService.getLogsByLevel(LogLevel.fatal);
        expect(fatalLogs.length, equals(1));
        expect(fatalLogs.first.message, equals(message));
        expect(fatalLogs.first.data, equals(data));
        expect(fatalLogs.first.error, isNotNull);
      });
    });

    group('Log Filtering', () {
      test('should filter logs by level', () {
        // Arrange
        mockLoggingService.info('Info message 1', {});
        mockLoggingService.warning('Warning message 1', {});
        mockLoggingService.info('Info message 2', {});
        mockLoggingService.error(
          'Error message 1',
          <String, dynamic>{},
          StackTrace.current,
        );

        // Act
        final infoLogs = mockLoggingService.getLogsByLevel(LogLevel.info);
        final warningLogs = mockLoggingService.getLogsByLevel(LogLevel.warning);
        final errorLogs = mockLoggingService.getLogsByLevel(LogLevel.error);

        // Assert
        expect(infoLogs.length, equals(2));
        expect(warningLogs.length, equals(1));
        expect(errorLogs.length, equals(1));

        expect(infoLogs.every((log) => log.level == LogLevel.info), isTrue);
        expect(
          warningLogs.every((log) => log.level == LogLevel.warning),
          isTrue,
        );
        expect(errorLogs.every((log) => log.level == LogLevel.error), isTrue);
      });

      test('should filter logs by message content', () {
        // Arrange
        mockLoggingService.info('Database operation started', {});
        mockLoggingService.info('Database operation completed', {});
        mockLoggingService.warning('Network timeout occurred', {});
        mockLoggingService.info('User login successful', {});

        // Act
        final databaseLogs = mockLoggingService.getLogsByMessage('Database');
        final networkLogs = mockLoggingService.getLogsByMessage('Network');
        final userLogs = mockLoggingService.getLogsByMessage('User');

        // Assert
        expect(databaseLogs.length, equals(2));
        expect(networkLogs.length, equals(1));
        expect(userLogs.length, equals(1));

        expect(
          databaseLogs.every((log) => log.message.contains('Database')),
          isTrue,
        );
        expect(
          networkLogs.every((log) => log.message.contains('Network')),
          isTrue,
        );
        expect(userLogs.every((log) => log.message.contains('User')), isTrue);
      });
    });

    group('Log Verification', () {
      test('should verify specific log calls', () {
        // Arrange
        const message = 'Test verification message';
        const data = {'test': true};

        // Act
        mockLoggingService.info(message, data);

        // Assert
        TestSetup.verifyLogging(message: message, level: LogLevel.info);
        mockLoggingService.verifyLogCall(LogLevel.info, message);
      });

      test('should verify log existence without level', () {
        // Arrange
        const message = 'Test message existence';

        // Act
        mockLoggingService.warning(message, {});

        // Assert
        TestSetup.verifyLogging(message: message);
        expect(mockLoggingService.hasLogWithMessage(message), isTrue);
      });
    });

    group('Log Cleanup', () {
      test('should clear captured logs', () {
        // Arrange
        mockLoggingService.info('Message 1', {});
        mockLoggingService.warning('Message 2', {});
        expect(mockLoggingService.getCapturedLogs().length, equals(2));

        // Act
        mockLoggingService.clearCapturedLogs();

        // Assert
        expect(mockLoggingService.getCapturedLogs().length, equals(0));
        expect(mockLoggingService.hasLogWithMessage('Message 1'), isFalse);
        expect(mockLoggingService.hasLogWithMessage('Message 2'), isFalse);
      });
    });

    group('Log Data Structure', () {
      test('should capture complete log entry data', () {
        // Arrange
        const message = 'Complete log test';
        const data = {'key1': 'value1', 'key2': 42};

        // Act
        mockLoggingService.error(message, data, StackTrace.current);
        // No hay método performance en LoggingService

        // Assert
        final capturedLogs = mockLoggingService.getCapturedLogs();
        expect(capturedLogs.length, equals(1));

        final errorLog = capturedLogs.firstWhere(
          (log) => log.level == LogLevel.error,
        );
        expect(errorLog.message, equals(message));
        expect(errorLog.data, equals(data));
        expect(errorLog.error, isNotNull);
        expect(errorLog.duration, isNull);
      });
    });
  });
}
