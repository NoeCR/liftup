import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/progress_data.dart';
import '../services/progress_service.dart';
import '../../sessions/notifiers/session_notifier.dart';

part 'progress_notifier.g.dart';

@riverpod
class ProgressNotifier extends _$ProgressNotifier {
  @override
  Future<List<ProgressData>> build() async {
    final progressService = ProgressService.instance;
    return await progressService.getAllProgressData();
  }

  /// Actualiza los datos de progreso basándose en las sesiones actuales
  Future<void> refreshFromSessions() async {
    state = const AsyncValue.loading();

    try {
      final sessionNotifier = ref.read(sessionNotifierProvider.notifier);
      final sessions = await sessionNotifier.future;

      final progressService = ProgressService.instance;
      final newProgressData = await progressService.refreshProgressData(sessions);

      state = AsyncValue.data(newProgressData);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Obtiene datos de progreso para un ejercicio específico
  Future<List<ProgressData>> getProgressForExercise(String exerciseId) async {
    final progressService = ProgressService.instance;
    return await progressService.getProgressForExercise(exerciseId);
  }

  /// Obtiene datos de progreso en un rango de fechas
  Future<List<ProgressData>> getProgressInDateRange(DateTime startDate, DateTime endDate) async {
    final progressService = ProgressService.instance;
    return await progressService.getProgressInDateRange(startDate, endDate);
  }

  /// Limpia todos los datos de progreso
  Future<void> clearAllProgress() async {
    state = const AsyncValue.loading();

    try {
      final progressService = ProgressService.instance;
      await progressService.clearAllProgressData();

      state = const AsyncValue.data([]);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Agrega un nuevo dato de progreso
  Future<void> addProgressData(ProgressData progressData) async {
    try {
      final progressService = ProgressService.instance;
      await progressService.saveProgressData([progressData]);

      // Actualizar el estado
      final currentData = state.value ?? [];
      state = AsyncValue.data([...currentData, progressData]);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}
