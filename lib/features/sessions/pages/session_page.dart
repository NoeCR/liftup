import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../notifiers/session_notifier.dart';
import '../../../common/widgets/custom_bottom_navigation.dart';
import '../../sessions/models/workout_session.dart';
import 'dart:async';
import '../../home/notifiers/selected_routine_provider.dart';
import '../../home/notifiers/routine_notifier.dart';
import '../../home/models/routine.dart';
import '../../exercise/notifiers/exercise_notifier.dart';
import '../../exercise/models/exercise.dart';
import '../../home/widgets/exercise_card_wrapper.dart';
import 'package:go_router/go_router.dart';

class SessionPage extends ConsumerStatefulWidget {
  const SessionPage({super.key});

  @override
  ConsumerState<SessionPage> createState() => _SessionPageState();
}

class _SessionPageState extends ConsumerState<SessionPage> {
  Timer? _ticker;
  int _elapsedSeconds = 0;
  bool _isManuallyPaused = false;
  bool _sessionJustCompleted = false;

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        _elapsedSeconds += 1;
      });
    });
  }

  void _stopTicker() {
    _ticker?.cancel();
    _ticker = null;
  }

  String _formatHms(int seconds) {
    final d = Duration(seconds: seconds);
    final two = (int n) => n.toString().padLeft(2, '0');
    return '${two(d.inHours)}:${two(d.inMinutes % 60)}:${two(d.inSeconds % 60)}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sesión de Entrenamiento'),
        backgroundColor: colorScheme.surface,
        actions: [
          IconButton(
            tooltip: 'Historial',
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
                // Mostrar estado sin sesión inmediatamente tras finalizar
                _stopTicker();
                _elapsedSeconds = 0;
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
                  (s) =>
                      (s.status == SessionStatus.active ||
                          s.status == SessionStatus.paused) &&
                      s.endTime == null,
                );
              } catch (_) {
                activeSession = null;
              }

              if (activeSession == null) {
                _stopTicker();
                _elapsedSeconds = 0;
                _isManuallyPaused = false;
                return _buildNoActiveSession();
              }

              // Si está activo y no hay ticker, calcular base limpia y arrancar
              if (_ticker == null &&
                  activeSession.status == SessionStatus.active &&
                  !_isManuallyPaused) {
                final notifier = ref.read(sessionNotifierProvider.notifier);
                _elapsedSeconds = notifier.calculateElapsedForUI(
                  activeSession,
                  now: DateTime.now(),
                );
                _startTicker();
              }
              // Si está pausado, detener el ticker y conservar _elapsedSeconds mostrado
              if (activeSession.status == SessionStatus.paused) {
                _stopTicker();
                final notifier = ref.read(sessionNotifierProvider.notifier);
                _elapsedSeconds = notifier.calculateElapsedForUI(
                  activeSession,
                  now: DateTime.now(),
                );
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
        _buildSessionControls(session),
      ],
    );
  }

  Widget _buildSessionTimer(WorkoutSession session) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            'Tiempo de Entrenamiento',
            style: theme.textTheme.titleMedium?.copyWith(
              color: colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _formatHms(_elapsedSeconds),
            style: theme.textTheme.headlineLarge?.copyWith(
              color: colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.bold,
            ),
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
              return const Center(child: Text('No hay rutina asociada'));
            }

            return exercisesAsync.when(
              data: (exercises) {
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: routine!.sections.length,
                  itemBuilder: (context, index) {
                    final section = routine!.sections[index];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            section.name,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        if (section.exercises.isEmpty)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Text(
                              'Sin ejercicios',
                              style: Theme.of(
                                context,
                              ).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context).hintColor,
                              ),
                            ),
                          )
                        else
                          SizedBox(
                            height: 300,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                              itemCount: section.exercises.length,
                              itemBuilder: (context, idx) {
                                final re = section.exercises[idx];
                                final ex = exercises.firstWhere(
                                  (e) => e.id == re.exerciseId,
                                  orElse:
                                      () => Exercise(
                                        id: '',
                                        name: 'Ejercicio',
                                        description: '',
                                        imageUrl: '',
                                        muscleGroups: const [],
                                        tips: const [],
                                        commonMistakes: const [],
                                        category: ExerciseCategory.fullBody,
                                        difficulty: ExerciseDifficulty.beginner,
                                        createdAt: DateTime.now(),
                                        updatedAt: DateTime.now(),
                                      ),
                                );

                                // ExerciseCardWrapper maneja internamente el estado de series realizadas

                                return SizedBox(
                                  width: 320,
                                  child: ExerciseCardWrapper(
                                    routineExercise: re,
                                    exercise: ex.id.isEmpty ? ex : ex,
                                    onTap: () {
                                      // Long press functionality for exercise details
                                    },
                                  ),
                                );
                              },
                            ),
                          ),
                        const SizedBox(height: 8),
                      ],
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error cargando ejercicios')),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error cargando rutina')),
        );
      },
    );
  }

  Widget _buildSessionControls(WorkoutSession session) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () async {
                final isPaused =
                    _isManuallyPaused || session.status == SessionStatus.paused;
                if (!isPaused) {
                  // Pausar
                  _isManuallyPaused = true;
                  _stopTicker();
                  await ref
                      .read(sessionNotifierProvider.notifier)
                      .pauseSession();
                  ref.invalidate(sessionNotifierProvider);
                } else {
                  // Reanudar inmediatamente
                  _isManuallyPaused = false;
                  await ref
                      .read(sessionNotifierProvider.notifier)
                      .resumeSession();
                  final notifier = ref.read(sessionNotifierProvider.notifier);
                  _elapsedSeconds = notifier.calculateElapsedForUI(
                    session,
                    now: DateTime.now(),
                  );
                  _startTicker();
                  ref.invalidate(sessionNotifierProvider);
                }
              },
              icon: Icon(
                (_isManuallyPaused || session.status == SessionStatus.paused)
                    ? Icons.play_arrow
                    : Icons.pause,
              ),
              label: Text(
                (_isManuallyPaused || session.status == SessionStatus.paused)
                    ? 'Reanudar'
                    : 'Pausar',
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: FilledButton.icon(
              onPressed: () async {
                _stopTicker();
                await ref
                    .read(sessionNotifierProvider.notifier)
                    .completeSession();
                if (!mounted) return;
                setState(() {
                  _isManuallyPaused = false;
                  _elapsedSeconds = 0;
                  _sessionJustCompleted = true;
                });
                // Forzar recarga de sesiones para ocultar controles
                ref.invalidate(sessionNotifierProvider);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Sesión finalizada')),
                );
                if (mounted) {
                  context.push('/session-summary');
                }
              },
              icon: const Icon(Icons.check),
              label: const Text('Finalizar'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoActiveSession() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.play_circle_outline,
            size: 64,
            color: colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text('No hay sesión activa', style: theme.textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(
            'Inicia una nueva sesión de entrenamiento',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () async {
              final selectedRoutineId = ref.read(selectedRoutineIdProvider);
              if (selectedRoutineId == null) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Selecciona una rutina en Home antes de iniciar la sesión.',
                    ),
                  ),
                );
                return;
              }
              await ref
                  .read(sessionNotifierProvider.notifier)
                  .startSession(name: 'Sesión', routineId: selectedRoutineId);
              if (mounted) setState(() {});
            },
            icon: const Icon(Icons.play_arrow),
            label: const Text('Iniciar Sesión'),
          ),
        ],
      ),
    );
  }
}
