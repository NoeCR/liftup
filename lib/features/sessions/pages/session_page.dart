import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../notifiers/session_notifier.dart';
import '../../../common/widgets/custom_bottom_navigation.dart';
import '../../sessions/models/workout_session.dart';
import 'dart:async';

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

              // Si está activo y no hay ticker, arrancar desde base persistente o resume
              if (_ticker == null &&
                  activeSession.status == SessionStatus.active &&
                  !_isManuallyPaused) {
                final notifier = ref.read(sessionNotifierProvider.notifier);
                final pausedElapsed =
                    notifier.getPausedElapsedSeconds(activeSession.id) ??
                    SessionNotifier.readPausedFromNotes(activeSession.notes);
                final lastResumeAt =
                    notifier.getLastResumeAt(activeSession.id) ??
                    SessionNotifier.readResumeAtFromNotes(activeSession.notes);
                int base;
                if (pausedElapsed != null && lastResumeAt != null) {
                  // Continuar desde el tiempo pausado + delta desde reanudación
                  base =
                      pausedElapsed +
                      DateTime.now().difference(lastResumeAt).inSeconds;
                } else {
                  base =
                      DateTime.now()
                          .difference(activeSession.startTime)
                          .inSeconds;
                }
                _elapsedSeconds = base < 0 ? 0 : base;
                _startTicker();
              }
              // Si está pausado, detener el ticker y conservar _elapsedSeconds mostrado
              if (activeSession.status == SessionStatus.paused) {
                _stopTicker();
                final pausedElapsed =
                    ref
                        .read(sessionNotifierProvider.notifier)
                        .getPausedElapsedSeconds(activeSession.id) ??
                    SessionNotifier.readPausedFromNotes(activeSession.notes);
                if (pausedElapsed != null) {
                  _elapsedSeconds = pausedElapsed;
                }
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
    return const Center(child: Text('Contenido de la sesión - En desarrollo'));
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
                  // Recalcular base y arrancar ticker ya
                  await ref
                      .read(sessionNotifierProvider.notifier)
                      .resumeSession();
                  // Base desde pausa + delta
                  final notifier = ref.read(sessionNotifierProvider.notifier);
                  final pausedElapsed =
                      notifier.getPausedElapsedSeconds(session.id) ??
                      _elapsedSeconds;
                  final lastResumeAt =
                      notifier.getLastResumeAt(session.id) ?? DateTime.now();
                  _elapsedSeconds =
                      pausedElapsed +
                      DateTime.now().difference(lastResumeAt).inSeconds;
                  if (_elapsedSeconds < 0) _elapsedSeconds = 0;
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
              await ref
                  .read(sessionNotifierProvider.notifier)
                  .startSession(name: 'Sesión');
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
