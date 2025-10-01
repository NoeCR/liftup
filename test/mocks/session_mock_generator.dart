import 'package:uuid/uuid.dart';
import 'package:liftup/features/sessions/models/workout_session.dart';
import 'package:liftup/features/exercise/models/exercise_set.dart';
import 'package:liftup/features/home/models/routine.dart';
import 'package:liftup/common/enums/week_day_enum.dart';

/// Generador de datos mock para sesiones de entrenamiento
/// Utilizado en pruebas y desarrollo
class SessionMockGenerator {
  static const String _routineId = 'mock-routine-id';
  static const String _exerciseId1 = 'mock-exercise-1';
  static const String _exerciseId2 = 'mock-exercise-2';
  static const String _exerciseId3 = 'mock-exercise-3';

  /// Genera sesiones diarias para las últimas 4 semanas con datos más realistas
  static List<WorkoutSession> generateLast4WeeksSessions() {
    final sessions = <WorkoutSession>[];
    final now = DateTime.now();

    // Generar sesiones para los últimos 28 días con patrones más realistas
    for (int i = 27; i >= 0; i--) {
      final day = now.subtract(Duration(days: i));

      // Simular patrones de entrenamiento más realistas:
      // - Entrenar 4-5 días por semana
      // - Saltar algunos días aleatoriamente
      // - Menos entrenamientos en fines de semana
      final shouldSkip = _shouldSkipDay(day, i);
      if (shouldSkip) continue;

      // Generar sesión con progreso más gradual y realista
      final session = _generateSessionForDay(day, i);
      sessions.add(session);
    }

    return sessions; // Ya están en orden cronológico (más antiguo primero)
  }

  /// Genera sesiones con saltos para probar el algoritmo de suavizado
  static List<WorkoutSession> generateSessionsWithJumps() {
    final sessions = <WorkoutSession>[];
    final now = DateTime.now();

    for (int i = 20; i >= 0; i--) {
      final day = now.subtract(Duration(days: i));
      
      // Crear saltos intencionalmente: algunos días sin datos, otros con picos
      if (i % 4 == 0) continue; // Saltar cada 4 días
      
      final session = _generateSessionWithJump(day, i);
      sessions.add(session);
    }

    return sessions;
  }

  /// Genera una sesión básica para pruebas
  static WorkoutSession generateBasicSession({
    DateTime? date,
    String? routineId,
    String? exerciseId,
  }) {
    final sessionDate = date ?? DateTime.now();
    final uuid = const Uuid();
    
    return WorkoutSession(
      id: uuid.v4(),
      routineId: routineId ?? _routineId,
      name: 'Sesión de prueba',
      startTime: sessionDate,
      endTime: sessionDate.add(const Duration(minutes: 60)),
      exerciseSets: [
        ExerciseSet(
          id: uuid.v4(),
          exerciseId: exerciseId ?? _exerciseId1,
          reps: 10,
          weight: 50.0,
          restTimeSeconds: 60,
          notes: 'Set de prueba',
          completedAt: sessionDate.add(const Duration(minutes: 5)),
          isCompleted: true,
        ),
      ],
      totalWeight: 50.0,
      totalReps: 10,
      status: SessionStatus.completed,
      notes: 'Sesión generada para pruebas',
    );
  }

  /// Determina si se debe saltar un día basado en patrones realistas
  static bool _shouldSkipDay(DateTime day, int dayIndex) {
    // Saltar fines de semana ocasionalmente (30% de probabilidad)
    if (day.weekday == DateTime.saturday || day.weekday == DateTime.sunday) {
      return dayIndex % 3 == 0 || dayIndex % 7 == 0;
    }

    // Saltar días entre semana ocasionalmente (15% de probabilidad)
    if (day.weekday >= DateTime.monday && day.weekday <= DateTime.friday) {
      return dayIndex % 7 == 0 || dayIndex % 11 == 0;
    }

    return false;
  }

  static WorkoutSession _generateSessionForDay(DateTime day, int dayIndex) {
    final uuid = const Uuid();
    final sessionId = uuid.v4();
    
    // Progreso más gradual y realista
    final baseWeight = 40.0 + (dayIndex * 0.8); // Progreso más lento
    final baseReps = 8 + (dayIndex % 3); // Variación en repeticiones
    
    // Generar 2-4 ejercicios por sesión
    final exerciseCount = 2 + (dayIndex % 3);
    final exerciseSets = <ExerciseSet>[];
    
    for (int e = 0; e < exerciseCount; e++) {
      final exerciseId = _getExerciseIdForIndex(e);
      final setsCount = 3 + (dayIndex % 2); // 3-4 sets por ejercicio
      
      for (int s = 0; s < setsCount; s++) {
        // Variación realista en peso y reps
        final weightVariation = (s * 2.5) + (e * 1.0);
        final repsVariation = (s * -1) + (e * 0);
        
        final weight = (baseWeight + weightVariation).clamp(20.0, 120.0);
        final reps = (baseReps + repsVariation).clamp(5, 15);
        
        exerciseSets.add(
          ExerciseSet(
            id: uuid.v4(),
            exerciseId: exerciseId,
            reps: reps,
            weight: weight,
            restTimeSeconds: 60 + (s * 15),
            notes: s == 0 ? 'Primer set' : null,
            completedAt: day.add(Duration(
              hours: 18,
              minutes: (e * 20) + (s * 3),
            )),
            isCompleted: true,
          ),
        );
      }
    }
    
    // Calcular totales
    final totalWeight = exerciseSets.fold<double>(
      0.0, 
      (sum, set) => sum + (set.weight * set.reps),
    );
    final totalReps = exerciseSets.fold<int>(
      0, 
      (sum, set) => sum + set.reps,
    );
    
    final startTime = DateTime(day.year, day.month, day.day, 18, 0);
    final duration = Duration(minutes: 45 + (exerciseCount * 10));
    final endTime = startTime.add(duration);
    
    return WorkoutSession(
      id: sessionId,
      routineId: _routineId,
      name: 'Entrenamiento ${_getDayName(day.weekday)}',
      startTime: startTime,
      endTime: endTime,
      exerciseSets: exerciseSets,
      totalWeight: totalWeight,
      totalReps: totalReps,
      status: SessionStatus.completed,
      notes: 'Sesión generada automáticamente',
    );
  }

