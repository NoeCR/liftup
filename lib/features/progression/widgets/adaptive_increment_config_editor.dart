import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../common/enums/muscle_group_enum.dart';
import '../../exercise/models/exercise.dart';
import '../configs/adaptive_increment_config.dart';

/// Widget para configurar incrementos personalizados de AdaptiveIncrementConfig
class AdaptiveIncrementConfigEditor extends ConsumerStatefulWidget {
  final Map<ExerciseType, Map<LoadType, IncrementRange>>? customWeightIncrements;
  final Map<ExerciseType, Map<LoadType, SeriesIncrementRange>>? customSeriesIncrements;
  final Function(
    Map<ExerciseType, Map<LoadType, IncrementRange>>,
    Map<ExerciseType, Map<LoadType, SeriesIncrementRange>>,
  )
  onConfigChanged;

  const AdaptiveIncrementConfigEditor({
    super.key,
    this.customWeightIncrements,
    this.customSeriesIncrements,
    required this.onConfigChanged,
  });

  @override
  ConsumerState<AdaptiveIncrementConfigEditor> createState() => _AdaptiveIncrementConfigEditorState();
}

class _AdaptiveIncrementConfigEditorState extends ConsumerState<AdaptiveIncrementConfigEditor> {
  late Map<ExerciseType, Map<LoadType, IncrementRange>> _weightIncrements;
  late Map<ExerciseType, Map<LoadType, SeriesIncrementRange>> _seriesIncrements;

  ExerciseType _selectedExerciseType = ExerciseType.multiJoint;
  LoadType _selectedLoadType = LoadType.barbell;

  @override
  void initState() {
    super.initState();
    _initializeIncrements();
  }

  void _initializeIncrements() {
    // Inicializar con valores por defecto o personalizados
    _weightIncrements = widget.customWeightIncrements ?? _getDefaultWeightIncrements();
    _seriesIncrements = widget.customSeriesIncrements ?? _getDefaultSeriesIncrements();
  }

  Map<ExerciseType, Map<LoadType, IncrementRange>> _getDefaultWeightIncrements() {
    final Map<ExerciseType, Map<LoadType, IncrementRange>> defaults = {};

    for (final exerciseType in ExerciseType.values) {
      defaults[exerciseType] = {};
      for (final loadType in LoadType.values) {
        // Crear un ejercicio temporal para obtener el rango
        final tempExercise = _createTempExercise(exerciseType, loadType);
        final range = AdaptiveIncrementConfig.getIncrementRange(tempExercise);
        if (range != null) {
          defaults[exerciseType]![loadType] = range;
        }
      }
    }

    return defaults;
  }

  Map<ExerciseType, Map<LoadType, SeriesIncrementRange>> _getDefaultSeriesIncrements() {
    final Map<ExerciseType, Map<LoadType, SeriesIncrementRange>> defaults = {};

    for (final exerciseType in ExerciseType.values) {
      defaults[exerciseType] = {};
      for (final loadType in LoadType.values) {
        // Crear un ejercicio temporal para obtener el rango
        final tempExercise = _createTempExercise(exerciseType, loadType);
        final range = AdaptiveIncrementConfig.getSeriesIncrementRange(tempExercise);
        if (range != null) {
          defaults[exerciseType]![loadType] = range;
        }
      }
    }

    return defaults;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Configuración de Incrementos Personalizados',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Personaliza los incrementos de peso y series para cada tipo de ejercicio y carga.',
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 16),

            // Selectores de tipo de ejercicio y carga
            _buildTypeSelectors(theme),
            const SizedBox(height: 16),

            // Configuración de incrementos
            _buildIncrementConfig(theme),
            const SizedBox(height: 16),

