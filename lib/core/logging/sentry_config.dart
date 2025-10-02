import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'sentry_dsn_config.dart';
import 'user_context_service.dart';

/// Configuración de Sentry para la aplicación LiftUp
class SentryConfig {
  // Usar el DSN configurado desde SentryDsnConfig
  static String get _dnsKey => SentryDsnConfig.dsn;

  // Callback para ejecutar la aplicación
  static void Function()? _appRunner;

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
  static FutureOr<SentryEvent?> _beforeSend(SentryEvent event, Hint hint) {
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
  static FutureOr<SentryTransaction?> _beforeSendTransaction(
    SentryTransaction transaction,
  ) {
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

    return sensitiveKeywords.any(
      (keyword) => message.contains(keyword) || exception.contains(keyword),
    );
  }

  /// Configuración inicial de Sentry
  static Future<void> initialize({void Function()? appRunner}) async {
    // Guardar el callback de la aplicación
    _appRunner = appRunner;

    await SentryFlutter.init(
      (options) {
        // Configuración básica
        options.dsn = _dnsKey;
        options.debug = kDebugMode && SentryDsnConfig.isDebugLoggingEnabled;
        options.environment = SentryDsnConfig.environment;
        options.release = UserContextService.instance.getReleaseInfo();

        // Configuraciones de rendimiento
        options.tracesSampleRate = SentryDsnConfig.tracesSampleRate;
        options.profilesSampleRate = SentryDsnConfig.profilesSampleRate;

        // Configuraciones de sesión
        options.enableAutoSessionTracking = true;
        options.maxBreadcrumbs = kDebugMode ? 100 : 50;

        // Filtros
        options.beforeSend = _beforeSend;
        options.beforeSendTransaction =
            _beforeSendTransaction as BeforeSendTransactionCallback?;

        // Configuraciones adicionales
        options.attachScreenshot = SentryDsnConfig.isScreenshotsEnabled;
        options.attachViewHierarchy = SentryDsnConfig.isViewHierarchyEnabled;
        options.enableUserInteractionTracing = true;
        options.enableAutoPerformanceTracing = true;
      },
      appRunner: () {
        // Ejecutar la aplicación después de que Sentry se inicialice correctamente
        if (_appRunner != null) {
          _appRunner!();
        }
      },
    );
  }
}
