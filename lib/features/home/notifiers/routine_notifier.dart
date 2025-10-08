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
  @override
  Future<List<Routine>> build() async {
    final routineService = ref.read(routineServiceProvider);

    // Load initial data if empty
    final routines = await routineService.getAllRoutines();

    if (routines.isEmpty) {
      await _loadInitialRoutine();
      final newRoutines = await routineService.getAllRoutines();
      return newRoutines;
    }

    return routines;
  }

  Future<void> addRoutine(Routine routine) async {
    final routineService = ref.read(routineServiceProvider);

    // Compute next available display order
    final currentRoutines = await routineService.getAllRoutines();
    final nextOrder =
        currentRoutines.isEmpty
            ? 0
            : (currentRoutines
                    .map((r) => r.order ?? 0)
                    .reduce((a, b) => a > b ? a : b) +
                1);

    final newRoutine = routine.copyWith(
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      order: nextOrder,
    );

    await routineService.saveRoutine(newRoutine);
    state = AsyncValue.data(await routineService.getAllRoutines());
  }

  Future<void> updateRoutine(Routine routine) async {
    final routineService = ref.read(routineServiceProvider);
    final updatedRoutine = routine.copyWith(updatedAt: DateTime.now());

    // Persist routine with updated sections and exercises

    await routineService.saveRoutine(updatedRoutine);
    state = AsyncValue.data(await routineService.getAllRoutines());
    // Routine saved successfully
  }

  Future<void> deleteRoutine(String routineId) async {
    final routineService = ref.read(routineServiceProvider);
    await routineService.deleteRoutine(routineId);
    state = AsyncValue.data(await routineService.getAllRoutines());
  }

  Future<Routine?> getRoutineById(String id) async {
    final routineService = ref.read(routineServiceProvider);
    return await routineService.getRoutineById(id);
  }

  Future<Routine?> getRoutineForToday() async {
    final routineService = ref.read(routineServiceProvider);
    final today = DateTime.now().weekday;
    final weekDay = _getWeekDayFromInt(today);
    return await routineService.getRoutineForDay(weekDay);
  }

  Future<List<Routine>> getRoutinesForDay(WeekDay day) async {
    final routineService = ref.read(routineServiceProvider);
    return await routineService.getRoutinesForDay(day);
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
    // Do not create routines automatically — the user will create them manually
    // This allows greater flexibility and customization
  }

  /// Reorders routines manually
  Future<void> reorderRoutines(List<String> routineIds) async {
    final currentRoutines = state.value;
    if (currentRoutines == null) return;

    final routineService = ref.read(routineServiceProvider);

    // Actualizar el orden de cada rutina
    for (int i = 0; i < routineIds.length; i++) {
      final routineId = routineIds[i];
      final routine = currentRoutines.firstWhere((r) => r.id == routineId);
      final updatedRoutine = routine.copyWith(order: i);
      await routineService.saveRoutine(updatedRoutine);
    }

    // Actualizar el estado
    state = AsyncValue.data(await routineService.getAllRoutines());
  }

  /// Moves a routine to a specific position
  Future<void> moveRoutineToPosition(String routineId, int newPosition) async {
    final currentRoutines = state.value;
    if (currentRoutines == null) return;

    // Crear nueva lista de IDs con la rutina movida
    final routineIds = currentRoutines.map((r) => r.id).toList();
    routineIds.remove(routineId);
    routineIds.insert(newPosition, routineId);

    // Reordenar todas las rutinas
    await reorderRoutines(routineIds);
  }

  Future<void> addSectionsToRoutine(
    String routineId,
    List<String> sectionTemplateIds,
  ) async {
    final currentRoutines = state.value;
    if (currentRoutines == null) {
      return;
    }

    try {
      // Find the specific routine
      final routineIndex = currentRoutines.indexWhere((r) => r.id == routineId);
      if (routineIndex == -1) {
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

            final uuid = const Uuid();
            return RoutineSection(
              id: uuid.v4(),
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
      final routineService = ref.read(routineServiceProvider);
      await routineService.saveRoutine(updatedRoutine);

      // Update the state with the updated routine
      final updatedRoutines = List<Routine>.from(currentRoutines);
      updatedRoutines[routineIndex] = updatedRoutine;
      state = AsyncValue.data(updatedRoutines);
    } catch (e) {
      rethrow; // Re-throw to handle in UI
    }
  }
}
