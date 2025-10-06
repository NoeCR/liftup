import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../notifiers/auto_routine_selection_notifier.dart';
import '../../../common/enums/week_day_enum.dart';
import '../../../common/themes/app_theme.dart';

/// Widget that shows information about automatic routine selection
class AutoSelectionInfoCard extends ConsumerWidget {
  const AutoSelectionInfoCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final autoSelectionInfo = ref.watch(autoRoutineSelectionNotifierProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppTheme.spacingXS),
                  decoration: BoxDecoration(
                    color:
                        autoSelectionInfo.hasSelection
                            ? colorScheme.primaryContainer
                            : colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(AppTheme.radiusS),
                  ),
                  child: Icon(
                    autoSelectionInfo.hasSelection
                        ? Icons.auto_awesome
                        : Icons.info_outline,
                    color:
                        autoSelectionInfo.hasSelection
                            ? colorScheme.onPrimaryContainer
                            : colorScheme.onSurfaceVariant,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppTheme.spacingM),
                Expanded(
                  child: Text(
                    autoSelectionInfo.hasSelection
                        ? 'Rutina Sugerida'
                        : 'Información',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color:
                          autoSelectionInfo.hasSelection
                              ? colorScheme.primary
                              : colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                _buildDayChip(context, autoSelectionInfo.currentDay),
              ],
            ),
            const SizedBox(height: AppTheme.spacingM),
            Text(
              autoSelectionInfo.hasSelection
                  ? autoSelectionInfo.description
                  : 'No hay rutinas específicas para ${autoSelectionInfo.currentDay.displayName}. Mostrando la primera rutina disponible.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
            if (autoSelectionInfo.hasSelection &&
                autoSelectionInfo.availableRoutines.length > 1) ...[
              const SizedBox(height: AppTheme.spacingS),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacingS,
                  vertical: AppTheme.spacingXS,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(AppTheme.radiusS),
                ),
                child: Text(
                  '${autoSelectionInfo.availableRoutines.length} rutinas disponibles para ${autoSelectionInfo.currentDay.displayName}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDayChip(BuildContext context, WeekDay day) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingS,
        vertical: AppTheme.spacingXS,
      ),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(AppTheme.radiusM),
      ),
      child: Text(
        day.shortName,
        style: theme.textTheme.bodySmall?.copyWith(
          color: colorScheme.onPrimaryContainer,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
