import 'package:flutter_test/flutter_test.dart';
import 'package:liftup/features/progression/services/session_progression_service.dart';

void main() {
  group('computeAdjustedSets', () {
    test('aplica delta positivo respetando clamp superior', () {
      // current=9, state=5, new=7 => delta +2 => 11 -> clamp 10
      final out = computeAdjustedSets(
        currentConfiguredSets: 9,
        previousSetsInState: 5,
        newSetsFromCalculation: 7,
        maxSets: 10,
      );
      expect(out, 10);
    });

    test('aplica delta negativo con clamp inferior 1', () {
      // current=2, state=5, new=2 => delta -3 => -1 -> clamp 1
      final out = computeAdjustedSets(
        currentConfiguredSets: 2,
        previousSetsInState: 5,
        newSetsFromCalculation: 2,
        maxSets: 30,
      );
      expect(out, 1);
    });

    test('sin cambios devuelve current respetando límites', () {
      // current=6, delta 0 => 6
      final out = computeAdjustedSets(
        currentConfiguredSets: 6,
        previousSetsInState: 5,
        newSetsFromCalculation: 5,
        maxSets: 30,
      );
      expect(out, 6);
    });
  });
}


