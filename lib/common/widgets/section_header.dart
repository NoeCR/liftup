import 'package:flutter/material.dart';
import '../../common/enums/section_muscle_group_enum.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final bool isCollapsed;
  final VoidCallback? onToggleCollapsed;
  final Widget? trailing;
  final String? iconName;
  final SectionMuscleGroup? muscleGroup;

  const SectionHeader({
    super.key,
    required this.title,
    this.isCollapsed = false,
    this.onToggleCollapsed,
    this.trailing,
    this.iconName,
    this.muscleGroup,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Material(
        color: colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onToggleCollapsed,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                if (iconName != null || muscleGroup != null) ...[
                  Icon(
                    _getIconData(iconName ?? muscleGroup?.iconName ?? 'fitness_center'),
                    color: colorScheme.onSurfaceVariant,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                if (trailing != null) ...[const SizedBox(width: 8), trailing!],
                const SizedBox(width: 8),
                AnimatedRotation(
                  turns: isCollapsed ? 0.5 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    Icons.keyboard_arrow_down,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'warm_up':
        return Icons.whatshot;
      case 'fitness_center':
        return Icons.fitness_center;
      case 'self_improvement':
        return Icons.self_improvement;
      case 'sports_gymnastics':
        return Icons.sports_gymnastics;
      case 'pool':
        return Icons.pool;
      case 'directions_run':
        return Icons.directions_run;
      case 'sports_martial_arts':
        return Icons.sports_martial_arts;
      case 'sports_tennis':
        return Icons.sports_tennis;
      case 'sports_basketball':
        return Icons.sports_basketball;
      case 'sports_soccer':
        return Icons.sports_soccer;
      case 'sports_volleyball':
        return Icons.sports_volleyball;
      case 'sports_handball':
        return Icons.sports_handball;
      case 'sports_kabaddi':
        return Icons.sports_kabaddi;
      case 'sports_motorsports':
        return Icons.sports_motorsports;
      case 'sports_mma':
        return Icons.sports_mma;
      case 'sports_rugby':
        return Icons.sports_rugby;
      case 'sports_cricket':
        return Icons.sports_cricket;
      case 'sports_golf':
        return Icons.sports_golf;
      case 'sports_hockey':
        return Icons.sports_hockey;
      case 'sports_baseball':
        return Icons.sports_baseball;
      case 'sports_football':
        return Icons.sports_football;
      case 'sports_esports':
        return Icons.sports_esports;
      case 'sports':
        return Icons.sports;
      case 'sports_score':
        return Icons.sports_score;
      case 'sports_bar':
        return Icons.sports_bar;
      case 'sports_cafe':
        return Icons.local_cafe;
      default:
        return Icons.fitness_center;
    }
  }
}
