/// Configuración del DSN de Sentry
/// 
/// IMPORTANTE: Este archivo contiene la configuración del DSN de Sentry.
/// 
/// Para configurar Sentry:
/// 1. Ve a https://sentry.io y crea una cuenta
/// 2. Crea un nuevo proyecto para Flutter
/// 3. Copia el DSN del proyecto
/// 4. Reemplaza el valor de _dnsKey con tu DSN real
/// 5. Asegúrate de que este archivo esté en .gitignore para no exponer tu DSN

class SentryDsnConfig {
  /// DSN de Sentry - REEMPLAZAR CON TU DSN REAL
  /// 
  /// Formato: https://[key]@[organization].ingest.sentry.io/[project_id]
  /// 
  /// Ejemplo:
  /// static const String _dnsKey = 'https://abc123def456@o123456.ingest.sentry.io/123456';
  static const String _dnsKey = 'YOUR_SENTRY_DSN_HERE';

  /// Obtiene el DSN configurado
  static String get dsn => _dnsKey;

  /// Verifica si el DSN está configurado correctamente
  static bool get isConfigured {
    return _dnsKey != 'YOUR_SENTRY_DSN_HERE' && 
           _dnsKey.isNotEmpty && 
           _dnsKey.startsWith('https://');
  }

  /// Obtiene información sobre la configuración del DSN
  static Map<String, dynamic> getDsnInfo() {
    return {
      'is_configured': isConfigured,
      'dsn_length': _dnsKey.length,
      'dsn_starts_with_https': _dnsKey.startsWith('https://'),
      'is_placeholder': _dnsKey == 'YOUR_SENTRY_DSN_HERE',
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
      '4. Reemplaza el valor de _dnsKey en este archivo con tu DSN real',
      '5. Asegúrate de que este archivo esté en .gitignore',
      '6. Reinicia la aplicación para que los cambios surtan efecto',
    ];
  }
}
