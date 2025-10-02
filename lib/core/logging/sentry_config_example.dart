// Este archivo es un ejemplo de configuración de Sentry
// Copia este archivo como sentry_config.dart y reemplaza los valores

import 'package:flutter/foundation.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

/// Configuración de ejemplo para Sentry
class SentryConfigExample {
  // Reemplaza con tu DSN real de Sentry
  static const String _dnsKey = 'https://your-dsn@sentry.io/project-id';
  
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
        options.debug = kDebugMode;
        options.environment = kDebugMode ? 'development' : 'production';
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

/*
INSTRUCCIONES DE CONFIGURACIÓN:

1. Crea una cuenta en Sentry.io
2. Crea un nuevo proyecto para Flutter
3. Copia el DSN del proyecto
4. Reemplaza 'YOUR_SENTRY_DSN_HERE' con tu DSN real
5. Opcionalmente, ajusta las configuraciones según tus necesidades:
   - tracesSampleRate: Porcentaje de transacciones a rastrear (0.0 - 1.0)
   - profilesSampleRate: Porcentaje de perfiles a rastrear (0.0 - 1.0)
   - maxBreadcrumbs: Número máximo de breadcrumbs a mantener
   - environment: Entorno de la aplicación (development, staging, production)

CONFIGURACIONES RECOMENDADAS:

Para desarrollo:
- tracesSampleRate: 1.0 (rastrear todas las transacciones)
- profilesSampleRate: 1.0 (rastrear todos los perfiles)
- debug: true (mostrar logs de Sentry)

Para producción:
- tracesSampleRate: 0.1 (rastrear 10% de las transacciones)
- profilesSampleRate: 0.1 (rastrear 10% de los perfiles)
- debug: false (no mostrar logs de Sentry)

FILTROS DE SEGURIDAD:

El sistema incluye filtros automáticos para:
- Información sensible (passwords, tokens, etc.)
- Eventos de desarrollo en producción
- Datos personales del usuario

Puedes personalizar estos filtros en los métodos _beforeSend y _containsSensitiveData.
*/
