import 'package:flutter/foundation.dart';
import 'package:liftly/features/progression/models/progression_config.dart';
import 'package:liftly/features/progression/models/progression_state.dart';
import 'package:liftly/features/progression/strategies/strategies/overload_progression_strategy.dart';

class PhaseChangeInfo {
  final String exerciseId;
  final String routineId;
  final String previousPhase;
  final String currentPhase;
  final int weekInPhase;
  final int totalWeeksInPhase;
  final String phaseDescription;
  final String progressionDetails;
  final DateTime changeDate;

  const PhaseChangeInfo({
    required this.exerciseId,
    required this.routineId,
    required this.previousPhase,
    required this.currentPhase,
    required this.weekInPhase,
    required this.totalWeeksInPhase,
    required this.phaseDescription,
    required this.progressionDetails,
    required this.changeDate,
  });

  @override
  String toString() {
    return 'PhaseChangeInfo(exerciseId: $exerciseId, routineId: $routineId, '
        'previousPhase: $previousPhase, currentPhase: $currentPhase, '
        'weekInPhase: $weekInPhase, totalWeeksInPhase: $totalWeeksInPhase)';
  }
}

class PhaseNotificationService extends ChangeNotifier {
  static final PhaseNotificationService _instance =
      PhaseNotificationService._internal();
  factory PhaseNotificationService() => _instance;
  PhaseNotificationService._internal();

  final List<PhaseChangeInfo> _phaseChanges = [];
  final Map<String, String> _lastKnownPhases =
      {}; // exerciseId+routineId -> phase
  bool _notificationsEnabled = true;

  List<PhaseChangeInfo> get phaseChanges => List.unmodifiable(_phaseChanges);
  bool get notificationsEnabled => _notificationsEnabled;

  void setNotificationsEnabled(bool enabled) {
    _notificationsEnabled = enabled;
    notifyListeners();
  }

  void clearPhaseChanges() {
    _phaseChanges.clear();
    notifyListeners();
  }

  void removePhaseChange(PhaseChangeInfo change) {
    _phaseChanges.remove(change);
    notifyListeners();
  }

  /// Detecta cambios de fase en una estrategia de progresión
  void detectPhaseChange({
    required ProgressionConfig config,
    required ProgressionState state,
    required String routineId,
  }) {
    if (!_notificationsEnabled) return;

    // Solo procesar estrategias que soportan fases automáticas
    if (config.type.name != 'overload' ||
        config.customParameters['overload_type'] != 'phases') {
      return;
    }

    final strategy = OverloadProgressionStrategy();
    final currentPhaseInfo = strategy.getCurrentPhaseInfo(config, state);

    final phaseKey = '${state.exerciseId}_$routineId';
    final lastKnownPhase = _lastKnownPhases[phaseKey];
    final currentPhaseName = currentPhaseInfo.phaseName;

    // Si es la primera vez o la fase cambió
    if (lastKnownPhase == null || lastKnownPhase != currentPhaseName) {
      final phaseChange = PhaseChangeInfo(
        exerciseId: state.exerciseId,
        routineId: routineId,
        previousPhase: lastKnownPhase ?? 'Inicio',
        currentPhase: currentPhaseName,
        weekInPhase: currentPhaseInfo.weekInPhase,
        totalWeeksInPhase: currentPhaseInfo.phaseDuration,
        phaseDescription: _getPhaseDescription(currentPhaseInfo.phase),
        progressionDetails: _getProgressionDetails(config, currentPhaseInfo),
        changeDate: DateTime.now(),
      );

      _phaseChanges.insert(
        0,
        phaseChange,
      ); // Insertar al inicio para mostrar los más recientes
      _lastKnownPhases[phaseKey] = currentPhaseName;

      // Limitar a 50 cambios recientes
      if (_phaseChanges.length > 50) {
        _phaseChanges.removeRange(50, _phaseChanges.length);
      }

      notifyListeners();
    }
  }

  /// Procesa múltiples estados de progresión para detectar cambios
  void processProgressionStates({
    required ProgressionConfig config,
    required List<ProgressionState> states,
    required String routineId,
  }) {
    for (final state in states) {
      detectPhaseChange(config: config, state: state, routineId: routineId);
    }
  }

