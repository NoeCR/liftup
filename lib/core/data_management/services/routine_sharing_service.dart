import 'dart:io';
import 'dart:convert';
import '../models/routine_sharing.dart';
import '../models/export_config.dart';
import '../models/export_type.dart';
import '../exporters/export_factory.dart';
import '../services/metadata_service.dart';
import '../importers/import_builder.dart';
import '../../../features/home/models/routine.dart';
import '../../../features/exercise/models/exercise.dart';

/// Servicio para compartir rutinas
abstract class RoutineSharingService {
  /// Comparte una rutina
  Future<ShareResult> shareRoutine({
    required String routineId,
    required String userId,
    required ShareConfig config,
    required Routine routine,
    required List<Exercise> exercises,
  });

  /// Obtiene una rutina compartida por ID
  Future<SharedRoutine?> getSharedRoutine(String shareId);

  /// Lista las rutinas compartidas por un usuario
  Future<List<SharedRoutine>> getUserSharedRoutines(String userId);

  /// Actualiza una rutina compartida
  Future<bool> updateSharedRoutine(String shareId, ShareConfig config);

  /// Elimina una rutina compartida
  Future<bool> deleteSharedRoutine(String shareId);

  /// Incrementa el contador de visualizaciones
  Future<void> incrementViewCount(String shareId);

  /// Incrementa el contador de descargas
  Future<void> incrementDownloadCount(String shareId);
}

/// Simulated implementation of the sharing service
class MockRoutineSharingService implements RoutineSharingService {
  final Map<String, SharedRoutine> _sharedRoutines = {};
  final Map<String, Map<String, dynamic>> _sharedData = {};

  @override
  Future<ShareResult> shareRoutine({
    required String routineId,
    required String userId,
    required ShareConfig config,
    required Routine routine,
    required List<Exercise> exercises,
  }) async {
    try {
      // Configure export for routines and exercises only
      final exportConfig = const ExportConfig(
        includeSessions: false,
        includeExercises: true,
        includeRoutines: true,
        includeProgressData: false,
        includeUserSettings: false,
        includeMetadata: true,
      );

      // Usar ExportFactory para crear el exportador JSON
      final exporter = ExportFactory.createExporter(
        type: ExportType.json,
        config: exportConfig,
        routines: [routine],
        exercises: exercises,
        sessions: [],
        progressData: [],
        userSettings: {},
        metadata: await MetadataService.instance.createExportMetadata(),
      );

      final filePath = await exporter.export();

      // Crear rutina compartida
      final shareId = 'share_${DateTime.now().millisecondsSinceEpoch}';
      final sharedRoutine = SharedRoutine(
        id: shareId,
        routineId: routineId,
        ownerId: userId,
        title: config.title,
        description: config.description,
        visibility: config.visibility,
        status: SharedRoutineStatus.active,
        createdAt: DateTime.now(),
        expiresAt: config.expiresAt,
        tags: config.tags,
        metadata: {
          'allowDownload': config.allowDownload,
          'allowComments': config.allowComments,
          'exerciseCount': exercises.length,
        },
      );

      _sharedRoutines[shareId] = sharedRoutine;
      _sharedData[shareId] = await _loadSharedData(filePath);

      // Generate sharing URL
      final shareUrl = 'https://liftly.app/share/$shareId';

      // Limpiar archivo temporal
      await File(filePath).delete();

      return ShareResult.success(shareId: shareId, shareUrl: shareUrl);
    } catch (e) {
      return ShareResult.failure('Error al compartir rutina: $e');
    }
  }

