import 'package:flutter_test/flutter_test.dart';
import 'package:liftly/features/progression/notifiers/progression_notifier.dart';

void main() {
  group('updateSkipNextByRoutineMap', () {
    test('adds routine id when skipping', () {
      final updated = updateSkipNextByRoutineMap({}, 'r1', true);
      expect((updated['skip_next_by_routine'] as Map)['r1'], true);
    });

    test('removes routine id when unsetting skip', () {
      final initial = {
        'skip_next_by_routine': {'r1': true, 'r2': true},
      };
      final updated = updateSkipNextByRoutineMap(initial, 'r1', false);
      final map = updated['skip_next_by_routine'] as Map;
      expect(map.containsKey('r1'), false);
      expect(map['r2'], true);
    });
  });
}
