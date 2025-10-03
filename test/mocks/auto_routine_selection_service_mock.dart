import 'package:liftup/features/home/services/auto_routine_selection_service.dart';
import 'package:liftup/features/home/models/routine.dart';
import 'package:liftup/common/enums/week_day_enum.dart';

class MockAutoRoutineSelectionService implements AutoRoutineSelectionService {
  WeekDay? _mockCurrentDay;

  void setMockCurrentDay(WeekDay day) {
    _mockCurrentDay = day;
  }

  void clearMockCurrentDay() {
    _mockCurrentDay = null;
  }

  @override
  WeekDay getCurrentWeekDay() {
    if (_mockCurrentDay != null) {
      return _mockCurrentDay!;
    }
    // Default to Monday if no mock day is set
    return WeekDay.monday;
  }

  @override
  List<Routine> findRoutinesForToday(List<Routine> routines) {
    final today = getCurrentWeekDay();
    return routines.where((routine) => routine.days.contains(today)).toList();
  }

  @override
  Routine? selectRoutineForToday(List<Routine> routines) {
    final todayRoutines = findRoutinesForToday(routines);
    if (todayRoutines.isEmpty) return null;

    // Ordenar por order (menor primero) y luego por fecha de creación
    todayRoutines.sort((a, b) {
      if (a.order != null && b.order != null) {
        return a.order!.compareTo(b.order!);
      }
      if (a.order != null && b.order == null) return -1;
      if (a.order == null && b.order != null) return 1;
      return a.createdAt.compareTo(b.createdAt);
    });

    return todayRoutines.first;
  }

  @override
  int calculateRoutinePriority(Routine routine, List<Routine> allRoutines) {
    // Prioridad basada en frecuencia de días
    final frequency = routine.days.length;
    return frequency * 1000; // Base priority
  }

  @override
  Routine? getNextScheduledRoutine(List<Routine> routines, WeekDay fromDay) {
    final allDays = WeekDay.values;
    final currentIndex = allDays.indexOf(fromDay);

    // Buscar desde el día siguiente
    for (int i = 1; i < allDays.length; i++) {
      final nextIndex = (currentIndex + i) % allDays.length;
      final nextDay = allDays[nextIndex];

      final routinesForDay =
          routines.where((r) => r.days.contains(nextDay)).toList();
      if (routinesForDay.isNotEmpty) {
        return routinesForDay.first;
      }
    }

    return null;
  }

  @override
  bool isValidRoutine(Routine routine) {
    return routine.days.isNotEmpty;
  }

  @override
  AutoSelectionInfo getAutoSelectionInfo(List<Routine> routines) {
    final today = getCurrentWeekDay();
    final todayRoutines = findRoutinesForToday(routines);
    final selectedRoutine = selectRoutineForToday(routines);

    return AutoSelectionInfo(
      currentDay: today,
      availableRoutines: todayRoutines,
      selectedRoutine: selectedRoutine,
      hasSelection: selectedRoutine != null,
    );
  }
}
