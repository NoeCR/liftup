import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/exercise.dart';

class FavoriteAnimationWidget extends StatefulWidget {
  final Exercise exercise;
  final int currentIndex;
  final int targetIndex;
  final VoidCallback? onAnimationComplete;
  final Widget Function(Exercise, int) itemBuilder;

  const FavoriteAnimationWidget({
    super.key,
    required this.exercise,
    required this.currentIndex,
    required this.targetIndex,
    this.onAnimationComplete,
    required this.itemBuilder,
  });

  @override
  State<FavoriteAnimationWidget> createState() => _FavoriteAnimationWidgetState();
}

class _FavoriteAnimationWidgetState extends State<FavoriteAnimationWidget> with TickerProviderStateMixin {
  late AnimationController _liftController;
  late AnimationController _moveController;
  late AnimationController _dropController;

  late Animation<double> _liftAnimation;
  late Animation<double> _moveAnimation;
  late Animation<Offset> _positionAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;

  bool _isAnimating = false;

  @override
  void initState() {
    super.initState();

    // Controlador para la elevación inicial
    _liftController = AnimationController(duration: const Duration(milliseconds: 200), vsync: this);

    // Controlador para el movimiento
    _moveController = AnimationController(duration: const Duration(milliseconds: 400), vsync: this);

    // Controlador para el descenso final
    _dropController = AnimationController(duration: const Duration(milliseconds: 200), vsync: this);

    // Animación de elevación
    _liftAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _liftController, curve: Curves.easeOut));

    // Animación de movimiento
    _moveAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _moveController, curve: Curves.easeInOut));

    // Animación de posición
    _positionAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset(0, -(widget.currentIndex - widget.targetIndex).toDouble()),
    ).animate(CurvedAnimation(parent: _moveController, curve: Curves.easeInOut));

    // Animación de escala
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(parent: _liftController, curve: Curves.easeOut));

    // Animación de elevación
    _elevationAnimation = Tween<double>(
      begin: 2.0,
      end: 12.0,
    ).animate(CurvedAnimation(parent: _liftController, curve: Curves.easeOut));

    // Iniciar la animación
    _startAnimation();
  }

  @override
  void dispose() {
    _liftController.dispose();
    _moveController.dispose();
    _dropController.dispose();
    super.dispose();
  }

  Future<void> _startAnimation() async {
    if (_isAnimating) return;

    setState(() {
      _isAnimating = true;
    });

    // Feedback háptico
    HapticFeedback.mediumImpact();

    // Fase 1: Elevar la tarjeta
    await _liftController.forward();

    // Fase 2: Mover hacia la posición objetivo
    await _moveController.forward();

    // Fase 3: Descender la tarjeta
    await _dropController.forward();

    // Resetear animaciones
    _liftController.reset();
    _moveController.reset();
    _dropController.reset();

    setState(() {
      _isAnimating = false;
    });

    // Notificar que la animación ha terminado
    widget.onAnimationComplete?.call();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _liftAnimation,
        _moveAnimation,
        _positionAnimation,
        _scaleAnimation,
        _elevationAnimation,
      ]),
      builder: (context, child) {
        return Transform.translate(
          offset: _positionAnimation.value * 80, // Ajustar según el tamaño de la tarjeta
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: _elevationAnimation.value,
                    offset: Offset(0, _elevationAnimation.value / 2),
                  ),
                ],
              ),
              child: widget.itemBuilder(widget.exercise, widget.currentIndex),
            ),
          ),
        );
      },
    );
  }
}

/// Widget que maneja la animación de favoritos para una lista completa
class FavoriteAnimationList extends StatefulWidget {
  final List<Exercise> exercises;
  final Widget Function(Exercise, int) itemBuilder;
  final Function(Exercise)? onFavoriteToggle;

  const FavoriteAnimationList({super.key, required this.exercises, required this.itemBuilder, this.onFavoriteToggle});

  @override
  State<FavoriteAnimationList> createState() => _FavoriteAnimationListState();
}

class _FavoriteAnimationListState extends State<FavoriteAnimationList> {
  Exercise? _animatingExercise;
  int? _animatingIndex;

  void _onAnimationComplete() {
    setState(() {
      _animatingExercise = null;
      _animatingIndex = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children:
          widget.exercises.asMap().entries.map((entry) {
            final index = entry.key;
            final exercise = entry.value;

            // Si este ejercicio está siendo animado, usar el widget de animación
            if (_animatingExercise?.id == exercise.id && _animatingIndex == index) {
              return FavoriteAnimationWidget(
                exercise: exercise,
                currentIndex: index,
                targetIndex: widget.exercises.indexWhere((e) => !e.isFavorite),
                onAnimationComplete: _onAnimationComplete,
                itemBuilder: widget.itemBuilder,
              );
            }

            // Si es el ejercicio que se está moviendo pero no es el que se está animando,
            // mostrar un placeholder vacío
            if (_animatingExercise?.id == exercise.id && _animatingIndex != index) {
              return const SizedBox(height: 80); // Altura aproximada de una tarjeta
            }

            // Ejercicio normal
            return widget.itemBuilder(exercise, index);
          }).toList(),
    );
  }
}
