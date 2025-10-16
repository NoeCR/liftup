import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:liftly/features/progression/notifiers/progression_notifier.dart';

import '../../../common/enums/progression_type_enum.dart';
import '../../../core/logging/logging.dart';
import '../../exercise/models/exercise.dart';
import '../configs/adaptive_increment_config.dart';
import '../configs/training_objective.dart';
import '../models/progression_config.dart';
import '../widgets/improved_preset_selector.dart';
import 'advanced_progression_config_page.dart';

class ProgressionConfigurationPage extends ConsumerStatefulWidget {
  final ProgressionType progressionType;

  const ProgressionConfigurationPage({super.key, required this.progressionType});

  @override
  ConsumerState<ProgressionConfigurationPage> createState() => _ProgressionConfigurationPageState();
}

class _ProgressionConfigurationPageState extends ConsumerState<ProgressionConfigurationPage> {
  final _formKey = GlobalKey<FormState>();

  // Valores por defecto
  ProgressionUnit _unit = ProgressionUnit.session;
  ProgressionTarget _primaryTarget = ProgressionTarget.weight;
  ProgressionTarget? _secondaryTarget;
  double _incrementValue = 2.5;
  int _incrementFrequency = 1;
  int _cycleLength = 4;
  int _deloadWeek = 4;
  double _deloadPercentage = 0.9;
  int _minReps = 6;
  int _maxReps = 12;
  int _baseSets = 3;

  // Custom parameters
  final Map<String, dynamic> _customParameters = {};

