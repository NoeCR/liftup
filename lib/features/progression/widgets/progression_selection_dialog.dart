import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';
import '../models/progression_template.dart';
import '../services/progression_template_service.dart';
import '../notifiers/progression_notifier.dart';
import '../../../common/enums/progression_type_enum.dart';

class ProgressionSelectionDialog extends ConsumerStatefulWidget {
  const ProgressionSelectionDialog({super.key});

  @override
  ConsumerState<ProgressionSelectionDialog> createState() =>
      _ProgressionSelectionDialogState();
}

class _ProgressionSelectionDialogState
    extends ConsumerState<ProgressionSelectionDialog> {
  ProgressionType? _selectedType;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.trending_up, color: colorScheme.primary),
          const SizedBox(width: 8),
          Text('progression.configureProgression'.tr()),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'progression.configureProgressionQuestion'.tr(),
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),

            // Free training option
            _buildOptionCard(
              title: 'progression.freeTraining'.tr(),
              description: 'progression.freeTrainingDescription'.tr(),
              icon: Icons.fitness_center,
              isSelected: _selectedType == ProgressionType.none,
              onTap: () {
                setState(() {
                  _selectedType = ProgressionType.none;
                });
              },
            ),

            const SizedBox(height: 12),

            // Automatic progression option
            _buildOptionCard(
              title: 'progression.automaticProgression'.tr(),
              description: 'progression.automaticProgressionDescription'.tr(),
              icon: Icons.auto_graph,
              isSelected:
                  _selectedType != null &&
                  _selectedType != ProgressionType.none,
              onTap: () {
                _showProgressionTypes();
              },
            ),

            if (_selectedType != null &&
                _selectedType != ProgressionType.none) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: colorScheme.primary.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: colorScheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'progression.selectedProgression'.tr(
                          namedArgs: {
                            'type': context.tr(_selectedType!.displayNameKey),
                          },
                        ),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed:
              _isLoading
                  ? null
                  : () {
                    Navigator.of(context).pop();
                  },
          child: Text('common.cancel'.tr()),
        ),
        FilledButton(
          onPressed: _isLoading ? null : _handleSelection,
          child:
              _isLoading
                  ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                  : Text('progression.continue'.tr()),
        ),
      ],
    );
  }

  Widget _buildOptionCard({
    required String title,
    required String description,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: isSelected ? 4 : 1,
      color: isSelected ? colorScheme.primaryContainer : null,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Icon(
                icon,
                color:
                    isSelected
                        ? colorScheme.onPrimaryContainer
                        : colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color:
                            isSelected ? colorScheme.onPrimaryContainer : null,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color:
                            isSelected ? colorScheme.onPrimaryContainer : null,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(Icons.check_circle, color: colorScheme.primary, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _showProgressionTypes() {
    showDialog(
      context: context,
      builder:
          (context) => _ProgressionTypeSelectionDialog(
            onTypeSelected: (type) {
              setState(() {
                _selectedType = type;
              });
            },
          ),
    );
  }

  Future<void> _handleSelection() async {
    if (_selectedType == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      if (_selectedType == ProgressionType.none) {
        // Disable current progression if it exists
        await ref
            .read(progressionNotifierProvider.notifier)
            .disableProgression();
      } else {
        // Navigate to progression configuration
        if (mounted) {
          Navigator.of(context).pop();
          context.push(
            '/progression-configuration',
            extra: {'progressionType': _selectedType!},
          );
          return;
        }
      }

      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}

class _ProgressionTypeSelectionDialog extends ConsumerStatefulWidget {
  final Function(ProgressionType) onTypeSelected;

  const _ProgressionTypeSelectionDialog({required this.onTypeSelected});

  @override
  ConsumerState<_ProgressionTypeSelectionDialog> createState() =>
      _ProgressionTypeSelectionDialogState();
}

class _ProgressionTypeSelectionDialogState
    extends ConsumerState<_ProgressionTypeSelectionDialog> {
  ProgressionType? _selectedType;

  @override
  void initState() {
    super.initState();
    // Ensure built-in templates exist when opening the dialog
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        final notifier = ref.read(progressionTemplateServiceProvider.notifier);
        await notifier.initializeBuiltInTemplates();
        ref.invalidate(progressionTemplateServiceProvider);
      } catch (_) {
        // Silence errors here; the builder will show the proper state
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('progression.selectProgressionType'.tr()),
      content: SizedBox(
        width: double.maxFinite,
        child: Consumer(
          builder: (context, ref, child) {
            final templatesAsync = ref.watch(
              progressionTemplateServiceProvider,
            );

            return templatesAsync.when(
              data: (templates) {
                // Filter only progression types (exclude 'none')
                final progressionTemplates =
                    templates
                        .where(
                          (template) => template.type != ProgressionType.none,
                        )
                        .toList();

                if (progressionTemplates.isEmpty) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 8),
                      Text(
                        'progression.noTemplatesFound'.tr(),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      FilledButton(
                        onPressed: () async {
                          try {
                            final notifier = ref.read(
                              progressionTemplateServiceProvider.notifier,
                            );
                            await notifier.restoreBuiltInTemplates();
                            ref.invalidate(progressionTemplateServiceProvider);
                          } catch (_) {}
                        },
                        child: Text('progression.restoreTemplates'.tr()),
                      ),
                    ],
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: progressionTemplates.length,
                  itemBuilder: (context, index) {
                    final template = progressionTemplates[index];
                    return _buildTypeCard(template);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Text('Error: $error'),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('common.cancel'.tr()),
        ),
        FilledButton(
          onPressed:
              _selectedType != null
                  ? () {
                    widget.onTypeSelected(_selectedType!);
                    Navigator.of(context).pop();
                  }
                  : null,
          child: const Text('Seleccionar'),
        ),
      ],
    );
  }

  Widget _buildTypeCard(ProgressionTemplate template) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isSelected = _selectedType == template.type;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: isSelected ? 4 : 1,
      color: isSelected ? colorScheme.primaryContainer : null,
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedType = template.type;
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      template.name,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color:
                            isSelected ? colorScheme.onPrimaryContainer : null,
                      ),
                    ),
                  ),
                  if (isSelected)
                    Icon(
                      Icons.check_circle,
                      color: colorScheme.primary,
                      size: 20,
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                template.description,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: isSelected ? colorScheme.onPrimaryContainer : null,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildInfoChip(
                    template.difficulty,
                    _getDifficultyColor(template.difficulty),
                  ),
                  const SizedBox(width: 8),
                  _buildInfoChip(
                    context.tr(template.type.displayNameKey),
                    colorScheme.secondary,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty) {
      case 'Principiante':
        return Colors.green;
      case 'Intermedio':
        return Colors.orange;
      case 'Avanzado':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }
}
