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

class ProgressionConfigurationWithTemplates extends ConsumerStatefulWidget {
  final ProgressionType progressionType;

  const ProgressionConfigurationWithTemplates({super.key, required this.progressionType});

  @override
  ConsumerState<ProgressionConfigurationWithTemplates> createState() => _ProgressionConfigurationWithTemplatesState();
}

class _ProgressionConfigurationWithTemplatesState extends ConsumerState<ProgressionConfigurationWithTemplates> {
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

  @override
  void initState() {
    super.initState();
    _initializeDefaultTemplate();
  }

  void _initializeDefaultTemplate() {
    ProgressionTemplateService.initializeTemplates();
    final templates = ProgressionTemplateService.getTemplatesForType(widget.progressionType);
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
        title: Text('${'progression.configureProgression'.tr()} ${context.tr(widget.progressionType.displayNameKey)}'),
        backgroundColor: colorScheme.surface,
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveProgression,
            child:
                _isLoading
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
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

              // Selector de plantillas (reemplaza la configuración avanzada)
              ProgressionTemplateSelector(progressionType: widget.progressionType, onTemplateSelected: _applyTemplate),
              const SizedBox(height: 24),

              // Configuración básica (solo lo esencial)
              _buildBasicConfiguration(),
              const SizedBox(height: 24),

              // Botón de guardar
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _isLoading ? null : _saveProgression,
                  icon:
                      _isLoading
                          ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Icon(Icons.save),
                  label: Text(_isLoading ? 'progression.saving'.tr() : 'progression.saveProgression'.tr()),
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
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text('progression.globalProgressionDescription'.tr(), style: theme.textTheme.bodyMedium),
            const SizedBox(height: 4),
            Text(
              '${'progression.types.${widget.progressionType.name}'.tr()}: ${context.tr(widget.progressionType.displayNameKey)}',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 4),
            Text(
              'progression.types.${widget.progressionType.name}Description'.tr(),
              style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicConfiguration() {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Configuración Básica', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(
              'Estos valores se configuran automáticamente según la plantilla seleccionada',
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 16),

            // Mostrar valores actuales (solo lectura)
            _buildReadOnlyField('Unidad de Progresión', _unit.displayNameKey.tr()),
            _buildReadOnlyField('Objetivo Principal', _primaryTarget.displayNameKey.tr()),
            if (_secondaryTarget != null)
              _buildReadOnlyField('Objetivo Secundario', _secondaryTarget!.displayNameKey.tr()),
            _buildReadOnlyField('Valor de Incremento', '${_incrementValue.toStringAsFixed(1)} kg'),
            _buildReadOnlyField(
              'Frecuencia de Incremento',
              '$_incrementFrequency ${_unit == ProgressionUnit.session ? 'sesiones' : 'semanas'}',
            ),
            _buildReadOnlyField('Longitud del Ciclo', '$_cycleLength semanas'),
            _buildReadOnlyField('Semana de Deload', _deloadWeek == 0 ? 'Sin deload' : 'Semana $_deloadWeek'),
            _buildReadOnlyField('Porcentaje de Deload', '${(_deloadPercentage * 100).toStringAsFixed(0)}%'),
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
            width: 120,
            child: Text(label, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
          ),
          const SizedBox(width: 16),
          Expanded(child: Text(value, style: theme.textTheme.bodyMedium)),
        ],
      ),
    );
  }

  Future<void> _saveProgression() async {
    if (_selectedTemplate == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Por favor selecciona una plantilla'), backgroundColor: Colors.red));
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final progressionNotifier = ref.read(progressionNotifierProvider.notifier);

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

      LoggingService.instance.info('Global progression configuration saved successfully', {
        'type': widget.progressionType.name,
        'template': _selectedTemplate!.id,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Progresión configurada exitosamente con plantilla: ${_selectedTemplate!.name}'),
            backgroundColor: Colors.green,
          ),
        );

        context.pop();
      }
    } catch (e, stackTrace) {
      LoggingService.instance.error('Error saving progression configuration', e, stackTrace, {
        'type': widget.progressionType.name,
      });

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al guardar la progresión: $e'), backgroundColor: Colors.red));
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
