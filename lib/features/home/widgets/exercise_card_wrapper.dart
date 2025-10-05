import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../sessions/notifiers/exercise_completion_notifier.dart';
import '../../sessions/notifiers/exercise_state_notifier.dart';
import '../../sessions/notifiers/performed_sets_notifier.dart';
import '../../../common/widgets/exercise_card.dart';
import '../models/routine.dart';
import '../../exercise/models/exercise.dart';
import '../../settings/notifiers/rest_prefs.dart';
import '../services/weekly_exercise_tracking_service.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';

class ExerciseCardWrapper extends ConsumerStatefulWidget {
  final RoutineExercise routineExercise;
  final Exercise exercise;
  final VoidCallback onTap;
  final bool showSetsControls;

  const ExerciseCardWrapper({
    required this.routineExercise,
    required this.exercise,
    required this.onTap,
    this.showSetsControls = false,
    super.key,
  });

  @override
  ConsumerState<ExerciseCardWrapper> createState() => _ExerciseCardWrapperState();
}

class _ExerciseCardWrapperState extends ConsumerState<ExerciseCardWrapper> {
  bool _showRestOverlay = false;
  int _restSecondsRemaining = 0;
  Timer? _restTimer;
  bool _isRingtonePlaying = false;

  @override
  void initState() {
    super.initState();
    // Defer provider modification until after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(exerciseStateNotifierProvider.notifier).initializeExercise(widget.routineExercise);
    });
  }

  @override
  void dispose() {
    _restTimer?.cancel();
    // Asegurar que detenemos cualquier tono activo
    try {
      FlutterRingtonePlayer().stop();
    } catch (_) {}
    super.dispose();
  }

  void _startRestTimer(int seconds) {
    _restTimer?.cancel();
    setState(() {
      _restSecondsRemaining = seconds;
      _showRestOverlay = true;
      _isRingtonePlaying = false;
    });
    _restTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      if (_restSecondsRemaining <= 1) {
        setState(() {
          _showRestOverlay = false;
          _restSecondsRemaining = 0;
        });
        _notifyRestFinished();
        t.cancel();
      } else {
        setState(() {
          _restSecondsRemaining -= 1;
        });
      }
    });
  }

  void _notifyRestFinished() {
    final soundEnabled = ref.read(restSoundEnabledProvider);
    final vibrationEnabled = ref.read(restVibrationEnabledProvider);
    final soundType = ref.read(restSoundTypeProvider);
    if (soundEnabled) {
      final androidSound = soundType == RestSoundType.alarm ? AndroidSounds.alarm : AndroidSounds.notification;
      final iosSound = soundType == RestSoundType.alarm ? IosSounds.alarm : IosSounds.triTone;
      FlutterRingtonePlayer().play(
        android: androidSound,
        ios: iosSound,
        looping: true,
        volume: 1.0,
        asAlarm: soundType == RestSoundType.alarm,
      );
      setState(() {
        _isRingtonePlaying = true;
      });
    }
    if (vibrationEnabled) {
      HapticFeedback.mediumImpact();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get current exercise state
    final currentExercise =
        ref.watch(exerciseStateNotifierProvider.select((state) => state[widget.routineExercise.id])) ??
        widget.routineExercise;

    final isCompleted = ref.watch(
      exerciseCompletionNotifierProvider.select((state) => state.contains(widget.routineExercise.id)),
    );

    // progreso de series realizadas
    // read current performed sets if needed for future display/logic
    // final performedSets = ref.watch(performedSetsNotifierProvider)[widget.routineExercise.id] ?? 0;

    final performedSets = ref.watch(performedSetsNotifierProvider)[widget.routineExercise.id] ?? 0;

    // Verificar si el ejercicio fue realizado esta semana
    final wasPerformedThisWeek = ref.watch(exercisePerformedThisWeekProvider(widget.exercise.id)).value ?? false;

    return Stack(
      children: [
        ExerciseCard(
          routineExercise: currentExercise,
          exercise: widget.exercise,
          isCompleted: isCompleted,
          wasPerformedThisWeek: wasPerformedThisWeek,
          performedSets: performedSets,
          showSetsControls: widget.showSetsControls,
          onTap: null,
          onLongPress: widget.onTap,
          onToggleCompleted: null,
          onWeightChanged: null,
          onRepsChanged: (newValue) {
            // Contador de series realizadas
            final totalSets = widget.exercise.defaultSets ?? 3;
            final previous = ref.read(performedSetsNotifierProvider)[widget.routineExercise.id] ?? 0;
            final int clamped = newValue.clamp(0, totalSets).toInt();
            ref.read(performedSetsNotifierProvider.notifier).setCount(widget.routineExercise.id, clamped);

            // Lanzar temporizador de descanso si incrementa y no es la última serie
            if (clamped > previous && clamped < totalSets) {
              final rest = widget.exercise.restTimeSeconds ?? 60;
              if (rest > 0) {
                _startRestTimer(rest);
              }
            }

            final nowCompleted = clamped >= totalSets;
            final completion = ref.read(exerciseCompletionNotifierProvider.notifier);
            final already = ref.read(exerciseCompletionNotifierProvider).contains(widget.routineExercise.id);
            if (nowCompleted && !already) {
              completion.toggleExerciseCompletion(widget.routineExercise.id);
            } else if (!nowCompleted && already) {
              completion.toggleExerciseCompletion(widget.routineExercise.id);
            }
          },
        ),

        // Overlay de descanso: contador durante el timer
        if (_showRestOverlay)
          Positioned(
            top: 8,
            left: 16,
            right: 16,
            height: 120,
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: Center(
                  child: Chip(
                    label: Text(
                      '${_restSecondsRemaining}s',
                      style: Theme.of(
                        context,
                      ).textTheme.titleMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    backgroundColor: Colors.black87,
                  ),
                ),
              ),
            ),
          ),

        // Botón de detener cuando el sonido está reproduciéndose (tras finalizar timer)
        if (_isRingtonePlaying)
          Positioned(
            top: 8,
            left: 16,
            right: 16,
            height: 120,
            child: IgnorePointer(
              ignoring: false,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: Center(
                  child: FilledButton.icon(
                    onPressed: () {
                      // detener sonido si se estuviera reproduciendo
                      FlutterRingtonePlayer().stop();
                      setState(() {
                        _isRingtonePlaying = false;
                      });
                    },
                    icon: const Icon(Icons.stop),
                    label: const Text('Detener'),
                    style: FilledButton.styleFrom(backgroundColor: Colors.black87, foregroundColor: Colors.white),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
