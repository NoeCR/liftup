import '../../../../features/exercise/models/exercise.dart';
import '../../models/progression_calculation_result.dart';
import '../../models/progression_config.dart';
import '../../models/progression_state.dart';
import '../base_progression_strategy.dart';
import '../progression_strategy.dart';

/// Estrategia de Sobrecarga Progresiva con Fases Automáticas
///
/// Esta estrategia implementa una sobrecarga progresiva que puede enfocarse en
/// volumen (series) o intensidad (peso) según la configuración, con soporte
/// para transiciones automáticas entre fases de periodización.
///
/// **Fundamentos teóricos:**
/// - Basada en el principio de sobrecarga progresiva
/// - Implementa periodización automática con fases
/// - Permite incrementar volumen o intensidad progresivamente
/// - Ideal para fases de acumulación, intensificación y peaking
/// - Facilita la adaptación a cargas crecientes
/// - Optimiza las ganancias de fuerza e hipertrofia
///
/// **Algoritmo:**
/// 1. Calcula la posición actual en el ciclo
/// 2. Determina la fase actual (acumulación, intensificación, peaking)
/// 3. Verifica si es período de deload
/// 4. Obtiene parámetros de sobrecarga según la fase:
///    - Fase de Acumulación: Enfoque en volumen
///    - Fase de Intensificación: Enfoque en intensidad
///    - Fase de Peaking: Máxima intensidad con volumen reducido
/// 5. Aplica sobrecarga según la fase y tipo:
///    - Si overloadType == 'volume':
///      * Mantiene peso y repeticiones constantes
///      * Incrementa series por el overloadRate
///    - Si overloadType == 'intensity':
///      * Incrementa peso por el overloadRate
///      * Mantiene repeticiones y series constantes
///    - Si overloadType == 'phases':
///      * Cambia automáticamente entre volumen e intensidad
/// 6. Durante deload:
///    - Reduce peso manteniendo incremento sobre base
///    - Reduce series al 70%
///
/// **Parámetros clave:**
/// - overloadType: Tipo de sobrecarga ('volume', 'intensity', 'phases')
/// - overloadRate: Tasa de incremento (0.1 = 10%)
/// - phase_duration_weeks: Duración de cada fase en semanas
/// - accumulation_rate: Tasa de incremento en fase de acumulación
/// - intensification_rate: Tasa de incremento en fase de intensificación
/// - peaking_rate: Tasa de incremento en fase de peaking
/// - deloadWeek: Semana de deload
/// - deloadPercentage: Porcentaje de reducción durante deload
///
/// **Fases automáticas:**
/// - **Acumulación**: Incrementa volumen progresivamente
/// - **Intensificación**: Incrementa intensidad progresivamente
/// - **Peaking**: Máxima intensidad con volumen reducido
/// - **Deload**: Recuperación activa
///
/// **Ventajas:**
/// - Periodización automática completa
/// - Flexible en el tipo de sobrecarga
/// - Progresión gradual y sostenible
/// - Efectiva para acumulación de volumen
/// - Permite adaptación a cargas crecientes
/// - Optimiza ganancias de fuerza e hipertrofia
/// - Ideal para preparación de competencia
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

    // 1. Determinar la fase actual y parámetros de sobrecarga
    final overloadType = (config.customParameters['overload_type'] as String?) ?? 'volume';
    final phaseInfo = _determineCurrentPhase(config, currentInCycle);

    // 2. Aplicar lógica específica de sobrecarga progresiva según la fase
    ProgressionCalculationResult result = _applyOverloadProgression(
      config,
      state,
      currentWeight,
      currentReps,
      currentSets,
      overloadType,
      phaseInfo,
    );

    // 3. Aplicar deload si es necesario
    if (isDeload) {
      return _applyDeload(config, state, result, currentInCycle);
    }

    return result;
  }

  /// Obtiene la información de la fase actual (método público para notificaciones)
  PhaseInfo getCurrentPhaseInfo(ProgressionConfig config, ProgressionState state) {
    final currentInCycle = getCurrentInCycle(config, state);
    return _determineCurrentPhase(config, currentInCycle);
  }

  /// Determina la fase actual basada en la posición en el ciclo
  PhaseInfo _determineCurrentPhase(ProgressionConfig config, int currentInCycle) {
    final phaseDurationWeeks = (config.customParameters['phase_duration_weeks'] as num?)?.toInt() ?? 4;
    final totalPhases = 3; // Acumulación, Intensificación, Peaking

    // Calcular la fase actual (0: Acumulación, 1: Intensificación, 2: Peaking)
    final currentPhase = ((currentInCycle - 1) / phaseDurationWeeks).floor().clamp(0, totalPhases - 1);
    final weekInPhase = ((currentInCycle - 1) % phaseDurationWeeks) + 1;

    return PhaseInfo(phase: currentPhase, weekInPhase: weekInPhase, phaseDuration: phaseDurationWeeks);
  }

  /// Aplica la progresión de sobrecarga según el tipo y la fase
  ProgressionCalculationResult _applyOverloadProgression(
    ProgressionConfig config,
    ProgressionState state,
    double currentWeight,
    int currentReps,
    int currentSets,
    String overloadType,
    PhaseInfo phaseInfo,
  ) {
    switch (overloadType) {
      case 'volume':
        return _applyVolumeOverload(config, state, currentWeight, currentReps, currentSets, phaseInfo);
      case 'intensity':
        return _applyIntensityOverload(config, state, currentWeight, currentReps, currentSets, phaseInfo);
      case 'phases':
        return _applyPhaseBasedOverload(config, state, currentWeight, currentReps, currentSets, phaseInfo);
      default:
        // Fallback a volumen si el tipo no es reconocido
        return _applyVolumeOverload(config, state, currentWeight, currentReps, currentSets, phaseInfo);
    }
  }

  /// Aplica sobrecarga de volumen
  ProgressionCalculationResult _applyVolumeOverload(
    ProgressionConfig config,
    ProgressionState state,
    double currentWeight,
    int currentReps,
    int currentSets,
    PhaseInfo phaseInfo,
  ) {
    final overloadRate = (config.customParameters['overload_rate'] as num?)?.toDouble() ?? 0.1;
    final newSets = (state.baseSets * (1 + overloadRate)).round();

    return ProgressionCalculationResult(
      newWeight: currentWeight,
      newReps: currentReps,
      newSets: newSets,
      incrementApplied: true,
      reason: 'Overload progression: increasing volume (${phaseInfo.phaseName}) - sets: ${state.baseSets} → $newSets',
    );
  }

  /// Aplica sobrecarga de intensidad
  ProgressionCalculationResult _applyIntensityOverload(
    ProgressionConfig config,
    ProgressionState state,
    double currentWeight,
    int currentReps,
    int currentSets,
    PhaseInfo phaseInfo,
  ) {
    final overloadRate = (config.customParameters['overload_rate'] as num?)?.toDouble() ?? 0.1;
    final newWeight = currentWeight * (1 + overloadRate);

    return ProgressionCalculationResult(
      newWeight: newWeight,
      newReps: currentReps,
      newSets: state.baseSets,
      incrementApplied: true,
      reason:
          'Overload progression: increasing intensity (${phaseInfo.phaseName}) - weight: ${currentWeight.toStringAsFixed(1)}kg → ${newWeight.toStringAsFixed(1)}kg',
    );
  }

  /// Aplica sobrecarga basada en fases automáticas
  ProgressionCalculationResult _applyPhaseBasedOverload(
    ProgressionConfig config,
    ProgressionState state,
    double currentWeight,
    int currentReps,
    int currentSets,
    PhaseInfo phaseInfo,
  ) {
    switch (phaseInfo.phase) {
      case 0: // Fase de Acumulación
        return _applyAccumulationPhase(config, state, currentWeight, currentReps, currentSets, phaseInfo);
      case 1: // Fase de Intensificación
        return _applyIntensificationPhase(config, state, currentWeight, currentReps, currentSets, phaseInfo);
      case 2: // Fase de Peaking
        return _applyPeakingPhase(config, state, currentWeight, currentReps, currentSets, phaseInfo);
      default:
        return _applyAccumulationPhase(config, state, currentWeight, currentReps, currentSets, phaseInfo);
    }
  }

  /// Aplica fase de acumulación (enfoque en volumen)
  ProgressionCalculationResult _applyAccumulationPhase(
    ProgressionConfig config,
    ProgressionState state,
    double currentWeight,
    int currentReps,
    int currentSets,
    PhaseInfo phaseInfo,
  ) {
    final accumulationRate = (config.customParameters['accumulation_rate'] as num?)?.toDouble() ?? 0.15;
    final newSets = (state.baseSets * (1 + accumulationRate)).round();

    return ProgressionCalculationResult(
      newWeight: currentWeight,
      newReps: currentReps,
      newSets: newSets,
      incrementApplied: true,
      reason:
          'Overload progression: accumulation phase (week ${phaseInfo.weekInPhase}/${phaseInfo.phaseDuration}) - volume focus - sets: ${state.baseSets} → $newSets',
    );
  }

  /// Aplica fase de intensificación (enfoque en intensidad)
  ProgressionCalculationResult _applyIntensificationPhase(
    ProgressionConfig config,
    ProgressionState state,
    double currentWeight,
    int currentReps,
    int currentSets,
    PhaseInfo phaseInfo,
  ) {
    final intensificationRate = (config.customParameters['intensification_rate'] as num?)?.toDouble() ?? 0.1;
    final newWeight = currentWeight * (1 + intensificationRate);

    return ProgressionCalculationResult(
      newWeight: newWeight,
      newReps: currentReps,
      newSets: state.baseSets,
      incrementApplied: true,
      reason:
          'Overload progression: intensification phase (week ${phaseInfo.weekInPhase}/${phaseInfo.phaseDuration}) - intensity focus - weight: ${currentWeight.toStringAsFixed(1)}kg → ${newWeight.toStringAsFixed(1)}kg',
    );
  }

  /// Aplica fase de peaking (máxima intensidad, volumen reducido)
  ProgressionCalculationResult _applyPeakingPhase(
    ProgressionConfig config,
    ProgressionState state,
    double currentWeight,
    int currentReps,
    int currentSets,
    PhaseInfo phaseInfo,
  ) {
    final peakingRate = (config.customParameters['peaking_rate'] as num?)?.toDouble() ?? 0.05;
    final newWeight = currentWeight * (1 + peakingRate);
    final newSets = (state.baseSets * 0.8).round(); // Reducir volumen en peaking

    return ProgressionCalculationResult(
      newWeight: newWeight,
      newReps: currentReps,
      newSets: newSets,
      incrementApplied: true,
      reason:
          'Overload progression: peaking phase (week ${phaseInfo.weekInPhase}/${phaseInfo.phaseDuration}) - max intensity, reduced volume - weight: ${currentWeight.toStringAsFixed(1)}kg → ${newWeight.toStringAsFixed(1)}kg, sets: ${state.baseSets} → $newSets',
    );
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
      shouldResetCycle: false, // Overload progression no reinicia ciclo - es sobrecarga progresiva
      reason: 'Overload progression: deload ${config.unit.name} (week $currentInCycle of ${config.cycleLength})',
    );
  }
}

/// Información sobre la fase actual
class PhaseInfo {
  final int phase; // 0: Acumulación, 1: Intensificación, 2: Peaking
  final int weekInPhase;
  final int phaseDuration;

  PhaseInfo({required this.phase, required this.weekInPhase, required this.phaseDuration});

  String get phaseName {
    switch (phase) {
      case 0:
        return 'Acumulación';
      case 1:
        return 'Intensificación';
      case 2:
        return 'Peaking';
      default:
        return 'Desconocida';
    }
  }
}
