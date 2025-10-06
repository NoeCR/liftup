import 'package:liftly/features/progression/models/progression_config.dart';
import 'package:liftly/features/progression/models/progression_state.dart';
import 'package:liftly/features/progression/models/progression_template.dart';
import 'package:liftly/common/enums/progression_type_enum.dart';
import 'package:liftly/features/exercise/models/exercise.dart';
import 'package:liftly/features/home/models/routine.dart';
import 'package:liftly/features/exercise/models/exercise_set.dart';
import 'package:liftly/common/enums/week_day_enum.dart';

/// Factory para generar datos mock específicos para pruebas de progresión
class ProgressionMockFactory {
  /// Genera una configuración de progresión mock
  static ProgressionConfig createProgressionConfig({
    String? id,
    ProgressionType? type,
    bool? isGlobal,
    ProgressionUnit? unit,
    ProgressionTarget? primaryTarget,
    ProgressionTarget? secondaryTarget,
    double? incrementValue,
    int? incrementFrequency,
    int? cycleLength,
    int? deloadWeek,
    double? deloadPercentage,
    Map<String, dynamic>? customParameters,
    bool? isActive,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return ProgressionConfig(
      id: id ?? 'test-config-${DateTime.now().millisecondsSinceEpoch}',
      isGlobal: isGlobal ?? true,
      type: type ?? ProgressionType.linear,
      unit: unit ?? ProgressionUnit.session,
      primaryTarget: primaryTarget ?? ProgressionTarget.weight,
      secondaryTarget: secondaryTarget,
      incrementValue: incrementValue ?? 2.5,
      incrementFrequency: incrementFrequency ?? 1,
      cycleLength: cycleLength ?? 4,
      deloadWeek: deloadWeek ?? 4,
      deloadPercentage: deloadPercentage ?? 0.9,
      customParameters: customParameters ?? {},
      startDate: startDate ?? DateTime.now(),
      endDate: endDate,
      isActive: isActive ?? true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// Genera un estado de progresión mock
  static ProgressionState createProgressionState({
    String? id,
    String? progressionConfigId,
    String? exerciseId,
    int? currentCycle,
    int? currentWeek,
    int? currentSession,
    double? currentWeight,
    int? currentReps,
    int? currentSets,
    double? baseWeight,
    int? baseReps,
    int? baseSets,
    Map<String, dynamic>? sessionHistory,
    bool? isDeloadWeek,
    double? oneRepMax,
    Map<String, dynamic>? customData,
    DateTime? lastUpdated,
  }) {
    return ProgressionState(
      id: id ?? 'test-state-${DateTime.now().millisecondsSinceEpoch}',
      progressionConfigId: progressionConfigId ?? 'test-config-1',
      exerciseId: exerciseId ?? 'test-exercise-1',
      currentCycle: currentCycle ?? 1,
      currentWeek: currentWeek ?? 1,
      currentSession: currentSession ?? 1,
      currentWeight: currentWeight ?? 100.0,
      currentReps: currentReps ?? 10,
      currentSets: currentSets ?? 3,
      baseWeight: baseWeight ?? 100.0,
      baseReps: baseReps ?? 10,
      baseSets: baseSets ?? 3,
      sessionHistory: sessionHistory ?? {},
      isDeloadWeek: isDeloadWeek ?? false,
      oneRepMax: oneRepMax ?? 125.0,
      customData: customData ?? {},
      lastUpdated: lastUpdated ?? DateTime.now(),
    );
  }

  /// Genera una plantilla de progresión mock
  static ProgressionTemplate createProgressionTemplate({
    String? id,
    String? name,
    String? description,
    ProgressionType? type,
    ProgressionUnit? defaultUnit,
    ProgressionTarget? defaultPrimaryTarget,
    ProgressionTarget? defaultSecondaryTarget,
    double? defaultIncrementValue,
    int? defaultIncrementFrequency,
    int? defaultCycleLength,
    int? defaultDeloadWeek,
    double? defaultDeloadPercentage,
    Map<String, dynamic>? defaultParameters,
    String? difficulty,
    List<String>? recommendedFor,
    String? example,
    bool? isBuiltIn,
  }) {
    return ProgressionTemplate(
      id: id ?? 'test-template-${DateTime.now().millisecondsSinceEpoch}',
      name: name ?? 'Test Template',
      description: description ?? 'Test template description',
      type: type ?? ProgressionType.linear,
      defaultUnit: defaultUnit ?? ProgressionUnit.session,
      defaultPrimaryTarget: defaultPrimaryTarget ?? ProgressionTarget.weight,
      defaultSecondaryTarget: defaultSecondaryTarget,
      defaultIncrementValue: defaultIncrementValue ?? 2.5,
      defaultIncrementFrequency: defaultIncrementFrequency ?? 1,
      defaultCycleLength: defaultCycleLength ?? 4,
      defaultDeloadWeek: defaultDeloadWeek ?? 4,
      defaultDeloadPercentage: defaultDeloadPercentage ?? 0.9,
      defaultParameters: defaultParameters ?? {},
      recommendedFor: recommendedFor ?? ['Principiante', 'Intermedio'],
      difficulty: difficulty ?? 'Intermedio',
      example: example ?? 'Ejemplo de uso',
      isBuiltIn: isBuiltIn ?? true,
      createdAt: DateTime.now(),
    );
  }

  /// Genera un ejercicio mock
  static Exercise createExercise({String? id, String? name, String? description}) {
    return Exercise(
      id: id ?? 'test-exercise-${DateTime.now().millisecondsSinceEpoch}',
      name: name ?? 'Test Exercise',
      description: description ?? 'Test exercise description',
      imageUrl: '',
      muscleGroups: [],
      tips: [],
      commonMistakes: [],
      category: ExerciseCategory.chest,
      difficulty: ExerciseDifficulty.intermediate,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// Genera un ejercicio de rutina mock
  static RoutineExercise createRoutineExercise({String? id, String? exerciseId, String? notes}) {
    return RoutineExercise(
      id: id ?? 'test-routine-exercise-${DateTime.now().millisecondsSinceEpoch}',
      routineSectionId: 'test-section-1',
      exerciseId: exerciseId ?? 'test-exercise-1',
      notes: notes ?? '',
      order: 1,
    );
  }

  /// Genera un set de ejercicio mock
  static ExerciseSet createExerciseSet({
    String? id,
    String? exerciseId,
    int? reps,
    double? weight,
    int? restTimeSeconds,
    String? notes,
    DateTime? completedAt,
    bool? isCompleted,
  }) {
    return ExerciseSet(
      id: id ?? 'test-exercise-set-${DateTime.now().millisecondsSinceEpoch}',
      exerciseId: exerciseId ?? 'test-exercise-1',
      reps: reps ?? 10,
      weight: weight ?? 100.0,
      restTimeSeconds: restTimeSeconds ?? 90,
      notes: notes ?? '',
      completedAt: completedAt ?? DateTime.now(),
      isCompleted: isCompleted ?? false,
    );
  }

  /// Genera una rutina mock
  static Routine createRoutine({String? id, String? name, String? description, List<RoutineExercise>? exercises}) {
    final routineId = id ?? 'test-routine-${DateTime.now().millisecondsSinceEpoch}';
    return Routine(
      id: routineId,
      name: name ?? 'Test Routine',
      description: description ?? 'Test routine description',
      days: [WeekDay.monday, WeekDay.wednesday, WeekDay.friday],
      sections: [
        RoutineSection(
          id: 'test-section-1',
          routineId: routineId,
          name: 'Test Section',
          exercises: exercises ?? [createRoutineExercise(), createRoutineExercise(exerciseId: 'test-exercise-2')],
          isCollapsed: false,
          order: 1,
        ),
      ],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// Genera configuraciones de progresión para cada tipo
  static Map<ProgressionType, ProgressionConfig> createAllProgressionTypes() {
    return {
      ProgressionType.linear: createProgressionConfig(
        type: ProgressionType.linear,
        incrementValue: 2.5,
        incrementFrequency: 1,
      ),
      ProgressionType.undulating: createProgressionConfig(
        type: ProgressionType.undulating,
        incrementValue: 5.0,
        incrementFrequency: 2,
        customParameters: {'heavy_day_multiplier': 1.1, 'light_day_multiplier': 0.9},
      ),
      ProgressionType.stepped: createProgressionConfig(
        type: ProgressionType.stepped,
        incrementValue: 2.5,
        incrementFrequency: 1,
        deloadWeek: 4,
        deloadPercentage: 0.85,
      ),
      ProgressionType.double: createProgressionConfig(
        type: ProgressionType.double,
        primaryTarget: ProgressionTarget.reps,
        secondaryTarget: ProgressionTarget.weight,
        customParameters: {'max_reps': 12, 'min_reps': 8},
      ),
      ProgressionType.wave: createProgressionConfig(
        type: ProgressionType.wave,
        incrementValue: 2.5,
        incrementFrequency: 1,
        cycleLength: 3,
        customParameters: {'week_1_multiplier': 1.0, 'week_2_multiplier': 1.05, 'week_3_multiplier': 1.1},
      ),
      ProgressionType.static: createProgressionConfig(
        type: ProgressionType.static,
        incrementValue: 0.0,
        incrementFrequency: 0,
      ),
      ProgressionType.reverse: createProgressionConfig(
        type: ProgressionType.reverse,
        incrementValue: -2.5,
        incrementFrequency: 1,
      ),
    };
  }

  /// Genera estados de progresión para diferentes escenarios
  static Map<String, ProgressionState> createProgressionStates() {
    return {
      'beginner': createProgressionState(
        currentWeight: 50.0,
        currentReps: 10,
        currentSets: 3,
        currentWeek: 1,
        currentSession: 1,
        baseWeight: 50.0,
        baseReps: 10,
        baseSets: 3,
      ),
      'intermediate': createProgressionState(
        currentWeight: 100.0,
        currentReps: 8,
        currentSets: 4,
        currentWeek: 2,
        currentSession: 3,
        baseWeight: 100.0,
        baseReps: 8,
        baseSets: 4,
      ),
      'advanced': createProgressionState(
        currentWeight: 150.0,
        currentReps: 6,
        currentSets: 5,
        currentWeek: 3,
        currentSession: 5,
        baseWeight: 150.0,
        baseReps: 6,
        baseSets: 5,
      ),
      'deload_week': createProgressionState(
        currentWeight: 120.0,
        currentReps: 8,
        currentSets: 3,
        currentWeek: 4,
        currentSession: 1,
        baseWeight: 120.0,
        baseReps: 8,
        baseSets: 3,
        isDeloadWeek: true,
      ),
    };
  }

  /// Genera plantillas de progresión para cada tipo
  static List<ProgressionTemplate> createAllProgressionTemplates() {
    return ProgressionType.values
        .where((type) => type != ProgressionType.none)
        .map(
          (type) => createProgressionTemplate(
            type: type,
            name: '${type.displayNameKey} Template',
            description: 'Template for ${type.displayNameKey} progression',
            difficulty: _getDifficultyForType(type),
          ),
        )
        .toList();
  }

  static String _getDifficultyForType(ProgressionType type) {
    switch (type) {
      case ProgressionType.linear:
      case ProgressionType.static:
        return 'Principiante';
      case ProgressionType.undulating:
      case ProgressionType.stepped:
      case ProgressionType.double:
        return 'Intermedio';
      case ProgressionType.wave:
      case ProgressionType.reverse:
        return 'Avanzado';
      default:
        return 'Intermedio';
    }
  }
}
