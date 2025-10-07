import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'logging_service.dart';

/// Servicio para configurar el contexto de usuario y metadata para Sentry
class UserContextService {
  static UserContextService? _instance;
  static UserContextService get instance => _instance ??= UserContextService._();

  UserContextService._();

  PackageInfo? _packageInfo;
  bool _isInitialized = false;

  /// Inicializa el servicio de contexto de usuario
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      LoggingService.instance.info('Initializing UserContextService');

      // Obtener información del paquete
      _packageInfo = await PackageInfo.fromPlatform();

      // Configurar contexto inicial
      await _setInitialContext();

      _isInitialized = true;
      LoggingService.instance.info('UserContextService initialized successfully');
    } catch (e, stackTrace) {
      LoggingService.instance.error('Failed to initialize UserContextService', e, stackTrace, {
        'component': 'user_context_initialization',
      });
    }
  }

  /// Configura el contexto inicial de la aplicación
  Future<void> _setInitialContext() async {
    try {
      // Configurar información de la aplicación
      if (_packageInfo != null) {
        LoggingService.instance.setTag('app_version', _packageInfo!.version);
        LoggingService.instance.setTag('build_number', _packageInfo!.buildNumber);
        LoggingService.instance.setTag('package_name', _packageInfo!.packageName);
      }

      // Configurar información del dispositivo
      LoggingService.instance.setContext('device', {
        'platform': Platform.operatingSystem,
        'platform_version': Platform.operatingSystemVersion,
        'is_debug': kDebugMode,
        'is_profile': kProfileMode,
        'is_release': kReleaseMode,
      });

      // Configurar información del entorno
      LoggingService.instance.setContext('environment', {
        'dart_version': Platform.version,
        'is_debug_mode': kDebugMode,
        'is_profile_mode': kProfileMode,
        'is_release_mode': kReleaseMode,
      });

      // Configurar información de la aplicación
      if (_packageInfo != null) {
        LoggingService.instance.setContext('app', {
          'name': _packageInfo!.appName,
          'version': _packageInfo!.version,
          'build_number': _packageInfo!.buildNumber,
          'package_name': _packageInfo!.packageName,
          'build_signature': _packageInfo!.buildSignature,
        });
      }

      LoggingService.instance.debug('Initial context configured', {
        'app_version': _packageInfo?.version,
        'platform': Platform.operatingSystem,
        'debug_mode': kDebugMode,
      });
    } catch (e, stackTrace) {
      LoggingService.instance.error('Failed to set initial context', e, stackTrace, {
        'component': 'set_initial_context',
      });
    }
  }

  /// Configura el contexto de un usuario específico
  void setUserContext({
    String? userId,
    String? username,
    String? email,
    String? userType,
    Map<String, dynamic>? customAttributes,
  }) {
    try {
      LoggingService.instance.info('Setting user context', {
        'user_id': userId,
        'username': username,
        'user_type': userType,
      });

      // Configurar usuario en Sentry
      LoggingService.instance.setUserContext(
        userId: userId,
        username: username,
        email: email,
        extra: {'user_type': userType, ...?customAttributes},
      );

      // Configurar tags adicionales
      if (userId != null) {
        LoggingService.instance.setTag('user_id', userId);
      }
      if (username != null) {
        LoggingService.instance.setTag('username', username);
      }
      if (userType != null) {
        LoggingService.instance.setTag('user_type', userType);
      }

      // Configurar contexto de usuario
      LoggingService.instance.setContext('user', {
        'id': userId,
        'username': username,
        'email': email,
        'type': userType,
        'custom_attributes': customAttributes ?? {},
      });

      LoggingService.instance.addBreadcrumb(
        'User context set',
        category: 'user',
        level: SentryLevel.info,
        data: {'user_id': userId, 'username': username, 'user_type': userType},
      );
    } catch (e, stackTrace) {
      LoggingService.instance.error('Failed to set user context', e, stackTrace, {'component': 'set_user_context'});
    }
  }

  /// Actualiza el contexto de sesión
  void updateSessionContext({String? sessionId, String? sessionType, Map<String, dynamic>? sessionData}) {
    try {
      LoggingService.instance.setContext('session', {
        'id': sessionId,
        'type': sessionType,
        'data': sessionData ?? {},
        'timestamp': DateTime.now().toIso8601String(),
      });

      if (sessionId != null) {
        LoggingService.instance.setTag('session_id', sessionId);
      }
      if (sessionType != null) {
        LoggingService.instance.setTag('session_type', sessionType);
      }

      LoggingService.instance.addBreadcrumb(
        'Session context updated',
        category: 'session',
        level: SentryLevel.info,
        data: {'session_id': sessionId, 'session_type': sessionType},
      );
    } catch (e, stackTrace) {
      LoggingService.instance.error('Failed to update session context', e, stackTrace, {
        'component': 'update_session_context',
      });
    }
  }

  /// Configura el contexto de una rutina específica
  void setRoutineContext({
    String? routineId,
    String? routineName,
    String? routineType,
    Map<String, dynamic>? routineData,
  }) {
    try {
      LoggingService.instance.setContext('routine', {
        'id': routineId,
        'name': routineName,
        'type': routineType,
        'data': routineData ?? {},
        'timestamp': DateTime.now().toIso8601String(),
      });

      if (routineId != null) {
        LoggingService.instance.setTag('routine_id', routineId);
      }
      if (routineName != null) {
        LoggingService.instance.setTag('routine_name', routineName);
      }
      if (routineType != null) {
        LoggingService.instance.setTag('routine_type', routineType);
      }

      LoggingService.instance.addBreadcrumb(
        'Routine context set',
        category: 'routine',
        level: SentryLevel.info,
        data: {'routine_id': routineId, 'routine_name': routineName, 'routine_type': routineType},
      );
    } catch (e, stackTrace) {
      LoggingService.instance.error('Failed to set routine context', e, stackTrace, {
        'component': 'set_routine_context',
      });
    }
  }

  /// Configura el contexto de un ejercicio específico
  void setExerciseContext({
    String? exerciseId,
    String? exerciseName,
    String? exerciseType,
    Map<String, dynamic>? exerciseData,
  }) {
    try {
      LoggingService.instance.setContext('exercise', {
        'id': exerciseId,
        'name': exerciseName,
        'type': exerciseType,
        'data': exerciseData ?? {},
        'timestamp': DateTime.now().toIso8601String(),
      });

      if (exerciseId != null) {
        LoggingService.instance.setTag('exercise_id', exerciseId);
      }
      if (exerciseName != null) {
        LoggingService.instance.setTag('exercise_name', exerciseName);
      }
      if (exerciseType != null) {
        LoggingService.instance.setTag('exercise_type', exerciseType);
      }

      LoggingService.instance.addBreadcrumb(
        'Exercise context set',
        category: 'exercise',
        level: SentryLevel.info,
        data: {'exercise_id': exerciseId, 'exercise_name': exerciseName, 'exercise_type': exerciseType},
      );
    } catch (e, stackTrace) {
      LoggingService.instance.error('Failed to set exercise context', e, stackTrace, {
        'component': 'set_exercise_context',
      });
    }
  }

  /// Limpia el contexto de usuario
  void clearUserContext() {
    try {
      LoggingService.instance.setUserContext();
      LoggingService.instance.addBreadcrumb('User context cleared', category: 'user', level: SentryLevel.info);
    } catch (e, stackTrace) {
      LoggingService.instance.error('Failed to clear user context', e, stackTrace, {'component': 'clear_user_context'});
    }
  }

  /// Obtiene información del paquete
  PackageInfo? get packageInfo => _packageInfo;

  /// Verifica si el servicio está inicializado
  bool get isInitialized => _isInitialized;

  /// Obtiene la información de release para Sentry
  String getReleaseInfo() {
    if (_packageInfo == null) {
      return 'liftly@unknown';
    }

    return '${_packageInfo!.packageName}@${_packageInfo!.version}+${_packageInfo!.buildNumber}';
  }

  /// Obtiene información del servicio
  Map<String, dynamic> getServiceInfo() {
    return {
      'is_initialized': _isInitialized,
      'package_info_available': _packageInfo != null,
      'package_name': _packageInfo?.packageName,
      'package_version': _packageInfo?.version,
      'package_build_number': _packageInfo?.buildNumber,
      'release_info': getReleaseInfo(),
    };
  }
}
