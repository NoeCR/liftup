import 'package:liftly/features/sessions/models/workout_session.dart';
import 'package:liftly/features/exercise/models/exercise.dart';
import 'package:liftly/features/exercise/models/exercise_set.dart';
import 'package:liftly/features/home/models/routine.dart';
import 'package:liftly/features/statistics/models/progress_data.dart';
import 'package:liftly/common/enums/muscle_group_enum.dart';
import 'session_mock_generator.dart';

/// Factory para generar datos mock completos para pruebas
class MockDataFactory {
  /// Genera un conjunto completo de datos mock
  static MockDataSet generateCompleteDataSet() {
    return MockDataSet(
      sessions: SessionMockGenerator.generateLast4WeeksSessions(),
      exercises: _generateMockExercises(),
      routines: SessionMockGenerator.generateMockRoutines(),
      progressData: _generateMockProgressData(),
    );
  }

  /// Genera datos mock para pruebas de suavizado (con saltos)
  static MockDataSet generateJumpTestDataSet() {
    return MockDataSet(
      sessions: SessionMockGenerator.generateSessionsWithJumps(),
      exercises: _generateMockExercises(),
      routines: SessionMockGenerator.generateMockRoutines(),
      progressData: _generateMockProgressData(),
    );
  }

  /// Genera un conjunto mínimo de datos mock
  static MockDataSet generateMinimalDataSet() {
    return MockDataSet(
      sessions: [SessionMockGenerator.generateBasicSession()],
      exercises: _generateMockExercises().take(1).toList(),
      routines: SessionMockGenerator.generateMockRoutines().take(1).toList(),
      progressData: [],
    );
  }

  /// Genera ejercicios mock
  static List<Exercise> _generateMockExercises() {
    final mockData = SessionMockGenerator.generateMockExercises();
    return mockData
        .map(
          (data) => Exercise(
            id: data['id'] as String,
            name: data['name'] as String,
            description: data['description'] as String,
            imageUrl: data['imageUrl'] as String? ?? '',
            videoUrl: data['videoUrl'] as String?,
            muscleGroups: _parseMuscleGroups(data['muscleGroups'] as List<String>),
            tips: ['Mantén la forma correcta', 'Respira adecuadamente'],
            commonMistakes: ['Arquear la espalda', 'Movimiento muy rápido'],
            category: ExerciseCategory.chest,
            difficulty: ExerciseDifficulty.intermediate,
            createdAt: data['createdAt'] as DateTime,
            updatedAt: data['updatedAt'] as DateTime,
          ),
        )
        .toList();
  }

  /// Convierte strings a MuscleGroup enum
  static List<MuscleGroup> _parseMuscleGroups(List<String> muscleGroupStrings) {
    return muscleGroupStrings.map((group) {
      switch (group.toLowerCase()) {
        case 'pecho':
          return MuscleGroup.pectoralMajor;
        case 'hombros':
          return MuscleGroup.anteriorDeltoid;
        case 'tríceps':
          return MuscleGroup.tricepsLongHead;
        case 'cuádriceps':
          return MuscleGroup.rectusFemoris;
        case 'glúteos':
          return MuscleGroup.gluteusMaximus;
        case 'isquiotibiales':
          return MuscleGroup.bicepsFemoris;
        case 'dorsales':
          return MuscleGroup.latissimusDorsi;
        case 'bíceps':
          return MuscleGroup.bicepsLongHead;
        case 'deltoides posterior':
          return MuscleGroup.posteriorDeltoid;
        default:
          return MuscleGroup.pectoralMajor;
      }
    }).toList();
  }

  /// Genera datos de progreso mock basados en las sesiones
  static List<ProgressData> _generateMockProgressData() {
    final sessions = SessionMockGenerator.generateLast4WeeksSessions();
    final progressData = <ProgressData>[];

    // Agrupar por ejercicio y fecha
    final exerciseDataByDate = <String, Map<DateTime, List<ExerciseSet>>>{};

    for (final session in sessions) {
      final sessionDate = DateTime(session.startTime.year, session.startTime.month, session.startTime.day);

      for (final set in session.exerciseSets) {
        exerciseDataByDate.putIfAbsent(set.exerciseId, () => {});
        exerciseDataByDate[set.exerciseId]!.putIfAbsent(sessionDate, () => []).add(set);
      }
    }

    // Generar ProgressData
    for (final exerciseEntry in exerciseDataByDate.entries) {
      final exerciseId = exerciseEntry.key;

      for (final dateEntry in exerciseEntry.value.entries) {
        final date = dateEntry.key;
        final sets = dateEntry.value;

        if (sets.isEmpty) continue;

        final maxWeight = sets.map((s) => s.weight).reduce((a, b) => a > b ? a : b);
        final totalReps = sets.map((s) => s.reps).reduce((a, b) => a + b);
        final totalSets = sets.length;
        final totalVolume = sets.map((s) => s.weight * s.reps).reduce((a, b) => a + b);

        progressData.add(
          ProgressData(
            id: '${exerciseId}_${date.millisecondsSinceEpoch}',
            exerciseId: exerciseId,
            date: date,
            maxWeight: maxWeight,
            totalReps: totalReps,
            totalSets: totalSets,
            totalVolume: totalVolume,
            duration: const Duration(minutes: 60),
          ),
        );
      }
    }

    return progressData;
  }
}

/// Conjunto de datos mock para pruebas
class MockDataSet {
  final List<WorkoutSession> sessions;
  final List<Exercise> exercises;
  final List<Routine> routines;
  final List<ProgressData> progressData;

  const MockDataSet({
    required this.sessions,
    required this.exercises,
    required this.routines,
    required this.progressData,
  });

  /// Obtiene el número total de elementos
  int get totalElements => sessions.length + exercises.length + routines.length + progressData.length;

  /// Obtiene una descripción del conjunto de datos
  String get description {
    return 'MockDataSet: ${sessions.length} sesiones, ${exercises.length} ejercicios, ${routines.length} rutinas, ${progressData.length} datos de progreso';
  }

  /// Verifica si el conjunto de datos está vacío
  bool get isEmpty => totalElements == 0;

  /// Verifica si el conjunto de datos tiene contenido
  bool get isNotEmpty => totalElements > 0;
}
