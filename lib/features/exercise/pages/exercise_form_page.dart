import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:extended_image/extended_image.dart' as ext_img;
import 'package:extended_image_library/extended_image_library.dart';
import 'package:image/image.dart' as image;
// import 'package:image_cropper/image_cropper.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:file_picker/file_picker.dart';
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
  final _imageUrlController = TextEditingController();
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
    // Hidratar parámetros de entrenamiento desde el contexto de rutina/sección si está disponible
    int sets = 3;
    int reps = 10;
    double weight = 0.0;

    final routines = ref.read(routineNotifierProvider).valueOrNull;
    if (routines != null) {
      if (widget.routineId != null && widget.sectionId != null) {
        final routine = routines.firstWhere(
          (r) => r.id == widget.routineId,
          orElse: () => routines.first,
        );
        final section = routine.sections.firstWhere(
          (s) => s.id == widget.sectionId,
          orElse:
              () =>
                  routine.sections.isNotEmpty
                      ? routine.sections.first
                      : routine.sections.first,
        );
        final re = section.exercises.firstWhere(
          (e) => e.exerciseId == exercise.id || e.id == exercise.id,
          orElse:
              () =>
                  section.exercises.isNotEmpty
                      ? section.exercises.first
                      : section.exercises.first,
        );
        sets = re.sets;
        reps = re.reps;
        weight = re.weight;
      } else {
        // Sin contexto: intenta recuperar la primera ocurrencia del ejercicio en cualquier rutina
        for (final routine in routines) {
          for (final section in routine.sections) {
            final match = section.exercises.where(
              (re) => re.exerciseId == exercise.id,
            );
            if (match.isNotEmpty) {
              final re = match.first;
              sets = re.sets;
              reps = re.reps;
              weight = re.weight;
              break;
            }
          }
        }
      }
    }

    _formSets = sets;
    _formReps = reps;
    _formWeight = weight;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _videoUrlController.dispose();
    _imageUrlController.dispose();
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
              _imagePath.isEmpty ? 'Seleccionar Imagen' : 'Cambiar Imagen',
            ),
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _imageUrlController,
          decoration: const InputDecoration(
            labelText: 'URL de imagen (opcional)',
            hintText: 'https://…/imagen.jpg o file:///…/imagen.jpg',
            border: OutlineInputBorder(),
            helperText: 'Tiene prioridad sobre la imagen local',
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
            label: const Text('Probar imagen'),
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
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _videoUrlController,
                decoration: const InputDecoration(
                  labelText: 'URL del Video',
                  hintText: 'https://youtu.be/… o https://…/video.mp4',
                  border: OutlineInputBorder(),
                  helperText: 'Pega un enlace de YouTube o URL directa',
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
                    label: const Text('Archivo'),
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
                // Ajustar relación de aspecto al espacio de la tarjeta principal (~banner)
                final screenWidth = MediaQuery.of(ctx).size.width;
                final bannerRatio = ((screenWidth - 32) / 120).clamp(1.5, 3.5);
                return ext_img.EditorConfig(
                  maxScale: 8.0,
                  cropRectPadding: const EdgeInsets.all(16),
                  hitTestSize: 20.0,
                  cornerColor: Theme.of(ctx).colorScheme.primary,
                  lineColor: Theme.of(ctx).colorScheme.primary,
                  // Bloquear a relación de aspecto aproximada al contenedor de la tarjeta
                  cropAspectRatio: bannerRatio.toDouble(),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(null),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                final state = editorKey.currentState;
                if (state == null) {
                  Navigator.of(ctx).pop(null);
                  return;
                }
                // Recorte manual con paquete image
                Uint8List croppedBytes;
                final raw = await state.rawImageData;
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
                if (!await imagesDir.exists())
                  await imagesDir.create(recursive: true);
                final filename =
                    'img_${DateTime.now().millisecondsSinceEpoch}.jpg';
                final file = File('${imagesDir.path}/$filename');
                await file.writeAsBytes(croppedBytes, flush: true);
                if (ctx.mounted) Navigator.of(ctx).pop(file.path);
              },
              child: const Text('Recortar y guardar'),
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
        final routines = ref.read(routineNotifierProvider).valueOrNull;
        if (routines != null) {
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
        }
      } else {
        // Sin contexto: actualizar todas las ocurrencias del ejercicio en todas las rutinas
        final routines = ref.read(routineNotifierProvider).valueOrNull;
        if (routines != null) {
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
        }
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
      // Caso 2: imagen local seleccionada → copiar a app dir si no está dentro
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
