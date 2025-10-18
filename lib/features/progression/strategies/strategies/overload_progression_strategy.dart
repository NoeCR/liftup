import '../../../../features/exercise/models/exercise.dart';
import '../../configs/adaptive_increment_config.dart';
import '../../enums/training_objective.dart';
import '../../models/progression_calculation_result.dart';
import '../../models/progression_config.dart';
import '../../models/progression_state.dart';
import '../base_progression_strategy.dart';
import '../progression_strategy.dart';

/// Estrategia de Sobrecarga Progresiva
///
/// Esta estrategia implementa una sobrecarga progresiva que puede enfocarse en
/// volumen (series) o intensidad (peso) según la configuración.
///
/// **Fundamentos teóricos:**
/// - Basada en el principio de sobrecarga progresiva
/// - Permite incrementar volumen o intensidad progresivamente
/// - Ideal para fases de acumulación de volumen
/// - Facilita la adaptación a cargas crecientes
/// - Optimiza las ganancias de fuerza e hipertrofia
///
/// **Algoritmo:**
/// 1. Calcula la posición actual en el ciclo
/// 2. Verifica si es período de deload
/// 3. Obtiene parámetros de sobrecarga:
///    - overloadType: Tipo de sobrecarga ('volume' o 'intensity')
///    - overloadRate: Tasa de incremento (default: 0.1 = 10%)
/// 4. Aplica sobrecarga según el tipo:
///    - Si overloadType == 'volume':
///      * Mantiene peso y repeticiones constantes
///      * Incrementa series por el overloadRate
///    - Si overloadType == 'intensity':
///      * Incrementa peso por el overloadRate
///      * Mantiene repeticiones y series constantes
/// 5. Durante deload:
///    - Reduce peso manteniendo incremento sobre base
///    - Reduce series al 70%
///
/// **Parámetros clave:**
/// - overloadType: Tipo de sobrecarga ('volume' o 'intensity')
/// - overloadRate: Tasa de incremento (0.1 = 10%)
/// - deloadWeek: Semana de deload
/// - deloadPercentage: Porcentaje de reducción durante deload
///
/// **Ventajas:**
/// - Flexible en el tipo de sobrecarga
/// - Progresión gradual y sostenible
/// - Efectiva para acumulación de volumen
/// - Permite adaptación a cargas crecientes
/// - Optimiza ganancias de fuerza e hipertrofia
///
/// **Limitaciones:**
/// - Requiere planificación cuidadosa de fases
/// - Puede llevar a sobreentrenamiento si no se maneja bien
/// - Necesita deloads apropiados
/// - Requiere monitoreo de fatiga
class OverloadProgressionStrategy extends BaseProgressionStrategy implements ProgressionStrategy {
  @override
  ProgressionCalculationResult calculate({
    required ProgressionConfig config,
    required ProgressionState state,
    required String routineId,
    required double currentWeight,
    required int currentReps,
    required int currentSets,
    ExerciseType? exerciseType,
    Exercise? exercise,
    bool isExerciseLocked = false,
  }) {
    // Verificar si la progresión está bloqueada
    if (isProgressionBlocked(state, state.exerciseId, routineId, isExerciseLocked)) {
      return createBlockedResult(
        currentWeight: currentWeight,
        currentReps: currentReps,
        currentSets: state.baseSets,
        reason: 'Overload progression: blocked for exercise ${state.exerciseId} in routine $routineId',
      );
    }

    final currentInCycle = getCurrentInCycle(config, state);
    final isDeload = isDeloadPeriod(config, currentInCycle);

    // Si es deload, aplicar deload estándar
    if (isDeload) {
      if (exercise == null) {
        return createBlockedResult(
          currentWeight: currentWeight,
          currentReps: currentReps,
          currentSets: currentSets,
          reason: 'Overload progression: exercise required for deload',
        );
      }

      return applyStandardDeload(
        config: config,
        state: state,
        currentWeight: currentWeight,
        currentReps: currentReps,
        currentSets: currentSets,
        currentInCycle: currentInCycle,
        exercise: exercise,
      );
    }

    // Requerir ejercicio para aplicar progresión
    if (exercise == null) {
      return createBlockedResult(
        currentWeight: currentWeight,
        currentReps: currentReps,
        currentSets: currentSets,
        reason: 'Overload progression: exercise required for progression',
      );
    }

    // Aplicar lógica específica de sobrecarga progresiva
    final overloadType = _getOverloadTypeByObjective(config);
    final overloadRate = _getOverloadRateByObjective(config);

    if (overloadType == 'volume') {
      return createProgressionResult(
        newWeight: currentWeight,
        newReps: currentReps,
        newSets: state.baseSets,
        incrementApplied: true,
        reason: 'Overload progression: increasing volume',
      );
    } else {
      // Usar AdaptiveIncrementConfig para incrementos de peso
      final incrementValue = getIncrementValueSync(config, exercise, state);
      final overloadIncrement = incrementValue * (1 + overloadRate);
      return createProgressionResult(
        newWeight: currentWeight + overloadIncrement,
        newReps: currentReps,
        newSets: state.baseSets,
        incrementApplied: true,
        reason: 'Overload progression: increasing intensity',
      );
    }
  }

  @override
  bool shouldApplyProgressionValues(ProgressionState? progressionState, String routineId, bool isExerciseLocked) {
    return true; // Overload progression siempre aplica valores
  }

  /// Obtiene el tipo de overload basado en el objetivo de entrenamiento
  String _getOverloadTypeByObjective(ProgressionConfig config) {
    final customParams = config.customParameters;
    final customType = customParams['overload_type'] as String?;

    if (customType != null) {
      return customType;
    }

    // Derivar tipo de overload por objetivo
    final objective = AdaptiveIncrementConfig.parseObjective(config.getTrainingObjective());

    switch (objective) {
      case TrainingObjective.strength:
        return 'intensity'; // Sobrecarga por intensidad para fuerza
      case TrainingObjective.hypertrophy:
        return 'volume'; // Sobrecarga por volumen para hipertrofia
      case TrainingObjective.endurance:
        return 'volume'; // Sobrecarga por volumen para resistencia
      case TrainingObjective.power:
        return 'intensity'; // Sobrecarga por intensidad para potencia
    }
  }

  /// Obtiene la tasa de overload basada en el objetivo de entrenamiento
  double _getOverloadRateByObjective(ProgressionConfig config) {
    final customParams = config.customParameters;
    final customRate = (customParams['overload_rate'] as num?)?.toDouble();

    if (customRate != null) {
      return customRate;
    }

    // Derivar tasa de overload por objetivo
    final objective = AdaptiveIncrementConfig.parseObjective(config.getTrainingObjective());

    switch (objective) {
      case TrainingObjective.strength:
        return 0.05; // Tasa conservadora para fuerza
      case TrainingObjective.hypertrophy:
        return 0.1; // Tasa moderada para hipertrofia
      case TrainingObjective.endurance:
        return 0.15; // Tasa más agresiva para resistencia
      case TrainingObjective.power:
        return 0.05; // Tasa conservadora para potencia
    }
  }
}
