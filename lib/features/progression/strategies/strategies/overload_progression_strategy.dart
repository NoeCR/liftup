import '../../../../features/exercise/models/exercise.dart';
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
    bool isExerciseLocked = false,
  }) {
    // Verificar si la progresión está bloqueada (por rutina completa O por ejercicio específico)
    if (isProgressionBlocked(state, state.exerciseId, routineId, isExerciseLocked)) {
      return ProgressionCalculationResult(
        newWeight: currentWeight,
        newReps: currentReps,
        newSets: state.baseSets, // Always use baseSets to avoid deload persistence
        incrementApplied: false,
        isDeload: false,
        reason: 'Overload progression: blocked for exercise ${state.exerciseId} in routine $routineId',
      );
    }

    final currentInCycle = getCurrentInCycle(config, state);
    final isDeload = isDeloadPeriod(config, currentInCycle);

    // 1. Aplicar lógica específica de sobrecarga progresiva
    final overloadType = (config.customParameters['overload_type'] as String?) ?? 'volume';
    final overloadRate = (config.customParameters['overload_rate'] as num?)?.toDouble() ?? 0.1;

    ProgressionCalculationResult result;
    if (overloadType == 'volume') {
      result = ProgressionCalculationResult(
        newWeight: currentWeight,
        newReps: currentReps,
        newSets: state.baseSets, // Ensure sets recover to base after deload
        incrementApplied: true,
        reason: 'Overload progression: increasing volume',
      );
    } else {
      result = ProgressionCalculationResult(
        newWeight: currentWeight * (1 + overloadRate),
        newReps: currentReps,
        newSets: state.baseSets, // Ensure sets recover to base after deload
        incrementApplied: true,
        reason: 'Overload progression: increasing intensity',
      );
    }

    // 2. Aplicar deload si es necesario
    if (isDeload) {
      return _applyDeload(config, state, result, currentInCycle);
    }

    return result;
  }

  /// Aplica deload específico para sobrecarga progresiva
  ProgressionCalculationResult _applyDeload(
    ProgressionConfig config,
    ProgressionState state,
    ProgressionCalculationResult result,
    int currentInCycle,
  ) {
    final double increaseOverBase = (result.newWeight - state.baseWeight).clamp(0, double.infinity);
    final double deloadWeight = state.baseWeight + (increaseOverBase * config.deloadPercentage);

    return ProgressionCalculationResult(
      newWeight: deloadWeight,
      newReps: result.newReps,
      newSets: (state.baseSets * 0.7).round(), // Use baseSets for deload calculation
      incrementApplied: true,
      isDeload: true,
      reason: 'Overload progression: deload ${config.unit.name} (week $currentInCycle of ${config.cycleLength})',
    );
  }
}
