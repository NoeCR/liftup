import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/home/notifiers/auto_routine_selection_notifier.dart';
import '../../features/home/notifiers/routine_notifier.dart';
import '../../features/home/notifiers/selected_routine_provider.dart';

/// Widget que inicializa la selección automática de rutinas al arrancar la aplicación
class AutoRoutineInitializer extends ConsumerStatefulWidget {
  final Widget child;

  const AutoRoutineInitializer({required this.child, super.key});

  @override
  ConsumerState<AutoRoutineInitializer> createState() =>
      _AutoRoutineInitializerState();
}

class _AutoRoutineInitializerState
    extends ConsumerState<AutoRoutineInitializer> {
  bool _hasInitialized = false;

  @override
  Widget build(BuildContext context) {
    // Escuchar cambios en las rutinas para inicializar la selección automática SOLO UNA VEZ
    if (!_hasInitialized) {
      ref.listen(routineNotifierProvider, (previous, next) {
        next.whenData((routines) {
          if (!_hasInitialized && routines.isNotEmpty) {
            _hasInitialized = true;
            // Solo inicializar la selección automática si no hay selección actual
            final currentSelection = ref.read(selectedRoutineIdProvider);
            if (currentSelection == null) {
              ref
                  .read(autoRoutineSelectionNotifierProvider.notifier)
                  .refreshAutoSelection();
            }
          }
        });
      });
    }

    return widget.child;
  }
}
