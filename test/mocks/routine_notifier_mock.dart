import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liftup/features/home/notifiers/routine_notifier.dart';
import 'package:liftup/features/home/models/routine.dart';
import 'package:liftup/common/enums/week_day_enum.dart';

class MockRoutineNotifier extends AsyncNotifier<List<Routine>> {
  List<Routine> _routines = [];
  bool _hasError = false;
  String? _errorMessage;

  void setupMockRoutines(List<Routine> routines) {
    _routines = List.from(routines);
    _hasError = false;
    _errorMessage = null;
  }

  void setupMockError(String message) {
    _hasError = true;
    _errorMessage = message;
    _routines = [];
  }

  void clearMockData() {
    _routines = [];
    _hasError = false;
    _errorMessage = null;
  }

  @override
  Future<List<Routine>> build() async {
    if (_hasError) {
      throw Exception(_errorMessage ?? 'Mock error');
    }
    return _routines;
  }

  // Mock methods for testing
  Future<void> addRoutine(Routine routine) async {
    _routines.add(routine);
    state = AsyncValue.data(_routines);
  }

  Future<void> updateRoutine(Routine routine) async {
    final index = _routines.indexWhere((r) => r.id == routine.id);
    if (index != -1) {
      _routines[index] = routine;
      state = AsyncValue.data(_routines);
    }
  }

  Future<void> deleteRoutine(String id) async {
    _routines.removeWhere((r) => r.id == id);
    state = AsyncValue.data(_routines);
  }

  Future<void> refreshRoutines() async {
    state = AsyncValue.data(_routines);
  }
}
