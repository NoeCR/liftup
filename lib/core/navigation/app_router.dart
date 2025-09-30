import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/home/pages/home_page.dart';
import '../../features/home/pages/create_routine_page.dart';
import '../../features/home/pages/routine_list_page.dart';
import '../../features/exercise/pages/exercise_detail_page.dart';
import '../../features/exercise/pages/exercise_list_page.dart';
import '../../features/exercise/pages/exercise_selection_page.dart';
import '../../features/exercise/pages/exercise_form_page.dart';
import '../../features/sessions/pages/session_page.dart';
import '../../features/statistics/pages/statistics_page.dart';
import '../../features/settings/pages/settings_page.dart';
import '../../features/home/pages/section_templates_page.dart';
import '../../features/home/notifiers/routine_notifier.dart';
import '../../features/exercise/notifiers/exercise_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppRouter {
  static const String home = '/';
  static const String createRoutine = '/create-routine';
  static const String routineList = '/routines';
  static const String exerciseList = '/exercises';
  static const String exerciseSelection = '/exercise-selection';
  static const String exerciseDetail = '/exercise/:id';
  static const String exerciseCreate = '/exercise/create';
  static const String exerciseEdit = '/exercise/edit/:id';
  static const String session = '/session';
  static const String statistics = '/statistics';
  static const String settings = '/settings';
  static const String sectionTemplates = '/section-templates';

  static final GoRouter router = GoRouter(
    initialLocation: home,
    routes: [
      GoRoute(
        path: home,
        name: 'home',
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: createRoutine,
        name: 'createRoutine',
        builder: (context, state) {
          final edit = state.uri.queryParameters['edit'] == 'true';
          final routineId = state.uri.queryParameters['routineId'];

          if (edit && routineId != null) {
            // Para edición, necesitamos obtener la rutina del notifier
            return Consumer(
              builder: (context, ref, child) {
                final routineAsync = ref.watch(routineNotifierProvider);
                return routineAsync.when(
                  data: (routines) {
                    final routine = routines.firstWhere(
                      (r) => r.id == routineId,
                      orElse: () => throw Exception('Rutina no encontrada'),
                    );
                    return CreateRoutinePage(routineToEdit: routine);
                  },
                  loading:
                      () => const Scaffold(
                        body: Center(child: CircularProgressIndicator()),
                      ),
                  error:
                      (error, stack) => Scaffold(
                        body: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.error_outline,
                                size: 64,
                                color: Colors.red,
                              ),
                              const SizedBox(height: 16),
                              Text('Error: $error'),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () => context.go(home),
                                child: const Text('Volver al inicio'),
                              ),
                            ],
                          ),
                        ),
                      ),
                );
              },
            );
          }

          return const CreateRoutinePage();
        },
      ),
      GoRoute(
        path: routineList,
        name: 'routineList',
        builder: (context, state) => const RoutineListPage(),
      ),
      GoRoute(
        path: exerciseList,
        name: 'exerciseList',
        builder: (context, state) => const ExerciseListPage(),
      ),
      GoRoute(
        path: exerciseSelection,
        name: 'exerciseSelection',
        builder: (context, state) {
          final routineId = state.uri.queryParameters['routineId'];
          final sectionId = state.uri.queryParameters['sectionId'];
          final title =
              state.uri.queryParameters['title'] ?? 'Seleccionar Ejercicios';
          final subtitle = state.uri.queryParameters['subtitle'];

          return ExerciseSelectionPage(
            routineId: routineId,
            sectionId: sectionId,
            title: title,
            subtitle: subtitle,
          );
        },
      ),
      // IMPORTANT: Specific routes must come BEFORE the generic '/exercise/:id'
      GoRoute(
        path: exerciseCreate,
        name: 'exerciseCreate',
        builder: (context, state) {
          final routineId = state.uri.queryParameters['routineId'];
          final sectionId = state.uri.queryParameters['sectionId'];
          final returnTo = state.uri.queryParameters['returnTo'];

          return ExerciseFormPage(
            routineId: routineId,
            sectionId: sectionId,
            returnTo: returnTo,
          );
        },
      ),
      GoRoute(
        path: exerciseEdit,
        name: 'exerciseEdit',
        builder: (context, state) {
          final exerciseId = state.pathParameters['id']!;
          return Consumer(
            builder: (context, ref, child) {
              final exerciseAsync = ref.watch(exerciseNotifierProvider);
              return exerciseAsync.when(
                data: (exercises) {
                  final exercise = exercises.firstWhere(
                    (e) => e.id == exerciseId,
                    orElse: () => throw Exception('Ejercicio no encontrado'),
                  );
                  return ExerciseFormPage(exerciseToEdit: exercise);
                },
                loading:
                    () => const Scaffold(
                      body: Center(child: CircularProgressIndicator()),
                    ),
                error:
                    (error, stack) => Scaffold(
                      body: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              size: 64,
                              color: Colors.red,
                            ),
                            const SizedBox(height: 16),
                            Text('Error: $error'),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () => context.go(exerciseList),
                              child: const Text('Volver a ejercicios'),
                            ),
                          ],
                        ),
                      ),
                    ),
              );
            },
          );
        },
      ),
      GoRoute(
        path: exerciseDetail,
        name: 'exerciseDetail',
        builder: (context, state) {
          final exerciseId = state.pathParameters['id']!;
          return ExerciseDetailPage(exerciseId: exerciseId);
        },
      ),
      GoRoute(
        path: session,
        name: 'session',
        builder: (context, state) => const SessionPage(),
      ),
      GoRoute(
        path: statistics,
        name: 'statistics',
        builder: (context, state) => const StatisticsPage(),
      ),
      GoRoute(
        path: settings,
        name: 'settings',
        builder: (context, state) => const SettingsPage(),
      ),
      GoRoute(
        path: sectionTemplates,
        name: 'sectionTemplates',
        builder: (context, state) => const SectionTemplatesPage(),
      ),
    ],
    errorBuilder:
        (context, state) => Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  'Página no encontrada',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  'La página que buscas no existe',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => context.go(home),
                  child: const Text('Volver al inicio'),
                ),
              ],
            ),
          ),
        ),
  );
}
