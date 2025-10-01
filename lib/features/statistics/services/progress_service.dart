import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/progress_data.dart';
import '../../sessions/models/workout_session.dart';
import '../../exercise/models/exercise_set.dart';

/// Servicio para generar y gestionar datos de progreso
class ProgressService {
  static ProgressService? _instance;
  static ProgressService get instance => _instance ??= ProgressService._();
  
  ProgressService._();

  /// Genera datos de progreso a partir de las sesiones de entrenamiento
  Future<List<ProgressData>> generateProgressFromSessions(
    List<WorkoutSession> sessions,
  ) async {
    final progressData = <ProgressData>[];
    final uuid = const Uuid();

    // Agrupar sets por ejercicio y fecha
    final exerciseDataByDate = <String, Map<DateTime, List<ExerciseSet>>>{};

    for (final session in sessions) {
      final sessionDate = DateTime(
        session.startTime.year,
        session.startTime.month,
        session.startTime.day,
      );

      for (final set in session.exerciseSets) {
        exerciseDataByDate.putIfAbsent(set.exerciseId, () => {});
        exerciseDataByDate[set.exerciseId]!
            .putIfAbsent(sessionDate, () => [])
            .add(set);
      }
    }

    // Generar ProgressData para cada ejercicio y fecha
    for (final exerciseEntry in exerciseDataByDate.entries) {
      final exerciseId = exerciseEntry.key;
      
      for (final dateEntry in exerciseEntry.value.entries) {
        final date = dateEntry.key;
        final sets = dateEntry.value;

        if (sets.isEmpty) continue;

        // Calcular métricas
        final maxWeight = sets.map((s) => s.weight).reduce((a, b) => a > b ? a : b);
        final totalReps = sets.map((s) => s.reps).reduce((a, b) => a + b);
        final totalSets = sets.length;
        final totalVolume = sets.map((s) => s.weight * s.reps).reduce((a, b) => a + b);

        // Calcular duración aproximada (basada en el tiempo de la sesión)
        final sessionForDate = sessions.firstWhere(
          (s) => DateTime(
            s.startTime.year,
            s.startTime.month,
            s.startTime.day,
          ).isAtSameMomentAs(date),
          orElse: () => sessions.first,
        );
        
        Duration? duration;
        if (sessionForDate.endTime != null) {
          duration = sessionForDate.endTime!.difference(sessionForDate.startTime);
        }

        final progress = ProgressData(
          id: uuid.v4(),
          exerciseId: exerciseId,
          date: date,
          maxWeight: maxWeight,
          totalReps: totalReps,
          totalSets: totalSets,
          totalVolume: totalVolume,
          duration: duration,
        );

        progressData.add(progress);
      }
    }

    // Ordenar por fecha
    progressData.sort((a, b) => a.date.compareTo(b.date));

    return progressData;
  }

  /// Guarda los datos de progreso en Hive
  Future<void> saveProgressData(List<ProgressData> progressData) async {
    final progressBox = Hive.box<ProgressData>('progress');
    
    for (final progress in progressData) {
      // Usar una clave compuesta para evitar duplicados
      final key = '${progress.exerciseId}_${progress.date.millisecondsSinceEpoch}';
      await progressBox.put(key, progress);
    }
  }

  /// Obtiene todos los datos de progreso de Hive
  Future<List<ProgressData>> getAllProgressData() async {
    final progressBox = Hive.box<ProgressData>('progress');
    return progressBox.values.toList();
  }

  /// Obtiene datos de progreso para un ejercicio específico
  Future<List<ProgressData>> getProgressForExercise(String exerciseId) async {
    final allProgress = await getAllProgressData();
    return allProgress.where((p) => p.exerciseId == exerciseId).toList();
  }

  /// Obtiene datos de progreso en un rango de fechas
  Future<List<ProgressData>> getProgressInDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final allProgress = await getAllProgressData();
    return allProgress.where((p) {
      return p.date.isAfter(startDate.subtract(const Duration(days: 1))) &&
             p.date.isBefore(endDate.add(const Duration(days: 1)));
    }).toList();
  }

  /// Limpia todos los datos de progreso
  Future<void> clearAllProgressData() async {
    final progressBox = Hive.box<ProgressData>('progress');
    await progressBox.clear();
  }

  /// Actualiza los datos de progreso basándose en las sesiones actuales
  Future<List<ProgressData>> refreshProgressData(
    List<WorkoutSession> sessions,
  ) async {
    // Limpiar datos existentes
    await clearAllProgressData();
    
    // Generar nuevos datos
    final newProgressData = await generateProgressFromSessions(sessions);
    
    // Guardar en Hive
    await saveProgressData(newProgressData);
    
    return newProgressData;
  }
}