  // Configuración seleccionada (preset o manual)
  ProgressionConfig? _selectedConfig;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadTemplateDefaults();
  }

  void _loadTemplateDefaults() {
    // Load defaults based on progression type
    switch (widget.progressionType) {
      case ProgressionType.linear:
        _incrementValue = 2.5;
        _incrementFrequency = 1;
        _cycleLength = 4;
        _deloadWeek = 4;
        _deloadPercentage = 0.9;
        break;
      case ProgressionType.undulating:
        _incrementValue = 2.5;
        _incrementFrequency = 2;
        _cycleLength = 6;
        _deloadWeek = 6;
        _deloadPercentage = 0.85;
        _secondaryTarget = ProgressionTarget.reps;
        break;
      case ProgressionType.stepped:
        _incrementValue = 2.5;
        _incrementFrequency = 1;
        _cycleLength = 4;
        _deloadWeek = 4;
        _deloadPercentage = 0.8;
        _unit = ProgressionUnit.week;
        break;
      case ProgressionType.double:
        _incrementValue = 2.5;
        _incrementFrequency = 1;
        _cycleLength = 6;
        _deloadWeek = 6;
        _deloadPercentage = 0.9;
        _primaryTarget = ProgressionTarget.reps;
        _secondaryTarget = ProgressionTarget.weight;
        // Derivar valores por objetivo de entrenamiento
        _deriveRepsByObjective();
        break;
      case ProgressionType.wave:
        _incrementValue = 5.0;
        _incrementFrequency = 3;
        _cycleLength = 9;
        _deloadWeek = 3;
        _deloadPercentage = 0.7;
        _unit = ProgressionUnit.week;
        _secondaryTarget = ProgressionTarget.volume;
        break;
      case ProgressionType.static:
        _incrementValue = 0.0;
        _incrementFrequency = 0;
        _cycleLength = 4;
        _deloadWeek = 0;
        _deloadPercentage = 1.0;
        _primaryTarget = ProgressionTarget.volume;
        break;
      case ProgressionType.reverse:
        _incrementValue = -2.5;
        _incrementFrequency = 1;
        _cycleLength = 6;
        _deloadWeek = 0;
        _deloadPercentage = 1.0;
        _unit = ProgressionUnit.week;
        _secondaryTarget = ProgressionTarget.reps;
        break;
      default:
        break;
    }
  }

  String _getProgressionTypeDisplayName(ProgressionType type) {
    switch (type) {
      case ProgressionType.linear:
        return 'Progresión Lineal';
      case ProgressionType.stepped:
        return 'Progresión Escalonada';
      case ProgressionType.double:
        return 'Progresión Doble';
      case ProgressionType.undulating:
        return 'Progresión Ondulante';
      case ProgressionType.autoregulated:
        return 'Progresión Autoregulada';
      case ProgressionType.doubleFactor:
        return 'Progresión Doble Factor';
      case ProgressionType.wave:
        return 'Progresión por Oleadas';
      case ProgressionType.overload:
        return 'Progresión por Sobrecarga';
      case ProgressionType.static:
        return 'Progresión Estática';
      case ProgressionType.reverse:
        return 'Progresión Inversa';
      default:
        return type.name;
    }
  }

  String _getObjectiveDisplayName(String objective) {
    switch (objective.toLowerCase()) {
      case 'hypertrophy':
        return 'Hipertrofia';
      case 'strength':
        return 'Fuerza';
      case 'endurance':
        return 'Resistencia';
      case 'power':
        return 'Potencia';
      default:
        return objective;
    }
  }

  String _getTargetDisplayName(ProgressionTarget target) {
    switch (target) {
      case ProgressionTarget.weight:
        return 'Peso';
      case ProgressionTarget.reps:
        return 'Repeticiones';
      case ProgressionTarget.volume:
        return 'Volumen';
      case ProgressionTarget.intensity:
        return 'Intensidad';
      default:
        return target.name;
    }
  }

  void _navigateToAdvancedConfig() {
    if (_selectedConfig != null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder:
              (context) => AdvancedProgressionConfigPage(
                preset: _selectedConfig!,
                onConfigSaved: (modifiedConfig) {
                  setState(() {
                    _selectedConfig = modifiedConfig;
                    // Actualizar los valores locales con la configuración modificada
                    _incrementValue = modifiedConfig.incrementValue;
                    _incrementFrequency = modifiedConfig.incrementFrequency;
                    _cycleLength = modifiedConfig.cycleLength;
                    _deloadWeek = modifiedConfig.deloadWeek;
                    _deloadPercentage = modifiedConfig.deloadPercentage;
                    _unit = modifiedConfig.unit;
                    _minReps = modifiedConfig.minReps;
                    _maxReps = modifiedConfig.maxReps;
                    _baseSets = modifiedConfig.baseSets;
                    _customParameters.clear();
                    _customParameters.addAll(modifiedConfig.customParameters);
                  });
                },
              ),
        ),
      );
    }
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
          IconButton(icon: const Icon(Icons.restore), tooltip: 'Restaurar plantillas', onPressed: _restoreTemplates),
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
              // Progression information
              _buildProgressionInfo(),
              const SizedBox(height: 24),

              // Basic configuration
              _buildBasicConfiguration(),
              const SizedBox(height: 24),

              // Advanced configuration
              _buildAdvancedConfiguration(),
              const SizedBox(height: 24),

              // Custom parameters
              _buildCustomParameters(),
              const SizedBox(height: 24),

              // Save button
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
            Text(
              'progression.basicConfiguration'.tr(),
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Progression unit
            DropdownButtonFormField<ProgressionUnit>(
              value: _unit,
              decoration: InputDecoration(
                labelText: 'progression.progressionUnit'.tr(),
                helperText: 'progression.progressionUnitHelper'.tr(),
              ),
              items:
                  ProgressionUnit.values
                      .map((unit) => DropdownMenuItem(value: unit, child: Text(context.tr(unit.displayNameKey))))
                      .toList(),
              onChanged: (value) {
                setState(() {
                  _unit = value!;
                });
              },
            ),
            const SizedBox(height: 16),

            // Solo mostrar selectores de objetivo si no hay preset seleccionado
            if (_selectedConfig == null) ...[
              // Objetivo principal
              DropdownButtonFormField<ProgressionTarget>(
                value: _primaryTarget,
                decoration: InputDecoration(
                  labelText: 'progression.primaryTarget'.tr(),
                  helperText: 'progression.primaryTargetHelper'.tr(),
                ),
                items:
                    ProgressionTarget.values
                        .map(
                          (target) => DropdownMenuItem(value: target, child: Text(context.tr(target.displayNameKey))),
                        )
                        .toList(),
                onChanged: (value) {
                  setState(() {
                    _primaryTarget = value!;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Objetivo secundario (opcional)
              DropdownButtonFormField<ProgressionTarget?>(
                value: _secondaryTarget,
                decoration: InputDecoration(
                  labelText: 'progression.secondaryTarget'.tr(),
                  helperText: 'progression.secondaryTargetHelper'.tr(),
                ),
                items: [
                  DropdownMenuItem<ProgressionTarget?>(value: null, child: Text('progression.none'.tr())),
                  ...ProgressionTarget.values.map(
                    (target) => DropdownMenuItem(value: target, child: Text(context.tr(target.displayNameKey))),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _secondaryTarget = value;
                  });
                },
              ),
            ] else ...[
              // Mostrar información del preset seleccionado
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.2)),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.check_circle, color: theme.colorScheme.primary, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Preset seleccionado: ${_getObjectiveDisplayName(_selectedConfig!.getTrainingObjective())}',
                                style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                              ),
                              Text(
                                'Objetivos: ${_getTargetDisplayName(_selectedConfig!.primaryTarget)} → ${_selectedConfig!.secondaryTarget != null ? _getTargetDisplayName(_selectedConfig!.secondaryTarget!) : 'Ninguno'}',
                                style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _navigateToAdvancedConfig,
                        icon: const Icon(Icons.tune),
                        label: const Text('Configuración Avanzada'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAdvancedConfiguration() {
    return ImprovedPresetSelector(
      currentConfig: _selectedConfig,
      title: 'Configuración de Progresión - ${_getProgressionTypeDisplayName(widget.progressionType)}',
      filterByType: widget.progressionType, // Filtrar por el tipo de progresión actual
      onConfigSelected: (config) {
        setState(() {
          _selectedConfig = config;
          // Actualizar los valores locales con la configuración seleccionada
          _incrementValue = config.incrementValue;
          _incrementFrequency = config.incrementFrequency;
          _cycleLength = config.cycleLength;
          _deloadWeek = config.deloadWeek;
          _deloadPercentage = config.deloadPercentage;
          _unit = config.unit;
          _minReps = config.minReps;
          _maxReps = config.maxReps;
          _baseSets = config.baseSets;
          _customParameters.clear();
          _customParameters.addAll(config.customParameters);
        });
      },
    );
  }

  Widget _buildCustomParameters() {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'progression.customParameters'.tr(),
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'progression.customParameters'.tr(),
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 16),

            // Adaptive experience switch
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Experiencia adaptativa'),
              subtitle: const Text('Ajusta los incrementos según ciclos/tiempo'),
              value:
                  (_customParameters['adaptive_experience'] as bool?) ??
                  false, // Experiencia derivada automáticamente del nivel del ejercicio
              onChanged: (v) {
                setState(() {
                  _customParameters['adaptive_experience'] = v;
                });
              },
            ),
            const SizedBox(height: 12),

            // Defaults por tipo de ejercicio (multi/isolation)
            ..._buildPerTypeDefaults(),
            const SizedBox(height: 16),

            // Parámetros específicos por tipo de progresión
            ..._buildTypeSpecificParameters(),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildPerTypeDefaults() {
    final theme = Theme.of(context);
    InputDecoration deco(String label, [String? helper]) =>
        InputDecoration(labelText: label, helperText: helper, border: const OutlineInputBorder());

    return [
      Text('Valores por tipo de ejercicio', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      // MULTI-JOINT
      Text('Multi-joint', style: theme.textTheme.bodyMedium),
      const SizedBox(height: 8),
      Row(
        children: [
          Expanded(
            child: TextFormField(
              initialValue:
                  (_customParameters['multi_increment_min'] ?? '2.5')
                      .toString(), // Campo oculto: valores derivados de tablas por objetivo
              decoration: deco('multi_increment_min', 'kg mínimo por incremento'),
              keyboardType: TextInputType.number,
              onSaved: (v) => _customParameters['multi_increment_min'] = double.tryParse(v!.trim()),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextFormField(
              initialValue:
                  (_customParameters['multi_increment_max'] ?? '5.0')
                      .toString(), // Campo oculto: valores derivados de tablas por objetivo
              decoration: deco('multi_increment_max', 'kg máximo por incremento'),
              keyboardType: TextInputType.number,
              onSaved: (v) => _customParameters['multi_increment_max'] = double.tryParse(v!.trim()),
            ),
          ),
        ],
      ),
      const SizedBox(height: 8),
      Row(
        children: [
          Expanded(
            child: TextFormField(
              initialValue:
                  (_customParameters['multi_reps_min'] ?? '15')
                      .toString(), // Campo oculto: valores derivados de tablas por objetivo
              decoration: deco('multi_reps_min', 'reps mínimas'),
              keyboardType: TextInputType.number,
              onSaved: (v) => _customParameters['multi_reps_min'] = int.tryParse(v!.trim()),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextFormField(
              initialValue:
                  (_customParameters['multi_reps_max'] ?? '20')
                      .toString(), // Campo oculto: valores derivados de tablas por objetivo
              decoration: deco('multi_reps_max', 'reps máximas'),
              keyboardType: TextInputType.number,
              onSaved: (v) => _customParameters['multi_reps_max'] = int.tryParse(v!.trim()),
            ),
          ),
        ],
      ),
      const SizedBox(height: 16),
      // ISOLATION
      Text('Isolation', style: theme.textTheme.bodyMedium),
      const SizedBox(height: 8),
      Row(
        children: [
          Expanded(
            child: TextFormField(
              initialValue:
                  (_customParameters['iso_increment_min'] ?? '1.25')
                      .toString(), // Campo oculto: valores derivados de tablas por objetivo
              decoration: deco('iso_increment_min', 'kg mínimo por incremento'),
              keyboardType: TextInputType.number,
              onSaved: (v) => _customParameters['iso_increment_min'] = double.tryParse(v!.trim()),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextFormField(
              initialValue:
                  (_customParameters['iso_increment_max'] ?? '2.5')
                      .toString(), // Campo oculto: valores derivados de tablas por objetivo
              decoration: deco('iso_increment_max', 'kg máximo por incremento'),
              keyboardType: TextInputType.number,
              onSaved: (v) => _customParameters['iso_increment_max'] = double.tryParse(v!.trim()),
            ),
          ),
        ],
      ),
      const SizedBox(height: 8),
      Row(
        children: [
          Expanded(
            child: TextFormField(
              initialValue:
                  (_customParameters['iso_reps_min'] ?? '8')
                      .toString(), // Campo oculto: valores derivados de tablas por objetivo
              decoration: deco('iso_reps_min', 'reps mínimas'),
              keyboardType: TextInputType.number,
              onSaved: (v) => _customParameters['iso_reps_min'] = int.tryParse(v!.trim()),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextFormField(
              initialValue:
                  (_customParameters['iso_reps_max'] ?? '12')
                      .toString(), // Campo oculto: valores derivados de tablas por objetivo
              decoration: deco('iso_reps_max', 'reps máximas'),
              keyboardType: TextInputType.number,
              onSaved: (v) => _customParameters['iso_reps_max'] = int.tryParse(v!.trim()),
            ),
          ),
        ],
      ),
      const SizedBox(height: 16),
      // Commons
      Row(
        children: [
          Expanded(
            child: TextFormField(
              initialValue:
                  (_customParameters['sets_min'] ?? '')
                      .toString(), // Campo oculto: valores derivados de tablas por objetivo
              decoration: deco('sets_min', 'series mínimas por ejercicio'),
              keyboardType: TextInputType.number,
              onSaved: (v) => _customParameters['sets_min'] = int.tryParse((v ?? '').trim()),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextFormField(
              initialValue:
                  (_customParameters['sets_max'] ?? '')
                      .toString(), // Campo oculto: valores derivados de tablas por objetivo
              decoration: deco('sets_max', 'series máximas por ejercicio'),
              keyboardType: TextInputType.number,
              onSaved: (v) => _customParameters['sets_max'] = int.tryParse((v ?? '').trim()),
            ),
          ),
        ],
      ),
    ];
  }

  List<Widget> _buildTypeSpecificParameters() {
    final theme = Theme.of(context);
    final widgets = <Widget>[];

    switch (widget.progressionType) {
      case ProgressionType.double:
        widgets.addAll([
          TextFormField(
            initialValue:
                _customParameters['min_reps']?.toString() ?? '8', // Valores derivados automáticamente por objetivo
            decoration: InputDecoration(
              labelText: 'progression.minReps'.tr(),
              helperText: 'progression.minRepsHelper'.tr(),
            ),
            keyboardType: TextInputType.number,
            onSaved: (value) {
              _customParameters['min_reps'] = int.parse(value!);
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            initialValue:
                _customParameters['max_reps']?.toString() ?? '12', // Valores derivados automáticamente por objetivo
            decoration: InputDecoration(
              labelText: 'progression.maxReps'.tr(),
              helperText: 'progression.maxRepsHelper'.tr(),
            ),
            keyboardType: TextInputType.number,
            onSaved: (value) {
              _customParameters['max_reps'] = int.parse(value!);
            },
          ),
        ]);
        break;
      case ProgressionType.autoregulated:
        widgets.addAll([
          TextFormField(
            initialValue: _customParameters['target_rpe']?.toString() ?? _getTargetRPEByObjective().toString(),
            decoration: const InputDecoration(
              labelText: 'RPE objetivo',
              helperText: 'Percepción de esfuerzo objetivo (1-10)',
            ),
            keyboardType: TextInputType.number,
            onSaved: (value) {
              _customParameters['target_rpe'] = int.parse(value!);
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            initialValue: _customParameters['rpe_range']?.toString() ?? _getRPERangeByObjective().toString(),
            decoration: const InputDecoration(labelText: 'Rango de RPE', helperText: 'Variación permitida en el RPE'),
            keyboardType: TextInputType.number,
            onSaved: (value) {
              _customParameters['rpe_range'] = int.parse(value!);
            },
          ),
        ]);
        break;
      default:
        widgets.add(
          Text(
            'No hay parámetros personalizados para este tipo de progresión',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontStyle: FontStyle.italic,
            ),
          ),
        );
    }

    return widgets;
  }

  Future<void> _restoreTemplates() async {
    try {
      final progressionNotifier = ref.read(progressionNotifierProvider.notifier);
      await progressionNotifier.restoreTemplates();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Plantillas de progresión restauradas exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error restaurando plantillas: $e'), backgroundColor: Colors.red));
      }
    }
  }

  Future<void> _saveProgression() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    _formKey.currentState!.save();
    setState(() {
      _isLoading = true;
    });

    try {
      final progressionNotifier = ref.read(progressionNotifierProvider.notifier);

      // Si hay un preset seleccionado, usar sus valores; si no, usar los valores manuales
      final configToSave =
          _selectedConfig ??
          ProgressionConfig(
            id: '',
            isGlobal: true,
            type: widget.progressionType,
            unit: _unit,
            primaryTarget: _primaryTarget,
            secondaryTarget: _secondaryTarget,
            incrementValue: _incrementValue,
            incrementFrequency: _incrementFrequency,
            cycleLength: _cycleLength,
            deloadWeek: _deloadWeek,
            deloadPercentage: _deloadPercentage,
            minReps: _minReps,
            maxReps: _maxReps,
            baseSets: _baseSets,
            customParameters: _customParameters,
            startDate: DateTime.now(),
            isActive: true,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );

      await progressionNotifier.setProgressionConfig(configToSave);

      LoggingService.instance.info('Global progression configuration saved successfully', {
        'type': widget.progressionType.name,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'progression.progressionConfiguredSuccessfully'.tr(
                namedArgs: {'type': context.tr(widget.progressionType.displayNameKey)},
              ),
            ),
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

  /// Deriva los valores de reps basado en el objetivo de entrenamiento
  void _deriveRepsByObjective() {
    // Crear configuración temporal para derivar objetivo
    final tempConfig = ProgressionConfig(
      id: 'temp',
      isGlobal: true,
      type: widget.progressionType,
      unit: _unit,
      primaryTarget: _primaryTarget,
      secondaryTarget: _secondaryTarget,
      incrementValue: 0,
      incrementFrequency: 1,
      cycleLength: 4,
      deloadWeek: 0,
      deloadPercentage: 0.9,
      customParameters: {},
      startDate: DateTime.now(),
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      minReps: 8,
      maxReps: 12,
      baseSets: 3,
    );

    // Crear ejercicio temporal para obtener valores adaptativos
    final tempExercise = Exercise(
      id: 'temp',
      name: 'Temporary Exercise',
      description: '',
      imageUrl: '',
      muscleGroups: const [],
      tips: const [],
      commonMistakes: const [],
      category: ExerciseCategory.chest,
      difficulty: ExerciseDifficulty.intermediate,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      exerciseType: ExerciseType.multiJoint,
      loadType: LoadType.barbell,
    );

    // Obtener rango de reps por objetivo
    final objective = AdaptiveIncrementConfig.parseObjective(tempConfig.getTrainingObjective());
    // Los valores se derivan automáticamente del objetivo
    // No es necesario almacenarlos en customParameters
    AdaptiveIncrementConfig.getRepetitionsRange(tempExercise, objective: objective);
  }

  /// Obtiene el RPE objetivo basado en el objetivo de entrenamiento
  int _getTargetRPEByObjective() {
    // Crear configuración temporal para derivar objetivo
    final tempConfig = ProgressionConfig(
      id: 'temp',
      isGlobal: true,
      type: widget.progressionType,
      unit: _unit,
      primaryTarget: _primaryTarget,
      secondaryTarget: _secondaryTarget,
      incrementValue: 0,
      incrementFrequency: 1,
      cycleLength: 4,
      deloadWeek: 0,
      deloadPercentage: 0.9,
      customParameters: {},
      startDate: DateTime.now(),
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      minReps: 8,
      maxReps: 12,
      baseSets: 3,
    );

    final objective = AdaptiveIncrementConfig.parseObjective(tempConfig.getTrainingObjective());

    // RPE objetivo basado en investigación científica
    switch (objective) {
      case TrainingObjective.strength:
        return 8; // RPE alto para fuerza máxima
      case TrainingObjective.hypertrophy:
        return 7; // RPE moderado-alto para hipertrofia
      case TrainingObjective.endurance:
        return 6; // RPE moderado para resistencia
      case TrainingObjective.power:
        return 8; // RPE alto para potencia máxima
    }
  }

  /// Obtiene el rango de RPE basado en el objetivo de entrenamiento
  int _getRPERangeByObjective() {
    // Crear configuración temporal para derivar objetivo
    final tempConfig = ProgressionConfig(
      id: 'temp',
      isGlobal: true,
      type: widget.progressionType,
      unit: _unit,
      primaryTarget: _primaryTarget,
      secondaryTarget: _secondaryTarget,
      incrementValue: 0,
      incrementFrequency: 1,
      cycleLength: 4,
      deloadWeek: 0,
      deloadPercentage: 0.9,
      customParameters: {},
      startDate: DateTime.now(),
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      minReps: 8,
      maxReps: 12,
      baseSets: 3,
    );

    final objective = AdaptiveIncrementConfig.parseObjective(tempConfig.getTrainingObjective());

    // Rango de RPE basado en objetivo
    switch (objective) {
      case TrainingObjective.strength:
        return 1; // Rango estrecho para fuerza
      case TrainingObjective.hypertrophy:
        return 2; // Rango moderado para hipertrofia
      case TrainingObjective.endurance:
        return 3; // Rango amplio para resistencia
      case TrainingObjective.power:
        return 1; // Rango estrecho para potencia
    }
  }
}
