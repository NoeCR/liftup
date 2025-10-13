import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../common/enums/progression_type_enum.dart';
import '../configs/preset_progression_configs.dart';
import '../models/progression_config.dart';

/// Widget mejorado para seleccionar presets de progresión
///
/// Muestra un selector claro con descripción detallada del preset seleccionado
class ImprovedPresetSelector extends ConsumerStatefulWidget {
  final ProgressionConfig? currentConfig;
  final Function(ProgressionConfig) onConfigSelected;
  final String? title;
  final ProgressionType? filterByType; // Filtrar por tipo de progresión

  const ImprovedPresetSelector({
    super.key,
    this.currentConfig,
    required this.onConfigSelected,
    this.title,
    this.filterByType,
  });

  @override
  ConsumerState<ImprovedPresetSelector> createState() =>
      _ImprovedPresetSelectorState();
}

class _ImprovedPresetSelectorState
    extends ConsumerState<ImprovedPresetSelector> {
  ProgressionConfig? _selectedConfig;
  late final List<ProgressionConfig> _filteredPresets;

  @override
  void initState() {
    super.initState();

    // Filtrar presets por tipo si se especifica
    final allPresets = PresetProgressionConfigs.getAllPresets();
    if (widget.filterByType != null) {
      _filteredPresets =
          allPresets
              .where((preset) => preset.type == widget.filterByType)
              .toList();
    } else {
      _filteredPresets = allPresets;
    }

    // Si hay una configuración actual, intentar encontrar el preset correspondiente
    if (widget.currentConfig != null) {
      _findMatchingPreset();
    }
  }

  void _findMatchingPreset() {
    if (widget.currentConfig == null) return;

    for (final preset in _filteredPresets) {
      if (_configsMatch(preset, widget.currentConfig!)) {
        setState(() {
          _selectedConfig = preset;
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

  String _getStrategyDisplayName(ProgressionType type) {
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título
            Text(
              widget.title ?? 'Seleccionar Preset de Progresión',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Elige una configuración preestablecida optimizada para tu objetivo de entrenamiento',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),

            // Selector de presets
            _buildPresetSelector(theme),

            if (_selectedConfig != null) ...[
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 16),

              // Descripción del preset seleccionado
              _buildPresetDescription(theme),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPresetSelector(ThemeData theme) {
    // Agrupar presets por objetivo
    final Map<String, List<ProgressionConfig>> groupedPresets = {};
    for (final preset in _filteredPresets) {
      final objective = preset.getTrainingObjective();
      groupedPresets.putIfAbsent(objective, () => []).add(preset);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Objetivo de Entrenamiento',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),

        // Dropdown para seleccionar preset
        DropdownButtonFormField<ProgressionConfig>(
          value: _selectedConfig,
          decoration: const InputDecoration(
            labelText: 'Selecciona un preset',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.fitness_center),
          ),
          isExpanded: true, // Evita overflow horizontal
          items:
              _filteredPresets.map((preset) {
                final objective = _getObjectiveDisplayName(
                  preset.getTrainingObjective(),
                );
                final strategy = _getStrategyDisplayName(preset.type);

                return DropdownMenuItem<ProgressionConfig>(
                  value: preset,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$objective - $strategy',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '${preset.minReps}-${preset.maxReps} reps, ${preset.baseSets} sets',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                );
              }).toList(),
          onChanged: (ProgressionConfig? newValue) {
            if (newValue != null) {
              setState(() {
                _selectedConfig = newValue;
              });
              widget.onConfigSelected(newValue);
            }
          },
        ),
      ],
    );
  }

  Widget _buildPresetDescription(ThemeData theme) {
    if (_selectedConfig == null) return const SizedBox.shrink();

    final metadata = PresetProgressionConfigs.getPresetMetadata(
      _selectedConfig!,
    );
    final objective = _getObjectiveDisplayName(
      _selectedConfig!.getTrainingObjective(),
    );
    final strategy = _getStrategyDisplayName(_selectedConfig!.type);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Título de la descripción
        Row(
          children: [
            Icon(
              Icons.info_outline,
              color: theme.colorScheme.primary,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Configuración Seleccionada',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Información básica
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer.withOpacity(0.3),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: theme.colorScheme.primary.withOpacity(0.2),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoRow('Objetivo', objective, theme),
              _buildInfoRow('Estrategia', strategy, theme),
              _buildInfoRow(
                'Rango de Reps',
                '${_selectedConfig!.minReps}-${_selectedConfig!.maxReps}',
                theme,
              ),
              _buildInfoRow(
                'Series Base',
                '${_selectedConfig!.baseSets}',
                theme,
              ),
              _buildInfoRow(
                'RPE Objetivo',
                '${_selectedConfig!.customParameters['target_rpe'] ?? 8.0}',
                theme,
              ),
              _buildInfoRow(
                'Descanso',
                '${_selectedConfig!.customParameters['rest_time_seconds'] ?? 90}s',
                theme,
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Descripción detallada
        if (metadata['description'] != null &&
            metadata['description'].toString().isNotEmpty) ...[
          Text(
            'Descripción',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _getTranslatedDescription(metadata['description'].toString()),
            style: theme.textTheme.bodyMedium,
          ),
        ],

        const SizedBox(height: 16),

        // Puntos clave
        if (metadata['key_points'] != null &&
            metadata['key_points'] is List) ...[
          Text(
            'Características Clave',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          ...((metadata['key_points'] as List).map(
            (point) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 16,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _getTranslatedKeyPoint(point.toString()),
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
          )),
        ],
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getTranslatedDescription(String description) {
    // Si es una clave de traducción, devolver texto por defecto
    if (description.startsWith('presets.')) {
      return _getDefaultDescription(description);
    }
    return description;
  }

  String _getTranslatedKeyPoint(String keyPoint) {
    // Si es una clave de traducción, devolver texto por defecto
    if (keyPoint.startsWith('presets.')) {
      return _getDefaultKeyPoint(keyPoint);
    }
    return keyPoint;
  }

  String _getDefaultDescription(String key) {
    // Descripciones por defecto para cada objetivo
    if (key.contains('hypertrophy')) {
      return 'Configuración optimizada para el crecimiento muscular, enfocándose en volumen y repeticiones moderadas.';
    } else if (key.contains('strength')) {
      return 'Configuración diseñada para maximizar la fuerza, con énfasis en cargas pesadas y pocas repeticiones.';
    } else if (key.contains('endurance')) {
      return 'Configuración para mejorar la resistencia muscular, con altas repeticiones y menor intensidad.';
    } else if (key.contains('power')) {
      return 'Configuración para desarrollar potencia explosiva, combinando fuerza e intensidad.';
    }
    return 'Configuración preestablecida optimizada para tu objetivo de entrenamiento.';
  }

  String _getDefaultKeyPoint(String key) {
    // Puntos clave por defecto basados en el tipo de clave
    if (key.contains('repRange')) {
      return 'Rango de repeticiones optimizado para el objetivo';
    } else if (key.contains('baseSets')) {
      return 'Número de series base recomendado';
    } else if (key.contains('targetRpe')) {
      return 'RPE objetivo para mantener la intensidad adecuada';
    } else if (key.contains('restTime')) {
      return 'Tiempo de descanso entre series';
    }
    return 'Característica clave de la configuración';
  }
}
