import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../notifiers/auto_routine_selection_notifier.dart';
import '../../../common/enums/week_day_enum.dart';

/// Widget que muestra información sobre la selección automática de rutinas
class AutoSelectionInfoCard extends ConsumerWidget {
  const AutoSelectionInfoCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final autoSelectionInfo = ref.watch(autoRoutineSelectionNotifierProvider);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  autoSelectionInfo.hasSelection ? Icons.auto_awesome : Icons.info_outline,
                  color: autoSelectionInfo.hasSelection ? colorScheme.primary : colorScheme.onSurfaceVariant,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  autoSelectionInfo.hasSelection ? 'Rutina Sugerida' : 'Information',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: autoSelectionInfo.hasSelection ? colorScheme.primary : colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                _buildDayChip(context, autoSelectionInfo.currentDay),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              autoSelectionInfo.hasSelection
                  ? autoSelectionInfo.description
                  : 'No specific routines for ${autoSelectionInfo.currentDay.displayName}. Showing first available routine.',
              style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
            ),
            if (autoSelectionInfo.hasSelection && autoSelectionInfo.availableRoutines.length > 1) ...[
              const SizedBox(height: 8),
              Text(
                '${autoSelectionInfo.availableRoutines.length} rutinas disponibles para ${autoSelectionInfo.currentDay.displayName}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontStyle: FontStyle.italic,
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: colorScheme.primaryContainer, borderRadius: BorderRadius.circular(12)),
      child: Text(
        day.shortName,
        style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onPrimaryContainer, fontWeight: FontWeight.bold),
      ),
    );
  }
}
