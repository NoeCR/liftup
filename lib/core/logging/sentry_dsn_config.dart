import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Configuración del DSN de Sentry usando variables de entorno
/// 
/// IMPORTANTE: Este archivo lee la configuración del DSN de Sentry desde variables de entorno.
/// 
/// Para configurar Sentry:
/// 1. Ve a https://sentry.io y crea una cuenta
/// 2. Crea un nuevo proyecto para Flutter
/// 3. Copia el DSN del proyecto
/// 4. Crea un archivo .env basado en env.example
/// 5. Reemplaza SENTRY_DSN con tu DSN real
/// 6. Asegúrate de que .env esté en .gitignore

class SentryDsnConfig {
  /// DSN de Sentry desde variables de entorno
  /// 
  /// Formato: https://[key]@[organization].ingest.sentry.io/[project_id]
  /// 
  /// Se lee desde la variable de entorno SENTRY_DSN
  static String get _dnsKey {
    final dsn = dotenv.env['SENTRY_DSN'];
    if (dsn == null || dsn.isEmpty) {
      return 'YOUR_SENTRY_DSN_HERE';
    }
    return dsn;
  }

  /// Obtiene el DSN configurado
  static String get dsn => _dnsKey;

  /// Verifica si el DSN está configurado correctamente
  static bool get isConfigured {
    final dsn = dotenv.env['SENTRY_DSN'];
    return dsn != null && 
           dsn.isNotEmpty && 
           dsn != 'YOUR_SENTRY_DSN_HERE' &&
           dsn.startsWith('https://');
  }

  /// Obtiene información sobre la configuración del DSN
  static Map<String, dynamic> getDsnInfo() {
    final dsn = dotenv.env['SENTRY_DSN'];
    return {
      'is_configured': isConfigured,
      'dsn_length': dsn?.length ?? 0,
      'dsn_starts_with_https': dsn?.startsWith('https://') ?? false,
      'is_placeholder': dsn == 'YOUR_SENTRY_DSN_HERE' || dsn == null,
      'source': 'environment_variable',
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
      '4. Crea un archivo .env basado en env.example',
      '5. Reemplaza SENTRY_DSN con tu DSN real en el archivo .env',
      '6. Asegúrate de que .env esté en .gitignore',
      '7. Reinicia la aplicación para que los cambios surtan efecto',
    ];
  }

  /// Obtiene el entorno configurado
  static String get environment {
    return dotenv.env['ENVIRONMENT'] ?? 'development';
  }

  /// Verifica si el logging debug está habilitado
  static bool get isDebugLoggingEnabled {
    return dotenv.env['DEBUG_LOGGING']?.toLowerCase() == 'true';
  }

  /// Verifica si el monitoreo de métricas está habilitado
  static bool get isMetricsMonitoringEnabled {
    return dotenv.env['ENABLE_METRICS_MONITORING']?.toLowerCase() == 'true';
  }

  /// Verifica si las alertas están habilitadas
  static bool get isAlertsEnabled {
    return dotenv.env['ENABLE_ALERTS']?.toLowerCase() == 'true';
  }
}
