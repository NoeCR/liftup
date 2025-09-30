import 'package:uuid/uuid.dart';
import 'package:liftup/features/sessions/models/workout_session.dart';
import 'package:liftup/features/exercise/models/exercise_set.dart';
import 'package:liftup/features/home/models/routine.dart';

class SessionMockGenerator {
  static const String _routineId = 'mock-routine-id';
  static const String _exerciseId1 = 'mock-exercise-1';
  static const String _exerciseId2 = 'mock-exercise-2';
  static const String _exerciseId3 = 'mock-exercise-3';

  /// Genera sesiones diarias para las últimas 4 semanas
  static List<WorkoutSession> generateLast4WeeksSessions() {
    final sessions = <WorkoutSession>[];
    final now = DateTime.now();

    // Generar sesiones para los últimos 28 días (desde la más antigua)
    for (int i = 27; i >= 0; i--) {
      final day = now.subtract(Duration(days: i));

      // Saltar algunos días para simular descansos (ej: fines de semana)
      if (day.weekday == DateTime.saturday || day.weekday == DateTime.sunday) {
        if (i % 3 == 0) continue; // Saltar algunos fines de semana
      }

      final session = _generateSessionForDay(day, i);
      sessions.add(session);
    }

    return sessions; // Ya están en orden cronológico (más antiguo primero)
  }

  static WorkoutSession _generateSessionForDay(DateTime day, int dayIndex) {
    final sessionId = const Uuid().v4();
    final startTime = DateTime(day.year, day.month, day.day, 18, 0);
    final endTime = startTime.add(Duration(minutes: 45 + (dayIndex % 20)));

    // Simular progreso gradual con variaciones realistas
    final variation = (dayIndex % 7) * 5.0; // Variación semanal

    final exerciseSets = <ExerciseSet>[];

    // Ejercicio 1: Press de banca (progreso más rápido)
    final benchPressWeight = 60.0 + (dayIndex * 1.2) + variation * 0.5;
    final benchPressReps = 8 + (dayIndex % 3);
    exerciseSets.addAll(
      _generateSetsForExercise(
        _exerciseId1,
        benchPressWeight,
        benchPressReps,
        startTime,
        3 + (dayIndex % 2),
      ),
    );

    // Ejercicio 2: Sentadillas (progreso moderado)
    final squatWeight = 80.0 + (dayIndex * 0.8) + variation * 0.3;
    final squatReps = 10 + (dayIndex % 2);
    exerciseSets.addAll(
      _generateSetsForExercise(
        _exerciseId2,
        squatWeight,
        squatReps,
        startTime.add(const Duration(minutes: 15)),
        3,
      ),
    );

    // Ejercicio 3: Dominadas (progreso lento, más reps)
    final pullupWeight = 0.0; // Peso corporal
    final pullupReps = 5 + (dayIndex * 0.3).round() + (dayIndex % 4);
    exerciseSets.addAll(
      _generateSetsForExercise(
        _exerciseId3,
        pullupWeight,
        pullupReps,
        startTime.add(const Duration(minutes: 30)),
        2 + (dayIndex % 2),
      ),
    );

    return WorkoutSession(
      id: sessionId,
      name: 'Sesión ${day.day}/${day.month}',
      routineId: _routineId,
      startTime: startTime,
      endTime: endTime,
      status: SessionStatus.completed,
      exerciseSets: exerciseSets,
      notes: null,
      totalWeight: exerciseSets.fold<double>(
        0,
        (sum, set) => sum + (set.weight * set.reps),
      ),
      totalReps: exerciseSets.fold<int>(0, (sum, set) => sum + set.reps),
    );
  }

  static List<ExerciseSet> _generateSetsForExercise(
    String exerciseId,
    double baseWeight,
    int baseReps,
    DateTime startTime,
    int setCount,
  ) {
    final sets = <ExerciseSet>[];

    for (int i = 0; i < setCount; i++) {
      // Variación realista entre sets (último set puede ser más pesado o más reps)
      final weight = baseWeight + (i * 2.5);
      final reps = i == setCount - 1 ? baseReps + 1 : baseReps;

      sets.add(
        ExerciseSet(
          id: const Uuid().v4(),
          exerciseId: exerciseId,
          reps: reps,
          weight: weight,
          restTimeSeconds: 90,
          notes: null,
          completedAt: startTime.add(Duration(minutes: i * 3)),
          isCompleted: true,
        ),
      );
    }

    return sets;
  }

  /// Genera rutinas mock para las pruebas
  static List<Routine> generateMockRoutines() {
    return [
      Routine(
        id: _routineId,
        name: 'Rutina Fuerza',
        description: 'Rutina de fuerza general',
        days: const [],
        sections: const [],
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        updatedAt: DateTime.now(),
        imageUrl: null,
      ),
    ];
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
}