            // Botones de acción
            _buildActionButtons(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeSelectors(ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: DropdownButtonFormField<ExerciseType>(
            value: _selectedExerciseType,
            decoration: const InputDecoration(labelText: 'Tipo de Ejercicio', border: OutlineInputBorder()),
            items:
                ExerciseType.values.map((type) {
                  return DropdownMenuItem(value: type, child: Text(_getExerciseTypeDisplayName(type)));
                }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _selectedExerciseType = value;
                });
              }
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: DropdownButtonFormField<LoadType>(
            value: _selectedLoadType,
            decoration: const InputDecoration(labelText: 'Tipo de Carga', border: OutlineInputBorder()),
            items:
                LoadType.values.map((type) {
                  return DropdownMenuItem(value: type, child: Text(_getLoadTypeDisplayName(type)));
                }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _selectedLoadType = value;
                });
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildIncrementConfig(ThemeData theme) {
    final weightRange = _weightIncrements[_selectedExerciseType]?[_selectedLoadType];
    final seriesRange = _seriesIncrements[_selectedExerciseType]?[_selectedLoadType];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Configuración para ${_getExerciseTypeDisplayName(_selectedExerciseType)} + ${_getLoadTypeDisplayName(_selectedLoadType)}',
          style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),

        // Incrementos de peso
        if (weightRange != null) ...[
          Text('Incrementos de Peso (kg)', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  initialValue: weightRange.min.toString(),
                  decoration: const InputDecoration(labelText: 'Mínimo', border: OutlineInputBorder()),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    final min = double.tryParse(value);
                    if (min != null) {
                      _updateWeightRange(min: min);
                    }
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextFormField(
                  initialValue: weightRange.defaultValue.toString(),
                  decoration: const InputDecoration(labelText: 'Por Defecto', border: OutlineInputBorder()),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    final defaultValue = double.tryParse(value);
                    if (defaultValue != null) {
                      _updateWeightRange(defaultValue: defaultValue);
                    }
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextFormField(
                  initialValue: weightRange.max.toString(),
                  decoration: const InputDecoration(labelText: 'Máximo', border: OutlineInputBorder()),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    final max = double.tryParse(value);
                    if (max != null) {
                      _updateWeightRange(max: max);
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],

        // Incrementos de series
        if (seriesRange != null) ...[
          Text('Incrementos de Series', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  initialValue: seriesRange.min.toString(),
                  decoration: const InputDecoration(labelText: 'Mínimo', border: OutlineInputBorder()),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    final min = int.tryParse(value);
                    if (min != null) {
                      _updateSeriesRange(min: min);
                    }
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextFormField(
                  initialValue: seriesRange.defaultValue.toString(),
                  decoration: const InputDecoration(labelText: 'Por Defecto', border: OutlineInputBorder()),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    final defaultValue = int.tryParse(value);
                    if (defaultValue != null) {
                      _updateSeriesRange(defaultValue: defaultValue);
                    }
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextFormField(
                  initialValue: seriesRange.max.toString(),
                  decoration: const InputDecoration(labelText: 'Máximo', border: OutlineInputBorder()),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    final max = int.tryParse(value);
                    if (max != null) {
                      _updateSeriesRange(max: max);
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildActionButtons(ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _resetToDefaults,
            icon: const Icon(Icons.refresh),
            label: const Text('Restaurar Valores por Defecto'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: FilledButton.icon(
            onPressed: _saveConfiguration,
            icon: const Icon(Icons.save),
            label: const Text('Guardar Configuración'),
          ),
        ),
      ],
    );
  }

  void _updateWeightRange({double? min, double? max, double? defaultValue}) {
    final currentRange = _weightIncrements[_selectedExerciseType]?[_selectedLoadType];
    if (currentRange != null) {
      final newRange = IncrementRange(
        min: min ?? currentRange.min,
        max: max ?? currentRange.max,
        defaultValue: defaultValue ?? currentRange.defaultValue,
      );

      setState(() {
        _weightIncrements[_selectedExerciseType]![_selectedLoadType] = newRange;
      });
    }
  }

  void _updateSeriesRange({int? min, int? max, int? defaultValue}) {
    final currentRange = _seriesIncrements[_selectedExerciseType]?[_selectedLoadType];
    if (currentRange != null) {
      final newRange = SeriesIncrementRange(
        min: min ?? currentRange.min,
        max: max ?? currentRange.max,
        defaultValue: defaultValue ?? currentRange.defaultValue,
      );

      setState(() {
        _seriesIncrements[_selectedExerciseType]![_selectedLoadType] = newRange;
      });
    }
  }

  void _resetToDefaults() {
    setState(() {
      _weightIncrements = _getDefaultWeightIncrements();
      _seriesIncrements = _getDefaultSeriesIncrements();
    });
  }

  void _saveConfiguration() {
    widget.onConfigChanged(_weightIncrements, _seriesIncrements);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Configuración de incrementos guardada'), backgroundColor: Colors.green),
    );
  }

  String _getExerciseTypeDisplayName(ExerciseType type) {
    switch (type) {
      case ExerciseType.multiJoint:
        return 'Multi-articular';
      case ExerciseType.isolation:
        return 'Aislamiento';
    }
  }

  String _getLoadTypeDisplayName(LoadType type) {
    switch (type) {
      case LoadType.barbell:
        return 'Barra';
      case LoadType.dumbbell:
        return 'Mancuernas';
      case LoadType.machine:
        return 'Máquina';
      case LoadType.cable:
        return 'Cable';
      case LoadType.kettlebell:
        return 'Kettlebell';
      case LoadType.plate:
        return 'Discos';
      case LoadType.bodyweight:
        return 'Peso Corporal';
      case LoadType.resistanceBand:
        return 'Banda Elástica';
    }
  }

  Exercise _createTempExercise(ExerciseType exerciseType, LoadType loadType) {
    return Exercise(
      id: 'temp',
      name: 'Temp Exercise',
      description: 'Temporary exercise for config',
      imageUrl: '',
      muscleGroups:
          exerciseType == ExerciseType.multiJoint ? [MuscleGroup.pectoralMajor] : [MuscleGroup.bicepsLongHead],
      tips: [],
      commonMistakes: [],
      category: exerciseType == ExerciseType.multiJoint ? ExerciseCategory.chest : ExerciseCategory.biceps,
      difficulty: ExerciseDifficulty.intermediate,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      exerciseType: exerciseType,
      loadType: loadType,
    );
  }
}
