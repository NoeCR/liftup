import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../common/enums/progression_type_enum.dart';
import '../configs/preset_progression_configs.dart';
import '../models/progression_config.dart';
import 'preset_config_selector.dart';

/// Widget que integra configuraciones preestablecidas con configuración manual
///
/// Permite al usuario elegir entre configuraciones preestablecidas optimizadas
/// o configurar manualmente los parámetros de progresión.
class ProgressionConfigWithPresets extends ConsumerStatefulWidget {
  final ProgressionConfig? initialConfig;
  final Function(ProgressionConfig) onConfigChanged;
  final bool showAdvancedOptions;

  const ProgressionConfigWithPresets({
    super.key,
    this.initialConfig,
    required this.onConfigChanged,
    this.showAdvancedOptions = true,
  });

  @override
  ConsumerState<ProgressionConfigWithPresets> createState() => _ProgressionConfigWithPresetsState();
}

class _ProgressionConfigWithPresetsState extends ConsumerState<ProgressionConfigWithPresets> {
  bool _usePreset = true;
  ProgressionConfig? _selectedPreset;
  ProgressionConfig? _customConfig;

  @override
  void initState() {
    super.initState();
    _customConfig = widget.initialConfig;

    // Si hay una configuración inicial, verificar si coincide con algún preset
    if (widget.initialConfig != null) {
      _checkIfMatchesPreset(widget.initialConfig!);
    }
  }

  void _checkIfMatchesPreset(ProgressionConfig config) {
    final allPresets = PresetProgressionConfigs.getAllPresets();
    for (final preset in allPresets) {
      if (_configsMatch(preset, config)) {
        setState(() {
          _selectedPreset = preset;
          _usePreset = true;
        });
        return;
      }
    }
    setState(() {
      _usePreset = false;
    });
  }

  bool _configsMatch(ProgressionConfig preset, ProgressionConfig config) {
    return preset.type == config.type &&
        preset.unit == config.unit &&
        preset.cycleLength == config.cycleLength &&
        preset.incrementValue == config.incrementValue &&
        preset.incrementFrequency == config.incrementFrequency &&
        preset.minReps == config.minReps &&
        preset.maxReps == config.maxReps &&
        preset.baseSets == config.baseSets;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Selector de modo (Preset vs Manual)
        _buildModeSelector(),

        const SizedBox(height: 16),

        // Contenido según el modo seleccionado
        if (_usePreset) ...[
          // Selector de configuraciones preestablecidas
          PresetConfigSelector(
            currentConfig: _selectedPreset,
            onConfigSelected: (config) {
              setState(() {
                _selectedPreset = config;
              });
              widget.onConfigChanged(config);
            },
            showDescription: true,
          ),
        ] else ...[
          // Configuración manual (placeholder para el widget existente)
          _buildCustomConfigPlaceholder(),
        ],

        const SizedBox(height: 16),

        // Botón para cambiar entre modos
        _buildModeToggleButton(),
      ],
    );
  }

  Widget _buildModeSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tipo de Configuración',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildModeOption(
                    'Configuraciones Preestablecidas',
                    'Configuraciones optimizadas para objetivos específicos',
                    Icons.recommend,
                    _usePreset,
                    () => _setMode(true),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildModeOption(
                    'Configuración Manual',
                    'Configurar parámetros personalizados',
                    Icons.settings,
                    !_usePreset,
                    () => _setMode(false),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModeOption(String title, String subtitle, IconData icon, bool isSelected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.outline,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color: isSelected ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3) : null,
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color:
                  isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: isSelected ? Theme.of(context).colorScheme.primary : null,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7)),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomConfigPlaceholder() {
    return Card(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(Icons.construction, size: 48, color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.6)),
            const SizedBox(height: 16),
            Text(
              'Configuración Manual',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Aquí se integrará el widget de configuración manual existente.\n'
              'Por ahora, usa las configuraciones preestablecidas para obtener\n'
              'configuraciones optimizadas para tu objetivo.',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.8)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _setMode(true),
              icon: const Icon(Icons.recommend),
              label: const Text('Usar Configuraciones Preestablecidas'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModeToggleButton() {
    return Center(
      child: TextButton.icon(
        onPressed: () => _setMode(!_usePreset),
        icon: Icon(_usePreset ? Icons.settings : Icons.recommend),
        label: Text(_usePreset ? 'Cambiar a Configuración Manual' : 'Cambiar a Configuraciones Preestablecidas'),
      ),
    );
  }

  void _setMode(bool usePreset) {
    setState(() {
      _usePreset = usePreset;
    });

    // Notificar el cambio de configuración
    if (usePreset && _selectedPreset != null) {
      widget.onConfigChanged(_selectedPreset!);
    } else if (!usePreset && _customConfig != null) {
      widget.onConfigChanged(_customConfig!);
    }
  }
}

/// Widget de resumen de configuración seleccionada
class ProgressionConfigSummary extends StatelessWidget {
  final ProgressionConfig config;
  final bool isPreset;

  const ProgressionConfigSummary({super.key, required this.config, this.isPreset = false});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(isPreset ? Icons.recommend : Icons.settings, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  isPreset ? 'Configuración Preestablecida' : 'Configuración Personalizada',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Información básica
            _buildSummaryRow(context, 'Tipo', _getTypeDisplayName(config.type)),
            _buildSummaryRow(context, 'Unidad', config.unit.name),
            _buildSummaryRow(context, 'Duración del ciclo', '${config.cycleLength} ${config.unit.name}'),
            _buildSummaryRow(context, 'Rango de reps', '${config.minReps}–${config.maxReps}'),
            _buildSummaryRow(context, 'Series', '${config.baseSets}'),
            _buildSummaryRow(
              context,
              'Incremento',
              '${config.incrementValue}kg cada ${config.incrementFrequency} ${config.unit.name}',
            ),

            if (isPreset) ...[
              const SizedBox(height: 8),
              const Divider(),
              const SizedBox(height: 8),

              // Información específica del preset
              if (config.customParameters['description'] != null)
                Text(
                  config.customParameters['description'] as String,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.8),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.8),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onPrimaryContainer),
            ),
          ),
        ],
      ),
    );
  }

  String _getTypeDisplayName(ProgressionType type) {
    switch (type) {
      case ProgressionType.linear:
        return 'Lineal';
      case ProgressionType.stepped:
        return 'Escalonada';
      case ProgressionType.double:
        return 'Doble';
      case ProgressionType.doubleFactor:
        return 'Doble Factor';
      case ProgressionType.undulating:
        return 'Ondulante';
      case ProgressionType.wave:
        return 'Por Oleadas';
      case ProgressionType.overload:
        return 'Sobrecarga';
      case ProgressionType.static:
        return 'Estática';
      case ProgressionType.reverse:
        return 'Inversa';
      case ProgressionType.autoregulated:
        return 'Autoregulada';
      default:
        return 'Personalizada';
    }
  }
}
