import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

/// Niveles de logging disponibles
enum LogLevel {
  debug,
  info,
  warning,
  error,
  fatal,
}

/// Servicio centralizado de logging que integra Logger y Sentry
class LoggingService {
  static LoggingService? _instance;
  static LoggingService get instance => _instance ??= LoggingService._();
  
  LoggingService._();

  late final Logger _logger;
  bool _isInitialized = false;

  /// Inicializa el servicio de logging
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
        printTime: true,
      ),
      filter: enableConsoleLogging ? DevelopmentFilter() : ProductionFilter(),
    );

    _isInitialized = true;
    
    info('LoggingService initialized', {
      'console_logging': enableConsoleLogging,
      'sentry_logging': enableSentryLogging,
    });
  }

  /// Log de nivel debug - información detallada para desarrollo
  void debug(String message, [Map<String, dynamic>? context]) {
    _log(LogLevel.debug, message, context);
  }

  /// Log de nivel info - información general de la aplicación
  void info(String message, [Map<String, dynamic>? context]) {
    _log(LogLevel.info, message, context);
  }

  /// Log de nivel warning - situaciones que requieren atención
  void warning(String message, [Map<String, dynamic>? context]) {
    _log(LogLevel.warning, message, context);
  }

  /// Log de nivel error - errores que no detienen la aplicación
  void error(String message, [Object? error, StackTrace? stackTrace, Map<String, dynamic>? context]) {
    _log(LogLevel.error, message, context, error, stackTrace);
  }

  /// Log de nivel fatal - errores críticos que pueden detener la aplicación
  void fatal(String message, [Object? error, StackTrace? stackTrace, Map<String, dynamic>? context]) {
    _log(LogLevel.fatal, message, context, error, stackTrace);
  }

  /// Método interno para manejar todos los logs
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
    
    // Log local con Logger
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

    // Envío a Sentry para errores y warnings
    if (level == LogLevel.error || level == LogLevel.fatal) {
      _sendToSentry(level, message, context, error, stackTrace);
    }
  }

  /// Envía logs críticos a Sentry
  void _sendToSentry(
    LogLevel level,
    String message,
    Map<String, dynamic>? context,
    Object? error,
    StackTrace? stackTrace,
  ) {
    try {
      if (error != null) {
        // Capturar excepción
        Sentry.captureException(
          error,
          stackTrace: stackTrace,
          withScope: (scope) {
            scope.setTag('log_level', level.name);
            scope.setExtra('logging_context', context ?? {});
            scope.level = level == LogLevel.fatal ? SentryLevel.fatal : SentryLevel.error;
          },
        );
      } else {
        // Capturar mensaje
        Sentry.captureMessage(
          message,
          level: level == LogLevel.fatal ? SentryLevel.fatal : SentryLevel.error,
          withScope: (scope) {
            scope.setTag('log_level', level.name);
            scope.setExtra('logging_context', context ?? {});
          },
        );
      }
    } catch (e) {
      // Fallback si Sentry falla
      developer.log('Failed to send log to Sentry: $e');
    }
  }

  /// Formatea el mensaje con contexto
  String _formatMessage(String message, Map<String, dynamic>? context) {
    if (context == null || context.isEmpty) {
      return message;
    }
    
    final contextString = context.entries
        .map((e) => '${e.key}: ${e.value}')
        .join(', ');
    
    return '$message | Context: $contextString';
  }

  /// Añade breadcrumb para Sentry
  void addBreadcrumb(String message, {
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

  /// Configura contexto de usuario para Sentry
  void setUserContext({
    String? userId,
    String? username,
    String? email,
    Map<String, dynamic>? extra,
  }) {
    try {
      Sentry.configureScope((scope) {
        scope.setUser(SentryUser(
          id: userId,
          username: username,
          email: email,
          extras: extra,
        ));
      });
    } catch (e) {
      developer.log('Failed to set user context: $e');
    }
  }

  /// Configura tags personalizados para Sentry
  void setTag(String key, String value) {
    try {
      Sentry.configureScope((scope) {
        scope.setTag(key, value);
      });
    } catch (e) {
      developer.log('Failed to set tag: $e');
    }
  }

  /// Configura contexto adicional para Sentry
  void setContext(String key, Map<String, dynamic> context) {
    try {
      Sentry.configureScope((scope) {
        scope.setExtra(key, context);
      });
    } catch (e) {
      developer.log('Failed to set context: $e');
    }
  }
}
