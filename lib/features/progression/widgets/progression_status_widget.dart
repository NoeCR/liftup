import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'progression_selection_dialog.dart';
import '../notifiers/progression_notifier.dart';

class ProgressionStatusWidget extends ConsumerWidget {
  const ProgressionStatusWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final progressionAsync = ref.watch(progressionNotifierProvider);

    return progressionAsync.when(
      data: (config) {
        if (config == null) {
          return _buildNoProgression(context, theme, colorScheme);
        }

        return _buildActiveProgression(context, theme, colorScheme, config, ref);
      },
      loading: () => const SizedBox.shrink(),
      error: (error, stack) => _buildErrorState(context, theme, colorScheme, error.toString()),
    );
  }

  Widget _buildNoProgression(BuildContext context, ThemeData theme, ColorScheme colorScheme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.fitness_center, color: colorScheme.onSurfaceVariant, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'progression.noProgression'.tr(),
              style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
            ),
          ),
          TextButton(
            onPressed: () => _showProgressionDialog(context),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text('progression.configure'.tr(), style: TextStyle(fontSize: 12, color: colorScheme.primary)),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveProgression(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
    dynamic config,
    WidgetRef ref,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.trending_up, color: colorScheme.primary, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'progression.activeProgression'.tr(namedArgs: {'type': context.tr(config.type.displayNameKey)}),
                  style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.primary, fontWeight: FontWeight.w500),
                ),
                Text(
                  context.tr(config.type.descriptionKey),
                  style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant, fontSize: 11),
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: colorScheme.primary, size: 16),
            onSelected: (value) {
              switch (value) {
                case 'change':
                  _showProgressionDialog(context);
                  break;
                case 'disable':
                  _disableProgression(context, ref);
                  break;
              }
            },
            itemBuilder:
                (context) => [
                  PopupMenuItem(
                    value: 'change',
                    child: Row(
                      children: [
                        const Icon(Icons.edit, size: 16),
                        const SizedBox(width: 8),
                        Text('progression.change'.tr()),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'disable',
                    child: Row(
                      children: [
                        const Icon(Icons.stop, size: 16),
                        const SizedBox(width: 8),
                        Text('progression.disable'.tr()),
                      ],
                    ),
                  ),
                ],
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, ThemeData theme, ColorScheme colorScheme, String error) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.error.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: colorScheme.error, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'progression.errorLoadingProgression'.tr(namedArgs: {'error': error}),
              style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }

  void _showProgressionDialog(BuildContext context) {
    showDialog(context: context, builder: (context) => const ProgressionSelectionDialog());
  }

  void _disableProgression(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('progression.disableProgression'.tr()),
            content: Text('progression.disableProgressionQuestion'.tr()),
            actions: [
              TextButton(onPressed: () => Navigator.of(context).pop(), child: Text('common.cancel'.tr())),
              FilledButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  try {
                    await ref.read(progressionNotifierProvider.notifier).disableProgression();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('progression.progressionDisabled'.tr()), backgroundColor: Colors.green),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('progression.errorDisablingProgression'.tr(namedArgs: {'error': e.toString()})),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
                child: Text('progression.disable'.tr()),
              ),
            ],
          ),
    );
  }
}
