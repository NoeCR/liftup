import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/routine.dart';
import '../../../common/enums/week_day_enum.dart';
import '../notifiers/routine_notifier.dart';
import '../../../core/logging/logging.dart';

/// Service for automatic routine selection based on the weekday
class AutoRoutineSelectionService {
  static AutoRoutineSelectionService? _instance;
  static AutoRoutineSelectionService get instance => _instance ??= AutoRoutineSelectionService._();

  AutoRoutineSelectionService._();

  /// Returns the current weekday
  WeekDay getCurrentWeekDay() {
    final now = DateTime.now();
    // DateTime.weekday devuelve 1-7 (lunes-domingo)
    return WeekDayExtension.fromInt(now.weekday);
  }

  /// Finds routines that match the current weekday
  List<Routine> findRoutinesForToday(List<Routine> routines) {
    final today = getCurrentWeekDay();
    final todayRoutines = routines.where((routine) => routine.days.contains(today)).toList();

    LoggingService.instance.debug('Finding routines for today', {
      'today': today.displayName,
      'total_routines': routines.length,
      'today_routines_count': todayRoutines.length,
      'component': 'auto_routine_selection',
    });

    for (final routine in todayRoutines) {
      LoggingService.instance.debug('Available routine for today', {
        'routine_name': routine.name,
        'routine_id': routine.id,
        'routine_days': routine.days.map((d) => d.displayName).join(', '),
        'routine_order': routine.order,
        'component': 'auto_routine_selection',
      });
    }

    return todayRoutines;
  }

  /// Automatically selects routine for today.
  /// Prioritizes routines with lower order, then by creation date.
  Routine? selectRoutineForToday(List<Routine> routines) {
    return PerformanceMonitor.instance.monitorSync('select_routine_for_today', () {
      final todayRoutines = findRoutinesForToday(routines);

      if (todayRoutines.isEmpty) {
        LoggingService.instance.info('No routines available for today', {'component': 'auto_routine_selection'});
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

      final selectedRoutine = todayRoutines.first;
      LoggingService.instance.info('Routine selected for today', {
        'selected_routine_name': selectedRoutine.name,
        'selected_routine_id': selectedRoutine.id,
        'selected_routine_order': selectedRoutine.order,
        'total_available': todayRoutines.length,
        'component': 'auto_routine_selection',
      });

      return selectedRoutine;
    }, context: {'total_routines': routines.length, 'component': 'auto_routine_selection'});
  }

  /// Returns info about the automatic selection
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

/// Information about automatic selection
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

  /// Descriptive message about the selection
  String get description {
    if (!hasSelection) {
      return 'No routines configured for ${currentDay.displayName}';
    }

    if (availableRoutines.length == 1) {
      return 'Auto routine for ${currentDay.displayName}: ${selectedRoutine!.name}';
    }

    return 'Selected routine for ${currentDay.displayName}: ${selectedRoutine!.name} (${availableRoutines.length} available)';
  }
}

/// Provider for the automatic selection service
final autoRoutineSelectionServiceProvider = Provider<AutoRoutineSelectionService>((ref) {
  return AutoRoutineSelectionService.instance;
});

/// Provider to obtain automatic selection info
final autoSelectionInfoProvider = Provider<AutoSelectionInfo>((ref) {
  final routines = ref.watch(routineNotifierProvider).value ?? [];
  final service = ref.watch(autoRoutineSelectionServiceProvider);
  return service.getAutoSelectionInfo(routines);
});

/// Provider for the automatically selected routine
final autoSelectedRoutineProvider = Provider<Routine?>((ref) {
  final info = ref.watch(autoSelectionInfoProvider);
  return info.selectedRoutine;
});
