import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'logging_service.dart';

/// Servicio para manejar variables de entorno
class EnvironmentService {
  static EnvironmentService? _instance;
  static EnvironmentService get instance => _instance ??= EnvironmentService._();

  EnvironmentService._();

  bool _isInitialized = false;
  String? _currentEnvironment;

  /// Inicializa el servicio de entorno
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      LoggingService.instance.info('Initializing EnvironmentService');

      // Determinar el entorno actual
      _currentEnvironment = _determineEnvironment();

      // Cargar el archivo .env apropiado
      await _loadEnvironmentFile();

      _isInitialized = true;
      LoggingService.instance.info('EnvironmentService initialized successfully', {
        'environment': _currentEnvironment,
        'env_file_loaded': _getEnvFileName(),
      });
    } catch (e, stackTrace) {
      LoggingService.instance.error('Failed to initialize EnvironmentService', e, stackTrace, {
        'component': 'environment_service',
      });
      rethrow;
    }
  }

  /// Determina el entorno actual
  String _determineEnvironment() {
    // 1. Verificar si hay una variable de entorno del sistema
    final systemEnv = Platform.environment['FLUTTER_ENV'];
    if (systemEnv != null && systemEnv.isNotEmpty) {
      LoggingService.instance.debug('Using system environment variable', {'FLUTTER_ENV': systemEnv});
      return systemEnv;
    }

    // 2. Verificar si estamos en modo debug
    if (kDebugMode) {
      LoggingService.instance.debug('Using debug mode environment');
      return 'development';
    }

    // 3. Verificar si estamos en modo profile
    if (kProfileMode) {
      LoggingService.instance.debug('Using profile mode environment');
      return 'staging';
    }

    // 4. Por defecto, usar producción
    LoggingService.instance.debug('Using release mode environment');
    return 'production';
  }

  /// Carga el archivo .env apropiado
  Future<void> _loadEnvironmentFile() async {
    final envFileName = _getEnvFileName();

    try {
      LoggingService.instance.debug('Loading environment file', {
        'file_name': envFileName,
        'environment': _currentEnvironment,
      });

      await dotenv.load(fileName: envFileName);

      LoggingService.instance.info('Environment file loaded successfully', {
        'file_name': envFileName,
        'environment': _currentEnvironment,
        'variables_count': dotenv.env.length,
      });
    } catch (e) {
      LoggingService.instance.warning('Failed to load environment file, using defaults', {
        'file_name': envFileName,
        'error': e.toString(),
        'environment': _currentEnvironment,
      });

      // Si no se puede cargar el archivo específico, intentar cargar .env
      if (envFileName != '.env') {
        try {
          await dotenv.load(fileName: '.env');
          LoggingService.instance.info('Fallback .env file loaded successfully');
        } catch (fallbackError) {
          LoggingService.instance.warning('Failed to load fallback .env file', {'error': fallbackError.toString()});
        }
      }
    }
  }

  /// Obtiene el nombre del archivo .env según el entorno
  String _getEnvFileName() {
    switch (_currentEnvironment) {
      case 'development':
        return '.env.development';
      case 'staging':
        return '.env.staging';
      case 'production':
        return '.env.production';
      default:
        return '.env';
    }
  }

  /// Obtiene el entorno actual
  String get environment => _currentEnvironment ?? 'development';

  /// Verifica si estamos en desarrollo
  bool get isDevelopment => environment == 'development';

  /// Verifica si estamos en staging
  bool get isStaging => environment == 'staging';

  /// Verifica si estamos en producción
  bool get isProduction => environment == 'production';

  /// Obtiene una variable de entorno con valor por defecto
  String getEnv(String key, {String defaultValue = ''}) {
    return dotenv.env[key] ?? defaultValue;
  }

  /// Obtiene una variable de entorno como booleano
  bool getEnvBool(String key, {bool defaultValue = false}) {
    final value = dotenv.env[key]?.toLowerCase();
    return value == 'true' || value == '1';
  }

  /// Obtiene una variable de entorno como entero
  int getEnvInt(String key, {int defaultValue = 0}) {
    final value = dotenv.env[key];
    return int.tryParse(value ?? '') ?? defaultValue;
  }

  /// Obtiene una variable de entorno como double
  double getEnvDouble(String key, {double defaultValue = 0.0}) {
    final value = dotenv.env[key];
    return double.tryParse(value ?? '') ?? defaultValue;
  }

  /// Verifica si una variable de entorno está definida
  bool hasEnv(String key) {
    return dotenv.env.containsKey(key) && dotenv.env[key]?.isNotEmpty == true;
  }

  /// Obtiene todas las variables de entorno (para debugging)
  Map<String, String> getAllEnvVars() {
    return Map.from(dotenv.env);
  }

  /// Obtiene información del servicio de entorno
  Map<String, dynamic> getServiceInfo() {
    return {
      'is_initialized': _isInitialized,
      'environment': environment,
      'is_development': isDevelopment,
      'is_staging': isStaging,
      'is_production': isProduction,
      'env_file_name': _getEnvFileName(),
      'variables_count': dotenv.env.length,
      'flutter_debug_mode': kDebugMode,
      'flutter_profile_mode': kProfileMode,
      'flutter_release_mode': kReleaseMode,
    };
  }

  /// Fuerza la recarga del archivo de entorno
  Future<void> reload() async {
    try {
      LoggingService.instance.info('Reloading environment configuration');
      _isInitialized = false;
      await initialize();
      LoggingService.instance.info('Environment configuration reloaded successfully');
    } catch (e, stackTrace) {
      LoggingService.instance.error('Failed to reload environment configuration', e, stackTrace, {
        'component': 'environment_service',
      });
    }
  }

  /// Cambia el entorno y recarga la configuración
  Future<void> changeEnvironment(String newEnvironment) async {
    try {
      LoggingService.instance.info('Changing environment', {'from': _currentEnvironment, 'to': newEnvironment});

      _currentEnvironment = newEnvironment;
      await reload();

      LoggingService.instance.info('Environment changed successfully', {'new_environment': newEnvironment});
    } catch (e, stackTrace) {
      LoggingService.instance.error('Failed to change environment', e, stackTrace, {
        'component': 'environment_service',
        'new_environment': newEnvironment,
      });
    }
  }
}
