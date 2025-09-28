import 'package:hive/hive.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/routine.dart';
import '../../../core/database/database_service.dart';

part 'routine_service.g.dart';

@riverpod
class RoutineService extends _$RoutineService {
  @override
  RoutineService build() {
    return this;
  }

  Box get _box => ref.read(databaseServiceProvider.notifier).routinesBox;

  Future<void> saveRoutine(Routine routine) async {
    await _box.put(routine.id, routine);
  }

  Future<Routine?> getRoutineById(String id) async {
    return _box.get(id);
  }

  Future<List<Routine>> getAllRoutines() async {
    return _box.values.cast<Routine>().toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  Future<List<Routine>> getActiveRoutines() async {
    final allRoutines = await getAllRoutines();
    return allRoutines.where((routine) => routine.isActive).toList();
  }

  Future<RoutineDay?> getRoutineForDay(WeekDay day) async {
    final activeRoutines = await getActiveRoutines();

    for (final routine in activeRoutines) {
      for (final routineDay in routine.days) {
        if (routineDay.dayOfWeek == day && routineDay.isActive) {
          return routineDay;
        }
      }
    }

    return null;
  }

  Future<List<RoutineDay>> getRoutinesForDay(WeekDay day) async {
    final activeRoutines = await getActiveRoutines();
    final List<RoutineDay> dayRoutines = [];

    for (final routine in activeRoutines) {
      for (final routineDay in routine.days) {
        if (routineDay.dayOfWeek == day && routineDay.isActive) {
          dayRoutines.add(routineDay);
        }
      }
    }

    return dayRoutines;
  }

  Future<void> deleteRoutine(String id) async {
    await _box.delete(id);
  }

  Future<int> getRoutineCount() async {
    return _box.length;
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
