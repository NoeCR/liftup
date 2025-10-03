import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'progression_selection_dialog.dart';
import '../notifiers/progression_notifier.dart';
import '../../../common/localization/app_localizations.dart';

class ProgressionStatusWidget extends ConsumerWidget {
  const ProgressionStatusWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    final progressionAsync = ref.watch(progressionNotifierProvider);

    return progressionAsync.when(
      data: (config) {
        if (config == null) {
          return _buildNoProgression(context, theme, colorScheme, l10n);
        }

        return _buildActiveProgression(
          context,
          theme,
          colorScheme,
          config,
          l10n,
          ref,
        );
      },
      loading: () => const SizedBox.shrink(),
      error:
          (error, stack) => _buildErrorState(
            context,
            theme,
            colorScheme,
            error.toString(),
            l10n,
          ),
    );
  }

  Widget _buildNoProgression(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
    AppLocalizations l10n,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.outline.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.fitness_center,
            color: colorScheme.onSurfaceVariant,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              l10n.noProgression,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          TextButton(
            onPressed: () => _showProgressionDialog(context),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              l10n.progressionConfigure,
              style: TextStyle(fontSize: 12, color: colorScheme.primary),
            ),
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
    AppLocalizations l10n,
    WidgetRef ref,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.primary.withOpacity(0.3)),
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
                  l10n.activeProgression(config.type.displayName),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  config.type.description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 11,
                  ),
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
                        Text(l10n.progressionChange),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'disable',
                    child: Row(
                      children: [
                        const Icon(Icons.stop, size: 16),
                        const SizedBox(width: 8),
                        Text(l10n.progressionDisable),
                      ],
                    ),
                  ),
                ],
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
    String error,
    AppLocalizations l10n,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.error.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: colorScheme.error, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              l10n.errorLoadingProgression(error),
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.error,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showProgressionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const ProgressionSelectionDialog(),
    );
  }

  void _disableProgression(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(l10n.disableProgression),
            content: Text(l10n.disableProgressionQuestion),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(l10n.cancel),
              ),
              FilledButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  try {
                    await ref
                        .read(progressionNotifierProvider.notifier)
                        .disableProgression();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(l10n.progressionDisabled),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            l10n.errorDisablingProgression(e.toString()),
                          ),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
                child: Text(l10n.progressionDisable),
              ),
            ],
          ),
    );
  }
}
