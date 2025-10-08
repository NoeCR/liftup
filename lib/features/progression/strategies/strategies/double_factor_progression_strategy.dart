import '../../models/progression_config.dart';
import '../../models/progression_state.dart';
import '../../models/progression_calculation_result.dart';
import '../../../../common/enums/progression_type_enum.dart';
import '../progression_strategy.dart';

/// Estrategia de Progresión Doble Factor
///
/// Esta estrategia implementa una progresión basada en el modelo de fitness-fatiga,
/// donde se considera el balance entre las ganancias de fitness y la acumulación de fatiga.
///
/// **Fundamentos teóricos:**
/// - Basada en el modelo de fitness-fatiga de Banister
/// - Considera dos factores: fitness (adaptación) y fatiga
/// - El rendimiento = fitness - fatiga
/// - Permite optimizar el timing de las cargas
/// - Considera la acumulación y disipación de fatiga
///
/// **Algoritmo:**
/// 1. Calcula la posición actual en el ciclo
/// 2. Verifica si es período de deload
/// 3. Obtiene parámetros del modelo:
///    - fitnessGain: Ganancia de fitness por sesión (default: 0.1)
///    - fatigueDecay: Disipación de fatiga (default: 0.05)
///    - currentFitness: Fitness actual del estado
///    - currentFatigue: Fatiga actual del estado
/// 4. Calcula nuevos valores:
///    - newFitness = currentFitness + fitnessGain
///    - newFatigue = (currentFatigue + fitnessGain * 0.8) * (1 - fatigueDecay)
/// 5. Calcula ratio fitness-fatiga:
///    - fitnessFatigueRatio = newFitness / (1 + newFatigue)
/// 6. Ajusta peso según el ratio:
///    - Si ratio > 1.0: Incrementa peso (multiplicador 1.05)
///    - Si ratio <= 1.0: Reduce peso (multiplicador 0.95)
/// 7. Durante deload:
///    - Reduce peso manteniendo incremento sobre base
///    - Reduce series al 70%
///
/// **Parámetros clave:**
/// - fitnessGain: Ganancia de fitness por sesión
/// - fatigueDecay: Disipación de fatiga
/// - deloadWeek: Semana de deload
/// - deloadPercentage: Porcentaje de reducción durante deload
///
/// **Ventajas:**
/// - Considera fatiga acumulada
/// - Optimiza el timing de las cargas
/// - Basada en evidencia científica
/// - Permite periodización avanzada
/// - Reduce riesgo de sobreentrenamiento
///
/// **Limitaciones:**
/// - Requiere seguimiento de fitness y fatiga
/// - Más compleja de implementar
/// - Necesita calibración de parámetros
/// - Requiere experiencia en periodización
class DoubleFactorProgressionStrategy implements ProgressionStrategy {
  @override
  ProgressionCalculationResult calculate({
    required ProgressionConfig config,
    required ProgressionState state,
    required double currentWeight,
    required int currentReps,
    required int currentSets,
  }) {
    final currentInCycle =
        config.unit == ProgressionUnit.session
            ? ((state.currentSession - 1) % config.cycleLength) + 1
            : ((state.currentWeek - 1) % config.cycleLength) + 1;

    final isDeloadPeriod =
        config.deloadWeek > 0 && currentInCycle == config.deloadWeek;

    if (isDeloadPeriod) {
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
            'Double factor progression: deload ${config.unit.name} (week $currentInCycle of ${config.cycleLength})',
      );
    }

    final fitnessGain =
        (config.customParameters['fitness_gain'] as num?)?.toDouble() ?? 0.1;
    final fatigueDecay =
        (config.customParameters['fatigue_decay'] as num?)?.toDouble() ?? 0.05;
    final currentFitness =
        (state.customData['fitness'] as num?)?.toDouble() ?? 1.0;
    final currentFatigue =
        (state.customData['fatigue'] as num?)?.toDouble() ?? 0.0;

    final newFitness = currentFitness + fitnessGain;
    final newFatigue =
        (currentFatigue + fitnessGain * 0.8) * (1 - fatigueDecay);
    final fitnessFatigueRatio = newFitness / (1 + newFatigue);
    final weightMultiplier = fitnessFatigueRatio > 1.0 ? 1.05 : 0.95;

    return ProgressionCalculationResult(
      newWeight: currentWeight * weightMultiplier,
      newReps: currentReps,
      newSets: currentSets,
      incrementApplied: true,
      reason:
          'Double factor progression: ratio=${fitnessFatigueRatio.toStringAsFixed(2)}',
    );
  }
}
