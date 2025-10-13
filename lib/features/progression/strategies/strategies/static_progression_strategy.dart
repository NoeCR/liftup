import '../../../../features/exercise/models/exercise.dart';
import '../../models/progression_calculation_result.dart';
import '../../models/progression_config.dart';
import '../../models/progression_state.dart';
import '../base_progression_strategy.dart';
import '../progression_strategy.dart';

/// Estrategia de Progresión Estática
///
/// Esta estrategia mantiene todos los valores constantes sin aplicar ningún cambio.
/// Es útil para fases de mantenimiento o cuando se desea estabilizar el rendimiento.
///
/// **Fundamentos teóricos:**
/// - Basada en el concepto de mantenimiento de adaptaciones
/// - Mantiene carga constante durante el bloque de entrenamiento
/// - Útil para fases de consolidación
/// - Permite adaptación completa a una carga específica
/// - Facilita la recuperación y estabilización
///
/// **Algoritmo:**
/// 1. No aplica ningún cambio a los valores actuales
/// 2. Mantiene peso, repeticiones y series constantes
/// 3. Retorna incrementApplied = false
///
/// **Parámetros clave:**
/// - No requiere parámetros específicos
/// - Mantiene todos los valores actuales
///
/// **Ventajas:**
/// - Permite consolidación de adaptaciones
/// - Útil para fases de mantenimiento
/// - Reduce fatiga acumulada
/// - Facilita la recuperación
/// - Estabiliza el rendimiento
///
/// **Limitaciones:**
/// - No genera nuevas adaptaciones
/// - Puede llevar a estancamiento a largo plazo
/// - No es efectiva para ganancias continuas
/// - Requiere cambio eventual de estrategia
class StaticProgressionStrategy extends BaseProgressionStrategy
    implements ProgressionStrategy {
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
    // La progresión estática no aplica deloads ni cambios
    return createProgressionResult(
      newWeight: currentWeight,
      newReps: currentReps,
      newSets: currentSets,
      incrementApplied: false,
      reason: 'Static progression: maintaining current values',
    );
  }

  @override
  bool shouldApplyProgressionValues(
    ProgressionState? progressionState,
    String routineId,
    bool isExerciseLocked,
  ) {
    return true; // Static progression siempre aplica valores (aunque no los cambie)
  }
}
