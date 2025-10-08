import '../../models/progression_config.dart';
import '../../models/progression_state.dart';
import '../../models/progression_calculation_result.dart';
import '../../../../features/exercise/models/exercise.dart';
import '../base_progression_strategy.dart';
import '../progression_strategy.dart';

/// Estrategia de Progresión Lineal
///
/// Esta estrategia implementa una progresión lineal clásica donde el peso se incrementa
/// de manera constante y predecible en intervalos regulares.
///
/// **Fundamentos teóricos:**
/// - Basada en el principio de sobrecarga progresiva
/// - Incremento constante de peso cada X sesiones/semanas
/// - Ideal para principiantes y fases de adaptación inicial
/// - Permite adaptación neuromuscular gradual
///
/// **Algoritmo:**
/// 1. Calcula la posición actual en el ciclo (sesión/semana)
/// 2. Verifica si es período de deload (reducción de carga)
/// 3. Si es momento de incrementar (según incrementFrequency):
///    - Aumenta el peso por el valor de incremento configurado
///    - Mantiene repeticiones y series constantes
/// 4. Durante deload:
///    - Reduce peso manteniendo incremento sobre peso base
///    - Reduce series al 70% del valor actual
///
/// **Parámetros clave:**
/// - incrementValue: Cantidad de peso a incrementar
/// - incrementFrequency: Cada cuántas sesiones/semanas incrementar
/// - cycleLength: Duración total del ciclo
/// - deloadWeek: Semana de deload (0 = sin deload)
/// - deloadPercentage: Porcentaje de reducción durante deload
///
/// **Ventajas:**
/// - Simple y predecible
/// - Fácil de seguir y monitorear
/// - Efectiva para ganancias iniciales de fuerza
///
/// **Limitaciones:**
/// - Puede volverse insostenible a largo plazo
/// - No considera fatiga acumulada
/// - Puede llevar a estancamiento
class LinearProgressionStrategy extends BaseProgressionStrategy
    implements ProgressionStrategy {
  @override
  ProgressionCalculationResult calculate({
    required ProgressionConfig config,
    required ProgressionState state,
    required double currentWeight,
    required int currentReps,
    required int currentSets,
    ExerciseType? exerciseType,
  }) {
    final currentInCycle = getCurrentInCycle(config, state);
    final isDeload = isDeloadPeriod(config, currentInCycle);

    // Si es deload, aplicar deload directamente sobre el peso actual
    if (isDeload) {
      return _applyDeload(
        config,
        state,
        currentWeight,
        currentReps,
        currentSets,
        currentInCycle,
      );
    }

    // 1. Aplicar lógica específica de progresión lineal
    if (currentInCycle % config.incrementFrequency == 0) {
      // Obtener incremento apropiado según parámetros personalizados y tipo de ejercicio
      final incrementValue = getIncrementValue(
        config,
        exerciseType: exerciseType,
      );

      return ProgressionCalculationResult(
        newWeight: currentWeight + incrementValue,
        newReps: currentReps,
        newSets: currentSets,
        incrementApplied: true,
        reason:
            'Linear progression: weight +${incrementValue}kg (week $currentInCycle of ${config.cycleLength})',
      );
    } else {
      return ProgressionCalculationResult(
        newWeight: currentWeight,
        newReps: currentReps,
        newSets: currentSets,
        incrementApplied: false,
        reason:
            'Linear progression: no increment (week $currentInCycle of ${config.cycleLength})',
      );
    }
  }

  /// Aplica deload específico para progresión lineal
  ProgressionCalculationResult _applyDeload(
    ProgressionConfig config,
    ProgressionState state,
    double currentWeight,
    int currentReps,
    int currentSets,
    int currentInCycle,
  ) {
    // Deload: reduce peso manteniendo el incremento sobre base, reduce series
    final double increaseOverBase = (currentWeight - state.baseWeight).clamp(
      0,
      double.infinity,
    );
    final double deloadWeight =
        state.baseWeight + (increaseOverBase * config.deloadPercentage);

    return ProgressionCalculationResult(
      newWeight: deloadWeight,
      newReps: currentReps,
      newSets: (currentSets * 0.7).round(),
      incrementApplied: true,
      reason:
          'Linear progression: deload ${config.unit.name} (week $currentInCycle of ${config.cycleLength})',
    );
  }
}