  static WorkoutSession _generateSessionWithJump(DateTime day, int dayIndex) {
    final uuid = const Uuid();
    final sessionId = uuid.v4();
    
    // Crear saltos intencionalmente
    double baseWeight;
    if (dayIndex % 6 == 0) {
      baseWeight = 80.0; // Pico alto
    } else if (dayIndex % 5 == 0) {
      baseWeight = 30.0; // Valle bajo
    } else {
      baseWeight = 50.0 + (dayIndex * 0.5); // Progreso normal
    }
    
    final exerciseSets = <ExerciseSet>[];
    final setsCount = 3 + (dayIndex % 2);
    
    for (int s = 0; s < setsCount; s++) {
      final weight = baseWeight + (s * 2.5);
      final reps = 8 + (s * -1);
      
      exerciseSets.add(
        ExerciseSet(
          id: uuid.v4(),
          exerciseId: _exerciseId1,
          reps: reps,
          weight: weight,
          restTimeSeconds: 60,
          notes: 'Set con salto',
          completedAt: day.add(Duration(hours: 18, minutes: s * 3)),
          isCompleted: true,
        ),
      );
    }
    
    final totalWeight = exerciseSets.fold<double>(
      0.0, 
      (sum, set) => sum + (set.weight * set.reps),
    );
    final totalReps = exerciseSets.fold<int>(
      0, 
      (sum, set) => sum + set.reps,
    );
    
    return WorkoutSession(
      id: sessionId,
      routineId: _routineId,
      name: 'Sesión con salto $dayIndex',
      startTime: DateTime(day.year, day.month, day.day, 18, 0),
      endTime: DateTime(day.year, day.month, day.day, 19, 0),
      exerciseSets: exerciseSets,
      totalWeight: totalWeight,
      totalReps: totalReps,
      status: SessionStatus.completed,
      notes: 'Sesión con saltos para pruebas',
    );
  }

  static String _getExerciseIdForIndex(int index) {
    switch (index % 3) {
      case 0: return _exerciseId1;
      case 1: return _exerciseId2;
      case 2: return _exerciseId3;
      default: return _exerciseId1;
    }
  }

  static String _getDayName(int weekday) {
    switch (weekday) {
      case DateTime.monday: return 'Lunes';
      case DateTime.tuesday: return 'Martes';
      case DateTime.wednesday: return 'Miércoles';
      case DateTime.thursday: return 'Jueves';
      case DateTime.friday: return 'Viernes';
      case DateTime.saturday: return 'Sábado';
      case DateTime.sunday: return 'Domingo';
      default: return 'Día';
    }
  }

  /// Genera ejercicios mock para las pruebas
  static List<Map<String, dynamic>> generateMockExercises() {
    return [
      {
        'id': _exerciseId1,
        'name': 'Press de Banca',
        'description': 'Ejercicio de pecho',
        'muscleGroups': ['Pecho', 'Hombros', 'Tríceps'],
        'equipment': 'Barra',
        'imageUrl': null,
        'videoUrl': null,
        'instructions': 'Acuéstate en el banco y baja la barra al pecho',
        'createdAt': DateTime.now().subtract(const Duration(days: 30)),
        'updatedAt': DateTime.now(),
      },
      {
        'id': _exerciseId2,
        'name': 'Sentadillas',
        'description': 'Ejercicio de piernas',
        'muscleGroups': ['Cuádriceps', 'Glúteos', 'Isquiotibiales'],
        'equipment': 'Barra',
        'imageUrl': null,
        'videoUrl': null,
        'instructions':
            'Coloca la barra en los hombros y baja como si te sentaras',
        'createdAt': DateTime.now().subtract(const Duration(days: 30)),
        'updatedAt': DateTime.now(),
      },
      {
        'id': _exerciseId3,
        'name': 'Dominadas',
        'description': 'Ejercicio de espalda',
        'muscleGroups': ['Dorsales', 'Bíceps', 'Deltoides posterior'],
        'equipment': 'Barra de dominadas',
        'imageUrl': null,
        'videoUrl': null,
        'instructions': 'Cuelga de la barra y tira hacia arriba',
        'createdAt': DateTime.now().subtract(const Duration(days: 30)),
        'updatedAt': DateTime.now(),
      },
    ];
  }

  /// Genera rutinas mock para las pruebas
  static List<Routine> generateMockRoutines() {
    final uuid = const Uuid();
    final now = DateTime.now();
    
    return [
      Routine(
        id: _routineId,
        name: 'Rutina de Fuerza',
        description: 'Rutina completa de fuerza para principiantes',
        days: [WeekDay.monday, WeekDay.wednesday, WeekDay.friday],
        sections: [],
        createdAt: now.subtract(const Duration(days: 30)),
        updatedAt: now,
        imageUrl: null,
        order: 1,
      ),
      Routine(
        id: uuid.v4(),
        name: 'Rutina de Hipertrofia',
        description: 'Rutina enfocada en crecimiento muscular',
        days: [WeekDay.tuesday, WeekDay.thursday, WeekDay.saturday],
        sections: [],
        createdAt: now.subtract(const Duration(days: 20)),
        updatedAt: now,
        imageUrl: null,
        order: 2,
      ),
    ];
  }
}
