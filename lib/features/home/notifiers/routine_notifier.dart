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
    print('RoutineNotifier: build() called');
    _routineService = ref.read(routineServiceProvider);
    _uuid = const Uuid();

    // Load initial data if empty
    final routines = await _routineService.getAllRoutines();
    print('RoutineNotifier: Found ${routines.length} routines');

    // Log details of each routine
    for (final routine in routines) {
      print(
        'RoutineNotifier: Routine "${routine.name}" has ${routine.sections.length} sections',
      );
      for (final section in routine.sections) {
        print('  - Section: ${section.name}');
      }
    }

    if (routines.isEmpty) {
      print('RoutineNotifier: No routines found, loading initial data');
      await _loadInitialRoutine();
      final newRoutines = await _routineService.getAllRoutines();
      print(
        'RoutineNotifier: After loading initial data: ${newRoutines.length} routines',
      );
      return newRoutines;
    }

    return routines;
  }

  Future<void> addRoutine(Routine routine) async {
    final newRoutine = routine.copyWith(
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

  Future<Routine?> getRoutineForToday() async {
    final today = DateTime.now().weekday;
    final weekDay = _getWeekDayFromInt(today);
    return await _routineService.getRoutineForDay(weekDay);
  }

  Future<List<Routine>> getRoutinesForDay(WeekDay day) async {
    return await _routineService.getRoutinesForDay(day);
  }

  Future<void> toggleSectionCollapsed(String sectionId) async {
    final currentRoutines = state.value;
    if (currentRoutines == null) return;

    for (final routine in currentRoutines) {
      for (final section in routine.sections) {
        if (section.id == sectionId) {
          final updatedSection = section.copyWith(
            isCollapsed: !section.isCollapsed,
          );

          final updatedSections =
              routine.sections.map((s) {
                return s.id == sectionId ? updatedSection : s;
              }).toList();

          final updatedRoutine = routine.copyWith(sections: updatedSections);
          await updateRoutine(updatedRoutine);
          return;
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

  Future<void> addSectionsToRoutine(
    String routineId,
    List<String> sectionTemplateIds,
  ) async {
    final currentRoutines = state.value;
    if (currentRoutines == null) {
      print('Error: No routines available');
      return;
    }

    try {
      // Find the specific routine
      final routineIndex = currentRoutines.indexWhere((r) => r.id == routineId);
      if (routineIndex == -1) {
        print('Error: Routine with id $routineId not found');
        return;
      }

      final routine = currentRoutines[routineIndex];

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
              routineId: routineId,
              name: template.name,
              exercises: [],
              isCollapsed: false,
              order: template.order,
              sectionTemplateId: template.id,
              iconName: template.iconName,
              muscleGroup: template.muscleGroup ?? SectionMuscleGroup.chest,
            );
          }).toList();

      // Update the routine with new sections
      final updatedSections = [...routine.sections, ...newSections];
      final updatedRoutine = routine.copyWith(sections: updatedSections);

      // Save the updated routine
      await _routineService.saveRoutine(updatedRoutine);

      // Test persistence immediately after saving
      print('RoutineNotifier: Testing persistence after save...');
      await _routineService.testPersistence();

      // Update the state with the updated routine
      final updatedRoutines = List<Routine>.from(currentRoutines);
      updatedRoutines[routineIndex] = updatedRoutine;
      state = AsyncValue.data(updatedRoutines);

      print(
        'Successfully added ${newSections.length} sections to routine $routineId',
      );
      print('Updated routine has ${updatedRoutine.sections.length} sections');
      for (final section in updatedRoutine.sections) {
        print(
          '  - Section: ${section.name} (${section.exercises.length} exercises)',
        );
      }

      // Verify the state was updated correctly
      print(
        'State updated. Current state has ${state.value?.length ?? 0} routines',
      );
      if (state.value != null) {
        final stateRoutine = state.value!.firstWhere((r) => r.id == routineId);
        print(
          'State routine "${stateRoutine.name}" has ${stateRoutine.sections.length} sections',
        );
      }
    } catch (e) {
      print('Error adding sections to routine: $e');
      rethrow; // Re-throw to handle in UI
    }
  }
}