  /// Obtiene los cambios de fase para un ejercicio específico
  List<PhaseChangeInfo> getPhaseChangesForExercise(
    String exerciseId,
    String routineId,
  ) {
    return _phaseChanges
        .where(
          (change) =>
              change.exerciseId == exerciseId && change.routineId == routineId,
        )
        .toList();
  }

  /// Obtiene los cambios de fase recientes (últimos 7 días)
  List<PhaseChangeInfo> getRecentPhaseChanges({int days = 7}) {
    final cutoffDate = DateTime.now().subtract(Duration(days: days));
    return _phaseChanges
        .where((change) => change.changeDate.isAfter(cutoffDate))
        .toList();
  }

  /// Obtiene estadísticas de cambios de fase
  Map<String, dynamic> getPhaseChangeStatistics() {
    if (_phaseChanges.isEmpty) {
      return {
        'totalChanges': 0,
        'changesByPhase': {},
        'changesByExercise': {},
        'averageChangesPerWeek': 0.0,
      };
    }

    final changesByPhase = <String, int>{};
    final changesByExercise = <String, int>{};

    for (final change in _phaseChanges) {
      changesByPhase[change.currentPhase] =
          (changesByPhase[change.currentPhase] ?? 0) + 1;
      changesByExercise[change.exerciseId] =
          (changesByExercise[change.exerciseId] ?? 0) + 1;
    }

    final firstChange = _phaseChanges.last.changeDate;
    final lastChange = _phaseChanges.first.changeDate;
    final weeksElapsed = lastChange.difference(firstChange).inDays / 7;
    final averageChangesPerWeek =
        weeksElapsed > 0 ? _phaseChanges.length / weeksElapsed : 0.0;

    return {
      'totalChanges': _phaseChanges.length,
      'changesByPhase': changesByPhase,
      'changesByExercise': changesByExercise,
      'averageChangesPerWeek': averageChangesPerWeek,
      'firstChange': firstChange,
      'lastChange': lastChange,
    };
  }

  String _getPhaseDescription(int phase) {
    switch (phase) {
      case 0:
        return 'Fase de acumulación: Enfoque en incrementar el volumen de entrenamiento para construir una base sólida.';
      case 1:
        return 'Fase de intensificación: Transición hacia cargas más pesadas mientras se mantiene el volumen.';
      case 2:
        return 'Fase de peaking: Máxima intensidad con volumen reducido para alcanzar el pico de rendimiento.';
      default:
        return 'Fase de transición: Preparación para el siguiente ciclo de entrenamiento.';
    }
  }

  String _getProgressionDetails(ProgressionConfig config, PhaseInfo phaseInfo) {
    final phaseDurationWeeks =
        (config.customParameters['phase_duration_weeks'] as num?)?.toInt() ?? 4;

    switch (phaseInfo.phase) {
      case 0: // Acumulación
        final accumulationRate =
            (config.customParameters['accumulation_rate'] as num?)
                ?.toDouble() ??
            0.15;
        return 'Incremento de volumen: +${(accumulationRate * 100).toInt()}% semanal por $phaseDurationWeeks semanas';
      case 1: // Intensificación
        final intensificationRate =
            (config.customParameters['intensification_rate'] as num?)
                ?.toDouble() ??
            0.1;
        return 'Incremento de intensidad: +${(intensificationRate * 100).toInt()}% semanal por $phaseDurationWeeks semanas';
      case 2: // Peaking
        final peakingRate =
            (config.customParameters['peaking_rate'] as num?)?.toDouble() ??
            0.05;
        return 'Incremento mínimo: +${(peakingRate * 100).toInt()}% semanal, volumen reducido por $phaseDurationWeeks semanas';
      default:
        return 'Transición hacia nuevo ciclo de entrenamiento';
    }
  }

  /// Resetea el estado del servicio (útil para testing o reinicio de aplicación)
  void reset() {
    _phaseChanges.clear();
    _lastKnownPhases.clear();
    _notificationsEnabled = true;
    notifyListeners();
  }
}
