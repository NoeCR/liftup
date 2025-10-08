import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/routine.dart';
import '../services/auto_routine_selection_service.dart';
import 'routine_notifier.dart';
import 'selected_routine_provider.dart';
import '../../../common/enums/week_day_enum.dart';
import '../../../core/logging/logging.dart';

part 'auto_routine_selection_notifier.g.dart';

/// Notifier para manejar la selección automática de rutinas
@riverpod
class AutoRoutineSelectionNotifier extends _$AutoRoutineSelectionNotifier {
  @override
  AutoSelectionInfo build() {
    // Escuchar cambios en las rutinas
    ref.listen(routineNotifierProvider, (previous, next) {
      next.whenData((routines) {
        _updateAutoSelection(routines);
      });
    });

    // Obtener rutinas iniciales y actualizar selección automática
    final routines = ref.read(routineNotifierProvider).value ?? [];
    final info = _getAutoSelectionInfo(routines);

    // Auto-seleccionar solo si no hay selección actual
    final currentSelection = ref.read(selectedRoutineIdProvider);
    if (currentSelection == null && routines.isNotEmpty) {
      _performAutoSelection(routines, info);
    }

    return info;
  }

  /// Actualiza la selección automática cuando cambian las rutinas
  void _updateAutoSelection(List<Routine> routines) {
    final newInfo = _getAutoSelectionInfo(routines);
    state = newInfo;

    final currentSelection = ref.read(selectedRoutineIdProvider);

    LoggingService.instance.debug('Updating auto selection', {
      'current_selection': currentSelection,
      'has_selection': newInfo.hasSelection,
      'today': newInfo.currentDay.displayName,
      'available_routines_count': newInfo.availableRoutines.length,
      'total_routines': routines.length,
      'component': 'auto_routine_selection_notifier',
    });

    // Solo seleccionar automáticamente si no hay selección actual
    if (currentSelection == null && routines.isNotEmpty) {
      _performAutoSelection(routines, newInfo);
    } else {
      LoggingService.instance.debug('Already have selection, not changing', {
        'current_selection': currentSelection,
        'component': 'auto_routine_selection_notifier',
      });
    }
  }

  /// Obtiene la información de selección automática
  AutoSelectionInfo _getAutoSelectionInfo(List<Routine> routines) {
    final service = ref.read(autoRoutineSelectionServiceProvider);
    return service.getAutoSelectionInfo(routines);
  }

  /// Selecciona automáticamente una rutina
  void _selectAutoRoutine(Routine routine) {
    LoggingService.instance.info('Selecting auto routine', {
      'routine_name': routine.name,
      'routine_id': routine.id,
      'component': 'auto_routine_selection_notifier',
    });
    ref.read(selectedRoutineIdProvider.notifier).state = routine.id;
  }

  /// Fuerza la selección automática (ignora selección manual actual)
  void forceAutoSelection() {
    final routines = ref.read(routineNotifierProvider).value ?? [];
    final info = _getAutoSelectionInfo(routines);

    if (info.hasSelection) {
      _selectAutoRoutine(info.selectedRoutine!);
      state = info;
    }
  }

  /// Realiza la auto-selección de rutina
  void _performAutoSelection(List<Routine> routines, AutoSelectionInfo info) {
    if (info.hasSelection) {
      // Si hay rutina para hoy, seleccionarla
      LoggingService.instance.info('Auto-selecting routine for today', {
        'selected_routine_name': info.selectedRoutine!.name,
        'selected_routine_id': info.selectedRoutine!.id,
        'component': 'auto_routine_selection_notifier',
      });
      _selectAutoRoutine(info.selectedRoutine!);
    } else if (routines.isNotEmpty) {
      // Si no hay rutina para hoy, seleccionar la primera disponible
      LoggingService.instance
          .info('No routine for today, selecting first available', {
            'selected_routine_name': routines.first.name,
            'selected_routine_id': routines.first.id,
            'component': 'auto_routine_selection_notifier',
          });
      _selectAutoRoutine(routines.first);
    }
  }

  /// Actualiza la selección automática (útil cuando cambia el día)
  void refreshAutoSelection() {
    final routines = ref.read(routineNotifierProvider).value ?? [];
    final info = _getAutoSelectionInfo(routines);
    state = info;

    final currentSelection = ref.read(selectedRoutineIdProvider);

    // Solo seleccionar automáticamente si no hay selección actual
    if (currentSelection == null && routines.isNotEmpty) {
      _performAutoSelection(routines, info);
    }
  }

  /// Obtiene la rutina seleccionada automáticamente para hoy
  Routine? getAutoSelectedRoutine() {
    return state.selectedRoutine;
  }

  /// Verifica si la rutina actualmente seleccionada es la automática para hoy
  bool isCurrentSelectionAuto() {
    final currentSelection = ref.read(selectedRoutineIdProvider);
    final autoRoutine = state.selectedRoutine;

    return currentSelection != null &&
        autoRoutine != null &&
        currentSelection == autoRoutine.id;
  }
}
