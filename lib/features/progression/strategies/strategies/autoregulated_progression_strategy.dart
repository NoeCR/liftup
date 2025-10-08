import '../../models/progression_config.dart';
import '../../models/progression_state.dart';
import '../../models/progression_calculation_result.dart';
import '../../../../common/enums/progression_type_enum.dart';
import '../../../../features/exercise/models/exercise.dart';
import '../progression_strategy.dart';

/// Estrategia de Progresión Autoregulada
///
/// Esta estrategia implementa una progresión basada en RPE (Rate of Perceived Exertion)
/// donde los ajustes se realizan según la percepción de esfuerzo del atleta,
/// simulando un sistema de autoregulación.
///
/// **Fundamentos teóricos:**
/// - Basada en el concepto de autoregulación del entrenamiento
/// - Utiliza RPE (Rate of Perceived Exertion) para ajustar la carga
/// - Permite adaptación individualizada según la condición del atleta
/// - Considera fatiga acumulada y estado de recuperación
/// - Optimiza el entrenamiento según la respuesta individual
///
/// **Algoritmo:**
/// 1. Calcula la posición actual en el ciclo
/// 2. Verifica si es período de deload
/// 3. Obtiene parámetros de autoregulación:
///    - targetRPE: RPE objetivo (default: 8.0)
///    - rpeThreshold: Umbral de variación (default: 0.5)
///    - targetReps: Repeticiones objetivo
///    - minReps/maxReps: Rangos de repeticiones
/// 4. Estima RPE basado en repeticiones realizadas:
///    - Si reps >= targetReps: RPE = targetRPE - ((reps - targetReps) * 0.5)
///    - Si reps < targetReps: RPE = targetRPE + ((targetReps - reps) * 0.8)
/// 5. Ajusta según RPE estimado:
///    - RPE bajo: Incrementa peso
///    - RPE alto: Reduce peso y ajusta reps
///    - RPE óptimo: Incrementa reps si es posible
/// 6. Durante deload:
///    - Reduce peso manteniendo incremento sobre base
///    - Reduce series al 70%
///
/// **Parámetros clave:**
/// - targetRPE: RPE objetivo (1-10)
/// - rpeThreshold: Umbral de variación para ajustes
/// - targetReps: Repeticiones objetivo
/// - minReps/maxReps: Rangos de repeticiones
/// - incrementValue: Cantidad de peso a ajustar
///
/// **Ventajas:**
/// - Adaptación individualizada
/// - Considera fatiga y recuperación
/// - Flexible y responsiva
/// - Efectiva para atletas experimentados
/// - Reduce riesgo de sobreentrenamiento
///
/// **Limitaciones:**
/// - Requiere experiencia en RPE
/// - Más compleja de implementar
/// - Dependiente de la autoevaluación del atleta
/// - Puede ser inconsistente entre sesiones
class AutoregulatedProgressionStrategy implements ProgressionStrategy {
  @override
  ProgressionCalculationResult calculate({
    required ProgressionConfig config,
    required ProgressionState state,
    required double currentWeight,
    required int currentReps,
    required int currentSets,
    ExerciseType? exerciseType,
  }) {
    final currentInCycle =
        config.unit == ProgressionUnit.session
            ? ((state.currentSession - 1) % config.cycleLength) + 1
            : ((state.currentWeek - 1) % config.cycleLength) + 1;

    final isDeloadPeriod = config.deloadWeek > 0 && currentInCycle == config.deloadWeek;

    if (isDeloadPeriod) {
      // Deload: reduce peso manteniendo el incremento sobre base, reduce series
      final double increaseOverBase = (currentWeight - state.baseWeight).clamp(0, double.infinity);
      final double deloadWeight = state.baseWeight + (increaseOverBase * config.deloadPercentage);
      return ProgressionCalculationResult(
        newWeight: deloadWeight,
        newReps: currentReps,
        newSets: (currentSets * 0.7).round(),
        incrementApplied: true,
        reason: 'Autoregulated progression: deload ${config.unit.name} (week $currentInCycle of ${config.cycleLength})',
      );
    }

    // Obtener parámetros de autoregulación
    final targetRPE = _getTargetRPE(config);
    final rpeThreshold = _getRPEThreshold(config);
    final targetReps = _getTargetReps(config);
    final maxReps = _getMaxReps(config);
    final minReps = _getMinReps(config);
    final incrementValue = _getIncrementValue(config);

    final lastSessionData = state.sessionHistory['session_${state.currentSession}'];
    final performedReps = (lastSessionData?['reps'] as num?)?.toInt() ?? currentReps;

    double estimatedRPE;
    if (performedReps >= targetReps) {
      estimatedRPE = targetRPE - ((performedReps - targetReps) * 0.5);
    } else {
      estimatedRPE = targetRPE + ((targetReps - performedReps) * 0.8);
    }
    estimatedRPE = estimatedRPE.clamp(1.0, 10.0);

    if (estimatedRPE < targetRPE - rpeThreshold) {
      return ProgressionCalculationResult(
        newWeight: currentWeight + incrementValue,
        newReps: currentReps,
        newSets: currentSets,
        incrementApplied: true,
        reason:
            'Autoregulated progression: RPE low (${estimatedRPE.toStringAsFixed(1)}), increasing weight +${incrementValue}kg',
      );
    } else if (estimatedRPE > targetRPE + rpeThreshold) {
      final adjustedReps = currentReps < minReps ? minReps : currentReps;
      return ProgressionCalculationResult(
        newWeight: (currentWeight - incrementValue * 0.5).clamp(0, currentWeight),
        newReps: adjustedReps,
        newSets: currentSets,
        incrementApplied: true,
        reason:
            adjustedReps > currentReps
                ? 'Autoregulated progression: RPE high (${estimatedRPE.toStringAsFixed(1)}), reduce weight and set reps to min'
                : 'Autoregulated progression: RPE high (${estimatedRPE.toStringAsFixed(1)}), reduce weight',
      );
    } else {
      final baseReps = currentReps < minReps ? minReps : currentReps;
      final newReps = baseReps < maxReps ? baseReps + 1 : baseReps;
      return ProgressionCalculationResult(
        newWeight: currentWeight,
        newReps: newReps,
        newSets: currentSets,
        incrementApplied: newReps > currentReps,
        reason:
            newReps > currentReps
                ? 'Autoregulated progression: RPE optimal (${estimatedRPE.toStringAsFixed(1)}), increasing reps'
                : 'Autoregulated progression: RPE optimal (${estimatedRPE.toStringAsFixed(1)}), max reps reached',
      );
    }
  }

