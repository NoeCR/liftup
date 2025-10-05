import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import '../notifiers/session_notifier.dart';
import '../../sessions/models/workout_session.dart';
import '../../home/notifiers/routine_notifier.dart';
import '../../home/models/routine.dart';
import '../../exercise/notifiers/exercise_notifier.dart';
import '../../exercise/models/exercise.dart';
import '../../exercise/models/exercise_set.dart';

class SessionSummaryPage extends ConsumerWidget {
  final String? sessionId;
  const SessionSummaryPage({super.key, this.sessionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionsAsync = ref.watch(sessionNotifierProvider);

    return sessionsAsync.when(
      data: (sessions) {
        // Escoger sesión específica si sessionId viene; si no, tomar la última completada
        WorkoutSession? session;
        if (sessionId != null) {
          try {
            session = sessions.firstWhere((s) => s.id == sessionId);
          } catch (_) {
            session = null;
          }
        }
        session ??=
            (() {
              final completed =
                  sessions.where((s) => s.status == SessionStatus.completed).toList()
                    ..sort((a, b) => b.endTime?.compareTo(a.endTime ?? DateTime(0)) ?? 0);
              return completed.isNotEmpty ? completed.first : null;
            })();

        return Scaffold(
          appBar: AppBar(title: Text(context.tr('session.summary'))),
          body:
              session == null
                  ? Center(child: Text(context.tr('session.noCompletedSession')))
                  : Padding(
                    padding: const EdgeInsets.all(16),
                    child: Consumer(
                      builder: (context, ref, _) {
                        final s = session!;
                        final routinesAsync = ref.watch(routineNotifierProvider);
                        final exercisesAsync = ref.watch(exerciseNotifierProvider);

                        return routinesAsync.when(
                          data: (routines) {
                            final routine = s.routineId == null ? null : _findRoutine(routines, s.routineId!);
                            return exercisesAsync.when(
                              data: (exercises) {
                                final exerciseMap = {for (final e in exercises) e.id: e};

                                // Agrupar sets por ejercicio
                                final setsByExercise = <String, List<ExerciseSet>>{};
                                for (final set in s.exerciseSets) {
                                  setsByExercise.putIfAbsent(set.exerciseId, () => <ExerciseSet>[]).add(set);
                                }

                                // Construir breakdown por sección si hay rutina
                                final sections = routine?.sections ?? <RoutineSection>[];

                                return ListView(
                                  children: [
                                    _SummaryTile(
                                      title: context.tr('session.routine'),
                                      value: routine?.name ?? 'Sin rutina',
                                    ),
                                    const SizedBox(height: 8),
                                    _SummaryTile(
                                      title: context.tr('session.date'),
                                      value: s.startTime.toLocal().toString(),
                                    ),
                                    const SizedBox(height: 8),
                                    _SummaryTile(
                                      title: context.tr('session.duration'),
                                      value: _formatDuration((s.endTime ?? DateTime.now()).difference(s.startTime)),
                                    ),
                                    const SizedBox(height: 8),
                                    _SummaryTile(title: context.tr('session.totalReps'), value: '${s.totalReps ?? 0}'),
                                    const SizedBox(height: 8),
                                    _SummaryTile(
                                      title: context.tr('session.totalWeight'),
                                      value: (s.totalWeight ?? 0).toStringAsFixed(1),
                                    ),
                                    const SizedBox(height: 16),
                                    if (sections.isNotEmpty)
                                      Text('Detalle por sección', style: Theme.of(context).textTheme.titleMedium),
                                    const SizedBox(height: 8),
                                    for (final sec in sections) ...[
                                      _SectionSummary(
                                        section: sec,
                                        exerciseMap: exerciseMap,
                                        setsByExercise: setsByExercise,
                                      ),
                                      const SizedBox(height: 12),
                                    ],
                                    if (sections.isEmpty && setsByExercise.isNotEmpty) ...[
                                      Text('Ejercicios', style: Theme.of(context).textTheme.titleMedium),
                                      const SizedBox(height: 8),
                                      for (final entry in setsByExercise.entries) ...[
                                        _ExerciseSummaryRow(exercise: exerciseMap[entry.key], sets: entry.value),
                                        const Divider(height: 12),
                                      ],
                                    ],
                                  ],
                                );
                              },
                              loading: () => const Center(child: CircularProgressIndicator()),
                              error:
                                  (e, _) => Center(
                                    child: Text(
                                      context.tr('errors.errorLoadingData', namedArgs: {'error': e.toString()}),
                                    ),
                                  ),
                            );
                          },
                          loading: () => const Center(child: CircularProgressIndicator()),
                          error: (e, _) => Center(child: Text('Error: $e')),
                        );
                      },
                    ),
                  ),
        );
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error:
          (e, _) => Scaffold(
            body: Center(child: Text(context.tr('errors.errorLoadingData', namedArgs: {'error': e.toString()}))),
          ),
    );
  }

  String _formatDuration(Duration d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.inHours)}:${two(d.inMinutes % 60)}:${two(d.inSeconds % 60)}';
  }
}

Routine? _findRoutine(List<Routine> routines, String id) {
  try {
    return routines.firstWhere((r) => r.id == id);
  } catch (_) {
    return null;
  }
}

class _SectionSummary extends StatelessWidget {
  final RoutineSection section;
  final Map<String, Exercise> exerciseMap;
  final Map<String, List<ExerciseSet>> setsByExercise;
  const _SectionSummary({required this.section, required this.exerciseMap, required this.setsByExercise});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(section.name, style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          if (section.exercises.isEmpty)
            Text('Sin ejercicios', style: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor))
          else
            ...section.exercises.map((re) {
              final ex = exerciseMap[re.exerciseId];
              final sets = setsByExercise[re.exerciseId] ?? const <ExerciseSet>[];
              return _ExerciseSummaryRow(exercise: ex, sets: sets, plannedSets: ex?.defaultSets ?? 3);
            }),
        ],
      ),
    );
  }
}

class _ExerciseSummaryRow extends StatelessWidget {
  final Exercise? exercise;
  final List<ExerciseSet> sets;
  final int? plannedSets;
  const _ExerciseSummaryRow({required this.exercise, required this.sets, this.plannedSets});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final completed = sets.length;
    final totalReps = sets.fold<int>(0, (sum, s) => sum + s.reps);
    final totalWeight = sets.fold<double>(0, (sum, s) => sum + s.weight * s.reps);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: colorScheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(exercise?.name ?? 'Ejercicio', style: theme.textTheme.titleSmall),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    _chip(context, 'Series: $completed${plannedSets != null ? '/$plannedSets' : ''}'),
                    _chip(context, 'Reps: $totalReps'),
                    _chip(context, 'Peso: ${totalWeight.toStringAsFixed(1)} kg'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(BuildContext context, String text) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: cs.surfaceContainerHighest, borderRadius: BorderRadius.circular(8)),
      child: Text(text, style: Theme.of(context).textTheme.bodySmall),
    );
  }
}

class _SummaryTile extends StatelessWidget {
  final String title;
  final String value;
  const _SummaryTile({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: theme.textTheme.bodyLarge),
          Text(value, style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
