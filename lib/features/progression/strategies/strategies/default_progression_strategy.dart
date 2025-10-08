import '../../models/progression_config.dart';
import '../../models/progression_state.dart';
import '../../models/progression_calculation_result.dart';
import '../../../../features/exercise/models/exercise.dart';
import '../base_progression_strategy.dart';
import '../progression_strategy.dart';

/// Estrategia de Progresión por Defecto
///
/// Esta estrategia no aplica ningún cambio a los valores actuales.
/// Es la estrategia por defecto cuando no se ha configurado ninguna progresión
/// o cuando se desea entrenamiento libre sin progresión automática.
///
/// **Fundamentos teóricos:**
/// - Representa entrenamiento libre sin progresión automática
/// - Permite al usuario controlar manualmente todos los parámetros
/// - Útil para atletas experimentados que prefieren autoregulación
/// - Mantiene valores constantes sin modificaciones automáticas
/// - Facilita la experimentación y ajustes manuales
///
/// **Algoritmo:**
/// 1. No aplica ningún cambio a los valores actuales
/// 2. Mantiene peso, repeticiones y series constantes
/// 3. Retorna incrementApplied = false
/// 4. Proporciona razón explicativa del comportamiento
///
/// **Parámetros clave:**
/// - No requiere parámetros específicos
/// - Mantiene todos los valores actuales sin modificación
///
/// **Ventajas:**
/// - Control total del usuario
/// - Flexibilidad máxima
/// - Útil para entrenamiento libre
/// - Permite experimentación
/// - No interfiere con la programación manual
///
/// **Limitaciones:**
/// - No genera progresión automática
/// - Requiere conocimiento del usuario
/// - Puede llevar a estancamiento sin planificación
/// - No optimiza automáticamente las cargas
class DefaultProgressionStrategy extends BaseProgressionStrategy
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
    // La progresión por defecto no aplica deloads ni cambios
    return ProgressionCalculationResult(
      newWeight: currentWeight,
      newReps: currentReps,
      newSets: currentSets,
      incrementApplied: false,
      reason: 'Default progression: no changes applied',
    );
  }
}
