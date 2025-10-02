import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../sessions/notifiers/session_notifier.dart';
import '../../sessions/models/workout_session.dart';
import '../../../core/logging/logging.dart';

/// Servicio para rastrear ejercicios realizados en la semana actual
class WeeklyExerciseTrackingService {
  static WeeklyExerciseTrackingService? _instance;
  static WeeklyExerciseTrackingService get instance =>
      _instance ??= WeeklyExerciseTrackingService._();

  WeeklyExerciseTrackingService._();

  /// Obtiene el inicio de la semana actual (lunes)
  DateTime getStartOfCurrentWeek() {
    final now = DateTime.now();
    final daysFromMonday = now.weekday - 1; // 0 = lunes, 6 = domingo
    return DateTime(now.year, now.month, now.day - daysFromMonday);
  }

  /// Obtiene el final de la semana actual (domingo)
  DateTime getEndOfCurrentWeek() {
    final startOfWeek = getStartOfCurrentWeek();
    return startOfWeek.add(
      const Duration(days: 6, hours: 23, minutes: 59, seconds: 59),
    );
  }

  /// Obtiene todos los ejercicios realizados en la semana actual
  Future<Set<String>> getExercisesPerformedThisWeek(Ref ref) async {
    return await PerformanceMonitor.instance.monitorAsync(
      'get_exercises_performed_this_week',
      () async {
        final sessions = await ref.read(sessionNotifierProvider.future);
        final startOfWeek = getStartOfCurrentWeek();
        final endOfWeek = getEndOfCurrentWeek();

        LoggingService.instance.debug('Getting exercises performed this week', {
          'start_of_week': startOfWeek.toIso8601String(),
          'end_of_week': endOfWeek.toIso8601String(),
          'total_sessions': sessions.length,
          'component': 'weekly_exercise_tracking',
        });

        final exercisesThisWeek = <String>{};

        for (final session in sessions) {
          LoggingService.instance.debug('Processing session', {
            'session_id': session.id,
            'start_time': session.startTime.toIso8601String(),
            'end_time': session.endTime?.toIso8601String(),
            'status': session.status.toString(),
            'exercise_sets_count': session.exerciseSets.length,
            'component': 'weekly_exercise_tracking',
          });

          // Solo considerar sesiones completadas
          if (session.status != SessionStatus.completed) {
            LoggingService.instance.debug('Session not completed, skipping', {
              'session_id': session.id,
              'status': session.status.toString(),
              'component': 'weekly_exercise_tracking',
            });
            continue;
          }

          // Verificar si la sesión fue completada en la semana actual
          final sessionDate = session.endTime ?? session.startTime;
          if (sessionDate.isAfter(startOfWeek) && sessionDate.isBefore(endOfWeek)) {
            LoggingService.instance.debug('Session completed in current week', {
              'session_id': session.id,
              'session_date': sessionDate.toIso8601String(),
              'component': 'weekly_exercise_tracking',
            });
            // Agregar todos los ejercicios de esta sesión
            for (final exerciseSet in session.exerciseSets) {
              LoggingService.instance.debug('Adding exercise from session', {
                'exercise_id': exerciseSet.exerciseId,
                'session_id': session.id,
                'component': 'weekly_exercise_tracking',
              });
              exercisesThisWeek.add(exerciseSet.exerciseId);
            }
          } else {
            LoggingService.instance.debug('Session not in current week', {
              'session_id': session.id,
              'session_date': sessionDate.toIso8601String(),
              'component': 'weekly_exercise_tracking',
            });
          }
        }

        LoggingService.instance.info('Weekly exercise tracking completed', {
          'total_exercises_this_week': exercisesThisWeek.length,
          'exercises': exercisesThisWeek.toList(),
          'component': 'weekly_exercise_tracking',
        });
        return exercisesThisWeek;
      },
      context: {
        'component': 'weekly_exercise_tracking',
      },
    );
  }

