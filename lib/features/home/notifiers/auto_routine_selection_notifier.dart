import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/routine.dart';
import '../services/auto_routine_selection_service.dart';
import 'routine_notifier.dart';
import 'selected_routine_provider.dart';

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

    // Obtener rutinas iniciales
    final routines = ref.read(routineNotifierProvider).value ?? [];
    return _getAutoSelectionInfo(routines);
  }

  /// Actualiza la selección automática cuando cambian las rutinas
  void _updateAutoSelection(List<Routine> routines) {
    final newInfo = _getAutoSelectionInfo(routines);
    state = newInfo;
    
    final currentSelection = ref.read(selectedRoutineIdProvider);
    
    // Solo seleccionar automáticamente si no hay selección actual
    if (currentSelection == null) {
      if (newInfo.hasSelection) {
        // Si hay rutina para hoy, seleccionarla
        _selectAutoRoutine(newInfo.selectedRoutine!);
      } else if (routines.isNotEmpty) {
        // Si no hay rutina para hoy, seleccionar la primera disponible
        _selectAutoRoutine(routines.first);
      }
    }
  }

  /// Obtiene la información de selección automática
  AutoSelectionInfo _getAutoSelectionInfo(List<Routine> routines) {
    final service = ref.read(autoRoutineSelectionServiceProvider);
    return service.getAutoSelectionInfo(routines);
  }

  /// Selecciona automáticamente una rutina
  void _selectAutoRoutine(Routine routine) {
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

  /// Actualiza la selección automática (útil cuando cambia el día)
  void refreshAutoSelection() {
    final routines = ref.read(routineNotifierProvider).value ?? [];
    final info = _getAutoSelectionInfo(routines);
    state = info;
    
    final currentSelection = ref.read(selectedRoutineIdProvider);
    
    // Solo seleccionar automáticamente si no hay selección actual
    if (currentSelection == null) {
      if (info.hasSelection) {
        // Si hay rutina para hoy, seleccionarla
        _selectAutoRoutine(info.selectedRoutine!);
      } else if (routines.isNotEmpty) {
        // Si no hay rutina para hoy, seleccionar la primera disponible
        _selectAutoRoutine(routines.first);
      }
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
