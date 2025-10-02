import 'package:flutter/foundation.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'sentry_dsn_config.dart';

/// Configuración de Sentry para la aplicación LiftUp
class SentryConfig {
  // Usar el DSN configurado desde SentryDsnConfig
  static String get _dnsKey => SentryDsnConfig.dsn;
  
  /// Configuración de Sentry para desarrollo
  static final SentryFlutterOptions developmentOptions = SentryFlutterOptions(
    dsn: _dnsKey,
  );

  /// Configuración de Sentry para producción
  static final SentryFlutterOptions productionOptions = SentryFlutterOptions(
    dsn: _dnsKey,
  );

  /// Obtiene la configuración apropiada según el entorno
  static SentryFlutterOptions get options {
    return kDebugMode ? developmentOptions : productionOptions;
  }

  /// Filtra eventos antes de enviarlos a Sentry
  static SentryEvent? _beforeSend(SentryEvent event, {Hint? hint}) {
    // Filtrar eventos de desarrollo en producción
    if (!kDebugMode && event.environment == 'development') {
      return null;
    }

    // Filtrar eventos con información sensible
    if (_containsSensitiveData(event)) {
      return null;
    }

    // Añadir información adicional del dispositivo
    event = event.copyWith(
      tags: {
        ...?event.tags,
        'app_name': 'LiftUp',
        'platform': defaultTargetPlatform.name,
      },
    );

    return event;
  }

  /// Filtra transacciones antes de enviarlas a Sentry
  static SentryTransaction? _beforeSendTransaction(SentryTransaction transaction, {Hint? hint}) {
    // Filtrar transacciones de desarrollo en producción
    if (!kDebugMode && transaction.environment == 'development') {
      return null;
    }

    return transaction;
  }

  /// Verifica si el evento contiene información sensible
  static bool _containsSensitiveData(SentryEvent event) {
    final message = event.message?.formatted.toLowerCase() ?? '';
    final exception = event.exceptions?.firstOrNull?.value?.toLowerCase() ?? '';
    
    final sensitiveKeywords = [
      'password',
      'token',
      'key',
      'secret',
      'auth',
      'credential',
    ];

    return sensitiveKeywords.any((keyword) => 
      message.contains(keyword) || exception.contains(keyword)
    );
  }

  /// Configuración inicial de Sentry
  static Future<void> initialize() async {
    await SentryFlutter.init(
      (options) {
        // Configuración básica
        options.dsn = _dnsKey;
        options.debug = kDebugMode && SentryDsnConfig.isDebugLoggingEnabled;
        options.environment = SentryDsnConfig.environment;
        options.release = 'liftup@1.0.0+1';
        
        // Configuraciones de rendimiento
        options.tracesSampleRate = kDebugMode ? 1.0 : 0.1;
        options.profilesSampleRate = kDebugMode ? 1.0 : 0.1;
        
        // Configuraciones de sesión
        options.enableAutoSessionTracking = true;
        options.maxBreadcrumbs = kDebugMode ? 100 : 50;
        
        // Filtros
        options.beforeSend = _beforeSend as BeforeSendCallback?;
        options.beforeSendTransaction = _beforeSendTransaction as BeforeSendTransactionCallback?;
        
        // Configuraciones adicionales
        options.attachScreenshot = true;
        options.attachViewHierarchy = true;
        options.enableUserInteractionTracing = true;
        options.enableAutoPerformanceTracing = true;
      },
      appRunner: () {
        // La aplicación se ejecutará después de la inicialización
      },
    );
  }
}
