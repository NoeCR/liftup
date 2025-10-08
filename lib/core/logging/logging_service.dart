import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

/// Available logging levels
enum LogLevel { debug, info, warning, error, fatal }

/// Centralized logging service that integrates Logger and Sentry
class LoggingService {
  static LoggingService? _instance;
  static LoggingService get instance => _instance ??= LoggingService._();

  LoggingService._();

  late final Logger _logger;
  bool _isInitialized = false;

  /// Initializes the logging service
  void initialize({
    bool enableConsoleLogging = kDebugMode,
    bool enableSentryLogging = true,
  }) {
    if (_isInitialized) return;

    _logger = Logger(
      printer: PrettyPrinter(
        methodCount: 2,
        errorMethodCount: 8,
        lineLength: 120,
        colors: true,
        printEmojis: true,
        dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
      ),
      filter: enableConsoleLogging ? DevelopmentFilter() : ProductionFilter(),
    );

    _isInitialized = true;

    info('LoggingService initialized', {
      'console_logging': enableConsoleLogging,
      'sentry_logging': enableSentryLogging,
    });
  }

  /// Debug level log - detailed information for development
  void debug(String message, [Map<String, dynamic>? context]) {
    _log(LogLevel.debug, message, context);
  }

  /// Info level log - general application information
  void info(String message, [Map<String, dynamic>? context]) {
    _log(LogLevel.info, message, context);
  }

  /// Warning level log - situations that require attention
  void warning(String message, [Map<String, dynamic>? context]) {
    _log(LogLevel.warning, message, context);
  }

  /// Error level log - errors that do not stop the application
  void error(
    String message, [
    Object? error,
    StackTrace? stackTrace,
    Map<String, dynamic>? context,
  ]) {
    _log(LogLevel.error, message, context, error, stackTrace);
  }

  /// Fatal level log - critical errors that may stop the application
  void fatal(
    String message, [
    Object? error,
    StackTrace? stackTrace,
    Map<String, dynamic>? context,
  ]) {
    _log(LogLevel.fatal, message, context, error, stackTrace);
  }

  /// Internal method to handle all logs
  void _log(
    LogLevel level,
    String message, [
    Map<String, dynamic>? context,
    Object? error,
    StackTrace? stackTrace,
  ]) {
    if (!_isInitialized) {
      developer.log('LoggingService not initialized. Message: $message');
      return;
    }

    final logMessage = _formatMessage(message, context);

    // Local log with Logger
    switch (level) {
      case LogLevel.debug:
        _logger.d(logMessage);
        break;
      case LogLevel.info:
        _logger.i(logMessage);
        break;
      case LogLevel.warning:
        _logger.w(logMessage);
        break;
      case LogLevel.error:
        _logger.e(logMessage, error: error, stackTrace: stackTrace);
        break;
      case LogLevel.fatal:
        _logger.f(logMessage, error: error, stackTrace: stackTrace);
        break;
    }

    // Send to Sentry for error/fatal
    if (level == LogLevel.error || level == LogLevel.fatal) {
      _sendToSentry(level, message, context, error, stackTrace);
    }
  }

  /// Sends critical logs to Sentry
  void _sendToSentry(
    LogLevel level,
    String message,
    Map<String, dynamic>? context,
    Object? error,
    StackTrace? stackTrace,
  ) {
    try {
      if (error != null) {
        // Capture exception
        Sentry.captureException(
          error,
          stackTrace: stackTrace,
          withScope: (scope) {
            scope.setTag('log_level', level.name);
            scope.setContexts('logging_context', context ?? {});
            scope.level =
                level == LogLevel.fatal ? SentryLevel.fatal : SentryLevel.error;
          },
        );
      } else {
        // Capture message
        Sentry.captureMessage(
          message,
          level:
              level == LogLevel.fatal ? SentryLevel.fatal : SentryLevel.error,
          withScope: (scope) {
            scope.setTag('log_level', level.name);
            scope.setContexts('logging_context', context ?? {});
          },
        );
      }
    } catch (e) {
      // Fallback if Sentry fails
      developer.log('Failed to send log to Sentry: $e');
    }
  }

  /// Formats message with context
  String _formatMessage(String message, Map<String, dynamic>? context) {
    if (context == null || context.isEmpty) {
      return message;
    }

    final contextString = context.entries
        .map((e) => '${e.key}: ${e.value}')
        .join(', ');

    return '$message | Context: $contextString';
  }

  /// Adds a breadcrumb to Sentry
  void addBreadcrumb(
    String message, {
    String? category,
    SentryLevel level = SentryLevel.info,
    Map<String, dynamic>? data,
  }) {
    try {
      Sentry.addBreadcrumb(
        Breadcrumb(
          message: message,
          category: category,
          level: level,
          data: data,
          timestamp: DateTime.now(),
        ),
      );
    } catch (e) {
      developer.log('Failed to add breadcrumb: $e');
    }
  }

  /// Sets user context for Sentry
  void setUserContext({
    String? userId,
    String? username,
    String? email,
    Map<String, dynamic>? extra,
  }) {
    try {
      Sentry.configureScope((scope) {
        scope.setUser(
          SentryUser(id: userId, username: username, email: email, data: extra),
        );
      });
    } catch (e) {
      developer.log('Failed to set user context: $e');
    }
  }

  /// Sets custom tags for Sentry
  void setTag(String key, String value) {
    try {
      Sentry.configureScope((scope) {
        scope.setTag(key, value);
      });
    } catch (e) {
      developer.log('Failed to set tag: $e');
    }
  }

  /// Sets additional context for Sentry
  void setContext(String key, Map<String, dynamic> context) {
    try {
      Sentry.configureScope((scope) {
        scope.setContexts(key, context);
      });
      // Log only in debug mode to avoid noise
      if (kDebugMode) {
        developer.log('Context set for Sentry: $key');
      }
    } catch (e) {
      developer.log('Failed to set context: $e');
    }
  }
}