  /// Verifica si un ejercicio específico fue realizado esta semana
  Future<bool> wasExercisePerformedThisWeek(String exerciseId, Ref ref) async {
    final exercisesThisWeek = await getExercisesPerformedThisWeek(ref);
    return exercisesThisWeek.contains(exerciseId);
  }

  /// Obtiene el número de veces que un ejercicio fue realizado esta semana
  Future<int> getExerciseCountThisWeek(String exerciseId, Ref ref) async {
    final sessions = await ref.read(sessionNotifierProvider.future);
    final startOfWeek = getStartOfCurrentWeek();
    final endOfWeek = getEndOfCurrentWeek();

    int count = 0;

    for (final session in sessions) {
      // Verificar si la sesión fue en la semana actual
      if (session.startTime.isAfter(startOfWeek) &&
          session.startTime.isBefore(endOfWeek)) {
        // Contar cuántas veces aparece este ejercicio en esta sesión
        for (final exerciseSet in session.exerciseSets) {
          if (exerciseSet.exerciseId == exerciseId) {
            count++;
          }
        }
      }
    }

    return count;
  }

  /// Obtiene información detallada sobre ejercicios realizados esta semana
  Future<WeeklyExerciseInfo> getWeeklyExerciseInfo(Ref ref) async {
    final exercisesThisWeek = await getExercisesPerformedThisWeek(ref);
    final startOfWeek = getStartOfCurrentWeek();
    final endOfWeek = getEndOfCurrentWeek();

    return WeeklyExerciseInfo(
      startOfWeek: startOfWeek,
      endOfWeek: endOfWeek,
      exercisesPerformed: exercisesThisWeek,
      totalExercises: exercisesThisWeek.length,
    );
  }
}

/// Información sobre ejercicios realizados en la semana actual
class WeeklyExerciseInfo {
  final DateTime startOfWeek;
  final DateTime endOfWeek;
  final Set<String> exercisesPerformed;
  final int totalExercises;

  const WeeklyExerciseInfo({
    required this.startOfWeek,
    required this.endOfWeek,
    required this.exercisesPerformed,
    required this.totalExercises,
  });

  /// Verifica si un ejercicio específico fue realizado esta semana
  bool wasExercisePerformed(String exerciseId) {
    return exercisesPerformed.contains(exerciseId);
  }

  /// Obtiene el número de ejercicios únicos realizados
  int get uniqueExercisesCount => exercisesPerformed.length;

  /// Descripción de la semana actual
  String get weekDescription {
    final start = '${startOfWeek.day}/${startOfWeek.month}';
    final end = '${endOfWeek.day}/${endOfWeek.month}';
    return 'Semana del $start al $end';
  }
}

/// Provider para el servicio de tracking semanal
final weeklyExerciseTrackingServiceProvider =
    Provider<WeeklyExerciseTrackingService>((ref) {
      return WeeklyExerciseTrackingService.instance;
    });

/// Provider para obtener información de ejercicios de la semana actual
final weeklyExerciseInfoProvider = FutureProvider<WeeklyExerciseInfo>((
  ref,
) async {
  final service = ref.watch(weeklyExerciseTrackingServiceProvider);
  return await service.getWeeklyExerciseInfo(ref);
});

/// Provider para verificar si un ejercicio específico fue realizado esta semana
final exercisePerformedThisWeekProvider = FutureProvider.family<bool, String>((
  ref,
  exerciseId,
) async {
  LoggingService.instance.debug('Checking if exercise was performed this week', {
    'exercise_id': exerciseId,
    'component': 'weekly_exercise_tracking_provider',
  });
  final service = ref.watch(weeklyExerciseTrackingServiceProvider);
  final result = await service.wasExercisePerformedThisWeek(exerciseId, ref);
  LoggingService.instance.debug('Exercise performance check completed', {
    'exercise_id': exerciseId,
    'was_performed': result,
    'component': 'weekly_exercise_tracking_provider',
  });
  return result;
});
