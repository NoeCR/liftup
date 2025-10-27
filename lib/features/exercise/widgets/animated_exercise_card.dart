import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../common/themes/app_theme.dart';
import '../models/exercise.dart';

class AnimatedExerciseCard extends StatefulWidget {
  final Exercise exercise;
  final int index;
  final VoidCallback? onTap;
  final VoidCallback? onFavoriteToggle;
  final VoidCallback? onLongPress;
  final bool isDragging;
  final bool isBeingDragged;

  const AnimatedExerciseCard({
    super.key,
    required this.exercise,
    required this.index,
    this.onTap,
    this.onFavoriteToggle,
    this.onLongPress,
    this.isDragging = false,
    this.isBeingDragged = false,
  });

  @override
  State<AnimatedExerciseCard> createState() => _AnimatedExerciseCardState();
}

class _AnimatedExerciseCardState extends State<AnimatedExerciseCard> with TickerProviderStateMixin {
  late AnimationController _elevationController;
  late AnimationController _scaleController;
  late AnimationController _favoriteController;

  late Animation<double> _elevationAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _favoriteScaleAnimation;
  late Animation<double> _favoriteRotationAnimation;

  bool _isPressed = false;
  bool _wasFavorite = false;

  @override
  void initState() {
    super.initState();
    _wasFavorite = widget.exercise.isFavorite;

    // Controlador para la elevación de la tarjeta
    _elevationController = AnimationController(duration: const Duration(milliseconds: 200), vsync: this);

    // Controlador para el escalado durante el drag
    _scaleController = AnimationController(duration: const Duration(milliseconds: 150), vsync: this);

    // Controlador para la animación del favorito
    _favoriteController = AnimationController(duration: const Duration(milliseconds: 200), vsync: this);

    // Animaciones
    _elevationAnimation = Tween<double>(
      begin: 0.0,
      end: 8.0,
    ).animate(CurvedAnimation(parent: _elevationController, curve: Curves.easeOut));

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(parent: _scaleController, curve: Curves.easeOut));

