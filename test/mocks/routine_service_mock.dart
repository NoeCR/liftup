import 'package:liftup/features/home/services/routine_service.dart';
import 'package:liftup/features/home/models/routine.dart';
import 'package:liftup/common/enums/week_day_enum.dart';

class MockRoutineService extends RoutineService {
  List<Routine> _routines = [];
  Exception? _getAllRoutinesError;
  Exception? _saveRoutineError;
  Exception? _deleteRoutineError;

  @override
  RoutineService build() {
    return this;
  }

  void setupMockBehavior() {
    _routines = [];
    _getAllRoutinesError = null;
    _saveRoutineError = null;
    _deleteRoutineError = null;
  }

  void setGetAllRoutinesError(Exception error) {
    _getAllRoutinesError = error;
  }

  void setSaveRoutineError(Exception error) {
    _saveRoutineError = error;
  }

  void setDeleteRoutineError(Exception error) {
    _deleteRoutineError = error;
  }

  void clearMockData() {
    _routines = [];
  }

  void setupMockRoutines(List<Routine> routines) {
    _routines = List.from(routines);
  }

  @override
  Future<void> saveRoutine(Routine routine) async {
    if (_saveRoutineError != null) {
      throw _saveRoutineError!;
    }
    final index = _routines.indexWhere((r) => r.id == routine.id);
    if (index != -1) {
      _routines[index] = routine;
    } else {
      _routines.add(routine);
    }
  }

  @override
  Future<Routine?> getRoutineById(String id) async {
    try {
      return _routines.firstWhere((r) => r.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<Routine>> getAllRoutines() async {
    if (_getAllRoutinesError != null) {
      throw _getAllRoutinesError!;
    }
    final routines = List<Routine>.from(_routines);

    // Ordenar por orden manual (order) y luego por fecha de creación como fallback
    routines.sort((a, b) {
      // Si ambas tienen order definido, usar order
      if (a.order != null && b.order != null) {
        return a.order!.compareTo(b.order!);
      }
      // Si solo una tiene order, la que tiene order va primero
      if (a.order != null && b.order == null) return -1;
      if (a.order == null && b.order != null) return 1;
      // Si ninguna tiene order, usar fecha de creación (más antiguo primero)
      return a.createdAt.compareTo(b.createdAt);
    });

    return routines;
  }

  @override
  Future<void> deleteRoutine(String id) async {
    if (_deleteRoutineError != null) {
      throw _deleteRoutineError!;
    }
    _routines.removeWhere((r) => r.id == id);
  }

  @override
  Future<int> getRoutineCount() async {
    return _routines.length;
  }

  @override
  Future<List<Routine>> getRoutinesForDay(WeekDay day) async {
    return _routines.where((routine) => routine.days.contains(day)).toList();
  }

  @override
  Future<Routine?> getRoutineForDay(WeekDay day) async {
    try {
      return _routines.firstWhere((routine) => routine.days.contains(day));
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<Routine>> getActiveRoutines() async {
    // Todas las rutinas están activas por defecto
    return await getAllRoutines();
  }

  @override
  Future<void> reorderRoutines(List<String> routineIds) async {
    for (int i = 0; i < routineIds.length; i++) {
      final routine = _routines.firstWhere((r) => r.id == routineIds[i]);
      final updatedRoutine = routine.copyWith(order: i);
      final index = _routines.indexWhere((r) => r.id == routineIds[i]);
      _routines[index] = updatedRoutine;
    }
  }

  @override
  Future<List<Routine>> searchRoutines(String query) async {
    if (query.isEmpty) return await getAllRoutines();

    return _routines.where((routine) {
      return routine.name.toLowerCase().contains(query.toLowerCase()) ||
          routine.description.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }
}
