import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../common/enums/progression_type_enum.dart';
import '../configs/preset_progression_configs.dart';
import '../models/progression_config.dart';

/// Widget selector de configuraciones preestablecidas de progresión
///
/// Permite seleccionar configuraciones optimizadas para diferentes objetivos
/// de entrenamiento y muestra descripciones detalladas de cada configuración.
class PresetConfigSelector extends ConsumerStatefulWidget {
  final ProgressionConfig? currentConfig;
  final Function(ProgressionConfig) onConfigSelected;
  final bool showDescription;

  const PresetConfigSelector({
    super.key,
    this.currentConfig,
    required this.onConfigSelected,
    this.showDescription = true,
  });

  @override
  ConsumerState<PresetConfigSelector> createState() => _PresetConfigSelectorState();
}

class _PresetConfigSelectorState extends ConsumerState<PresetConfigSelector> {
  String? selectedObjective;
  ProgressionConfig? selectedConfig;
  final List<ProgressionConfig> _allPresets = PresetProgressionConfigs.getAllPresets();

  @override
  void initState() {
    super.initState();
    // Si hay una configuración actual, intentar encontrar su objetivo
    if (widget.currentConfig != null) {
      _findCurrentObjective();
    }
  }

  void _findCurrentObjective() {
    if (widget.currentConfig == null) return;

    for (final config in _allPresets) {
      if (_configsMatch(config, widget.currentConfig!)) {
        setState(() {
          selectedObjective = _getObjectiveForConfig(config);
          selectedConfig = config;
        });
        return;
      }
    }
  }

  bool _configsMatch(ProgressionConfig preset, ProgressionConfig current) {
    return preset.type == current.type &&
        preset.unit == current.unit &&
        preset.cycleLength == current.cycleLength &&
        preset.incrementValue == current.incrementValue &&
        preset.incrementFrequency == current.incrementFrequency &&
        preset.minReps == current.minReps &&
        preset.maxReps == current.maxReps;
  }

  String _getObjectiveForConfig(ProgressionConfig config) {
    // Obtener el objetivo basado en los customParameters del config
    final objective = config.getTrainingObjective();
    return objective;
  }

