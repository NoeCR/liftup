import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../common/enums/progression_type_enum.dart';
import '../../../common/themes/app_theme.dart';
import '../../../common/widgets/custom_bottom_navigation.dart';
import '../../../common/widgets/section_header.dart';
import '../../exercise/models/exercise.dart';
import '../../exercise/notifiers/exercise_notifier.dart';
import '../../home/models/routine.dart';
import '../../home/notifiers/routine_notifier.dart';
import '../../home/notifiers/selected_routine_provider.dart';
import '../../home/widgets/exercise_card_wrapper.dart';
import '../../progression/notifiers/progression_notifier.dart';
import '../../progression/widgets/progression_status_widget.dart';
import '../../sessions/models/workout_session.dart';
import '../notifiers/session_notifier.dart';
import '../utils/exercise_search_helper.dart';

class SessionPage extends ConsumerStatefulWidget {
  const SessionPage({super.key});

  @override
  ConsumerState<SessionPage> createState() => _SessionPageState();
}

class _SessionPageState extends ConsumerState<SessionPage> {
  Timer? _ticker;
  final ValueNotifier<int> _elapsedSecondsVN = ValueNotifier(0);
  bool _isManuallyPaused = false;
  bool _sessionJustCompleted = false;

  /// Creates a sorted list of routine exercises with their corresponding Exercise objects
  List<({RoutineExercise routineExercise, Exercise exercise})> _createSortedExerciseList(
    List<RoutineExercise> routineExercises,
    List<Exercise> exercises,
    BuildContext context,
  ) {
    return ExerciseSearchHelper.createSortedExerciseList(
      routineExercises,
      exercises,
      defaultName: context.tr('exercises.title'),
      sortType: ExerciseSortType.lastPerformed,
    );
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _elapsedSecondsVN.dispose();
    super.dispose();
  }

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      _elapsedSecondsVN.value += 1;
    });
  }

  void _stopTicker() {
    _ticker?.cancel();
    _ticker = null;
  }

  String _two(int n) => n.toString().padLeft(2, '0');
  String _formatHms(int seconds) {
    final d = Duration(seconds: seconds);
    return '${_two(d.inHours)}:${_two(d.inMinutes % 60)}:${_two(d.inSeconds % 60)}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('session.title')),
        backgroundColor: colorScheme.surface,
        actions: [
          IconButton(
            tooltip: context.tr('sessionHistory.title'),
            onPressed: () => context.push('/session-history'),
            icon: const Icon(Icons.list_alt),
          ),
        ],
      ),
      body: Consumer(
        builder: (context, ref, child) {
          final sessionAsync = ref.watch(sessionNotifierProvider);

          return sessionAsync.when(
            data: (sessions) {
              if (_sessionJustCompleted) {
                // Show no-session state immediately after finishing
                _stopTicker();
                _elapsedSecondsVN.value = 0;
                _isManuallyPaused = false;
                // Limpiar bandera una vez renderizado
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) setState(() => _sessionJustCompleted = false);
                });
                return _buildNoActiveSession();
              }
              WorkoutSession? activeSession;
              try {
                activeSession = sessions.firstWhere(
                  (s) => (s.status == SessionStatus.active || s.status == SessionStatus.paused) && s.endTime == null,
                );
              } catch (_) {
                activeSession = null;
              }

              if (activeSession == null) {
                _stopTicker();
                _elapsedSecondsVN.value = 0;
                _isManuallyPaused = false;
                return _buildNoActiveSession();
              }

              // If active and no ticker, compute clean base and start
              if (_ticker == null && activeSession.status == SessionStatus.active && !_isManuallyPaused) {
                final notifier = ref.read(sessionNotifierProvider.notifier);
                _elapsedSecondsVN.value = notifier.calculateElapsedForUI(activeSession, now: DateTime.now());
                _startTicker();
              }
              // If paused, stop ticker and keep displayed _elapsedSeconds
              if (activeSession.status == SessionStatus.paused) {
                _stopTicker();
                final notifier = ref.read(sessionNotifierProvider.notifier);
                _elapsedSecondsVN.value = notifier.calculateElapsedForUI(activeSession, now: DateTime.now());
              }

              return _buildActiveSession(activeSession);
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => _buildNoActiveSession(),
          );
        },
      ),
      bottomNavigationBar: const CustomBottomNavigation(currentIndex: 2),
    );
  }

  Widget _buildActiveSession(WorkoutSession session) {
    return Column(
      children: [
        // Session Timer
        _buildSessionTimer(session),

        // Session Content
        Expanded(child: _buildSessionContent(session)),

        // Session Controls
        SafeArea(
          top: false,
          bottom: true,
          child: Padding(
            padding: const EdgeInsets.only(bottom: AppTheme.spacingS),
            child: _buildSessionControls(session),
          ),
        ),
      ],
    );
  }

  Widget _buildSessionTimer(WorkoutSession session) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.all(AppTheme.spacingM),
      padding: const EdgeInsets.all(AppTheme.spacingL),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(AppTheme.radiusL),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: AppTheme.elevationM,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            context.tr('session.workoutTime'),
            style: theme.textTheme.titleMedium?.copyWith(
              color: colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppTheme.spacingS),
          ValueListenableBuilder<int>(
            valueListenable: _elapsedSecondsVN,
            builder: (context, elapsedSeconds, child) {
              return Text(
                _formatHms(elapsedSeconds),
                style: theme.textTheme.headlineLarge?.copyWith(
                  color: colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSessionContent(WorkoutSession session) {
    return Consumer(
      builder: (context, ref, child) {
        final routinesAsync = ref.watch(routineNotifierProvider);
        final exercisesAsync = ref.watch(exerciseNotifierProvider);

        return routinesAsync.when(
          data: (routines) {
            Routine? routine;
            if (session.routineId != null) {
              try {
                routine = routines.firstWhere((r) => r.id == session.routineId);
              } catch (_) {}
            }
            routine ??= routines.isNotEmpty ? routines.first : null;
            if (routine == null) {
              return Center(child: Text(context.tr('session.noRoutineAssociated')));
            }

            return exercisesAsync.when(
              data: (exercises) {
                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(
                    AppTheme.spacingM,
                    AppTheme.spacingM,
                    AppTheme.spacingM,
                    kBottomNavigationBarHeight + AppTheme.spacingL,
                  ),
                  itemCount: routine!.sections.length,
                  itemBuilder: (context, index) {
                    final section = routine!.sections[index];
                    return Column(
                      children: [
                        SectionHeader(
                          title: section.name,
                          isCollapsed: section.isCollapsed,
                          iconName: section.iconName,
                          muscleGroup: section.muscleGroup,
                          onToggleCollapsed: () {
                            ref.read(routineNotifierProvider.notifier).toggleSectionCollapsed(section.id);
                          },
                        ),
                        if (!section.isCollapsed) ...[
                          if (section.exercises.isEmpty)
                            Padding(
                              padding: const EdgeInsets.only(bottom: AppTheme.spacingM),
                              child: Text(
                                context.tr('session.noExercises'),
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            )
                          else
                            SizedBox(
                              height: 360,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingS),
                                itemCount: _createSortedExerciseList(section.exercises, exercises, context).length,
                                itemBuilder: (context, idx) {
                                  final sortedExerciseList = _createSortedExerciseList(
                                    section.exercises,
                                    exercises,
                                    context,
                                  );
                                  final exerciseData = sortedExerciseList[idx];
                                  final re = exerciseData.routineExercise;
                                  final ex = exerciseData.exercise;

                                  return SizedBox(
                                    width: 320,
                                    child: ExerciseCardWrapper(
                                      routineExercise: re,
                                      exercise: ex,
                                      showSetsControls: true,
                                      routineId: session.routineId,
                                      onTap: () {
                                        // Long press functionality for exercise details
                                      },
                                    ),
                                  );
                                },
                              ),
                            ),
                        ],
                      ],
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text(context.tr('session.errorLoadingExercises'))),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text(context.tr('session.errorLoadingRoutine'))),
        );
      },
    );
  }

  Widget _buildSessionControls(WorkoutSession session) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingM),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () async {
                final isPaused = _isManuallyPaused || session.status == SessionStatus.paused;
                if (!isPaused) {
                  // Pausar
                  _isManuallyPaused = true;
                  _stopTicker();
                  await ref.read(sessionNotifierProvider.notifier).pauseSession();
                  ref.invalidate(sessionNotifierProvider);
                } else {
                  // Reanudar inmediatamente
                  _isManuallyPaused = false;
                  await ref.read(sessionNotifierProvider.notifier).resumeSession();
                  final notifier = ref.read(sessionNotifierProvider.notifier);
                  _elapsedSecondsVN.value = notifier.calculateElapsedForUI(session, now: DateTime.now());
                  _startTicker();
                  ref.invalidate(sessionNotifierProvider);
                }
              },
              icon: Icon(
                (_isManuallyPaused || session.status == SessionStatus.paused) ? Icons.play_arrow : Icons.pause,
              ),
              label: Text(
                (_isManuallyPaused || session.status == SessionStatus.paused)
                    ? context.tr('session.resume')
                    : context.tr('session.pause'),
              ),
            ),
          ),
          const SizedBox(width: AppTheme.spacingM),
          Expanded(
            child: FilledButton.icon(
              onPressed: () async {
                _stopTicker();
                final progressionConfig = await ref.read(progressionNotifierProvider.future);
                bool applyNext = true;
                if (progressionConfig != null) {
                  final isWeekly = progressionConfig.unit == ProgressionUnit.week;
                  final isEndOfWeek = DateTime.now().weekday == DateTime.sunday;
                  final shouldAsk = !isWeekly || (isWeekly && isEndOfWeek);
                  if (shouldAsk && mounted) {
                    applyNext =
                        await showDialog<bool>(
                          context: context,
                          builder: (ctx) {
                            return AlertDialog(
                              title: Text(ctx.tr('progression.confirmApplyTitle')),
                              content: Text(ctx.tr('progression.confirmApplyMessage')),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(ctx).pop(false),
                                  child: Text(ctx.tr('common.keepValues')),
                                ),
                                FilledButton(
                                  onPressed: () => Navigator.of(ctx).pop(true),
                                  child: Text(ctx.tr('progression.applyNextSession')),
                                ),
                              ],
                            );
                          },
                        ) ??
                        true;
                  }
                }

                // Persist skip flag per routine if user decides to keep values
                try {
                  final activeSession = await ref.read(sessionNotifierProvider.notifier).getCurrentOngoingSession();
                  final routineId = activeSession?.routineId;
                  if (routineId != null) {
                    final routine = (await ref.read(
                      routineNotifierProvider.future,
                    )).firstWhere((r) => r.id == routineId);
                    final exerciseIds =
                        routine.sections.expand((s) => s.exercises.map((e) => e.exerciseId)).toSet().toList();
                    await ref
                        .read(progressionNotifierProvider.notifier)
                        .setSkipNextProgressionForRoutine(
                          routineId: routineId,
                          exerciseIds: exerciseIds,
                          skip: !applyNext,
                        );
                  }
                } catch (_) {}

                await ref.read(sessionNotifierProvider.notifier).completeSession();
                if (!mounted) return;
                setState(() {
                  _isManuallyPaused = false;
                  _sessionJustCompleted = true;
                });
                _elapsedSecondsVN.value = 0;
                // Forzar recarga de sesiones para ocultar controles
                ref.invalidate(sessionNotifierProvider);
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(context.tr('session.sessionFinished'))));
                if (mounted) {
                  context.push('/session-summary');
                }
              },
              icon: const Icon(Icons.check),
              label: Text(context.tr('session.finish')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoActiveSession() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      children: [
        // Progression status widget
        const ProgressionStatusWidget(),

        // Contenido principal
        Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.spacingXL),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppTheme.spacingXL),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer.withValues(alpha: 0.3),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.play_circle_outline, size: 64, color: colorScheme.primary),
                  ),
                  const SizedBox(height: AppTheme.spacingL),
                  Text(
                    context.tr('session.noActiveSession'),
                    style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppTheme.spacingS),
                  Text(
                    context.tr('session.startNewSession'),
                    style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppTheme.spacingXL),
                  FilledButton.icon(
                    onPressed: () async {
                      final selectedRoutineId = ref.read(selectedRoutineIdProvider);
                      if (selectedRoutineId == null) {
                        if (!mounted) return;
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text(context.tr('session.selectRoutineFirst'))));
                        return;
                      }
                      await ref
                          .read(sessionNotifierProvider.notifier)
                          .startSession(name: context.tr('session.title'), routineId: selectedRoutineId);
                      if (mounted) setState(() {});
                    },
                    icon: const Icon(Icons.play_arrow),
                    label: Text(context.tr('session.startSession')),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
