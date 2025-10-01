import 'package:uuid/uuid.dart';
import 'package:liftup/features/sessions/models/workout_session.dart';
import 'package:liftup/features/exercise/models/exercise_set.dart';
import 'package:liftup/features/home/models/routine.dart';

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
    final sessionId = const Uuid().v4();
    final startTime = DateTime(day.year, day.month, day.day, 18, 0);
    final endTime = startTime.add(Duration(minutes: 45 + (dayIndex % 20)));

    // Simular progreso más gradual y realista con variaciones naturales
    final weeklyCycle = (dayIndex % 7) / 7.0; // Ciclo semanal 0-1
    final monthlyProgress = dayIndex / 28.0; // Progreso mensual 0-1

    // Variación semanal más suave (días de descanso vs entrenamiento intenso)
    final weeklyVariation = (weeklyCycle - 0.5) * 10.0; // -5 a +5

    // Variación aleatoria pequeña para simular días buenos/malos
    final randomVariation = (dayIndex * 0.1) % 1.0 - 0.5; // -0.5 a +0.5

    final exerciseSets = <ExerciseSet>[];

    // Ejercicio 1: Press de banca (progreso gradual con variaciones)
    final benchPressBase = 60.0 + (monthlyProgress * 15.0); // Progreso mensual
    final benchPressWeight =
        benchPressBase + weeklyVariation * 0.3 + randomVariation * 2.0;
    final benchPressReps = 8 + (weeklyCycle * 2).round(); // 8-10 reps
    exerciseSets.addAll(
      _generateSetsForExercise(
        _exerciseId1,
        benchPressWeight,
        benchPressReps,
        startTime,
        3 + (weeklyCycle * 1).round(), // 3-4 sets
      ),
    );

    // Ejercicio 2: Sentadillas (progreso moderado)
    final squatBase = 80.0 + (monthlyProgress * 12.0);
    final squatWeight =
        squatBase + weeklyVariation * 0.2 + randomVariation * 1.5;
    final squatReps = 10 + (weeklyCycle * 1).round(); // 10-11 reps
    exerciseSets.addAll(
      _generateSetsForExercise(
        _exerciseId2,
        squatWeight,
        squatReps,
        startTime.add(const Duration(minutes: 15)),
        3,
      ),
    );

    // Ejercicio 3: Dominadas (progreso lento pero consistente)
    final pullupWeight = 0.0; // Peso corporal
    final pullupBase = 5.0 + (monthlyProgress * 8.0);
    final pullupReps =
        (pullupBase + weeklyVariation * 0.1 + randomVariation * 1.0).round();
    exerciseSets.addAll(
      _generateSetsForExercise(
        _exerciseId3,
        pullupWeight,
        pullupReps,
        startTime.add(const Duration(minutes: 30)),
        2 + (weeklyCycle * 1).round(), // 2-3 sets
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

  /// Genera sesiones con saltos bruscos para probar el algoritmo de suavizado
  static List<WorkoutSession> generateSessionsWithJumps() {
    final sessions = <WorkoutSession>[];
    final now = DateTime.now();

    // Generar sesiones con patrones de saltos bruscos
    for (int i = 27; i >= 0; i--) {
      final day = now.subtract(Duration(days: i));

      // Saltar algunos días para crear huecos
      if (i % 4 == 0) continue;

      final session = _generateSessionWithJumps(day, i);
      sessions.add(session);
    }

    return sessions;
  }

  static WorkoutSession _generateSessionWithJumps(DateTime day, int dayIndex) {
    final sessionId = const Uuid().v4();
    final startTime = DateTime(day.year, day.month, day.day, 18, 0);
    final endTime = startTime.add(Duration(minutes: 45 + (dayIndex % 20)));

    final exerciseSets = <ExerciseSet>[];

    // Crear saltos bruscos intencionalmente
    double weight;
    if (dayIndex < 7) {
      weight = 60.0; // Semana 1: peso bajo
    } else if (dayIndex < 14) {
      weight = 90.0; // Semana 2: salto brusco hacia arriba
    } else if (dayIndex < 21) {
      weight = 70.0; // Semana 3: salto brusco hacia abajo
    } else {
      weight = 85.0; // Semana 4: recuperación gradual
    }

    // Agregar variación aleatoria pequeña
    weight += (dayIndex % 3) * 2.0;

    exerciseSets.addAll(
      _generateSetsForExercise(
        _exerciseId1,
        weight,
        8 + (dayIndex % 3),
        startTime,
        3,
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
