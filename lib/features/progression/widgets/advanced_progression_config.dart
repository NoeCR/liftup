import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import '../configs/preset_progression_configs.dart';
import '../models/progression_config.dart';
import '../../../common/enums/progression_type_enum.dart';

/// Enum para los modos de configuración
enum ConfigurationMode { preset, manual }

extension ConfigurationModeExtension on ConfigurationMode {
  String get displayName {
    switch (this) {
      case ConfigurationMode.preset:
        return 'advancedConfig.modeSelector.preset'.tr();
      case ConfigurationMode.manual:
        return 'advancedConfig.modeSelector.manual'.tr();
    }
  }
}

/// Widget para configuración avanzada de progresión con presets filtrados
///
/// Permite seleccionar entre presets predefinidos (hipertrofia, fuerza, etc.)
/// o configuración manual para la estrategia de progresión seleccionada.
class AdvancedProgressionConfig extends ConsumerStatefulWidget {
  final ProgressionType progressionType;
  final ProgressionConfig? initialConfig;
  final Function(ProgressionConfig) onConfigChanged;
  final bool showManualOptions;

  const AdvancedProgressionConfig({
    super.key,
    required this.progressionType,
    this.initialConfig,
    required this.onConfigChanged,
    this.showManualOptions = true,
  });

  @override
  ConsumerState<AdvancedProgressionConfig> createState() => _AdvancedProgressionConfigState();
}

class _AdvancedProgressionConfigState extends ConsumerState<AdvancedProgressionConfig> {
  ConfigurationMode _configurationMode = ConfigurationMode.preset;
  ProgressionConfig? _selectedPreset;
  ProgressionConfig? _customConfig;

  // Campos para configuración manual
  double _incrementValue = 2.5;
  int _incrementFrequency = 1;
  int _cycleLength = 4;
  int _deloadWeek = 4;
  double _deloadPercentage = 0.8;
  ProgressionUnit _unit = ProgressionUnit.session;
  ProgressionTarget _primaryTarget = ProgressionTarget.volume;
  ProgressionTarget? _secondaryTarget = ProgressionTarget.reps;
  int _minReps = 8;
  int _maxReps = 12;
  int _baseSets = 3;

  @override
  void initState() {
    super.initState();
    _customConfig = widget.initialConfig;

    // Si hay una configuración inicial, verificar si coincide con algún preset
    if (widget.initialConfig != null) {
      _checkIfMatchesPreset(widget.initialConfig!);
      _loadConfigValues(widget.initialConfig!);
    }
  }

  void _checkIfMatchesPreset(ProgressionConfig config) {
    final presets = PresetProgressionConfigs.getPresetsForType(widget.progressionType);

    for (final preset in presets) {
      if (_configsMatch(config, preset)) {
        setState(() {
          _selectedPreset = preset;
          _configurationMode = ConfigurationMode.preset;
        });
        return;
      }
    }

    // Si no coincide con ningún preset, usar configuración manual
    setState(() {
      _configurationMode = ConfigurationMode.manual;
    });
  }

  bool _configsMatch(ProgressionConfig config1, ProgressionConfig config2) {
    return config1.type == config2.type &&
        config1.primaryTarget == config2.primaryTarget &&
        config1.secondaryTarget == config2.secondaryTarget &&
        config1.minReps == config2.minReps &&
        config1.maxReps == config2.maxReps &&
        config1.baseSets == config2.baseSets;
  }

