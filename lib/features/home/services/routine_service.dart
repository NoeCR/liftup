import 'package:hive/hive.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/routine.dart';
import '../../../common/enums/week_day_enum.dart';
import '../../../core/database/database_service.dart';

part 'routine_service.g.dart';

@riverpod
class RoutineService extends _$RoutineService {
  @override
  RoutineService build() {
    return this;
  }

  Box get _box {
    return DatabaseService.getInstance().routinesBox;
  }

  Future<void> saveRoutine(Routine routine) async {
    final box = _box;
    await box.put(routine.id, routine);
  }

  Future<Routine?> getRoutineById(String id) async {
    final box = _box;
    return box.get(id);
  }

  Future<List<Routine>> getAllRoutines() async {
    final box = _box;
    final routines =
        box.values.cast<Routine>().toList()
          ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

    return routines;
  }

  Future<List<Routine>> getActiveRoutines() async {
    // Todas las rutinas están activas por defecto
    return await getAllRoutines();
  }

  Future<Routine?> getRoutineForDay(WeekDay day) async {
    final allRoutines = await getAllRoutines();

    for (final routine in allRoutines) {
      if (routine.days.contains(day)) {
        return routine;
      }
    }

    return null;
  }

  Future<List<Routine>> getRoutinesForDay(WeekDay day) async {
    final allRoutines = await getAllRoutines();
    final List<Routine> dayRoutines = [];

    for (final routine in allRoutines) {
      if (routine.days.contains(day)) {
        dayRoutines.add(routine);
      }
    }

    return dayRoutines;
  }

  Future<void> deleteRoutine(String id) async {
    final box = _box;
    await box.delete(id);
  }

  Future<int> getRoutineCount() async {
    final box = _box;
    return box.length;
  }

  Future<List<Routine>> searchRoutines(String query) async {
    final allRoutines = await getAllRoutines();
    final lowercaseQuery = query.toLowerCase();

    return allRoutines.where((routine) {
      return routine.name.toLowerCase().contains(lowercaseQuery) ||
          routine.description.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }
}
