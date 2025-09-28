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

  Box get _box => ref.read(databaseServiceProvider.notifier).routinesBox;

  Future<void> saveRoutine(Routine routine) async {
    print(
      'RoutineService: Saving routine "${routine.name}" with ${routine.sections.length} sections',
    );
    for (final section in routine.sections) {
      print('  - Section: ${section.name}');
    }
    await _box.put(routine.id, routine);
    print('RoutineService: Routine saved successfully');
  }

  Future<Routine?> getRoutineById(String id) async {
    return _box.get(id);
  }

  Future<List<Routine>> getAllRoutines() async {
    final routines =
        _box.values.cast<Routine>().toList()
          ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

    print('RoutineService: Loading ${routines.length} routines from database');
    for (final routine in routines) {
      print(
        'RoutineService: Routine "${routine.name}" has ${routine.sections.length} sections',
      );
      for (final section in routine.sections) {
        print('  - Section: ${section.name}');
      }
    }

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

  // Test method to verify persistence
  Future<void> testPersistence() async {
    print('RoutineService: Testing persistence...');
    final routines = await getAllRoutines();
    print('RoutineService: Found ${routines.length} routines in database');

    for (final routine in routines) {
      print(
        'RoutineService: Routine "${routine.name}" has ${routine.sections.length} sections',
      );
      for (final section in routine.sections) {
        print('  - Section: ${section.name} (ID: ${section.id})');
      }
    }
  }
}