  List<String> _getUniqueObjectives() {
    return _allPresets.map((config) => _getObjectiveForConfig(config)).toSet().toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Selector de objetivo
        _buildObjectiveSelector(),

        if (selectedObjective != null) ...[
          const SizedBox(height: 16),

          // Selector de configuración específica
          _buildConfigSelector(),

          if (widget.showDescription && selectedConfig != null) ...[
            const SizedBox(height: 16),

            // Descripción detallada
            _buildConfigDescription(),
          ],
        ],
      ],
    );
  }

  Widget _buildObjectiveSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Objetivo de Entrenamiento',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children:
              _getUniqueObjectives().map((objective) {
                final isSelected = selectedObjective == objective;
                return FilterChip(
                  label: Text(objective),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      selectedObjective = selected ? objective : null;
                      selectedConfig = null;
                    });
                  },
                  selectedColor: Theme.of(context).colorScheme.primaryContainer,
                  checkmarkColor: Theme.of(context).colorScheme.onPrimaryContainer,
                );
              }).toList(),
        ),
      ],
    );
  }

  Widget _buildConfigSelector() {
    final configs = _allPresets.where((config) => _getObjectiveForConfig(config) == selectedObjective).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Configuración Específica',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ...configs.map((config) => _buildConfigCard(config)),
      ],
    );
  }

  Widget _buildConfigCard(ProgressionConfig config) {
    final isSelected = selectedConfig == config;

    // Obtener metadatos del preset
    final metadata = PresetProgressionConfigs.getPresetMetadata(config);

    final description =
        metadata['description'] as String? ?? 'Configuración personalizada para ${config.type.displayName}';
    final difficulty = metadata['difficulty'] as String? ?? '';
    final progressionRate = metadata['progression_rate'] as String? ?? '';

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: isSelected ? 4 : 1,
      color: isSelected ? Theme.of(context).colorScheme.primaryContainer : Theme.of(context).colorScheme.surface,
      child: InkWell(
        onTap: () {
          setState(() {
            selectedConfig = config;
          });
          widget.onConfigSelected(config);
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
                    child: Text(
                      _getConfigDisplayName(config),
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Theme.of(context).colorScheme.onPrimaryContainer : null,
                      ),
                    ),
                  ),
                  if (isSelected) Icon(Icons.check_circle, color: Theme.of(context).colorScheme.primary, size: 20),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color:
                      isSelected
                          ? Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.8)
                          : Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildInfoChip('Dificultad', difficulty, isSelected),
                  const SizedBox(width: 8),
                  _buildInfoChip('Progresión', progressionRate, isSelected),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(String label, String value, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color:
            isSelected
                ? Theme.of(context).colorScheme.primary.withOpacity(0.2)
                : Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '$label: $value',
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color:
              isSelected
                  ? Theme.of(context).colorScheme.onPrimaryContainer
                  : Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  Widget _buildConfigDescription() {
    final config = selectedConfig!;

    // Obtener metadatos del preset
    final metadata = PresetProgressionConfigs.getPresetMetadata(config);

    final targetRpe = metadata['target_rpe'] as num?;
    final restTime = metadata['rest_time'] as num?;
    final intensityRange = metadata['intensity_range'] as String?;
    final bestFor = metadata['best_for'] as List<dynamic>?;

    return Card(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '💡 Parámetros Detallados',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // Información básica
            _buildParameterRow('Rango de repeticiones', '${config.minReps}–${config.maxReps} reps'),
            _buildParameterRow('Series por ejercicio', '${config.baseSets}'),
            _buildParameterRow('Duración del ciclo', '${config.cycleLength} ${config.unit.name}'),
            _buildParameterRow('Frecuencia de incremento', 'Cada ${config.incrementFrequency} ${config.unit.name}'),
            _buildParameterRow('Valor de incremento', '${config.incrementValue}kg'),

            if (targetRpe != null) _buildParameterRow('RPE objetivo', targetRpe.toStringAsFixed(1)),
            if (restTime != null) _buildParameterRow('Tiempo de descanso', '${restTime.toInt()}s'),
            if (intensityRange != null) _buildParameterRow('Rango de intensidad', intensityRange),

            const SizedBox(height: 12),

            // Mejores usos
            if (bestFor != null && bestFor.isNotEmpty) ...[
              Text(
                '🎯 Mejor para:',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Wrap(
                spacing: 4,
                runSpacing: 4,
                children:
                    bestFor
                        .map(
                          (use) => Chip(
                            label: Text(use.toString()),
                            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                            labelStyle: Theme.of(
                              context,
                            ).textTheme.labelSmall?.copyWith(color: Theme.of(context).colorScheme.onPrimaryContainer),
                          ),
                        )
                        .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildParameterRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500)),
          ),
          Expanded(child: Text(value, style: Theme.of(context).textTheme.bodySmall)),
        ],
      ),
    );
  }

  String _getConfigDisplayName(ProgressionConfig config) {
    switch (config.type) {
      case ProgressionType.linear:
        return 'Progresión Lineal';
      case ProgressionType.stepped:
        return 'Progresión Escalonada';
      case ProgressionType.double:
        return 'Progresión Doble';
      case ProgressionType.doubleFactor:
        return 'Progresión Doble Factor';
      case ProgressionType.undulating:
        return 'Progresión Ondulante';
      case ProgressionType.wave:
        return 'Progresión por Oleadas';
      case ProgressionType.overload:
        final overloadType = config.customParameters['overload_type'] as String?;
        return overloadType == 'volume' ? 'Sobrecarga por Volumen' : 'Sobrecarga por Intensidad';
      case ProgressionType.static:
        return 'Progresión Estática';
      case ProgressionType.reverse:
        return 'Progresión Inversa';
      case ProgressionType.autoregulated:
        return 'Progresión Autoregulada';
      default:
        return 'Configuración Personalizada';
    }
  }
}

/// Widget simplificado para mostrar solo la descripción de una configuración
class PresetConfigDescription extends StatelessWidget {
  final ProgressionConfig config;

  const PresetConfigDescription({super.key, required this.config});

  @override
  Widget build(BuildContext context) {
    // Obtener metadatos del preset
    final metadata = PresetProgressionConfigs.getPresetMetadata(config);

    final description =
        metadata['description'] as String? ?? 'Configuración personalizada para ${config.type.displayName}';
    final targetRpe = metadata['target_rpe'] as num?;
    final restTime = metadata['rest_time'] as num?;
    final intensityRange = metadata['intensity_range'] as String?;
    final difficulty = metadata['difficulty'] as String?;
    final progressionRate = metadata['progression_rate'] as String?;

    return Card(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Configuración Seleccionada',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(description, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 12),

            // Parámetros clave
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (difficulty != null) _buildInfoChip(context, 'Dificultad', difficulty),
                if (progressionRate != null) _buildInfoChip(context, 'Progresión', progressionRate),
                if (targetRpe != null) _buildInfoChip(context, 'RPE', targetRpe.toStringAsFixed(1)),
                if (restTime != null) _buildInfoChip(context, 'Descanso', '${restTime.toInt()}s'),
                if (intensityRange != null) _buildInfoChip(context, 'Intensidad', intensityRange),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(BuildContext context, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '$label: $value',
        style: Theme.of(
          context,
        ).textTheme.labelSmall?.copyWith(color: Theme.of(context).colorScheme.onPrimaryContainer),
      ),
    );
  }
}
