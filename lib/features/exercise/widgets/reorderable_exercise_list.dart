import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/exercise.dart';
import '../notifiers/exercise_notifier.dart';
import 'animated_exercise_card.dart';

class ReorderableExerciseList extends ConsumerStatefulWidget {
  final List<Exercise> exercises;
  final Function(Exercise)? onExerciseTap;
  final Function(Exercise)? onFavoriteToggle;
  final Widget Function()? emptyBuilder;
  final Widget Function(String)? errorBuilder;

  const ReorderableExerciseList({
    super.key,
    required this.exercises,
    this.onExerciseTap,
    this.onFavoriteToggle,
    this.emptyBuilder,
    this.errorBuilder,
  });

  @override
  ConsumerState<ReorderableExerciseList> createState() => _ReorderableExerciseListState();
}

class _ReorderableExerciseListState extends ConsumerState<ReorderableExerciseList> with TickerProviderStateMixin {
  List<Exercise> _exercises = [];
  int? _draggedIndex;
  bool _isReordering = false;

  late AnimationController _reorderAnimationController;
  late Animation<double> _reorderAnimation;

  @override
  void initState() {
    super.initState();
    _exercises = List.from(widget.exercises);

    _reorderAnimationController = AnimationController(duration: const Duration(milliseconds: 300), vsync: this);

    _reorderAnimation = CurvedAnimation(parent: _reorderAnimationController, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _reorderAnimationController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(ReorderableExerciseList oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Actualizar la lista local cuando cambien los ejercicios
    if (widget.exercises != oldWidget.exercises) {
      _updateExercisesList();
    }
  }

  void _updateExercisesList() {
    setState(() {
      _exercises = List.from(widget.exercises);
    });
  }

  Future<void> _onReorder(int oldIndex, int newIndex) async {
    if (oldIndex == newIndex) return;

    setState(() {
      _isReordering = true;
    });

    // Calcular el nuevo índice considerando que se mueve hacia abajo
    final int adjustedNewIndex = newIndex > oldIndex ? newIndex - 1 : newIndex;

    // Mover el elemento en la lista local
    final Exercise movedExercise = _exercises.removeAt(oldIndex);
    _exercises.insert(adjustedNewIndex, movedExercise);

    // Animar la reordenación
    await _reorderAnimationController.forward();
    _reorderAnimationController.reset();

    // Actualizar en el backend
    await _updateExerciseOrder();

    setState(() {
      _isReordering = false;
    });
  }

  Future<void> _updateExerciseOrder() async {
    try {
      final exerciseNotifier = ref.read(exerciseNotifierProvider.notifier);
      await exerciseNotifier.reorderExercises(_exercises);
    } catch (e) {
      // Si hay error, revertir la lista local
      setState(() {
        _exercises = List.from(widget.exercises);
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al reordenar ejercicios: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _onFavoriteToggle(Exercise exercise) async {
    print('🎯 ReorderableExerciseList: Toggle favorite para ${exercise.name}');
    print('🎯 Estado actual isFavorite: ${exercise.isFavorite}');

    try {
      final exerciseNotifier = ref.read(exerciseNotifierProvider.notifier);
      await exerciseNotifier.toggleFavorite(exercise.id);

      print('🎯 ReorderableExerciseList: Toggle completado');

      // Feedback háptico
      HapticFeedback.lightImpact();

      // Animar el movimiento a la parte superior si se marca como favorito
      if (exercise.isFavorite) {
        print('🎯 ReorderableExerciseList: Ejecutando animación hacia arriba');
        await _animateToTop(exercise);
      }
    } catch (e) {
      print('🎯 ReorderableExerciseList: Error al actualizar favorito: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al actualizar favorito: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _animateToTop(Exercise exercise) async {
    final currentIndex = _exercises.indexWhere((e) => e.id == exercise.id);
    if (currentIndex == -1 || currentIndex == 0) return;

    // Encontrar la posición correcta para el favorito
    final favoriteIndex = _exercises.indexWhere((e) => !e.isFavorite);
    final targetIndex = favoriteIndex == -1 ? 0 : favoriteIndex;

    setState(() {
      _isReordering = true;
    });

    // Mover el ejercicio a la posición correcta
    final Exercise movedExercise = _exercises.removeAt(currentIndex);
    _exercises.insert(targetIndex, movedExercise);

    // Actualizar en el backend
    await _updateExerciseOrder();

    setState(() {
      _isReordering = false;
    });
  }

  void _onLongPress(Exercise exercise) {
    // Feedback háptico para indicar que se puede arrastrar
    HapticFeedback.mediumImpact();

    // Mostrar un snackbar con instrucciones
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Mantén presionado y arrastra para reordenar'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_exercises.isEmpty) {
      return widget.emptyBuilder?.call() ?? const SizedBox.shrink();
    }

    return ReorderableListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _exercises.length,
      onReorder: _onReorder,
      onReorderStart: (index) {
        setState(() {
          _draggedIndex = index;
        });
        // Feedback háptico al iniciar el arrastre
        HapticFeedback.mediumImpact();
      },
      onReorderEnd: (index) {
        setState(() {
          _draggedIndex = null;
        });
        // Feedback háptico al finalizar el arrastre
        HapticFeedback.lightImpact();
      },
      itemBuilder: (context, index) {
        final exercise = _exercises[index];
        final isDragging = _draggedIndex == index;

        return AnimatedExerciseCard(
          key: ValueKey(exercise.id),
          exercise: exercise,
          index: index,
          isDragging: isDragging,
          isBeingDragged: _isReordering && isDragging,
          onTap: () => widget.onExerciseTap?.call(exercise),
          onFavoriteToggle: () => _onFavoriteToggle(exercise),
          onLongPress: () => _onLongPress(exercise),
        );
      },
    );
  }
}
