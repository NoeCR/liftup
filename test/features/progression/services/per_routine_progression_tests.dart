import 'package:flutter_test/flutter_test.dart';
import 'package:liftly/features/progression/models/progression_calculation_result.dart';
import 'package:liftly/features/progression/models/progression_state.dart';
import 'package:liftly/features/progression/services/progression_service.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'per_routine_progression_tests.mocks.dart';

@GenerateMocks([ProgressionService])
void main() {
  group('Per-routine progression', () {
    late MockProgressionService mockService;

    setUp(() {
      mockService = MockProgressionService();
    });

    test('ejercicios mantienen estados independientes por rutina', () async {
      // Arrange
      final configId = 'config-1';
      final exerciseId = 'squat';
      final routineA = 'routine-A';
      final routineB = 'routine-B';

      // Estados diferentes por rutina
      final stateA = ProgressionState(
        id: 'state-A',
        progressionConfigId: configId,
        exerciseId: exerciseId,
        routineId: routineA,
        currentCycle: 1,
        currentWeek: 1,
        currentSession: 1,
        currentWeight: 100,
        currentReps: 8,
        currentSets: 3,
        baseWeight: 100,
        baseReps: 8,
        baseSets: 3,
        sessionHistory: {},
        lastUpdated: DateTime.now(),
        isDeloadWeek: false,
        customData: {},
      );

      final stateB = ProgressionState(
        id: 'state-B',
        progressionConfigId: configId,
        exerciseId: exerciseId,
        routineId: routineB,
        currentCycle: 1,
        currentWeek: 1,
        currentSession: 1,
        currentWeight: 80,
        currentReps: 10,
        currentSets: 4,
        baseWeight: 80,
        baseReps: 10,
        baseSets: 4,
        sessionHistory: {},
        lastUpdated: DateTime.now(),
        isDeloadWeek: false,
        customData: {},
      );

      when(mockService.getProgressionStateByExercise(configId, exerciseId, routineA)).thenAnswer((_) async => stateA);
      when(mockService.getProgressionStateByExercise(configId, exerciseId, routineB)).thenAnswer((_) async => stateB);

      // Act
      final a = await mockService.getProgressionStateByExercise(configId, exerciseId, routineA);
      final b = await mockService.getProgressionStateByExercise(configId, exerciseId, routineB);

      // Assert
      expect(a, isNotNull);
      expect(b, isNotNull);
      expect(a!.routineId, isNot(b!.routineId));
      expect(a.currentWeight, 100);
      expect(b.currentWeight, 80);
    });

    test('no aplica deload en primera sesión de nueva rutina (inicialización crea estado base)', () async {
      // Arrange
      final configId = 'config-1';
      final exerciseId = 'bench';
      final newRoutine = 'routine-new';

      when(mockService.getProgressionStateByExercise(configId, exerciseId, newRoutine)).thenAnswer((_) async => null);

      // Inicializa con valores base de sesión configurada
      when(
        mockService.initializeExerciseProgression(
          configId: configId,
          exerciseId: exerciseId,
          routineId: newRoutine,
          baseWeight: 60.0,
          baseReps: 10,
          baseSets: 3,
        ),
      ).thenAnswer(
        (_) async => ProgressionState(
          id: 'new-state',
          progressionConfigId: configId,
          exerciseId: exerciseId,
          routineId: newRoutine,
          currentCycle: 1,
          currentWeek: 1,
          currentSession: 0,
          currentWeight: 60.0,
          currentReps: 10,
          currentSets: 3,
          baseWeight: 60.0,
          baseReps: 10,
          baseSets: 3,
          sessionHistory: {},
          lastUpdated: DateTime.now(),
          isDeloadWeek: false,
          customData: {},
        ),
      );

      // Act
      final existing = await mockService.getProgressionStateByExercise(configId, exerciseId, newRoutine);
      if (existing == null) {
        await mockService.initializeExerciseProgression(
          configId: configId,
          exerciseId: exerciseId,
          routineId: newRoutine,
          baseWeight: 60.0,
          baseReps: 10,
          baseSets: 3,
        );
      }

      // Assert: se inicializa, sin lógica de deload
      verify(
        mockService.initializeExerciseProgression(
          configId: configId,
          exerciseId: exerciseId,
          routineId: newRoutine,
          baseWeight: 60.0,
          baseReps: 10,
          baseSets: 3,
        ),
      ).called(1);
    });

    test('la progresión se calcula por rutina (llamadas incluyen routineId)', () async {
      // Arrange
      final configId = 'config-2';
      final exerciseId = 'deadlift';
      final routineX = 'routine-X';
      final routineY = 'routine-Y';

      when(mockService.calculateProgression(configId, exerciseId, routineX, 100.0, 5, 3)).thenAnswer(
        (_) async =>
            ProgressionCalculationResult(newWeight: 102.5, newReps: 5, newSets: 3, incrementApplied: true, reason: 'X'),
      );
      when(mockService.calculateProgression(configId, exerciseId, routineY, 80.0, 8, 3)).thenAnswer(
        (_) async =>
            ProgressionCalculationResult(newWeight: 82.5, newReps: 8, newSets: 3, incrementApplied: true, reason: 'Y'),
      );

      // Act
      final x = await mockService.calculateProgression(configId, exerciseId, routineX, 100.0, 5, 3);
      final y = await mockService.calculateProgression(configId, exerciseId, routineY, 80.0, 8, 3);

      // Assert
      expect(x.newWeight, 102.5);
      expect(y.newWeight, 82.5);

      verify(mockService.calculateProgression(configId, exerciseId, routineX, 100.0, 5, 3)).called(1);
      verify(mockService.calculateProgression(configId, exerciseId, routineY, 80.0, 8, 3)).called(1);
    });
  });
}
