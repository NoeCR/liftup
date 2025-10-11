import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:liftly/features/progression/models/progression_template.dart';
import 'package:liftly/features/progression/notifiers/progression_notifier.dart';
import 'package:liftly/features/progression/services/progression_template_service.dart';

import '../../../common/enums/progression_type_enum.dart';
import '../../../core/logging/logging.dart';
import 'progression_template_selector.dart';

class ProgressionConfigurationWithTemplatesIntegrated
    extends ConsumerStatefulWidget {
  final ProgressionType progressionType;

  const ProgressionConfigurationWithTemplatesIntegrated({
    super.key,
    required this.progressionType,
  });

  @override
  ConsumerState<ProgressionConfigurationWithTemplatesIntegrated>
  createState() => _ProgressionConfigurationWithTemplatesIntegratedState();
}

class _ProgressionConfigurationWithTemplatesIntegratedState
    extends ConsumerState<ProgressionConfigurationWithTemplatesIntegrated> {
  final _formKey = GlobalKey<FormState>();

  // Valores de configuración (se llenan automáticamente desde la plantilla)
  ProgressionUnit _unit = ProgressionUnit.session;
  ProgressionTarget _primaryTarget = ProgressionTarget.weight;
  ProgressionTarget? _secondaryTarget;
  double _incrementValue = 2.5;
  int _incrementFrequency = 1;
  int _cycleLength = 4;
  int _deloadWeek = 4;
  double _deloadPercentage = 0.9;
  final Map<String, dynamic> _customParameters = {};

  // Plantilla seleccionada
  ProgressionTemplate? _selectedTemplate;

  bool _isLoading = false;
  bool _useTemplates = true; // Toggle entre plantillas y configuración manual

  @override
  void initState() {
    super.initState();
    _initializeDefaultTemplate();
  }

  void _initializeDefaultTemplate() {
    ProgressionTemplateService.initializeTemplates();
    final templates = ProgressionTemplateService.getTemplatesForType(
      widget.progressionType,
    );
    if (templates.isNotEmpty) {
      _selectedTemplate = templates.first;
      _applyTemplate(_selectedTemplate!);
    }
  }

  void _applyTemplate(ProgressionTemplate template) {
    setState(() {
      _selectedTemplate = template;
      _unit = template.unit;
      _primaryTarget = template.primaryTarget;
      _secondaryTarget = template.secondaryTarget;
      _incrementValue = template.incrementValue;
      _incrementFrequency = template.incrementFrequency;
      _cycleLength = template.cycleLength;
      _deloadWeek = template.deloadWeek;
      _deloadPercentage = template.deloadPercentage;
      _customParameters.clear();
      _customParameters.addAll(template.customParameters);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${'progression.configureProgression'.tr()} ${context.tr(widget.progressionType.displayNameKey)}',
        ),
        backgroundColor: colorScheme.surface,
        actions: [
          // Toggle entre plantillas y configuración manual
          IconButton(
            icon: Icon(_useTemplates ? Icons.tune : Icons.auto_awesome),
            tooltip: _useTemplates ? 'Configuración manual' : 'Usar plantillas',
            onPressed: () {
              setState(() {
                _useTemplates = !_useTemplates;
              });
            },
          ),
          TextButton(
            onPressed: _isLoading ? null : _saveProgression,
            child:
                _isLoading
                    ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                    : Text('common.save'.tr()),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Información de la progresión
              _buildProgressionInfo(),
              const SizedBox(height: 24),

              // Toggle entre plantillas y configuración manual
              _buildModeToggle(),
              const SizedBox(height: 24),

              if (_useTemplates) ...[
                // Selector de plantillas (reemplaza la configuración avanzada)
                ProgressionTemplateSelector(
                  progressionType: widget.progressionType,
                  onTemplateSelected: _applyTemplate,
                ),
                const SizedBox(height: 24),

                // Configuración básica (solo lectura)
                _buildReadOnlyConfiguration(),
              ] else ...[
                // Configuración manual (original)
                _buildManualConfiguration(),
              ],

              const SizedBox(height: 24),

              // Botón de guardar
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _isLoading ? null : _saveProgression,
                  icon:
                      _isLoading
                          ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                          : const Icon(Icons.save),
                  label: Text(
                    _isLoading
                        ? 'progression.saving'.tr()
                        : 'progression.saveProgression'.tr(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressionInfo() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'progression.progressionConfiguration'.tr(),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'progression.globalProgressionDescription'.tr(),
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 4),
            Text(
              '${'progression.types.${widget.progressionType.name}'.tr()}: ${context.tr(widget.progressionType.displayNameKey)}',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 4),
            Text(
              'progression.types.${widget.progressionType.name}Description'
                  .tr(),
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModeToggle() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Modo de Configuración',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _useTemplates
                  ? 'Usando plantillas predefinidas con valores optimizados'
                  : 'Configuración manual avanzada',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: SegmentedButton<bool>(
                    segments: const [
                      ButtonSegment<bool>(
                        value: true,
                        label: Text('Plantillas'),
                        icon: Icon(Icons.auto_awesome),
                      ),
                      ButtonSegment<bool>(
                        value: false,
                        label: Text('Manual'),
                        icon: Icon(Icons.tune),
                      ),
                    ],
                    selected: {_useTemplates},
                    onSelectionChanged: (Set<bool> selection) {
                      setState(() {
                        _useTemplates = selection.first;
                      });
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReadOnlyConfiguration() {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.visibility, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Configuración de la Plantilla',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Estos valores se configuran automáticamente según la plantilla seleccionada',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),

            // Mostrar valores actuales (solo lectura)
            _buildReadOnlyField(
              'Unidad de Progresión',
              _unit.displayNameKey.tr(),
            ),
            _buildReadOnlyField(
              'Objetivo Principal',
              _primaryTarget.displayNameKey.tr(),
            ),
            if (_secondaryTarget != null)
              _buildReadOnlyField(
                'Objetivo Secundario',
                _secondaryTarget!.displayNameKey.tr(),
              ),
            _buildReadOnlyField(
              'Valor de Incremento',
              '${_incrementValue.toStringAsFixed(1)} kg',
            ),
            _buildReadOnlyField(
              'Frecuencia de Incremento',
              '$_incrementFrequency ${_unit == ProgressionUnit.session ? 'sesiones' : 'semanas'}',
            ),
            _buildReadOnlyField('Longitud del Ciclo', '$_cycleLength semanas'),
            _buildReadOnlyField(
              'Semana de Deload',
              _deloadWeek == 0 ? 'Sin deload' : 'Semana $_deloadWeek',
            ),
            _buildReadOnlyField(
              'Porcentaje de Deload',
              '${(_deloadPercentage * 100).toStringAsFixed(0)}%',
            ),
            if (_customParameters.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                'Parámetros Personalizados',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ..._customParameters.entries.map(
                (entry) =>
                    _buildReadOnlyField(entry.key, entry.value.toString()),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildManualConfiguration() {
    // Aquí iría la configuración manual original
    // Por ahora, mostramos un placeholder
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Configuración Manual',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              'La configuración manual avanzada estará disponible próximamente.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () {
                setState(() {
                  _useTemplates = true;
                });
              },
              icon: const Icon(Icons.auto_awesome),
              label: const Text('Usar Plantillas'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReadOnlyField(String label, String value) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
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

  Future<void> _saveProgression() async {
    if (_useTemplates && _selectedTemplate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor selecciona una plantilla'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final progressionNotifier = ref.read(
        progressionNotifierProvider.notifier,
      );

      await progressionNotifier.setProgression(
        type: widget.progressionType,
        unit: _unit,
        primaryTarget: _primaryTarget,
        secondaryTarget: _secondaryTarget,
        incrementValue: _incrementValue,
        incrementFrequency: _incrementFrequency,
        cycleLength: _cycleLength,
        deloadWeek: _deloadWeek,
        deloadPercentage: _deloadPercentage,
        customParameters: _customParameters,
      );

      LoggingService.instance
          .info('Global progression configuration saved successfully', {
            'type': widget.progressionType.name,
            'template': _selectedTemplate?.id,
            'useTemplates': _useTemplates,
          });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _useTemplates
                  ? 'Progresión configurada exitosamente con plantilla: ${_selectedTemplate!.name}'
                  : 'Progresión configurada exitosamente',
            ),
            backgroundColor: Colors.green,
          ),
        );

        context.pop();
      }
    } catch (e, stackTrace) {
      LoggingService.instance.error(
        'Error saving progression configuration',
        e,
        stackTrace,
        {'type': widget.progressionType.name},
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar la progresión: $e'),
            backgroundColor: Colors.red,
          ),
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
