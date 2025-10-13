import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../common/enums/progression_type_enum.dart';
import '../../exercise/models/exercise.dart';
import '../configs/adaptive_increment_config.dart';
import '../models/progression_config.dart';
import '../widgets/adaptive_increment_config_editor.dart';

/// Página de configuración avanzada que permite ajustar parámetros seguros
/// sin romper el objetivo fundamental del preset
class AdvancedProgressionConfigPage extends ConsumerStatefulWidget {
  final ProgressionConfig preset;
  final Function(ProgressionConfig) onConfigSaved;

  const AdvancedProgressionConfigPage({
    super.key,
    required this.preset,
    required this.onConfigSaved,
  });

  @override
  ConsumerState<AdvancedProgressionConfigPage> createState() =>
      _AdvancedProgressionConfigPageState();
}

class _AdvancedProgressionConfigPageState
    extends ConsumerState<AdvancedProgressionConfigPage> {
  late ProgressionConfig _modifiedConfig;

  // Parámetros configurables
  late int _baseSets;
  late int _sessionsPerWeek;
  late int _restTimeSeconds;
  late int _cycleLength;
  late int _deloadWeek;
  late double _deloadPercentage;

  // Configuración de incrementos personalizados
  Map<ExerciseType, Map<LoadType, IncrementRange>>? _customWeightIncrements;
  Map<ExerciseType, Map<LoadType, SeriesIncrementRange>>?
  _customSeriesIncrements;

  @override
  void initState() {
    super.initState();
    _initializeConfig();
  }

  void _initializeConfig() {
    _modifiedConfig = widget.preset.copyWith();

    // Inicializar parámetros configurables
    _baseSets = widget.preset.baseSets;
    _sessionsPerWeek = widget.preset.customParameters['sessions_per_week'] ?? 3;
    _restTimeSeconds =
        widget.preset.customParameters['rest_time_seconds'] ?? 90;
    _cycleLength = widget.preset.cycleLength;
    _deloadWeek = widget.preset.deloadWeek;
    _deloadPercentage = widget.preset.deloadPercentage;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final objective = _getObjectiveDisplayName(
      widget.preset.getTrainingObjective(),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('Configuración Avanzada - $objective'),
        actions: [
          IconButton(
            onPressed: _saveConfiguration,
            icon: const Icon(Icons.save),
            tooltip: 'Guardar configuración',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Información del preset
            _buildPresetInfo(theme),
            const SizedBox(height: 24),

            // Parámetros configurables
            _buildConfigurableParameters(theme),
            const SizedBox(height: 24),

            // Configuración de incrementos personalizados
            _buildIncrementConfig(theme),
            const SizedBox(height: 24),

            // Advertencias y limitaciones
            _buildWarnings(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildPresetInfo(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Preset Base',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '${_getObjectiveDisplayName(widget.preset.getTrainingObjective())} - ${_getStrategyDisplayName(widget.preset.type)}',
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Rango de reps: ${widget.preset.minReps}-${widget.preset.maxReps} | RPE objetivo: ${widget.preset.customParameters['target_rpe'] ?? 8.0}',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfigurableParameters(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Parámetros Configurables',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Estos parámetros pueden ajustarse sin afectar el objetivo fundamental del preset.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),

            // Número de series base
            TextFormField(
              initialValue: _baseSets.toString(),
              decoration: const InputDecoration(
                labelText: 'Series Base',
                helperText: 'Número de series por ejercicio',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                _baseSets = int.tryParse(value) ?? _baseSets;
                _updateConfig();
              },
            ),
            const SizedBox(height: 16),

            // Sesiones por semana
            TextFormField(
              initialValue: _sessionsPerWeek.toString(),
              decoration: const InputDecoration(
                labelText: 'Sesiones por Semana',
                helperText: 'Frecuencia de entrenamiento',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                _sessionsPerWeek = int.tryParse(value) ?? _sessionsPerWeek;
                _updateConfig();
              },
            ),
            const SizedBox(height: 16),

            // Tiempo de descanso
            TextFormField(
              initialValue: _restTimeSeconds.toString(),
              decoration: const InputDecoration(
                labelText: 'Tiempo de Descanso (segundos)',
                helperText: 'Descanso entre series',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                _restTimeSeconds = int.tryParse(value) ?? _restTimeSeconds;
                _updateConfig();
              },
            ),
            const SizedBox(height: 16),

            // Longitud del ciclo
            TextFormField(
              initialValue: _cycleLength.toString(),
              decoration: const InputDecoration(
                labelText: 'Longitud del Ciclo (sesiones)',
                helperText: 'Duración del ciclo de progresión',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                _cycleLength = int.tryParse(value) ?? _cycleLength;
                _updateConfig();
              },
            ),
            const SizedBox(height: 16),

            // Semana de deload
            TextFormField(
              initialValue: _deloadWeek.toString(),
              decoration: const InputDecoration(
                labelText: 'Semana de Deload',
                helperText: 'Cuándo aplicar el deload',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                _deloadWeek = int.tryParse(value) ?? _deloadWeek;
                _updateConfig();
              },
            ),
            const SizedBox(height: 16),

            // Porcentaje de deload
            TextFormField(
              initialValue: _deloadPercentage.toString(),
              decoration: const InputDecoration(
                labelText: 'Porcentaje de Deload',
                helperText: 'Intensidad del deload (0.0 - 1.0)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                _deloadPercentage = double.tryParse(value) ?? _deloadPercentage;
                _updateConfig();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIncrementConfig(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Incrementos Personalizados',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Personaliza los incrementos de peso y series para cada tipo de ejercicio y carga.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),

            AdaptiveIncrementConfigEditor(
              customWeightIncrements: _customWeightIncrements,
              customSeriesIncrements: _customSeriesIncrements,
              onConfigChanged: (weightIncrements, seriesIncrements) {
                setState(() {
                  _customWeightIncrements = weightIncrements;
                  _customSeriesIncrements = seriesIncrements;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWarnings(ThemeData theme) {
    return Card(
      color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.warning_amber_outlined,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Limitaciones',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '• Los rangos de repeticiones (${widget.preset.minReps}-${widget.preset.maxReps}) no pueden modificarse para mantener el objetivo del preset.\n'
              '• El RPE objetivo (${widget.preset.customParameters['target_rpe'] ?? 8.0}) no puede modificarse para mantener la intensidad adecuada.\n'
              '• Los objetivos primario y secundario no pueden modificarse para preservar la estrategia de entrenamiento.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _updateConfig() {
    setState(() {
      _modifiedConfig = _modifiedConfig.copyWith(
        baseSets: _baseSets,
        cycleLength: _cycleLength,
        deloadWeek: _deloadWeek,
        deloadPercentage: _deloadPercentage,
        customParameters: {
          ..._modifiedConfig.customParameters,
          'sessions_per_week': _sessionsPerWeek,
          'rest_time_seconds': _restTimeSeconds,
        },
      );
    });
  }

  void _saveConfiguration() {
    widget.onConfigSaved(_modifiedConfig);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Configuración avanzada guardada'),
        backgroundColor: Colors.green,
      ),
    );

    Navigator.of(context).pop();
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
}
