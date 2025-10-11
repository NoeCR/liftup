import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liftly/features/progression/models/progression_template.dart';
import 'package:liftly/features/progression/services/progression_template_service.dart';
import 'package:liftly/features/progression/widgets/phase_visualization_widget.dart';
import 'package:liftly/features/progression/widgets/template_filters_widget.dart';

import '../../../common/enums/progression_type_enum.dart';

class ProgressionTemplateSelector extends ConsumerStatefulWidget {
  final ProgressionType progressionType;
  final Function(ProgressionTemplate) onTemplateSelected;

  const ProgressionTemplateSelector({
    super.key,
    required this.progressionType,
    required this.onTemplateSelected,
  });

  @override
  ConsumerState<ProgressionTemplateSelector> createState() =>
      _ProgressionTemplateSelectorState();
}

class _ProgressionTemplateSelectorState
    extends ConsumerState<ProgressionTemplateSelector> {
  ProgressionTemplate? _selectedTemplate;
  List<ProgressionTemplate> _availableTemplates = [];
  List<ProgressionTemplate> _filteredTemplates = [];
  bool _showFilters = false;

  @override
  void initState() {
    super.initState();
    _loadTemplates();
  }

  void _loadTemplates() {
    ProgressionTemplateService.initializeTemplates();
    _availableTemplates = ProgressionTemplateService.getTemplatesForType(
      widget.progressionType,
    );
    _filteredTemplates = List.from(_availableTemplates);
    if (_filteredTemplates.isNotEmpty) {
      _selectedTemplate = _filteredTemplates.first;
      widget.onTemplateSelected(_selectedTemplate!);
    }
  }

  void _onFiltersChanged(List<ProgressionTemplate> filteredTemplates) {
    setState(() {
      _filteredTemplates = filteredTemplates;
      // Si la plantilla seleccionada no está en las filtradas, seleccionar la primera
      if (!_filteredTemplates.contains(_selectedTemplate)) {
        _selectedTemplate =
            _filteredTemplates.isNotEmpty ? _filteredTemplates.first : null;
        if (_selectedTemplate != null) {
          widget.onTemplateSelected(_selectedTemplate!);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Plantilla de Progresión',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Selecciona una plantilla predefinida para tu estrategia de progresión',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),

            // Botón para mostrar/ocultar filtros
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      setState(() {
                        _showFilters = !_showFilters;
                      });
                    },
                    icon: Icon(
                      _showFilters ? Icons.filter_list_off : Icons.filter_list,
                    ),
                    label: Text(
                      _showFilters ? 'Ocultar Filtros' : 'Mostrar Filtros',
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${_filteredTemplates.length} de ${_availableTemplates.length} plantillas',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Widget de filtros
            if (_showFilters) ...[
              TemplateFiltersWidget(
                allTemplates: _availableTemplates,
                onFiltersChanged: _onFiltersChanged,
                showAdvancedFilters: true,
              ),
              const SizedBox(height: 16),
            ],

            // Selector de plantillas
            if (_filteredTemplates.isEmpty) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: theme.colorScheme.outline.withOpacity(0.2),
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.search_off,
                      size: 48,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'No se encontraron plantillas',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Intenta ajustar los filtros de búsqueda',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              DropdownButtonFormField<ProgressionTemplate>(
                value: _selectedTemplate,
                decoration: const InputDecoration(
                  labelText: 'Plantilla',
                  helperText:
                      'Elige la plantilla que mejor se adapte a tus objetivos',
                  border: OutlineInputBorder(),
                ),
                items:
                    _filteredTemplates.map((template) {
                      return DropdownMenuItem(
                        value: template,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              template.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              template.description,
                              style: TextStyle(
                                fontSize: 12,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                onChanged: (template) {
                  setState(() {
                    _selectedTemplate = template;
                  });
                  if (template != null) {
                    widget.onTemplateSelected(template);
                  }
                },
              ),
            ],

            // Información detallada de la plantilla seleccionada
            if (_selectedTemplate != null) ...[
              const SizedBox(height: 24),
              _buildTemplateDetails(_selectedTemplate!),

              // Visualización de fases (solo para plantillas con fases automáticas)
              if (_selectedTemplate!.customParameters['overload_type'] ==
                  'phases') ...[
                const SizedBox(height: 16),
                PhaseVisualizationWidget(
                  template: _selectedTemplate!,
                  currentWeek:
                      null, // Se puede pasar la semana actual si está disponible
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTemplateDetails(ProgressionTemplate template) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outline.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header con categoría y dificultad
          Row(
            children: [
              _buildInfoChip(
                'Categoría',
                template.category,
                colorScheme.primary,
              ),
              const SizedBox(width: 8),
              _buildInfoChip(
                'Dificultad',
                template.difficulty,
                colorScheme.secondary,
              ),
              const SizedBox(width: 8),
              _buildInfoChip(
                'Duración',
                '${template.estimatedDuration} sem',
                colorScheme.tertiary,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Descripción detallada
          Text(
            'Descripción',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(template.detailedDescription, style: theme.textTheme.bodyMedium),
          const SizedBox(height: 16),

          // Cuándo usar
          Text(
            'Cuándo usar',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(template.whenToUse, style: theme.textTheme.bodyMedium),
          const SizedBox(height: 16),

          // Explicación de progresión
          Text(
            'Cómo funciona',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            template.progressionExplanation,
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),

          // Explicación de deload
          Text(
            'Deload',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(template.deloadExplanation, style: theme.textTheme.bodyMedium),
          const SizedBox(height: 16),

          // Beneficios y consideraciones
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Beneficios',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 4),
                    ...template.benefits.map(
                      (benefit) => Padding(
                        padding: const EdgeInsets.only(bottom: 2),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('• ', style: TextStyle(color: Colors.green)),
                            Expanded(
                              child: Text(
                                benefit,
                                style: theme.textTheme.bodySmall,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Consideraciones',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                    const SizedBox(height: 4),
                    ...template.considerations.map(
                      (consideration) => Padding(
                        padding: const EdgeInsets.only(bottom: 2),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('• ', style: TextStyle(color: Colors.orange)),
                            Expanded(
                              child: Text(
                                consideration,
                                style: theme.textTheme.bodySmall,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(String label, String value, Color color) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        '$label: $value',
        style: theme.textTheme.bodySmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
