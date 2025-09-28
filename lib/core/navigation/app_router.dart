import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/home/pages/home_page.dart';
import '../../features/home/pages/create_routine_page.dart';
import '../../features/exercise/pages/exercise_detail_page.dart';
import '../../features/exercise/pages/exercise_list_page.dart';
import '../../features/exercise/pages/exercise_selection_page.dart';
import '../../features/sessions/pages/session_page.dart';
import '../../features/statistics/pages/statistics_page.dart';
import '../../features/settings/pages/settings_page.dart';
import '../../features/home/pages/section_templates_page.dart';

class AppRouter {
  static const String home = '/';
  static const String createRoutine = '/create-routine';
  static const String exerciseList = '/exercises';
  static const String exerciseSelection = '/exercise-selection';
  static const String exerciseDetail = '/exercise/:id';
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
        builder: (context, state) => const CreateRoutinePage(),
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
          final title = state.uri.queryParameters['title'] ?? 'Seleccionar Ejercicios';
          final subtitle = state.uri.queryParameters['subtitle'];
          
          return ExerciseSelectionPage(
            routineId: routineId,
            sectionId: sectionId,
            title: title,
            subtitle: subtitle,
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
