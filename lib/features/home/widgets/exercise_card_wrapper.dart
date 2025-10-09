import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../common/themes/app_theme.dart';
import '../../../common/widgets/exercise_card.dart';
import '../../exercise/models/exercise.dart';
import '../../exercise/notifiers/exercise_notifier.dart';
import '../../sessions/notifiers/exercise_completion_notifier.dart';
import '../../sessions/notifiers/exercise_state_notifier.dart';
import '../../sessions/notifiers/performed_sets_notifier.dart';
import '../../settings/notifiers/rest_prefs.dart';
import '../models/routine.dart';
import '../services/weekly_exercise_tracking_service.dart';

class ExerciseCardWrapper extends ConsumerStatefulWidget {
  final RoutineExercise routineExercise;
  final Exercise exercise;
  final VoidCallback onTap;
  final bool showSetsControls;
  final String? routineId;

  const ExerciseCardWrapper({
    required this.routineExercise,
    required this.exercise,
    required this.onTap,
    this.showSetsControls = false,
    this.routineId,
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
          isLocked: widget.exercise.isProgressionLocked,
          onToggleLock: () async {
            final exerciseNotifier = ref.read(exerciseNotifierProvider.notifier);

            // Update the exercise's isProgressionLocked field
            final updated = widget.exercise.copyWith(isProgressionLocked: !widget.exercise.isProgressionLocked);
            await exerciseNotifier.updateExercise(updated);
          },
          performedSets: performedSets,
          showSetsControls: widget.showSetsControls,
          isResting: _showRestOverlay,
          onTap: null,
          onLongPress: widget.onTap,
          onToggleCompleted: null,
          onWeightChanged: null,
          onRepsChanged: (newValue) {
            // Contador de series realizadas
            final totalSets = widget.exercise.defaultSets ?? 4;
            final previous = ref.read(performedSetsNotifierProvider)[widget.routineExercise.id] ?? 0;
            final int clamped = newValue.clamp(0, totalSets).toInt();
            ref.read(performedSetsNotifierProvider.notifier).setCount(widget.routineExercise.id, clamped);

            // Launch rest timer if it increments and it's not the last set
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
            top: AppTheme.spacingS,
            left: AppTheme.spacingM,
            right: AppTheme.spacingM,
            height: 120,
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(AppTheme.radiusL)),
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

        // Stop button when sound is playing (after timer finishes)
        if (_isRingtonePlaying)
          Positioned(
            top: AppTheme.spacingS,
            left: AppTheme.spacingM,
            right: AppTheme.spacingM,
            height: 120,
            child: IgnorePointer(
              ignoring: false,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(AppTheme.radiusL)),
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