  void _loadConfigValues(ProgressionConfig config) {
    _incrementValue = config.incrementValue;
    _incrementFrequency = config.incrementFrequency;
    _cycleLength = config.cycleLength;
    _deloadWeek = config.deloadWeek;
    _deloadPercentage = config.deloadPercentage;
    _unit = config.unit;
    _primaryTarget = config.primaryTarget;
    _secondaryTarget = config.secondaryTarget;
    _minReps = config.minReps;
    _maxReps = config.maxReps;
    _baseSets = config.baseSets;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final presets = PresetProgressionConfigs.getPresetsForType(widget.progressionType);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Título de la sección
        Text('advancedConfig.title'.tr(), style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),

        // Selector de modo (Preset vs Manual)
        _buildModeSelector(),
        const SizedBox(height: 16),

        // Contenido según el modo seleccionado
        if (_configurationMode == ConfigurationMode.preset) ...[
          // Selector de presets filtrados
          if (presets.isNotEmpty) ...[
            _buildPresetSelector(presets),
            const SizedBox(height: 16),
            if (_selectedPreset != null) ...[_buildSelectedPresetDescription()],
          ] else ...[
            // No hay presets para este tipo de progresión
            _buildNoPresetsMessage(),
          ],
        ] else ...[
          // Configuración manual
          _buildManualConfiguration(),
        ],
      ],
    );
  }

  /// Selector entre modo preset y manual
  Widget _buildModeSelector() {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'advancedConfig.modeSelector.title'.tr(),
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<ConfigurationMode>(
              value: _configurationMode,
              decoration: InputDecoration(
                hintText: 'advancedConfig.modeSelector.hint'.tr(),
                border: const OutlineInputBorder(),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: [
                DropdownMenuItem(
                  value: ConfigurationMode.preset,
                  child: Row(
                    children: [
                      Icon(Icons.settings_applications, size: 20, color: theme.colorScheme.primary),
                      const SizedBox(width: 8),
                      Text(ConfigurationMode.preset.displayName),
                    ],
                  ),
                ),
                if (widget.showManualOptions)
                  DropdownMenuItem(
                    value: ConfigurationMode.manual,
                    child: Row(
                      children: [
                        Icon(Icons.tune, size: 20, color: theme.colorScheme.primary),
                        const SizedBox(width: 8),
                        Text(ConfigurationMode.manual.displayName),
                      ],
                    ),
                  ),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _configurationMode = value;
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Selector de presets filtrados por tipo de progresión
  Widget _buildPresetSelector(List<ProgressionConfig> presets) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'advancedConfig.presetSelector.title'.tr(),
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            ...presets.map((preset) => _buildPresetOption(preset)),
          ],
        ),
      ),
    );
  }

  /// Opción individual de preset
  Widget _buildPresetOption(ProgressionConfig preset) {
    final theme = Theme.of(context);
    final metadata = PresetProgressionConfigs.getPresetMetadata(preset);
    final isSelected = _selectedPreset?.id == preset.id;

    return Card(
      color: isSelected ? theme.colorScheme.primaryContainer : null,
      child: ListTile(
        title: Text(metadata['title']),
        subtitle: Text(metadata['description']),
        leading: Radio<ProgressionConfig>(
          value: preset,
          groupValue: _selectedPreset,
          onChanged: (value) {
            setState(() {
              _selectedPreset = value;
            });
            widget.onConfigChanged(value!);
          },
        ),
        onTap: () {
          setState(() {
            _selectedPreset = preset;
          });
          widget.onConfigChanged(preset);
        },
      ),
    );
  }

  /// Descripción del preset seleccionado
  Widget _buildSelectedPresetDescription() {
    final theme = Theme.of(context);
    final metadata = PresetProgressionConfigs.getPresetMetadata(_selectedPreset!);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'advancedConfig.presetDescription.title'.tr(),
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Text(metadata['description'], style: theme.textTheme.bodyMedium),
            const SizedBox(height: 12),
            ...(metadata['key_points'] as List).map(
              (point) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [const Text('• '), Expanded(child: Text(point))],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Mensaje cuando no hay presets disponibles
  Widget _buildNoPresetsMessage() {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(Icons.info_outline, size: 48, color: theme.colorScheme.primary),
            const SizedBox(height: 12),
            Text(
              'advancedConfig.noPresets.title'.tr(),
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              'advancedConfig.noPresets.message'.tr(
                namedArgs: {'progressionType': widget.progressionType.displayNameKey.tr()},
              ),
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Configuración manual
  Widget _buildManualConfiguration() {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'advancedConfig.manualConfig.title'.tr(),
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),

            // Valor de incremento
            _buildNumberField(
              label: 'advancedConfig.manualConfig.incrementValue'.tr(),
              value: _incrementValue,
              onChanged: (value) {
                setState(() {
                  _incrementValue = value;
                });
                _updateCustomConfig();
              },
            ),

            // Frecuencia de incremento
            _buildNumberField(
              label: 'advancedConfig.manualConfig.incrementFrequency'.tr(),
              value: _incrementFrequency.toDouble(),
              onChanged: (value) {
                setState(() {
                  _incrementFrequency = value.toInt();
                });
                _updateCustomConfig();
              },
              isInteger: true,
            ),

            // Longitud del ciclo
            _buildNumberField(
              label: 'advancedConfig.manualConfig.cycleLength'.tr(),
              value: _cycleLength.toDouble(),
              onChanged: (value) {
                setState(() {
                  _cycleLength = value.toInt();
                });
                _updateCustomConfig();
              },
              isInteger: true,
            ),

            // Semana de deload
            _buildNumberField(
              label: 'advancedConfig.manualConfig.deloadWeek'.tr(),
              value: _deloadWeek.toDouble(),
              onChanged: (value) {
                setState(() {
                  _deloadWeek = value.toInt();
                });
                _updateCustomConfig();
              },
              isInteger: true,
            ),

            // Porcentaje de deload
            _buildNumberField(
              label: 'advancedConfig.manualConfig.deloadPercentage'.tr(),
              value: _deloadPercentage,
              onChanged: (value) {
                setState(() {
                  _deloadPercentage = value;
                });
                _updateCustomConfig();
              },
              min: 0.1,
              max: 1.0,
            ),

            // Repeticiones mínimas
            _buildNumberField(
              label: 'advancedConfig.manualConfig.minReps'.tr(),
              value: _minReps.toDouble(),
              onChanged: (value) {
                setState(() {
                  _minReps = value.toInt();
                });
                _updateCustomConfig();
              },
              isInteger: true,
            ),

            // Repeticiones máximas
            _buildNumberField(
              label: 'advancedConfig.manualConfig.maxReps'.tr(),
              value: _maxReps.toDouble(),
              onChanged: (value) {
                setState(() {
                  _maxReps = value.toInt();
                });
                _updateCustomConfig();
              },
              isInteger: true,
            ),

            // Series base
            _buildNumberField(
              label: 'advancedConfig.manualConfig.baseSets'.tr(),
              value: _baseSets.toDouble(),
              onChanged: (value) {
                setState(() {
                  _baseSets = value.toInt();
                });
                _updateCustomConfig();
              },
              isInteger: true,
            ),
          ],
        ),
      ),
    );
  }

  /// Campo numérico reutilizable
  Widget _buildNumberField({
    required String label,
    required double value,
    required Function(double) onChanged,
    bool isInteger = false,
    double? min,
    double? max,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        initialValue: isInteger ? value.toInt().toString() : value.toString(),
        decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
        keyboardType: TextInputType.number,
        onChanged: (text) {
          final parsed = double.tryParse(text);
          if (parsed != null) {
            if (min != null && parsed < min) return;
            if (max != null && parsed > max) return;
            onChanged(parsed);
          }
        },
      ),
    );
  }

  /// Actualiza la configuración personalizada
  void _updateCustomConfig() {
    final config = ProgressionConfig(
      id: _customConfig?.id ?? '',
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
      customParameters: const {},
      startDate: DateTime.now(),
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      minReps: _minReps,
      maxReps: _maxReps,
      baseSets: _baseSets,
    );

    setState(() {
      _customConfig = config;
    });

    widget.onConfigChanged(config);
  }
}
