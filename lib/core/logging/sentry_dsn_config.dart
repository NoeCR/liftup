import 'environment_service.dart';

/// Configuración del DSN de Sentry usando variables de entorno
///
/// IMPORTANTE: Este archivo lee la configuración del DSN de Sentry desde variables de entorno.
///
/// Para configurar Sentry:
/// 1. Ve a https://sentry.io y crea una cuenta
/// 2. Crea un nuevo proyecto para Flutter
/// 3. Copia el DSN del proyecto
/// 4. Crea archivos .env basados en env.{environment}.example
/// 5. Reemplaza SENTRY_DSN con tu DSN real
/// 6. Asegúrate de que los archivos .env estén en .gitignore

class SentryDsnConfig {
  /// DSN de Sentry desde variables de entorno
  ///
  /// Formato: https://[key]@[organization].ingest.sentry.io/[project_id]
  ///
  /// Se lee desde la variable de entorno SENTRY_DSN usando EnvironmentService
  static String get _dnsKey {
    final dsn = EnvironmentService.instance.getEnv('SENTRY_DSN');
    if (dsn.isEmpty) {
      return 'YOUR_SENTRY_DSN_HERE';
    }
    return dsn;
  }

  /// Obtiene el DSN configurado
  static String get dsn => _dnsKey;

  /// Verifica si el DSN está configurado correctamente
  static bool get isConfigured {
    final dsn = EnvironmentService.instance.getEnv('SENTRY_DSN');
    return dsn.isNotEmpty && dsn != 'YOUR_SENTRY_DSN_HERE' && dsn.startsWith('https://');
  }

  /// Obtiene información sobre la configuración del DSN
  static Map<String, dynamic> getDsnInfo() {
    final dsn = EnvironmentService.instance.getEnv('SENTRY_DSN');
    return {
      'is_configured': isConfigured,
      'dsn_length': dsn.length,
      'dsn_starts_with_https': dsn.startsWith('https://'),
      'is_placeholder': dsn == 'YOUR_SENTRY_DSN_HERE' || dsn.isEmpty,
      'source': 'environment_variable',
      'environment': EnvironmentService.instance.environment,
      'configured_at': DateTime.now().toIso8601String(),
    };
  }

  /// Valida el formato del DSN
  static bool validateDsn(String dsn) {
    if (dsn.isEmpty) return false;
    if (!dsn.startsWith('https://')) return false;
    if (!dsn.contains('@')) return false;
    if (!dsn.contains('.ingest.sentry.io/')) return false;
    return true;
  }

  /// Obtiene instrucciones para configurar Sentry
  static List<String> getSetupInstructions() {
    return [
      '1. Ve a https://sentry.io y crea una cuenta',
      '2. Crea un nuevo proyecto para Flutter',
      '3. Copia el DSN del proyecto',
      '4. Crea archivos .env basados en env.{environment}.example',
      '5. Reemplaza SENTRY_DSN con tu DSN real en los archivos .env',
      '6. Asegúrate de que los archivos .env estén en .gitignore',
      '7. Reinicia la aplicación para que los cambios surtan efecto',
    ];
  }

  /// Obtiene el entorno configurado
  static String get environment {
    return EnvironmentService.instance.environment;
  }

  /// Verifica si el logging debug está habilitado
  static bool get isDebugLoggingEnabled {
    return EnvironmentService.instance.getEnvBool('DEBUG_LOGGING', defaultValue: true);
  }

  /// Verifica si el monitoreo de métricas está habilitado
  static bool get isMetricsMonitoringEnabled {
    return EnvironmentService.instance.getEnvBool('ENABLE_METRICS_MONITORING', defaultValue: true);
  }

  /// Verifica si las alertas están habilitadas
  static bool get isAlertsEnabled {
    return EnvironmentService.instance.getEnvBool('ENABLE_ALERTS', defaultValue: true);
  }

  /// Verifica si las capturas de pantalla están habilitadas
  static bool get isScreenshotsEnabled {
    return EnvironmentService.instance.getEnvBool('ENABLE_SCREENSHOTS', defaultValue: true);
  }

  /// Verifica si la captura de jerarquía de vistas está habilitada
  static bool get isViewHierarchyEnabled {
    return EnvironmentService.instance.getEnvBool('ENABLE_VIEW_HIERARCHY', defaultValue: true);
  }

  /// Obtiene el nivel de muestreo para transacciones
  static double get tracesSampleRate {
    return EnvironmentService.instance.getEnvDouble('TRACES_SAMPLE_RATE', defaultValue: 1.0);
  }

  /// Obtiene el nivel de muestreo para perfiles
  static double get profilesSampleRate {
    return EnvironmentService.instance.getEnvDouble('PROFILES_SAMPLE_RATE', defaultValue: 1.0);
  }
}
