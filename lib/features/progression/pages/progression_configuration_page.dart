import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:liftly/features/progression/notifiers/progression_notifier.dart';
import '../../../common/enums/progression_type_enum.dart';
import '../../../core/logging/logging.dart';

class ProgressionConfigurationPage extends ConsumerStatefulWidget {
  final ProgressionType progressionType;

  const ProgressionConfigurationPage({
    super.key,
    required this.progressionType,
  });

  @override
  ConsumerState<ProgressionConfigurationPage> createState() =>
      _ProgressionConfigurationPageState();
}

class _ProgressionConfigurationPageState
    extends ConsumerState<ProgressionConfigurationPage> {
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

  // Custom parameters
  final Map<String, dynamic> _customParameters = {};

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
        _customParameters['min_reps'] = 8;
        _customParameters['max_reps'] = 12;
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
          IconButton(
            icon: const Icon(Icons.restore),
            tooltip: 'Restaurar plantillas',
            onPressed: _restoreTemplates,
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
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
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
                      .map(
                        (unit) => DropdownMenuItem(
                          value: unit,
                          child: Text(context.tr(unit.displayNameKey)),
                        ),
                      )
                      .toList(),
              onChanged: (value) {
                setState(() {
                  _unit = value!;
                });
              },
            ),
            const SizedBox(height: 16),

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
                        (target) => DropdownMenuItem(
                          value: target,
                          child: Text(context.tr(target.displayNameKey)),
                        ),
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
                DropdownMenuItem<ProgressionTarget?>(
                  value: null,
                  child: Text('progression.none'.tr()),
                ),
                ...ProgressionTarget.values.map(
                  (target) => DropdownMenuItem(
                    value: target,
                    child: Text(context.tr(target.displayNameKey)),
                  ),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  _secondaryTarget = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdvancedConfiguration() {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'progression.advancedConfiguration'.tr(),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Valor de incremento
            TextFormField(
              initialValue: _incrementValue.toString(),
              decoration: InputDecoration(
                labelText: 'progression.incrementValue'.tr(),
                helperText: 'progression.incrementValueHelper'.tr(),
                suffixText: 'kg',
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingresa un valor de incremento';
                }
                final parsed = double.tryParse(value);
                if (parsed == null) {
                  return 'Por favor ingresa un número válido';
                }
                return null;
              },
              onSaved: (value) {
                _incrementValue = double.parse(value!);
              },
            ),
            const SizedBox(height: 16),

            // Frecuencia de incremento
            TextFormField(
              initialValue: _incrementFrequency.toString(),
              decoration: InputDecoration(
                labelText: 'progression.incrementFrequency'.tr(),
                helperText: 'progression.incrementFrequencyHelper'.tr(),
                suffixText:
                    _unit == ProgressionUnit.session
                        ? 'progression.sessions'.tr()
                        : 'progression.weeks'.tr(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingresa una frecuencia';
                }
                final parsed = int.tryParse(value);
                if (parsed == null || parsed <= 0) {
                  return 'Por favor ingresa un número válido mayor a 0';
                }
                return null;
              },
              onSaved: (value) {
                _incrementFrequency = int.parse(value!);
              },
            ),
            const SizedBox(height: 16),

            // Longitud del ciclo
            TextFormField(
              initialValue: _cycleLength.toString(),
              decoration: InputDecoration(
                labelText: 'progression.cycleLength'.tr(),
                helperText: 'progression.cycleLengthHelper'.tr(),
                suffixText: 'progression.weeks'.tr(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingresa una longitud de ciclo';
                }
                final parsed = int.tryParse(value);
                if (parsed == null || parsed <= 0) {
                  return 'Por favor ingresa un número válido mayor a 0';
                }
                return null;
              },
              onSaved: (value) {
                _cycleLength = int.parse(value!);
              },
            ),
            const SizedBox(height: 16),

            // Semana de deload
            TextFormField(
              initialValue: _deloadWeek.toString(),
              decoration: InputDecoration(
                labelText: 'progression.deloadWeek'.tr(),
                helperText: 'progression.deloadWeekHelper'.tr(),
                suffixText: 'progression.week'.tr(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingresa una semana de deload';
                }
                final parsed = int.tryParse(value);
                if (parsed == null || parsed < 0) {
                  return 'Por favor ingresa un número válido mayor o igual a 0';
                }
                return null;
              },
              onSaved: (value) {
                _deloadWeek = int.parse(value!);
              },
            ),
            const SizedBox(height: 16),

            // Porcentaje de deload
            TextFormField(
              initialValue: (_deloadPercentage * 100).toString(),
              decoration: InputDecoration(
                labelText: 'progression.deloadPercentage'.tr(),
                helperText: 'progression.deloadPercentageHelper'.tr(),
                suffixText: '%',
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingresa un porcentaje de deload';
                }
                final parsed = double.tryParse(value);
                if (parsed == null || parsed <= 0 || parsed > 100) {
                  return 'Por favor ingresa un porcentaje válido entre 0 y 100';
                }
                return null;
              },
              onSaved: (value) {
                _deloadPercentage = double.parse(value!) / 100;
              },
            ),
          ],
        ),
      ),
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
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'progression.customParameters'.tr(),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),

            // Show type-specific parameters
            ..._buildTypeSpecificParameters(),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildTypeSpecificParameters() {
    final theme = Theme.of(context);
    final widgets = <Widget>[];

    switch (widget.progressionType) {
      case ProgressionType.double:
        widgets.addAll([
          TextFormField(
            initialValue: _customParameters['min_reps']?.toString() ?? '8',
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
            initialValue: _customParameters['max_reps']?.toString() ?? '12',
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
            initialValue: _customParameters['target_rpe']?.toString() ?? '8',
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
            initialValue: _customParameters['rpe_range']?.toString() ?? '2',
            decoration: const InputDecoration(
              labelText: 'Rango de RPE',
              helperText: 'Variación permitida en el RPE',
            ),
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
      final progressionNotifier = ref.read(
        progressionNotifierProvider.notifier,
      );
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error restaurando plantillas: $e'),
            backgroundColor: Colors.red,
          ),
        );
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

      LoggingService.instance.info(
        'Global progression configuration saved successfully',
        {'type': widget.progressionType.name},
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'progression.progressionConfiguredSuccessfully'.tr(
                namedArgs: {
                  'type': context.tr(widget.progressionType.displayNameKey),
                },
              ),
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