  @override
  Future<SharedRoutine?> getSharedRoutine(String shareId) async {
    try {
      // Simular consulta a la nube
      await Future.delayed(const Duration(milliseconds: 300));

      final sharedRoutine = _sharedRoutines[shareId];
      if (sharedRoutine != null) {
        // Incrementar contador de visualizaciones
        await incrementViewCount(shareId);
      }

      return sharedRoutine;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<SharedRoutine>> getUserSharedRoutines(String userId) async {
    try {
      // Simular consulta a la nube
      await Future.delayed(const Duration(milliseconds: 500));

      return _sharedRoutines.values
          .where((routine) => routine.ownerId == userId)
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (e) {
      return [];
    }
  }

  @override
  Future<bool> updateSharedRoutine(String shareId, ShareConfig config) async {
    try {
      // Simulate cloud update
      await Future.delayed(const Duration(milliseconds: 500));

      final existingRoutine = _sharedRoutines[shareId];
      if (existingRoutine == null) return false;

      final updatedRoutine = existingRoutine.copyWith(
        title: config.title,
        description: config.description,
        visibility: config.visibility,
        expiresAt: config.expiresAt,
        tags: config.tags,
        metadata: {
          'allowDownload': config.allowDownload,
          'allowComments': config.allowComments,
          'exerciseCount': existingRoutine.metadata?['exerciseCount'],
        },
      );

      _sharedRoutines[shareId] = updatedRoutine;
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> deleteSharedRoutine(String shareId) async {
    try {
      // Simulate cloud deletion
      await Future.delayed(const Duration(milliseconds: 500));

      _sharedRoutines.remove(shareId);
      _sharedData.remove(shareId);

      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<void> incrementViewCount(String shareId) async {
    final routine = _sharedRoutines[shareId];
    if (routine != null) {
      _sharedRoutines[shareId] = routine.copyWith(
        viewCount: routine.viewCount + 1,
      );
    }
  }

  @override
  Future<void> incrementDownloadCount(String shareId) async {
    final routine = _sharedRoutines[shareId];
    if (routine != null) {
      _sharedRoutines[shareId] = routine.copyWith(
        downloadCount: routine.downloadCount + 1,
      );
    }
  }

  /// Carga los datos compartidos desde el archivo
  Future<Map<String, dynamic>> _loadSharedData(String filePath) async {
    final file = File(filePath);
    final jsonString = await file.readAsString();
    return jsonDecode(jsonString) as Map<String, dynamic>;
  }

  /// Obtiene los datos de una rutina compartida
  Future<Map<String, dynamic>?> getSharedRoutineData(String shareId) async {
    try {
      // Simular descarga desde la nube
      await Future.delayed(const Duration(milliseconds: 500));

      return _sharedData[shareId];
    } catch (e) {
      return null;
    }
  }
}

/// Servicio para importar rutinas compartidas
class SharedRoutineImportService {
  final RoutineSharingService _sharingService;

  SharedRoutineImportService({required RoutineSharingService sharingService})
    : _sharingService = sharingService;

  /// Importa una rutina compartida
  Future<ImportResult> importSharedRoutine(String shareId) async {
    try {
      // Obtain shared routine info
      final sharedRoutine = await _sharingService.getSharedRoutine(shareId);
      if (sharedRoutine == null) {
        return ImportResult(
          success: false,
          importedCount: 0,
          skippedCount: 0,
          errorCount: 1,
          errorMessage: 'Rutina compartida no encontrada',
          importedSessions: [],
          importedExercises: [],
          importedRoutines: [],
          importedProgressData: [],
          errors: ['Rutina no encontrada'],
          warnings: [],
        );
      }

      // Verificar si la rutina ha expirado
      if (sharedRoutine.expiresAt != null &&
          DateTime.now().isAfter(sharedRoutine.expiresAt!)) {
        return ImportResult(
          success: false,
          importedCount: 0,
          skippedCount: 0,
          errorCount: 1,
          errorMessage: 'La rutina compartida ha expirado',
          importedSessions: [],
          importedExercises: [],
          importedRoutines: [],
          importedProgressData: [],
          errors: ['Rutina expirada'],
          warnings: [],
        );
      }

      // Obtener datos de la rutina
      final mockService = _sharingService as MockRoutineSharingService;
      final data = await mockService.getSharedRoutineData(shareId);
      if (data == null) {
        return ImportResult(
          success: false,
          importedCount: 0,
          skippedCount: 0,
          errorCount: 1,
          errorMessage: 'No se pudieron obtener los datos de la rutina',
          importedSessions: [],
          importedExercises: [],
          importedRoutines: [],
          importedProgressData: [],
          errors: ['Datos no disponibles'],
          warnings: [],
        );
      }

      // Incrementar contador de descargas
      await _sharingService.incrementDownloadCount(shareId);

      // Procesar los datos importados
      final importedRoutines = <Routine>[];
      final importedExercises = <Exercise>[];

      if (data.containsKey('routines')) {
        final routinesData = data['routines'] as List;
        for (final routineData in routinesData) {
          try {
            final routine = Routine.fromJson(
              routineData as Map<String, dynamic>,
            );
            importedRoutines.add(routine);
          } catch (e) {
            // Error importing specific routine
          }
        }
      }

      if (data.containsKey('exercises')) {
        final exercisesData = data['exercises'] as List;
        for (final exerciseData in exercisesData) {
          try {
            final exercise = Exercise.fromJson(
              exerciseData as Map<String, dynamic>,
            );
            importedExercises.add(exercise);
          } catch (e) {
            // Error importing specific exercise
          }
        }
      }

      return ImportResult(
        success: true,
        importedCount: importedRoutines.length + importedExercises.length,
        skippedCount: 0,
        errorCount: 0,
        importedSessions: [],
        importedExercises: importedExercises,
        importedRoutines: importedRoutines,
        importedProgressData: [],
        errors: [],
        warnings: [],
      );
    } catch (e) {
      return ImportResult(
        success: false,
        importedCount: 0,
        skippedCount: 0,
        errorCount: 1,
        errorMessage: 'Error importing shared routine: $e',
        importedSessions: [],
        importedExercises: [],
        importedRoutines: [],
        importedProgressData: [],
        errors: ['Import error: $e'],
        warnings: [],
      );
    }
  }
}
