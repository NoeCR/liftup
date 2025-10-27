import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../common/themes/app_theme.dart';
import '../models/exercise.dart';
import '../notifiers/exercise_notifier.dart';

class SimpleAnimatedCard extends ConsumerStatefulWidget {
  final Exercise exercise;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool showFavoriteButton;

  const SimpleAnimatedCard({
    super.key,
    required this.exercise,
    this.onTap,
    this.onLongPress,
    this.showFavoriteButton = true,
  });

  @override
  ConsumerState<SimpleAnimatedCard> createState() => _SimpleAnimatedCardState();
}

class _SimpleAnimatedCardState extends ConsumerState<SimpleAnimatedCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  bool _wasFavorite = false;

  @override
  void initState() {
    super.initState();
    _wasFavorite = widget.exercise.isFavorite;

    _controller = AnimationController(duration: const Duration(milliseconds: 600), vsync: this);

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.3,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.2,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(SimpleAnimatedCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Animar cuando se marca como favorito
    if (!_wasFavorite && widget.exercise.isFavorite) {
      print('🎯 SimpleAnimatedCard: Detectado cambio a favorito');
      _animateFavorite();
    }
    _wasFavorite = widget.exercise.isFavorite;
  }

  void _animateFavorite() {
    print('🎯 SimpleAnimatedCard: Iniciando animación de favorito');
    HapticFeedback.lightImpact();

    _controller.forward().then((_) {
      _controller.reverse();
    });
  }

  Future<void> _toggleFavorite() async {
    print('🎯 SimpleAnimatedCard: Toggle favorite para ${widget.exercise.name}');

    try {
      final exerciseNotifier = ref.read(exerciseNotifierProvider.notifier);
      await exerciseNotifier.toggleFavorite(widget.exercise.id);

      print('🎯 SimpleAnimatedCard: Toggle completado');
    } catch (e) {
      print('🎯 SimpleAnimatedCard: Error al actualizar favorito: $e');
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Transform.rotate(
            angle: _rotationAnimation.value,
            child: Card(
              elevation: 2,
              margin: const EdgeInsets.symmetric(horizontal: AppTheme.spacingM, vertical: AppTheme.spacingXS),
              child: InkWell(
                onTap: widget.onTap,
                onLongPress: widget.onLongPress,
                borderRadius: BorderRadius.circular(AppTheme.radiusM),
                child: Padding(
                  padding: const EdgeInsets.all(AppTheme.spacingM),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Imagen del ejercicio
                      ClipRRect(
                        borderRadius: BorderRadius.circular(AppTheme.radiusS),
                        child: Container(
                          width: 60,
                          height: 60,
                          color: colorScheme.surfaceContainerHighest,
                          child:
                              widget.exercise.imageUrl.isNotEmpty
                                  ? Image.asset(
                                    widget.exercise.imageUrl,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            Icon(Icons.fitness_center, color: colorScheme.onSurfaceVariant),
                                  )
                                  : Icon(Icons.fitness_center, color: colorScheme.onSurfaceVariant),
                        ),
                      ),

                      const SizedBox(width: AppTheme.spacingM),

                      // Contenido principal
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Nombre del ejercicio
                            Text(
                              widget.exercise.name,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: colorScheme.onSurface,
                              ),
                            ),

                            const SizedBox(height: AppTheme.spacingXS),

                            // Descripción
                            Text(
                              widget.exercise.description,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                            ),

                            const SizedBox(height: AppTheme.spacingS),

                            // Grupos musculares
                            Wrap(
                              spacing: AppTheme.spacingXS,
                              runSpacing: AppTheme.spacingXS,
                              children:
                                  widget.exercise.muscleGroups.map((muscle) {
                                    return Chip(
                                      label: Text(
                                        muscle.name,
                                        style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500),
                                      ),
                                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    );
                                  }).toList(),
                            ),
                          ],
                        ),
                      ),

                      // Botón de favorito
                      if (widget.showFavoriteButton)
                        IconButton(
                          icon: Icon(
                            widget.exercise.isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: widget.exercise.isFavorite ? Colors.red : colorScheme.onSurfaceVariant,
                          ),
                          onPressed: _toggleFavorite,
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
