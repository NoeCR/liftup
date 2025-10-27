import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SimpleFavoriteAnimation extends StatefulWidget {
  final Widget child;
  final bool isFavorite;
  final VoidCallback? onAnimationComplete;

  const SimpleFavoriteAnimation({super.key, required this.child, required this.isFavorite, this.onAnimationComplete});

  @override
  State<SimpleFavoriteAnimation> createState() => _SimpleFavoriteAnimationState();
}

class _SimpleFavoriteAnimationState extends State<SimpleFavoriteAnimation> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(duration: const Duration(milliseconds: 300), vsync: this);

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(SimpleFavoriteAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);

    print('🎯 SimpleFavoriteAnimation: didUpdateWidget - old: ${oldWidget.isFavorite}, new: ${widget.isFavorite}');

    // Si cambió de no favorito a favorito, animar
    if (!oldWidget.isFavorite && widget.isFavorite) {
      print('🎯 SimpleFavoriteAnimation: Detectado cambio a favorito, iniciando animación');
      _animateFavorite();
    }
  }

  void _animateFavorite() {
    print('🎯 SimpleFavoriteAnimation: Iniciando animación de favorito');

    // Feedback háptico
    HapticFeedback.lightImpact();

    // Animar
    _controller.forward().then((_) {
      print('🎯 SimpleFavoriteAnimation: Animación hacia adelante completada');
      _controller.reverse().then((_) {
        print('🎯 SimpleFavoriteAnimation: Animación hacia atrás completada');
        widget.onAnimationComplete?.call();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Transform.rotate(angle: _rotationAnimation.value, child: widget.child),
        );
      },
    );
  }
}
