import '../../../../features/exercise/models/exercise.dart';
import '../../models/progression_calculation_result.dart';
import '../../models/progression_config.dart';
import '../../models/progression_state.dart';
import '../base_progression_strategy.dart';
import '../progression_strategy.dart';

/// Estrategia de Progresión Doble
///
/// Esta estrategia implementa una progresión de doble variable donde primero se incrementan
/// las repeticiones hasta alcanzar un máximo, y luego se incrementa el peso reseteando las reps.
///
/// **Fundamentos teóricos:**
/// - Basada en el concepto de "double progression" de la literatura de entrenamiento
/// - Permite adaptación tanto en volumen (reps) como en intensidad (peso)
/// - Ideal para ejercicios de fuerza-hipertrofia
/// - Facilita la adaptación técnica antes de incrementar peso
///
/// **Algoritmo:**
/// 1. Calcula la posición actual en el ciclo
/// 2. Verifica si es período de deload
/// 3. Si currentReps < maxReps:
///    - Incrementa repeticiones en 1
///    - Mantiene peso y series constantes
/// 4. Si currentReps >= maxReps:
///    - Incrementa peso por el valor configurado
///    - Resetea repeticiones al valor mínimo
///    - Mantiene series constantes
/// 5. Durante deload:
///    - Reduce peso manteniendo incremento sobre base
///    - Reduce series al 70%
///
/// **Parámetros clave:**
/// - minReps: Repeticiones mínimas (valor de reset)
/// - maxReps: Repeticiones máximas antes de incrementar peso
/// - incrementValue: Cantidad de peso a incrementar
/// - deloadWeek: Semana de deload
/// - deloadPercentage: Porcentaje de reducción durante deload
///
/// **Ventajas:**
/// - Progresión más gradual y sostenible
/// - Mejora técnica antes de incrementar peso
/// - Reduce riesgo de lesiones
/// - Efectiva para hipertrofia
///
/// **Limitaciones:**
/// - Progresión más lenta en peso absoluto
/// - Requiere rangos de repeticiones apropiados
/// - Puede ser menos efectiva para fuerza máxima
class DoubleProgressionStrategy extends BaseProgressionStrategy implements ProgressionStrategy {
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
        reason: 'Double progression: blocked for exercise ${state.exerciseId} in routine $routineId',
      );
    }

    final currentInCycle = getCurrentInCycle(config, state);
    final isDeload = isDeloadPeriod(config, currentInCycle);

    if (isDeload) {
      // Deload: reduce peso manteniendo el incremento sobre base, reduce series
      final double increaseOverBase = (currentWeight - state.baseWeight).clamp(0, double.infinity);
      final double deloadWeight = state.baseWeight + (increaseOverBase * config.deloadPercentage);
      final deloadSets = (currentSets * 0.7).round();
      return ProgressionCalculationResult(
        newWeight: deloadWeight,
        newReps: currentReps,
        newSets: deloadSets,
        incrementApplied: true,
        isDeload: true,
        shouldResetCycle: false, // Double progression no reinicia ciclo - es progresión secuencial
        reason: 'Double progression: deload ${config.unit.name} (week $currentInCycle of ${config.cycleLength})',
      );
    }

    // Leer parámetros de progresión con fallbacks apropiados
    final maxReps = getMaxReps(config, exerciseType: exerciseType);
    final minReps = getMinReps(config, exerciseType: exerciseType);

    if (currentReps < maxReps) {
      return ProgressionCalculationResult(
        newWeight: currentWeight,
        newReps: currentReps < minReps ? minReps : currentReps + 1,
        newSets: state.baseSets, // Ensure sets recover to base after deload
        incrementApplied: true,
        reason: 'Double progression: increasing reps (week $currentInCycle of ${config.cycleLength})',
      );
    } else {
      // Incrementar peso y resetear reps al mínimo
      final incrementValue = getIncrementValue(config, exerciseType: exerciseType);
      return ProgressionCalculationResult(
        newWeight: currentWeight + incrementValue,
        newReps: minReps,
        newSets: state.baseSets, // Ensure sets recover to base after deload
        incrementApplied: true,
        reason:
            'Double progression: increasing weight +${incrementValue}kg and resetting reps to $minReps (week $currentInCycle of ${config.cycleLength})',
      );
    }
  }
}
