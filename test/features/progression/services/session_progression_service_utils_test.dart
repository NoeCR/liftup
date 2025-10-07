import 'package:flutter_test/flutter_test.dart';
import 'package:liftly/features/progression/services/session_progression_service.dart';

void main() {
  group('computeAdjustedSets', () {
    test('applies positive delta within max', () {
      final result = computeAdjustedSets(
        currentConfiguredSets: 4,
        previousSetsInState: 4,
        newSetsFromCalculation: 5,
        maxSets: 8,
      );
      expect(result, 5);
    });

    test('does not go below 1', () {
      final result = computeAdjustedSets(
        currentConfiguredSets: 3,
        previousSetsInState: 4,
        newSetsFromCalculation: 1,
        maxSets: 8,
      );
      expect(result, 1);
    });

    test('caps at maxSets', () {
      final result = computeAdjustedSets(
        currentConfiguredSets: 6,
        previousSetsInState: 4,
        newSetsFromCalculation: 10,
        maxSets: 8,
      );
      expect(result, 8);
    });

    test('no change when new equals previous', () {
      final result = computeAdjustedSets(
        currentConfiguredSets: 5,
        previousSetsInState: 4,
        newSetsFromCalculation: 4,
        maxSets: 8,
      );
      expect(result, 5);
    });
  });
}
