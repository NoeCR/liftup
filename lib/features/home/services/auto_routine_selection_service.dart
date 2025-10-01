import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/routine.dart';
import '../../../common/enums/week_day_enum.dart';
import '../notifiers/routine_notifier.dart';

/// Servicio para selección automática de rutinas basada en el día de la semana
class AutoRoutineSelectionService {
  static AutoRoutineSelectionService? _instance;
  static AutoRoutineSelectionService get instance =>
      _instance ??= AutoRoutineSelectionService._();

  AutoRoutineSelectionService._();

  /// Obtiene el día de la semana actual
  WeekDay getCurrentWeekDay() {
    final now = DateTime.now();
    // DateTime.weekday devuelve 1-7 (lunes-domingo)
    return WeekDayExtension.fromInt(now.weekday);
  }

  /// Encuentra rutinas que coincidan con el día de la semana actual
  List<Routine> findRoutinesForToday(List<Routine> routines) {
    final today = getCurrentWeekDay();
    final todayRoutines = routines.where((routine) => routine.days.contains(today)).toList();
    
    print('AutoSelectionService: Today is ${today.displayName}');
    print('AutoSelectionService: Total routines: ${routines.length}');
    print('AutoSelectionService: Routines for today: ${todayRoutines.length}');
    for (final routine in todayRoutines) {
      print('AutoSelectionService: - ${routine.name} (days: ${routine.days.map((d) => d.displayName).join(', ')})');
    }
    
    return todayRoutines;
  }

  /// Selecciona automáticamente la rutina para el día actual
  /// Prioriza rutinas con menor orden, luego por fecha de creación
  Routine? selectRoutineForToday(List<Routine> routines) {
    final todayRoutines = findRoutinesForToday(routines);

    if (todayRoutines.isEmpty) {
      return null;
    }

    // Ordenar por orden (ascendente), luego por fecha de creación (ascendente)
    todayRoutines.sort((a, b) {
      // Primero por orden
      final orderA = a.order ?? 999;
      final orderB = b.order ?? 999;
      if (orderA != orderB) {
        return orderA.compareTo(orderB);
      }
      // Luego por fecha de creación
      return a.createdAt.compareTo(b.createdAt);
    });

    return todayRoutines.first;
  }

  /// Obtiene información sobre la selección automática
  AutoSelectionInfo getAutoSelectionInfo(List<Routine> routines) {
    final today = getCurrentWeekDay();
    final todayRoutines = findRoutinesForToday(routines);
    final selectedRoutine = selectRoutineForToday(routines);

    return AutoSelectionInfo(
      currentDay: today,
      availableRoutines: todayRoutines,
      selectedRoutine: selectedRoutine,
      hasSelection: selectedRoutine != null,
    );
  }
}

/// Información sobre la selección automática
class AutoSelectionInfo {
  final WeekDay currentDay;
  final List<Routine> availableRoutines;
  final Routine? selectedRoutine;
  final bool hasSelection;

  const AutoSelectionInfo({
    required this.currentDay,
    required this.availableRoutines,
    this.selectedRoutine,
    required this.hasSelection,
  });

  /// Mensaje descriptivo sobre la selección
  String get description {
    if (!hasSelection) {
      return 'No hay rutinas configuradas para ${currentDay.displayName}';
    }

    if (availableRoutines.length == 1) {
      return 'Rutina automática para ${currentDay.displayName}: ${selectedRoutine!.name}';
    }

    return 'Rutina seleccionada para ${currentDay.displayName}: ${selectedRoutine!.name} (${availableRoutines.length} disponibles)';
  }
}

/// Provider para el servicio de selección automática
final autoRoutineSelectionServiceProvider =
    Provider<AutoRoutineSelectionService>((ref) {
      return AutoRoutineSelectionService.instance;
    });

/// Provider para obtener información de selección automática
final autoSelectionInfoProvider = Provider<AutoSelectionInfo>((ref) {
  final routines = ref.watch(routineNotifierProvider).value ?? [];
  final service = ref.watch(autoRoutineSelectionServiceProvider);
  return service.getAutoSelectionInfo(routines);
});

/// Provider para la rutina seleccionada automáticamente
final autoSelectedRoutineProvider = Provider<Routine?>((ref) {
  final info = ref.watch(autoSelectionInfoProvider);
  return info.selectedRoutine;
});
