// import 'package:image_cropper/image_cropper.dart';
import 'dart:io';
import 'dart:typed_data';

import 'package:easy_localization/easy_localization.dart';
import 'package:extended_image/extended_image.dart' as ext_img;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as image;
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../../common/enums/muscle_group_enum.dart';
import '../../../common/enums/progression_type_enum.dart';
import '../../progression/notifiers/progression_notifier.dart';
import '../models/exercise.dart';
import '../notifiers/exercise_notifier.dart';

class ExerciseFormPage extends ConsumerStatefulWidget {
  final Exercise? exerciseToEdit;
  final String? routineId;
  final String? sectionId;
  final String? returnTo;

  const ExerciseFormPage({
    super.key,
    this.exerciseToEdit,
    this.routineId,
    this.sectionId,
    this.returnTo,
  });

  @override
  ConsumerState<ExerciseFormPage> createState() => _ExerciseFormPageState();
}

class _ExerciseFormPageState extends ConsumerState<ExerciseFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _videoUrlController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _tipsController = TextEditingController();
  final _commonMistakesController = TextEditingController();
  final _setsController = TextEditingController();
  final _repsController = TextEditingController();
  final _weightController = TextEditingController();
  final _restTimeController = TextEditingController();

  // Progression settings controllers
  // Los incrementos de peso y rangos de reps se manejan automáticamente
  // por AdaptiveIncrementConfig y ProgressionConfig
  final _setsMinController = TextEditingController();
  final _setsMaxController = TextEditingController();
  final _targetRpeController = TextEditingController();
  final _incFreqController = TextEditingController();

  ExerciseCategory _selectedCategory = ExerciseCategory.chest;
  ExerciseDifficulty _selectedDifficulty = ExerciseDifficulty.beginner;
  List<MuscleGroup> _selectedMuscleGroups = [];
  String _imagePath = '';
  bool _isLoading = false;
  int _formSets = 3;
  int _formReps = 10;
  double _formWeight = 0.0;
  int? _formRestTimeSeconds;
  ExerciseType _exerciseType = ExerciseType.multiJoint;
  LoadType _loadType = LoadType.barbell;

  @override
  void initState() {
    super.initState();

    // Initialize controllers with default values
    _setsController.text = _formSets.toString();
    _repsController.text = _formReps.toString();
    _weightController.text = _formWeight.toStringAsFixed(1);
    _restTimeController.text = _formRestTimeSeconds?.toString() ?? '';

    if (widget.exerciseToEdit != null) {
      _populateForm();
      // Prefill progression settings from active config if available
      _prefillProgressionFromConfig();
    }
  }

  void _populateForm() {
    final exercise = widget.exerciseToEdit!;
    _nameController.text = exercise.name;
    _descriptionController.text = exercise.description;
    _videoUrlController.text = exercise.videoUrl ?? '';
    _tipsController.text = exercise.tips.join('\n');
    _commonMistakesController.text = exercise.commonMistakes.join('\n');
    _selectedCategory = exercise.category;
    _selectedDifficulty = exercise.difficulty;
    _selectedMuscleGroups = List.from(exercise.muscleGroups);
    _imagePath = exercise.imageUrl;

    // Usar valores por defecto del ejercicio
    _formSets = exercise.defaultSets ?? 4;
    _formReps = exercise.defaultReps ?? 10;
    _formWeight = exercise.defaultWeight ?? 0.0;
    _formRestTimeSeconds = exercise.restTimeSeconds;
    _exerciseType = exercise.exerciseType;
    _loadType = exercise.loadType;

    // Update controllers with exercise default values
    _setsController.text = _formSets.toString();
    _repsController.text = _formReps.toString();
    _weightController.text = _formWeight.toStringAsFixed(1);
    _restTimeController.text = _formRestTimeSeconds?.toString() ?? '';
  }

  Future<void> _prefillProgressionFromConfig() async {
    try {
      final config = await ref.read(progressionNotifierProvider.future);
      final exercise = widget.exerciseToEdit;
      if (config == null || exercise == null) return;

      final perExercise =
          (config.customParameters['per_exercise'] as Map?)
              ?.cast<String, dynamic>();
      final current =
          perExercise != null
              ? (perExercise[exercise.id] as Map?)?.cast<String, dynamic>()
              : null;
      if (current == null) return;

      // Los incrementos de peso y rangos de reps se manejan automáticamente
      // por AdaptiveIncrementConfig y ProgressionConfig
      _setsMinController.text = (current['sets_min'] ?? '').toString();
      _setsMaxController.text = (current['sets_max'] ?? '').toString();
      _targetRpeController.text = (current['target_rpe'] ?? '').toString();
      _incFreqController.text =
          (current['increment_frequency'] ?? '').toString();
      if (mounted) setState(() {});
    } catch (_) {}
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _videoUrlController.dispose();
    _imageUrlController.dispose();
    _tipsController.dispose();
    _commonMistakesController.dispose();
    _setsController.dispose();
    _repsController.dispose();
    _weightController.dispose();
    _restTimeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isEditing = widget.exerciseToEdit != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEditing
              ? context.tr('exercises.editExercise')
              : context.tr('exercises.newExercise'),
        ),
        backgroundColor: colorScheme.surface,
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            TextButton(
              onPressed: _isLoading ? null : _saveExercise,
              child: Text(
                isEditing ? 'Actualizar' : 'Guardar',
                style: TextStyle(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
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
              // Image Section
              _buildImageSection(),
              const SizedBox(height: 24),

              // Basic Information
              _buildBasicInfoSection(),
              const SizedBox(height: 24),

              // Category and Difficulty
              _buildCategoryAndDifficultySection(),
              const SizedBox(height: 24),

              // Muscle Groups
              _buildMuscleGroupsSection(),
              const SizedBox(height: 24),

              // Tips and Common Mistakes
              _buildTipsAndMistakesSection(),
              const SizedBox(height: 24),

              // Training params (series, reps, peso)
              _buildTrainingParamsSection(),
              const SizedBox(height: 24),

              // Video URL
              _buildVideoUrlSection(),
              const SizedBox(height: 32),

              // Progression settings
              _buildProgressionSettingsSection(),
              const SizedBox(height: 32),

              // Save Button
              _buildSaveButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressionSettingsSection() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Configuración de Progresión',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            border: Border.all(color: colorScheme.outline),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: colorScheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Incrementos Automáticos',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Los incrementos de peso se calcularán automáticamente basándose en:',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.fitness_center,
                    color: colorScheme.secondary,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Tipo de ejercicio: ${_exerciseType.displayNameKey.tr()}',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.sports_gymnastics,
                    color: colorScheme.secondary,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Tipo de carga: ${_loadType.displayNameKey.tr()}',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '💡 Los incrementos se ajustarán automáticamente según las mejores prácticas para cada combinación de tipo de ejercicio y carga.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildImageSection() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Imagen del Ejercicio',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Center(
          child: GestureDetector(
            onTap: _pickImage,
            child: Container(
              width: 200,
              height: 150,
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: colorScheme.outline,
                  style: BorderStyle.solid,
                ),
              ),
              child: _buildPreviewImage(),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: TextButton.icon(
            onPressed: _pickImage,
            icon: const Icon(Icons.camera_alt),
            label: Text(
              _imagePath.isEmpty
                  ? context.tr('exercises.selectImage')
                  : context.tr('exercises.changeImage'),
            ),
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _imageUrlController,
          decoration: InputDecoration(
            labelText: context.tr('exercises.imageUrlOptional'),
            hintText: context.tr('exercises.imageUrlHint'),
            border: OutlineInputBorder(),
            helperText: context.tr('exercises.imageUrlHelper'),
          ),
          keyboardType: TextInputType.url,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: OutlinedButton.icon(
            onPressed: () {
              // Fuerza refresco del preview para probar la imagen
              setState(() {});
            },
            icon: const Icon(Icons.image_search),
            label: Text(context.tr('exercises.testImage')),
          ),
        ),
      ],
    );
  }

  Widget _buildImagePlaceholder() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.add_photo_alternate,
          size: 48,
          color: colorScheme.onSurfaceVariant,
        ),
        const SizedBox(height: 8),
        Text(
          context.tr('exercises.addImage'),
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildPreviewImage() {
    final url = _imageUrlController.text.trim();
    if (url.isNotEmpty) {
      if (url.startsWith('http')) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            url,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _buildImagePlaceholder(),
          ),
        );
      }
      if (url.startsWith('file:') || url.startsWith('/')) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.file(
            File(url.replaceFirst('file://', '')),
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _buildImagePlaceholder(),
          ),
        );
      }
      return _buildImagePlaceholder();
    }
    if (_imagePath.isNotEmpty) {
      if (_imagePath.startsWith('assets/')) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.asset(
            _imagePath,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _buildImagePlaceholder(),
          ),
        );
      }
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.file(
          File(_imagePath),
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildImagePlaceholder(),
        ),
      );
    }
    return _buildImagePlaceholder();
  }

  Widget _buildBasicInfoSection() {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.tr('exercises.basicInformation'),
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _nameController,
          decoration: InputDecoration(
            labelText: context.tr('exercises.exerciseName'),
            hintText: context.tr('exercises.exerciseNameHint'),
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return context.tr('exercises.nameRequired');
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _descriptionController,
          decoration: InputDecoration(
            labelText: context.tr('routine.description'),
            hintText: context.tr('exercises.describeExercise'),
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return context.tr('exercises.descriptionRequired');
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildCategoryAndDifficultySection() {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.tr('exercises.categoryAndDifficulty'),
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<ExerciseCategory>(
                value: _selectedCategory,
                decoration: InputDecoration(
                  labelText: context.tr('exercises.category'),
                  border: OutlineInputBorder(),
                ),
                items:
                    ExerciseCategory.values.map((category) {
                      return DropdownMenuItem(
                        value: category,
                        child: Text(category.displayName),
                      );
                    }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedCategory = value;
                    });
                  }
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: DropdownButtonFormField<ExerciseDifficulty>(
                value: _selectedDifficulty,
                decoration: InputDecoration(
                  labelText: context.tr('exercises.difficulty'),
                  border: OutlineInputBorder(),
                ),
                items:
                    ExerciseDifficulty.values.map((difficulty) {
                      return DropdownMenuItem(
                        value: difficulty,
                        child: Text(_getDifficultyName(difficulty)),
                      );
                    }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedDifficulty = value;
                    });
                  }
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Tipo de ejercicio (multi/isolation) con autodetección básica
        DropdownButtonFormField<ExerciseType>(
          value: _exerciseType,
          decoration: InputDecoration(
            labelText: 'Tipo de ejercicio',
            border: OutlineInputBorder(),
            helperText: 'Usado para ajustar incrementos y rangos de reps',
          ),
          items:
              ExerciseType.values
                  .map(
                    (t) => DropdownMenuItem(
                      value: t,
                      child: Text(t.displayNameKey.tr()),
                    ),
                  )
                  .toList(),
          onChanged: (value) {
            if (value != null) setState(() => _exerciseType = value);
          },
        ),
        const SizedBox(height: 12),
        // Tipo de carga (barbell, dumbbell, etc.)
        DropdownButtonFormField<LoadType>(
          value: _loadType,
          decoration: InputDecoration(
            labelText: 'Tipo de carga',
            border: OutlineInputBorder(),
            helperText: 'Usado para calcular incrementos adaptativos',
          ),
          items:
              LoadType.values
                  .map(
                    (t) => DropdownMenuItem(
                      value: t,
                      child: Text(t.displayNameKey.tr()),
                    ),
                  )
                  .toList(),
          onChanged: (value) {
            if (value != null) setState(() => _loadType = value);
          },
        ),
      ],
    );
  }

  Widget _buildMuscleGroupsSection() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.tr('exercises.musclesWorked'),
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: colorScheme.outline),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.tr('exercises.selectMuscles'),
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children:
                    MuscleGroup.values.map((muscle) {
                      final isSelected = _selectedMuscleGroups.contains(muscle);
                      return FilterChip(
                        label: Text(muscle.displayName),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedMuscleGroups.add(muscle);
                            } else {
                              _selectedMuscleGroups.remove(muscle);
                            }
                          });
                        },
                        selectedColor: colorScheme.primaryContainer,
                        checkmarkColor: colorScheme.onPrimaryContainer,
                      );
                    }).toList(),
              ),
              if (_selectedMuscleGroups.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    context.tr('exercises.selectAtLeastOneMuscle'),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.error,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTipsAndMistakesSection() {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Consejos y Errores Comunes',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _tipsController,
          decoration: InputDecoration(
            labelText: context.tr('exercises.tipsOnePerLine'),
            hintText: context.tr('exercises.tipsHint'),
            border: OutlineInputBorder(),
            helperText: context.tr('exercises.writeEachTipOnSeparateLine'),
          ),
          maxLines: 4,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _commonMistakesController,
          decoration: InputDecoration(
            labelText: context.tr('exercises.commonMistakesOnePerLine'),
            hintText: context.tr('exercises.commonMistakesHint'),
            border: OutlineInputBorder(),
            helperText: context.tr('exercises.writeEachMistakeOnSeparateLine'),
          ),
          maxLines: 4,
        ),
      ],
    );
  }

  Widget _buildVideoUrlSection() {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.tr('exercises.demoVideoOptional'),
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _videoUrlController,
                decoration: InputDecoration(
                  labelText: context.tr('exercises.videoUrl'),
                  hintText: context.tr('exercises.videoUrlHint'),
                  border: OutlineInputBorder(),
                  helperText: context.tr('exercises.videoUrlHelper'),
                ),
                keyboardType: TextInputType.url,
              ),
            ),
            const SizedBox(width: 12),
            Column(
              children: [
                SizedBox(
                  height: 48,
                  child: OutlinedButton.icon(
                    onPressed: _pickVideoFile,
                    icon: const Icon(Icons.folder_open),
                    label: Text(context.tr('exercises.file')),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 40,
                  child: Text(
                    _isYouTubeUrl(_videoUrlController.text)
                        ? 'YouTube'
                        : _isLocalPath(_videoUrlController.text)
                        ? 'Local'
                        : _videoUrlController.text.isNotEmpty
                        ? 'URL'
                        : '',
                    style: theme.textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTrainingParamsSection() {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.tr('exercises.trainingParameters'),
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _setsController,
                decoration: InputDecoration(
                  labelText: context.tr('exercises.sets'),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                onChanged: (v) {
                  final parsed = int.tryParse(v.trim());
                  if (parsed != null && parsed > 0) {
                    _formSets = parsed;
                  }
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: _repsController,
                decoration: InputDecoration(
                  labelText: context.tr('exercises.reps'),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                onChanged: (v) {
                  final parsed = int.tryParse(v.trim());
                  if (parsed != null && parsed > 0) {
                    _formReps = parsed;
                  }
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: _weightController,
                decoration: InputDecoration(
                  labelText: context.tr('exercises.weight'),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                onChanged: (v) {
                  final parsed = double.tryParse(v.trim());
                  if (parsed != null && parsed >= 0) {
                    _formWeight = parsed;
                  }
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _restTimeController,
                decoration: InputDecoration(
                  labelText: 'Tiempo de descanso (segundos)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                onChanged: (v) {
                  final parsed = int.tryParse(v.trim());
                  if (parsed != null && parsed > 0) {
                    _formRestTimeSeconds = parsed;
                  } else if (v.trim().isEmpty) {
                    _formRestTimeSeconds = null;
                  }
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  // removed old getters; now using in-memory form fields

  Widget _buildSaveButton() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isEditing = widget.exerciseToEdit != null;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _saveExercise,
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child:
            _isLoading
                ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
                : Text(
                  isEditing ? 'Actualizar Ejercicio' : 'Crear Ejercicio',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
      ),
    );
  }

  Future<void> _pickImage() async {
    showModalBottomSheet(
      context: context,
      builder:
          (context) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: Text(context.tr('exercises.gallery')),
                  onTap: () async {
                    Navigator.pop(context);
                    await _pickImageFromSource(ImageSource.gallery);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: Text(context.tr('exercises.camera')),
                  onTap: () async {
                    Navigator.pop(context);
                    await _pickImageFromSource(ImageSource.camera);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.delete),
                  title: Text(context.tr('exercises.deleteImage')),
                  onTap: () {
                    Navigator.pop(context);
                    setState(() {
                      _imagePath = '';
                    });
                  },
                ),
              ],
            ),
          ),
    );
  }

  Future<void> _pickImageFromSource(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: source);

    if (image != null) {
      final cropped = await _openCropperDialog(image.path);
      setState(() {
        _imagePath = cropped ?? image.path;
      });
    }
  }

  Future<String?> _openCropperDialog(String path) async {
    final editorKey = GlobalKey<ext_img.ExtendedImageEditorState>();
    return await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          contentPadding: EdgeInsets.zero,
          content: SizedBox(
            width: MediaQuery.of(ctx).size.width * 0.9,
            height: MediaQuery.of(ctx).size.height * 0.6,
            child: ext_img.ExtendedImage.file(
              File(path),
              fit: BoxFit.contain,
              mode: ext_img.ExtendedImageMode.editor,
              extendedImageEditorKey: editorKey,
              cacheRawData: true,
              initEditorConfigHandler: (state) {
                return ext_img.EditorConfig(
                  maxScale: 8.0,
                  cropRectPadding: const EdgeInsets.all(16),
                  hitTestSize: 20.0,
                  cornerColor: Theme.of(ctx).colorScheme.primary,
                  lineColor: Theme.of(ctx).colorScheme.primary,
                  // Aspect ratio 4:3
                  cropAspectRatio: 4 / 3,
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(null),
              child: Text(context.tr('common.cancel')),
            ),
            ElevatedButton(
              onPressed: () async {
                final state = editorKey.currentState;
                if (state == null) {
                  Navigator.of(ctx).pop(null);
                  return;
                }
                // Manual crop using image package
                Uint8List croppedBytes;
                final raw = state.rawImageData;
                final rect = state.getCropRect();
                final img = image.decodeImage(raw);
                if (img != null && rect != null) {
                  final crop = image.copyCrop(
                    img,
                    x: rect.left.round().clamp(0, img.width - 1),
                    y: rect.top.round().clamp(0, img.height - 1),
                    width: rect.width.round().clamp(1, img.width),
                    height: rect.height.round().clamp(1, img.height),
                  );
                  croppedBytes = Uint8List.fromList(
                    image.encodeJpg(crop, quality: 92),
                  );
                } else {
                  croppedBytes = raw;
                }
                // Guardar a AppDocuments/images
                final dir = await getApplicationDocumentsDirectory();
                final imagesDir = Directory('${dir.path}/images');
                if (!await imagesDir.exists()) {
                  await imagesDir.create(recursive: true);
                }
                final filename =
                    'img_${DateTime.now().millisecondsSinceEpoch}.jpg';
                final file = File('${imagesDir.path}/$filename');
                await file.writeAsBytes(croppedBytes, flush: true);
                if (ctx.mounted) Navigator.of(ctx).pop(file.path);
              },
              child: Text(context.tr('exercises.cropAndSave')),
            ),
          ],
        );
      },
    );
  }

  Future<void> _pickVideoFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.video,
      allowMultiple: false,
    );
    if (result != null && result.files.isNotEmpty) {
      final path = result.files.single.path;
      if (path != null && mounted) {
        setState(() {
          _videoUrlController.text = path;
        });
      }
    }
  }

  bool _isYouTubeUrl(String url) {
    final u = url.toLowerCase();
    return u.contains('youtube.com') || u.contains('youtu.be');
  }

  bool _isLocalPath(String url) {
    return url.startsWith('/') || url.startsWith('file:');
  }

  String _getDifficultyName(ExerciseDifficulty difficulty) {
    switch (difficulty) {
      case ExerciseDifficulty.beginner:
        return 'Principiante';
      case ExerciseDifficulty.intermediate:
        return 'Intermedio';
      case ExerciseDifficulty.advanced:
        return 'Avanzado';
    }
  }

  Future<void> _saveExercise() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedMuscleGroups.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.tr('exercises.selectAtLeastOneMuscle')),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final tips =
          _tipsController.text
              .split('\n')
              .where((tip) => tip.trim().isNotEmpty)
              .map((tip) => tip.trim())
              .toList();

      final commonMistakes =
          _commonMistakesController.text
              .split('\n')
              .where((mistake) => mistake.trim().isNotEmpty)
              .map((mistake) => mistake.trim())
              .toList();

      // Resolver imagen persistente
      final resolvedImagePath = await _resolveAndPersistImagePath();

      final exercise = Exercise(
        id: widget.exerciseToEdit?.id ?? '',
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        imageUrl: resolvedImagePath,
        videoUrl:
            _videoUrlController.text.trim().isNotEmpty
                ? _videoUrlController.text.trim()
                : null,
        muscleGroups: _selectedMuscleGroups,
        tips: tips,
        commonMistakes: commonMistakes,
        category: _selectedCategory,
        difficulty: _selectedDifficulty,
        createdAt: widget.exerciseToEdit?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
        defaultWeight: _formWeight > 0 ? _formWeight : null,
        defaultSets: _formSets > 0 ? _formSets : null,
        defaultReps: _formReps > 0 ? _formReps : null,
        restTimeSeconds: _formRestTimeSeconds,
        exerciseType: _exerciseType,
        loadType: _loadType,
      );

      // Debug: saving exercise with default values

      if (widget.exerciseToEdit != null) {
        await ref
            .read(exerciseNotifierProvider.notifier)
            .updateExercise(exercise);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Ejercicio actualizado correctamente'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        await ref.read(exerciseNotifierProvider.notifier).addExercise(exercise);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Ejercicio creado correctamente'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }

      // Weight, sets, reps and rest time are stored directly in Exercise.
      // RoutineExercise does not need updates because values are read from Exercise.
      // Debug: Valores guardados en Exercise

      if (mounted) {
        // Navigate back based on context
        if (widget.returnTo == 'selection' &&
            widget.routineId != null &&
            widget.sectionId != null) {
          // Return to exercise selection with context
          context.go(
            '/exercise-selection?routineId=${widget.routineId}&sectionId=${widget.sectionId}&title=Agregar Ejercicios',
          );
        } else {
          // Navigate back to exercise list
          context.go('/exercises');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
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

  Future<String> _resolveAndPersistImagePath() async {
    try {
      final remote = _imageUrlController.text.trim();
      // Caso 1: URL remota → descargar a app dir
      if (remote.isNotEmpty && remote.startsWith('http')) {
        final bytes = await http.readBytes(Uri.parse(remote));
        final dir = await getApplicationDocumentsDirectory();
        final imagesDir = Directory('${dir.path}/images');
        if (!await imagesDir.exists()) await imagesDir.create(recursive: true);
        // Guardar temporalmente y ofrecer recorte
        final tempName = 'tmp_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final tempFile = File('${imagesDir.path}/$tempName');
        await tempFile.writeAsBytes(bytes, flush: true);
        final croppedPath = await _openCropperDialog(tempFile.path);
        return croppedPath ?? tempFile.path;
      }
      // Case 2: local image selected → copy to app directory if needed
      if (_imagePath.isNotEmpty) {
        if (_imagePath.startsWith('assets/')) return _imagePath;
        final src = File(
          _imagePath.startsWith('file:')
              ? _imagePath.replaceFirst('file://', '')
              : _imagePath,
        );
        if (!await src.exists()) return 'assets/images/default_exercise.png';
        final dir = await getApplicationDocumentsDirectory();
        final imagesDir = Directory('${dir.path}/images');
        if (!await imagesDir.exists()) await imagesDir.create(recursive: true);
        final filename =
            'img_${DateTime.now().millisecondsSinceEpoch}${p.extension(src.path)}';
        final dst = File('${imagesDir.path}/$filename');
        await dst.writeAsBytes(await src.readAsBytes(), flush: true);
        return dst.path;
      }
      // Caso 3: ruta local en campo URL (file:///)
      if (remote.isNotEmpty &&
          (remote.startsWith('file:') || remote.startsWith('/'))) {
        final src = File(remote.replaceFirst('file://', ''));
        if (!await src.exists()) return 'assets/images/default_exercise.png';
        final dir = await getApplicationDocumentsDirectory();
        final imagesDir = Directory('${dir.path}/images');
        if (!await imagesDir.exists()) await imagesDir.create(recursive: true);
        final filename =
            'img_${DateTime.now().millisecondsSinceEpoch}${p.extension(src.path)}';
        final dst = File('${imagesDir.path}/$filename');
        await dst.writeAsBytes(await src.readAsBytes(), flush: true);
        return dst.path;
      }
    } catch (_) {}
    return 'assets/images/default_exercise.png';
  }
}

// Visible for tests: construye el mapa per_exercise a partir de entradas del formulario
// Los incrementos de peso y rangos de reps se manejan automáticamente
// por AdaptiveIncrementConfig y ProgressionConfig
@visibleForTesting
Map<String, dynamic> buildPerExerciseOverrideMap({
  int? setsMin,
  int? setsMax,
  num? targetRpe,
  int? incrementFrequency,
  ProgressionUnit? unit,
}) {
  final map = <String, dynamic>{
    'sets_min': setsMin,
    'sets_max': setsMax,
    'target_rpe': targetRpe,
    'increment_frequency': incrementFrequency,
  };
  if (unit != null) {
    map['unit'] = unit.name;
  }
  map.removeWhere((k, v) => v == null);
  return map;
}
