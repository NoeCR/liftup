import 'package:flutter_test/flutter_test.dart';
import '../mocks/progression_mock_factory.dart';

void main() {
  group('ProgressionState', () {
    test('should create a valid progression state', () {
      // Arrange & Act
      final state = ProgressionMockFactory.createProgressionState();

      // Assert
      expect(state.id, isNotEmpty);
      expect(state.progressionConfigId, isNotEmpty);
      expect(state.exerciseId, isNotEmpty);
      expect(state.currentWeek, 1);
      expect(state.currentCycle, 1);
      expect(state.currentSession, 1);
      expect(state.currentWeight, 100.0);
      expect(state.currentReps, 10);
      expect(state.currentSets, 3);
      expect(state.oneRepMax, 125.0);
      expect(state.lastUpdated, isNotNull);
    });

    test('should create a copy with modified values', () {
      // Arrange
      final originalState = ProgressionMockFactory.createProgressionState();

      // Act
      final modifiedState = originalState.copyWith(
        currentWeight: 110.0,
        currentReps: 12,
        currentWeek: 2,
        lastUpdated: DateTime.now().add(const Duration(days: 1)),
      );

      // Assert
      expect(modifiedState.id, originalState.id);
      expect(modifiedState.currentWeight, 110.0);
      expect(modifiedState.currentReps, 12);
      expect(modifiedState.currentWeek, 2);
      expect(modifiedState.lastUpdated, isNot(originalState.lastUpdated));
    });

    test('should handle different progression states', () {
      // Arrange & Act
      final beginnerState = ProgressionMockFactory.createProgressionState(
        currentWeight: 50.0,
        currentReps: 10,
        currentSets: 3,
        currentWeek: 1,
        baseWeight: 50.0,
        baseReps: 10,
        baseSets: 3,
      );
      final intermediateState = ProgressionMockFactory.createProgressionState(
        currentWeight: 100.0,
        currentReps: 8,
        currentSets: 4,
        currentWeek: 2,
        baseWeight: 100.0,
        baseReps: 8,
        baseSets: 4,
      );
      final advancedState = ProgressionMockFactory.createProgressionState(
        currentWeight: 150.0,
        currentReps: 6,
        currentSets: 5,
        currentWeek: 3,
        baseWeight: 150.0,
        baseReps: 6,
        baseSets: 5,
      );

      // Assert
      expect(beginnerState.currentWeight, 50.0);
      expect(beginnerState.currentReps, 10);
      expect(beginnerState.currentSets, 3);
      expect(beginnerState.currentWeek, 1);

      expect(intermediateState.currentWeight, 100.0);
      expect(intermediateState.currentReps, 8);
      expect(intermediateState.currentSets, 4);
      expect(intermediateState.currentWeek, 2);

      expect(advancedState.currentWeight, 150.0);
      expect(advancedState.currentReps, 6);
      expect(advancedState.currentSets, 5);
      expect(advancedState.currentWeek, 3);
    });

    test('should handle custom state parameters', () {
      // Arrange
      final customState = {'last_rpe': 8.5, 'fatigue_level': 0.7, 'motivation': 0.9, 'notes': 'Feeling strong today'};

      // Act
      final state = ProgressionMockFactory.createProgressionState(customData: customState);

      // Assert
      expect(state.customData, customState);
      expect(state.customData['last_rpe'], 8.5);
      expect(state.customData['fatigue_level'], 0.7);
      expect(state.customData['motivation'], 0.9);
      expect(state.customData['notes'], 'Feeling strong today');
    });

    test('should handle one rep max calculation', () {
      // Arrange & Act
      final state = ProgressionMockFactory.createProgressionState(
        currentWeight: 100.0,
        currentReps: 10,
        oneRepMax: 133.0, // Calculated 1RM
      );

      // Assert
      expect(state.currentWeight, 100.0);
      expect(state.currentReps, 10);
      expect(state.oneRepMax, 133.0);
    });

    test('should handle progression tracking over time', () {
      // Arrange
      final initialState = ProgressionMockFactory.createProgressionState(
        currentWeight: 100.0,
        currentReps: 10,
        currentWeek: 1,
        currentSession: 1,
        baseWeight: 100.0,
        baseReps: 10,
        baseSets: 3,
      );

      // Act - Simulate progression over multiple sessions
      final session2State = initialState.copyWith(
        currentWeight: 102.5,
        currentSession: 2,
        lastUpdated: DateTime.now().add(const Duration(days: 1)),
      );

      final session3State = session2State.copyWith(
        currentWeight: 105.0,
        currentSession: 3,
        lastUpdated: DateTime.now().add(const Duration(days: 2)),
      );

      final week2State = session3State.copyWith(
        currentWeight: 107.5,
        currentWeek: 2,
        currentSession: 1,
        lastUpdated: DateTime.now().add(const Duration(days: 3)),
      );

      // Assert
      expect(initialState.currentWeight, 100.0);
      expect(initialState.currentSession, 1);
      expect(initialState.currentWeek, 1);

      expect(session2State.currentWeight, 102.5);
      expect(session2State.currentSession, 2);
      expect(session2State.currentWeek, 1);

      expect(session3State.currentWeight, 105.0);
      expect(session3State.currentSession, 3);
      expect(session3State.currentWeek, 1);

      expect(week2State.currentWeight, 107.5);
      expect(week2State.currentSession, 1);
      expect(week2State.currentWeek, 2);
    });

    test('should handle deload scenarios', () {
      // Arrange & Act
      final normalState = ProgressionMockFactory.createProgressionState(
        currentWeight: 120.0,
        currentReps: 8,
        currentWeek: 3,
        baseWeight: 120.0,
        baseReps: 8,
        baseSets: 3,
      );

      final deloadState = normalState.copyWith(
        currentWeight: 102.0, // 15% reduction
        currentReps: 10,
        currentWeek: 4,
        isDeloadWeek: true,
        customData: {'is_deload': true, 'deload_percentage': 0.85},
      );

      // Assert
      expect(normalState.currentWeight, 120.0);
      expect(normalState.currentReps, 8);
      expect(normalState.currentWeek, 3);

      expect(deloadState.currentWeight, 102.0);
      expect(deloadState.currentReps, 10);
      expect(deloadState.currentWeek, 4);
      expect(deloadState.isDeloadWeek, isTrue);
      expect(deloadState.customData['is_deload'], isTrue);
      expect(deloadState.customData['deload_percentage'], 0.85);
    });

    test('should handle different exercise types', () {
      // Arrange & Act
      final strengthState = ProgressionMockFactory.createProgressionState(
        exerciseId: 'bench-press',
        currentWeight: 100.0,
        currentReps: 5,
        currentSets: 5,
        baseWeight: 100.0,
        baseReps: 5,
        baseSets: 5,
      );

      final hypertrophyState = ProgressionMockFactory.createProgressionState(
        exerciseId: 'bicep-curl',
        currentWeight: 20.0,
        currentReps: 12,
        currentSets: 3,
        baseWeight: 20.0,
        baseReps: 12,
        baseSets: 3,
      );

      final enduranceState = ProgressionMockFactory.createProgressionState(
        exerciseId: 'push-ups',
        currentWeight: 0.0, // Bodyweight
        currentReps: 20,
        currentSets: 4,
        baseWeight: 0.0,
        baseReps: 20,
        baseSets: 4,
      );

      // Assert
      expect(strengthState.exerciseId, 'bench-press');
      expect(strengthState.currentWeight, 100.0);
      expect(strengthState.currentReps, 5);
      expect(strengthState.currentSets, 5);

      expect(hypertrophyState.exerciseId, 'bicep-curl');
      expect(hypertrophyState.currentWeight, 20.0);
      expect(hypertrophyState.currentReps, 12);
      expect(hypertrophyState.currentSets, 3);

      expect(enduranceState.exerciseId, 'push-ups');
      expect(enduranceState.currentWeight, 0.0);
      expect(enduranceState.currentReps, 20);
      expect(enduranceState.currentSets, 4);
    });

    test('should handle state updates with timestamps', () {
      // Arrange
      final baseTime = DateTime(2024, 1, 1, 10, 0, 0);

      // Act
      final state1 = ProgressionMockFactory.createProgressionState(lastUpdated: baseTime);

      final state2 = state1.copyWith(currentWeight: 102.5, lastUpdated: baseTime.add(const Duration(hours: 1)));

      final state3 = state2.copyWith(currentWeight: 105.0, lastUpdated: baseTime.add(const Duration(hours: 2)));

      // Assert
      expect(state1.lastUpdated, baseTime);
      expect(state2.lastUpdated, baseTime.add(const Duration(hours: 1)));
      expect(state3.lastUpdated, baseTime.add(const Duration(hours: 2)));
      expect(state2.lastUpdated.isAfter(state1.lastUpdated), isTrue);
      expect(state3.lastUpdated.isAfter(state2.lastUpdated), isTrue);
    });
  });
}
