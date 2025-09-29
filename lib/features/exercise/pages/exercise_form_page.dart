import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../notifiers/exercise_notifier.dart';
import '../../home/notifiers/routine_notifier.dart';
import '../models/exercise.dart';
import '../../../common/enums/muscle_group_enum.dart';

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
  final _tipsController = TextEditingController();
  final _commonMistakesController = TextEditingController();

  ExerciseCategory _selectedCategory = ExerciseCategory.chest;
  ExerciseDifficulty _selectedDifficulty = ExerciseDifficulty.beginner;
  List<MuscleGroup> _selectedMuscleGroups = [];
  String _imagePath = '';
  bool _isLoading = false;
  int _formSets = 3;
  int _formReps = 10;
  double _formWeight = 0.0;

  @override
  void initState() {
    super.initState();
    if (widget.exerciseToEdit != null) {
      _populateForm();
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
    // Valores por defecto de entrenamiento (si viniera con contexto se podrían hidratar)
    _formSets = 3;
    _formReps = 10;
    _formWeight = 0.0;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _videoUrlController.dispose();
    _tipsController.dispose();
    _commonMistakesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isEditing = widget.exerciseToEdit != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Ejercicio' : 'Nuevo Ejercicio'),
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

              // Save Button
              _buildSaveButton(),
            ],
          ),
        ),
      ),
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
                color: colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: colorScheme.outline,
                  style: BorderStyle.solid,
                ),
              ),
              child:
                  _imagePath.isNotEmpty
                      ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child:
                            _imagePath.startsWith('assets/')
                                ? Image.asset(
                                  _imagePath,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return _buildImagePlaceholder();
                                  },
                                )
                                : Image.network(
                                  _imagePath,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return _buildImagePlaceholder();
                                  },
                                ),
                      )
                      : _buildImagePlaceholder(),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: TextButton.icon(
            onPressed: _pickImage,
            icon: const Icon(Icons.camera_alt),
            label: Text(
              _imagePath.isEmpty ? 'Seleccionar Imagen' : 'Cambiar Imagen',
            ),
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
          'Agregar imagen',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildBasicInfoSection() {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Información Básica',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: 'Nombre del Ejercicio',
            hintText: 'Ej: Press de Banca',
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'El nombre es obligatorio';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _descriptionController,
          decoration: const InputDecoration(
            labelText: 'Descripción',
            hintText: 'Describe cómo realizar el ejercicio...',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'La descripción es obligatoria';
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
          'Categoría y Dificultad',
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
                decoration: const InputDecoration(
                  labelText: 'Categoría',
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
                decoration: const InputDecoration(
                  labelText: 'Dificultad',
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
          'Músculos Trabajados',
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
                'Selecciona los músculos que trabaja este ejercicio:',
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
                    'Selecciona al menos un músculo',
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
          decoration: const InputDecoration(
            labelText: 'Consejos (uno por línea)',
            hintText: 'Mantén los pies firmes en el suelo\nContrae el core...',
            border: OutlineInputBorder(),
            helperText: 'Escribe cada consejo en una línea separada',
          ),
          maxLines: 4,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _commonMistakesController,
          decoration: const InputDecoration(
            labelText: 'Errores Comunes (uno por línea)',
            hintText: 'Rebotar la barra en el pecho\nArquear excesivamente...',
            border: OutlineInputBorder(),
            helperText: 'Escribe cada error en una línea separada',
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
          'Video de Demostración (Opcional)',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _videoUrlController,
          decoration: const InputDecoration(
            labelText: 'URL del Video',
            hintText: 'https://example.com/video.mp4',
            border: OutlineInputBorder(),
            helperText: 'Opcional: URL de un video demostrativo',
          ),
          keyboardType: TextInputType.url,
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
          'Parámetros de Entrenamiento',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                initialValue: _formSets.toString(),
                decoration: const InputDecoration(
                  labelText: 'Series',
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
                initialValue: _formReps.toString(),
                decoration: const InputDecoration(
                  labelText: 'Repeticiones',
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
                initialValue: _formWeight.toStringAsFixed(1),
                decoration: const InputDecoration(
                  labelText: 'Peso (kg)',
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
                  title: const Text('Galería'),
                  onTap: () async {
                    Navigator.pop(context);
                    await _pickImageFromSource(ImageSource.gallery);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: const Text('Cámara'),
                  onTap: () async {
                    Navigator.pop(context);
                    await _pickImageFromSource(ImageSource.camera);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.delete),
                  title: const Text('Eliminar imagen'),
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
      setState(() {
        _imagePath = image.path;
      });
    }
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
        const SnackBar(
          content: Text('Selecciona al menos un músculo trabajado'),
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

      final exercise = Exercise(
        id: widget.exerciseToEdit?.id ?? '',
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        imageUrl:
            _imagePath.isNotEmpty
                ? _imagePath
                : 'assets/images/default_exercise.png',
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
      );

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

      // Si viene con contexto de rutina/sección, aplicar series/reps/peso como defaults en esa sección
      if (widget.routineId != null && widget.sectionId != null) {
        final routineAsync = ref.read(routineNotifierProvider);
        await routineAsync.whenData((routines) async {
          final routine = routines.firstWhere(
            (r) => r.id == widget.routineId,
            orElse: () => throw Exception('Rutina no encontrada'),
          );

          final updatedSections =
              routine.sections.map((s) {
                if (s.id != widget.sectionId) return s;
                final updatedExercises =
                    s.exercises.map((re) {
                      if (re.exerciseId == exercise.id ||
                          re.id == exercise.id) {
                        return re.copyWith(
                          sets: _formSets,
                          reps: _formReps,
                          weight: _formWeight,
                        );
                      }
                      return re;
                    }).toList();
                return s.copyWith(exercises: updatedExercises);
              }).toList();

          final updatedRoutine = routine.copyWith(
            sections: updatedSections,
            updatedAt: DateTime.now(),
          );
          await ref
              .read(routineNotifierProvider.notifier)
              .updateRoutine(updatedRoutine);
        });
      } else {
        // Sin contexto: actualizar todas las ocurrencias del ejercicio en todas las rutinas
        final routineAsync = ref.read(routineNotifierProvider);
        await routineAsync.whenData((routines) async {
          for (final routine in routines) {
            bool changed = false;
            final updatedSections =
                routine.sections.map((s) {
                  final updatedExercises =
                      s.exercises.map((re) {
                        if (re.exerciseId == exercise.id) {
                          changed = true;
                          return re.copyWith(
                            sets: _formSets,
                            reps: _formReps,
                            weight: _formWeight,
                          );
                        }
                        return re;
                      }).toList();
                  return s.copyWith(exercises: updatedExercises);
                }).toList();

            if (changed) {
              final updatedRoutine = routine.copyWith(
                sections: updatedSections,
                updatedAt: DateTime.now(),
              );
              await ref
                  .read(routineNotifierProvider.notifier)
                  .updateRoutine(updatedRoutine);
            }
          }
        });
      }

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
}
