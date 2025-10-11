import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liftly/common/enums/progression_type_enum.dart';
import 'package:liftly/features/progression/models/progression_template.dart';
import 'package:liftly/features/progression/services/progression_template_service.dart';
import 'package:liftly/features/progression/widgets/phase_visualization_widget.dart';

class OverloadPhasesDemoPage extends ConsumerStatefulWidget {
  const OverloadPhasesDemoPage({super.key});

  @override
  ConsumerState<OverloadPhasesDemoPage> createState() =>
      _OverloadPhasesDemoPageState();
}

class _OverloadPhasesDemoPageState
    extends ConsumerState<OverloadPhasesDemoPage> {
  ProgressionTemplate? _selectedTemplate;
  int _currentWeek = 1;

  @override
  void initState() {
    super.initState();
    _loadTemplates();
  }

  void _loadTemplates() {
    ProgressionTemplateService.initializeTemplates();
    final templates = ProgressionTemplateService.getTemplatesForType(
      ProgressionType.overload,
    );
    final phasesTemplates =
        templates
            .where((t) => t.customParameters['overload_type'] == 'phases')
            .toList();

    if (phasesTemplates.isNotEmpty) {
      setState(() {
        _selectedTemplate = phasesTemplates.first;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Demo - Fases Automáticas'),
        backgroundColor: colorScheme.surface,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: _showInfoDialog,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Información del demo
            _buildDemoInfo(theme, colorScheme),
            const SizedBox(height: 24),

            // Selector de plantilla
            _buildTemplateSelector(theme, colorScheme),
            const SizedBox(height: 24),

            // Control de semana actual
            _buildWeekSelector(theme, colorScheme),
            const SizedBox(height: 24),

            // Visualización de fases
            if (_selectedTemplate != null) ...[
              PhaseVisualizationWidget(
                template: _selectedTemplate!,
                currentWeek: _currentWeek,
              ),
              const SizedBox(height: 24),
            ],

            // Información detallada de la plantilla
            if (_selectedTemplate != null) ...[
              _buildTemplateDetails(theme, colorScheme),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDemoInfo(ThemeData theme, ColorScheme colorScheme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.auto_awesome, color: colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Fases Automáticas en OverloadProgressionStrategy',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Este demo muestra las nuevas plantillas con periodización automática que cambian entre fases de acumulación, intensificación y peaking sin intervención manual.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Text(
              'Características:',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ...const [
              '• 5 plantillas especializadas con fases automáticas',
              '• Transiciones automáticas entre fases',
              '• Visualización de fases en tiempo real',
              '• Configuraciones optimizadas por objetivo',
              '• Parámetros personalizables por fase',
            ].map(
              (feature) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(feature, style: theme.textTheme.bodyMedium),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTemplateSelector(ThemeData theme, ColorScheme colorScheme) {
    final templates = ProgressionTemplateService.getTemplatesForType(
      ProgressionType.overload,
    );
    final phasesTemplates =
        templates
            .where((t) => t.customParameters['overload_type'] == 'phases')
            .toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Seleccionar Plantilla',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<ProgressionTemplate>(
              value: _selectedTemplate,
              decoration: const InputDecoration(
                labelText: 'Plantilla con Fases Automáticas',
                helperText:
                    'Elige una plantilla para ver su visualización de fases',
                border: OutlineInputBorder(),
              ),
              items:
                  phasesTemplates.map((template) {
                    return DropdownMenuItem(
                      value: template,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            template.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            template.description,
                            style: TextStyle(
                              fontSize: 12,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
              onChanged: (template) {
                setState(() {
                  _selectedTemplate = template;
                  _currentWeek = 1; // Reset week when changing template
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeekSelector(ThemeData theme, ColorScheme colorScheme) {
    if (_selectedTemplate == null) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Simular Semana Actual',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Cambia la semana para ver cómo se actualiza la visualización de fases',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Slider(
                    value: _currentWeek.toDouble(),
                    min: 1,
                    max: _selectedTemplate!.cycleLength.toDouble(),
                    divisions: _selectedTemplate!.cycleLength - 1,
                    label: 'Semana $_currentWeek',
                    onChanged: (value) {
                      setState(() {
                        _currentWeek = value.round();
                      });
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  'Semana $_currentWeek',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTemplateDetails(ThemeData theme, ColorScheme colorScheme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Detalles de la Plantilla',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildDetailRow('Nombre', _selectedTemplate!.name),
            _buildDetailRow('Descripción', _selectedTemplate!.description),
            _buildDetailRow('Categoría', _selectedTemplate!.category),
            _buildDetailRow('Objetivo', _selectedTemplate!.goal),
            _buildDetailRow(
              'Duración del Ciclo',
              '${_selectedTemplate!.cycleLength} semanas',
            ),
            _buildDetailRow(
              'Duración de Fases',
              '${_selectedTemplate!.customParameters['phase_duration_weeks']} semanas',
            ),
            _buildDetailRow(
              'Tasa de Acumulación',
              '${(_selectedTemplate!.customParameters['accumulation_rate'] as num? ?? 0.15) * 100}%',
            ),
            _buildDetailRow(
              'Tasa de Intensificación',
              '${(_selectedTemplate!.customParameters['intensification_rate'] as num? ?? 0.1) * 100}%',
            ),
            _buildDetailRow(
              'Tasa de Peaking',
              '${(_selectedTemplate!.customParameters['peaking_rate'] as num? ?? 0.05) * 100}%',
            ),
            _buildDetailRow('Dificultad', _selectedTemplate!.difficulty),
            _buildDetailRow(
              'Duración Estimada',
              '${_selectedTemplate!.estimatedDuration} semanas',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(child: Text(value, style: theme.textTheme.bodyMedium)),
        ],
      ),
    );
  }

  void _showInfoDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Información sobre Fases Automáticas'),
            content: const SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Las fases automáticas implementan periodización científica:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 12),
                  Text('🔵 Acumulación: Enfoque en volumen'),
                  Text('🟠 Intensificación: Enfoque en intensidad'),
                  Text('🔴 Peaking: Máxima intensidad, volumen reducido'),
                  SizedBox(height: 12),
                  Text(
                    'Beneficios:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text('• Progresión automática sin configuración manual'),
                  Text('• Optimización científica del rendimiento'),
                  Text('• Preparación para competencia'),
                  Text('• Adaptaciones profundas y sostenibles'),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cerrar'),
              ),
            ],
          ),
    );
  }
}
