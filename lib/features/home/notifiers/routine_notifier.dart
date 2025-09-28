import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';
import '../models/routine.dart';
import '../services/routine_service.dart';
import '../../../common/enums/week_day_enum.dart';
import '../../../common/enums/section_muscle_group_enum.dart';
import 'routine_section_template_notifier.dart';

part 'routine_notifier.g.dart';

@riverpod
class RoutineNotifier extends _$RoutineNotifier {
  late final RoutineService _routineService;
  late final Uuid _uuid;

  @override
  Future<List<Routine>> build() async {
    _routineService = ref.read(routineServiceProvider);
    _uuid = const Uuid();

    // Load initial data if empty
    final routines = await _routineService.getAllRoutines();
    if (routines.isEmpty) {
      await _loadInitialRoutine();
      return await _routineService.getAllRoutines();
    }

    return routines;
  }

  Future<void> addRoutine(Routine routine) async {
    final newRoutine = routine.copyWith(
      id: _uuid.v4(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await _routineService.saveRoutine(newRoutine);
    state = AsyncValue.data(await _routineService.getAllRoutines());
  }

  Future<void> updateRoutine(Routine routine) async {
    final updatedRoutine = routine.copyWith(updatedAt: DateTime.now());

    await _routineService.saveRoutine(updatedRoutine);
    state = AsyncValue.data(await _routineService.getAllRoutines());
  }

  Future<void> deleteRoutine(String routineId) async {
    await _routineService.deleteRoutine(routineId);
    state = AsyncValue.data(await _routineService.getAllRoutines());
  }

  Future<Routine?> getRoutineById(String id) async {
    return await _routineService.getRoutineById(id);
  }

  Future<RoutineDay?> getRoutineForToday() async {
    final today = DateTime.now().weekday;
    final weekDay = _getWeekDayFromInt(today);
    return await _routineService.getRoutineForDay(weekDay);
  }

  Future<List<RoutineDay>> getRoutinesForDay(WeekDay day) async {
    return await _routineService.getRoutinesForDay(day);
  }

  Future<void> toggleRoutineActive(String routineId) async {
    final routine = await getRoutineById(routineId);
    if (routine == null) return;

    final updatedRoutine = routine.copyWith(isActive: !routine.isActive);

    await updateRoutine(updatedRoutine);
  }

  Future<void> toggleSectionCollapsed(String sectionId) async {
    final routines = await _routineService.getAllRoutines();

    for (final routine in routines) {
      for (final day in routine.days) {
        for (final section in day.sections) {
          if (section.id == sectionId) {
            final updatedSection = section.copyWith(
              isCollapsed: !section.isCollapsed,
            );

            final updatedSections =
                day.sections.map((s) {
                  return s.id == sectionId ? updatedSection : s;
                }).toList();

            final updatedDay = day.copyWith(sections: updatedSections);
            final updatedDays =
                routine.days.map((d) {
                  return d.id == day.id ? updatedDay : d;
                }).toList();

            final updatedRoutine = routine.copyWith(days: updatedDays);
            await updateRoutine(updatedRoutine);
            return;
          }
        }
      }
    }
  }

  WeekDay _getWeekDayFromInt(int weekday) {
    switch (weekday) {
      case 1:
        return WeekDay.monday;
      case 2:
        return WeekDay.tuesday;
      case 3:
        return WeekDay.wednesday;
      case 4:
        return WeekDay.thursday;
      case 5:
        return WeekDay.friday;
      case 6:
        return WeekDay.saturday;
      case 7:
        return WeekDay.sunday;
      default:
        return WeekDay.monday;
    }
  }

  Future<void> _loadInitialRoutine() async {
    // No crear rutinas automáticamente - el usuario las creará manualmente
    // Esto permite mayor flexibilidad y personalización
  }

  Future<void> addSectionsToDay(
    String routineId,
    String dayId,
    List<String> sectionTemplateIds,
  ) async {
    final currentRoutines = state.value;
    if (currentRoutines == null) return;

    try {
      // Get section templates
      final sectionTemplates = await ref.read(
        routineSectionTemplateNotifierProvider.future,
      );

      // Create sections based on selected templates
      final newSections =
          sectionTemplateIds.map((templateId) {
            final template = sectionTemplates.firstWhere(
              (t) => t.id == templateId,
              orElse: () => sectionTemplates.first,
            );

            return RoutineSection(
              id: _uuid.v4(),
              routineDayId: dayId,
              name: template.name,
              exercises: [],
              isCollapsed: false,
              order: template.order,
              sectionTemplateId: template.id,
              iconName: template.iconName,
              muscleGroup: template.muscleGroup ?? SectionMuscleGroup.chest,
            );
          }).toList();

      final updatedRoutines =
          currentRoutines.map((routine) {
            if (routine.id == routineId) {
              final updatedDays =
                  routine.days.map((day) {
                    if (day.id == dayId) {
                      final updatedSections = [...day.sections, ...newSections];
                      return day.copyWith(sections: updatedSections);
                    }
                    return day;
                  }).toList();
              return routine.copyWith(days: updatedDays);
            }
            return routine;
          }).toList();

      for (final routine in updatedRoutines) {
        await _routineService.saveRoutine(routine);
      }
      state = AsyncValue.data(updatedRoutines);
    } catch (e) {
      print('Error adding sections to day: $e');
    }
  }
}
