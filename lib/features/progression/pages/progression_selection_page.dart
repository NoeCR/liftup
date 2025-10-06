import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';
import '../models/progression_template.dart';
import '../services/progression_template_service.dart';
import '../../../common/enums/progression_type_enum.dart';

class ProgressionSelectionPage extends ConsumerStatefulWidget {
  const ProgressionSelectionPage({super.key});

  @override
  ConsumerState<ProgressionSelectionPage> createState() => _ProgressionSelectionPageState();
}

class _ProgressionSelectionPageState extends ConsumerState<ProgressionSelectionPage> {
  ProgressionType? _selectedType;
  String? _selectedDifficulty;
  final List<String> _difficulties = ['Principiante', 'Intermedio', 'Avanzado'];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurar Progresión Global'),
        backgroundColor: colorScheme.surface,
        actions: [
          if (_selectedType != null)
            TextButton(onPressed: () => _navigateToConfiguration(), child: const Text('Siguiente')),
        ],
      ),
      body: Column(
        children: [
          // Filtros
          _buildFilters(),

          // Lista de plantillas
          Expanded(child: _buildTemplatesList()),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        border: Border(bottom: BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.2))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Filtrar por dificultad:', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              FilterChip(
                label: const Text('Todas'),
                selected: _selectedDifficulty == null,
                onSelected: (selected) {
                  setState(() {
                    _selectedDifficulty = selected ? null : _selectedDifficulty;
                  });
                },
              ),
              ..._difficulties.map(
                (difficulty) => FilterChip(
                  label: Text(difficulty),
                  selected: _selectedDifficulty == difficulty,
                  onSelected: (selected) {
                    setState(() {
                      _selectedDifficulty = selected ? difficulty : null;
                    });
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTemplatesList() {
    return Consumer(
      builder: (context, ref, child) {
        final templatesAsync = ref.watch(progressionTemplateServiceProvider);

        return templatesAsync.when(
          data: (templates) {
            // Filter templates by difficulty if selected
            final filteredTemplates =
                _selectedDifficulty != null
                    ? templates.where((t) => t.difficulty == _selectedDifficulty).toList()
                    : templates;

            if (filteredTemplates.isEmpty) {
              return _buildEmptyState();
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filteredTemplates.length,
              itemBuilder: (context, index) {
                final template = filteredTemplates[index];
                return _buildTemplateCard(template);
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => _buildErrorState(error.toString()),
        );
      },
    );
  }

  Widget _buildTemplateCard(ProgressionTemplate template) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isSelected = _selectedType == template.type;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
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
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          template.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isSelected ? colorScheme.onPrimaryContainer : null,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          template.description,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: isSelected ? colorScheme.onPrimaryContainer : null,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isSelected) Icon(Icons.check_circle, color: colorScheme.primary),
                ],
              ),
              const SizedBox(height: 12),

              // Additional information
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  _buildInfoChip(template.difficulty, _getDifficultyColor(template.difficulty)),
                  _buildInfoChip(context.tr(template.type.displayNameKey), colorScheme.secondary),
                  ...template.recommendedFor.map(
                    (recommendation) => _buildInfoChip(recommendation, colorScheme.tertiary),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Ejemplo
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Ejemplo:', style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(template.example, style: theme.textTheme.bodySmall),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(label, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w500)),
    );
  }

  Color _getDifficultyColor(String difficulty) {
    final colorScheme = Theme.of(context).colorScheme;
    switch (difficulty) {
      case 'Principiante':
        return Colors.green;
      case 'Intermedio':
        return Colors.orange;
      case 'Avanzado':
        return Colors.red;
      default:
        return colorScheme.primary;
    }
  }

  Widget _buildEmptyState() {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.fitness_center, size: 64, color: theme.colorScheme.outline),
          const SizedBox(height: 16),
          Text(
            'No se encontraron plantillas',
            style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.outline),
          ),
          const SizedBox(height: 8),
          Text(
            'Intenta cambiar los filtros de búsqueda',
            style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.outline),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: theme.colorScheme.error),
          const SizedBox(height: 16),
          Text(
            'Error al cargar plantillas',
            style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.error),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.error),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _navigateToConfiguration() {
    if (_selectedType != null) {
      context.push('/progression-configuration', extra: {'progressionType': _selectedType!});
    }
  }
}