    _favoriteScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.15,
    ).animate(CurvedAnimation(parent: _favoriteController, curve: Curves.easeInOut));

    _favoriteRotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.05,
    ).animate(CurvedAnimation(parent: _favoriteController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _elevationController.dispose();
    _scaleController.dispose();
    _favoriteController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(AnimatedExerciseCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Animar cuando se marca como favorito
    if (!_wasFavorite && widget.exercise.isFavorite) {
      print('🎯 AnimatedExerciseCard: Detectado cambio a favorito');
      _animateFavorite();
    }
    _wasFavorite = widget.exercise.isFavorite;

    // Animar cuando se está arrastrando
    if (widget.isDragging != oldWidget.isDragging) {
      if (widget.isDragging) {
        _animateDragStart();
      } else {
        _animateDragEnd();
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // También verificar aquí por si acaso
    if (!_wasFavorite && widget.exercise.isFavorite) {
      print('🎯 AnimatedExerciseCard: Detectado cambio a favorito en didChangeDependencies');
      _animateFavorite();
    }
    _wasFavorite = widget.exercise.isFavorite;
  }

  void _animateDragStart() {
    _scaleController.forward();
    _elevationController.forward();
  }

  void _animateDragEnd() {
    _scaleController.reverse();
    _elevationController.reverse();
  }

  void _animateFavorite() {
    print('🎯 AnimatedExerciseCard: Iniciando animación de favorito');
    HapticFeedback.lightImpact();

    _favoriteController.forward().then((_) {
      _favoriteController.reverse();
    });
  }

  void _onTapDown(TapDownDetails details) {
    setState(() {
      _isPressed = true;
    });
    _elevationController.forward();
  }

  void _onTapUp(TapUpDetails details) {
    setState(() {
      _isPressed = false;
    });
    _elevationController.reverse();
  }

  void _onTapCancel() {
    setState(() {
      _isPressed = false;
    });
    _elevationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AnimatedBuilder(
      animation: Listenable.merge([
        _elevationAnimation,
        _scaleAnimation,
        _favoriteScaleAnimation,
        _favoriteRotationAnimation,
      ]),
      builder: (context, child) {
        return Transform.scale(
          scale: widget.isDragging ? _scaleAnimation.value : 1.0,
          child: Transform.scale(
            scale: _favoriteScaleAnimation.value,
            child: Transform.rotate(
              angle: _favoriteRotationAnimation.value,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: AppTheme.spacingM, vertical: AppTheme.spacingXS),
                child: Material(
                  elevation: widget.isDragging ? _elevationAnimation.value : (_isPressed ? 4.0 : 2.0),
                  borderRadius: BorderRadius.circular(AppTheme.radiusM),
                  color: widget.isBeingDragged ? colorScheme.surfaceContainerHighest : colorScheme.surface,
                  child: GestureDetector(
                    onTap: widget.onTap,
                    onLongPress: widget.onLongPress,
                    onTapDown: _onTapDown,
                    onTapUp: _onTapUp,
                    onTapCancel: _onTapCancel,
                    child: _buildCardContent(theme, colorScheme),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCardContent(ThemeData theme, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.all(AppTheme.spacingM),
      child: Row(
        children: [
          // Imagen del ejercicio
          _buildExerciseImage(colorScheme),

          const SizedBox(width: AppTheme.spacingM),

          // Contenido principal
          Expanded(child: _buildExerciseContent(theme, colorScheme)),

          // Botones de acción
          _buildActionButtons(theme, colorScheme),
        ],
      ),
    );
  }

  Widget _buildExerciseImage(ColorScheme colorScheme) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppTheme.radiusS),
      child: Container(
        width: 60,
        height: 60,
        color: colorScheme.surfaceContainerHighest,
        child: _buildAdaptiveImage(widget.exercise.imageUrl, colorScheme),
      ),
    );
  }

  Widget _buildExerciseContent(ThemeData theme, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Título
        Text(
          widget.exercise.name,
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600, color: colorScheme.onSurface),
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
                  label: Text(muscle.name, style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500)),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                );
              }).toList(),
        ),
      ],
    );
  }

  Widget _buildActionButtons(ThemeData theme, ColorScheme colorScheme) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Botón de favorito
        IconButton(
          icon: Icon(
            widget.exercise.isFavorite ? Icons.favorite : Icons.favorite_border,
            color: widget.exercise.isFavorite ? Colors.red : colorScheme.onSurfaceVariant,
          ),
          onPressed: widget.onFavoriteToggle,
        ),

        // Indicador de arrastre o navegación
        if (widget.isDragging)
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(color: colorScheme.primary, borderRadius: BorderRadius.circular(4)),
            child: Icon(Icons.drag_handle, color: colorScheme.onPrimary, size: 16),
          )
        else
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Indicador de que se puede arrastrar
              Icon(Icons.drag_handle, size: 16, color: colorScheme.onSurfaceVariant.withOpacity(0.5)),
              const SizedBox(width: 8),
              Icon(Icons.arrow_forward_ios, size: 16, color: colorScheme.onSurfaceVariant),
            ],
          ),
      ],
    );
  }

  Widget _buildAdaptiveImage(String path, ColorScheme colorScheme) {
    if (path.isEmpty) {
      return Icon(Icons.fitness_center, color: colorScheme.onSurfaceVariant);
    }

    if (path.startsWith('assets/')) {
      return Image.asset(
        path,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Icon(Icons.fitness_center, color: colorScheme.onSurfaceVariant),
      );
    }

    if (path.startsWith('http')) {
      return Image.network(
        path,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Icon(Icons.fitness_center, color: colorScheme.onSurfaceVariant),
      );
    }

    final String filePath = path.startsWith('file:') ? path.replaceFirst('file://', '') : path;
    return Image.file(
      File(filePath),
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => Icon(Icons.fitness_center, color: colorScheme.onSurfaceVariant),
    );
  }
}