  /// Obtiene el RPE objetivo desde parámetros personalizados
  double _getTargetRPE(ProgressionConfig config) {
    final customParams = config.customParameters;

    // Buscar en per_exercise primero
    final perExercise = customParams['per_exercise'] as Map<String, dynamic>?;
    if (perExercise != null) {
      final exerciseParams = perExercise.values.first as Map<String, dynamic>?;
      if (exerciseParams != null) {
        final rpe = exerciseParams['target_rpe'];
        if (rpe != null) return (rpe as num).toDouble();
      }
    }

    // Fallback a global
    return (customParams['target_rpe'] as num?)?.toDouble() ?? 8.0;
  }

  /// Obtiene el umbral de RPE desde parámetros personalizados
  double _getRPEThreshold(ProgressionConfig config) {
    final customParams = config.customParameters;
    return (customParams['rpe_threshold'] as num?)?.toDouble() ?? 0.5;
  }

  /// Obtiene las repeticiones objetivo desde parámetros personalizados
  int _getTargetReps(ProgressionConfig config) {
    final customParams = config.customParameters;
    return (customParams['target_reps'] as num?)?.toInt() ?? 10;
  }

  /// Obtiene el máximo de repeticiones desde parámetros personalizados
  int _getMaxReps(ProgressionConfig config) {
    final customParams = config.customParameters;

    // Buscar en per_exercise primero
    final perExercise = customParams['per_exercise'] as Map<String, dynamic>?;
    if (perExercise != null) {
      final exerciseParams = perExercise.values.first as Map<String, dynamic>?;
      if (exerciseParams != null) {
        final maxReps =
            exerciseParams['max_reps'] ?? exerciseParams['multi_reps_max'] ?? exerciseParams['iso_reps_max'];
        if (maxReps != null) return maxReps as int;
      }
    }

    // Fallback a global
    return customParams['max_reps'] ?? customParams['multi_reps_max'] ?? customParams['iso_reps_max'] ?? 12; // default
  }

  /// Obtiene el mínimo de repeticiones desde parámetros personalizados
  int _getMinReps(ProgressionConfig config) {
    final customParams = config.customParameters;

    // Buscar en per_exercise primero
    final perExercise = customParams['per_exercise'] as Map<String, dynamic>?;
    if (perExercise != null) {
      final exerciseParams = perExercise.values.first as Map<String, dynamic>?;
      if (exerciseParams != null) {
        final minReps =
            exerciseParams['min_reps'] ?? exerciseParams['multi_reps_min'] ?? exerciseParams['iso_reps_min'];
        if (minReps != null) return minReps as int;
      }
    }

    // Fallback a global
    return customParams['min_reps'] ?? customParams['multi_reps_min'] ?? customParams['iso_reps_min'] ?? 5; // default
  }

  /// Obtiene el valor de incremento desde parámetros personalizados
  double _getIncrementValue(ProgressionConfig config) {
    final customParams = config.customParameters;

    // Buscar en per_exercise primero
    final perExercise = customParams['per_exercise'] as Map<String, dynamic>?;
    if (perExercise != null) {
      final exerciseParams = perExercise.values.first as Map<String, dynamic>?;
      if (exerciseParams != null) {
        final increment =
            exerciseParams['increment_value'] ??
            exerciseParams['multi_increment_min'] ??
            exerciseParams['iso_increment_min'];
        if (increment != null) return (increment as num).toDouble();
      }
    }

    // Fallback a global
    return customParams['increment_value'] ??
        customParams['multi_increment_min'] ??
        customParams['iso_increment_min'] ??
        config.incrementValue; // fallback al valor base
  }
}
