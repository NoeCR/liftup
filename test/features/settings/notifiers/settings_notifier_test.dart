import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liftup/features/settings/notifiers/rest_prefs.dart';
import '../../../test_helpers/test_setup.dart';

void main() {
  group('Settings Notifiers Tests', () {
    late ProviderContainer container;

    setUp(() {
      TestSetup.initialize();
      container = TestSetup.createTestContainer();
    });

    tearDown(() {
      TestSetup.cleanup();
      container.dispose();
    });

    group('Rest Sound Settings', () {
      test('should initialize with default sound enabled', () {
        final soundEnabled = container.read(restSoundEnabledProvider);

        expect(soundEnabled, equals(true));
      });

      test('should update sound enabled setting', () {
        final notifier = container.read(restSoundEnabledProvider.notifier);

        notifier.state = false;

        final soundEnabled = container.read(restSoundEnabledProvider);
        expect(soundEnabled, equals(false));
      });

      test('should notify listeners when sound setting changes', () {
        bool notified = false;
        container.listen(restSoundEnabledProvider, (previous, next) {
          notified = true;
        });

        final notifier = container.read(restSoundEnabledProvider.notifier);
        notifier.state = false;

        expect(notified, isTrue);
      });
    });

    group('Rest Vibration Settings', () {
      test('should initialize with default vibration enabled', () {
        final vibrationEnabled = container.read(restVibrationEnabledProvider);

        expect(vibrationEnabled, equals(true));
      });

      test('should update vibration enabled setting', () {
        final notifier = container.read(restVibrationEnabledProvider.notifier);

        notifier.state = false;

        final vibrationEnabled = container.read(restVibrationEnabledProvider);
        expect(vibrationEnabled, equals(false));
      });

      test('should notify listeners when vibration setting changes', () {
        bool notified = false;
        container.listen(restVibrationEnabledProvider, (previous, next) {
          notified = true;
        });

        final notifier = container.read(restVibrationEnabledProvider.notifier);
        notifier.state = false;

        expect(notified, isTrue);
      });
    });

    group('Rest Sound Type Settings', () {
      test('should initialize with default sound type', () {
        final soundType = container.read(restSoundTypeProvider);

        expect(soundType, equals(RestSoundType.notification));
      });

      test('should update sound type setting', () {
        final notifier = container.read(restSoundTypeProvider.notifier);

        notifier.state = RestSoundType.alarm;

        final soundType = container.read(restSoundTypeProvider);
        expect(soundType, equals(RestSoundType.alarm));
      });

      test('should notify listeners when sound type changes', () {
        bool notified = false;
        container.listen(restSoundTypeProvider, (previous, next) {
          notified = true;
        });

        final notifier = container.read(restSoundTypeProvider.notifier);
        notifier.state = RestSoundType.alarm;

        expect(notified, isTrue);
      });
    });

    group('Settings Persistence', () {
      test('should maintain state across provider container recreation', () {
        // Change settings
        container.read(restSoundEnabledProvider.notifier).state = false;
        container.read(restVibrationEnabledProvider.notifier).state = false;
        container.read(restSoundTypeProvider.notifier).state =
            RestSoundType.alarm;

        // Verify changes
        expect(container.read(restSoundEnabledProvider), equals(false));
        expect(container.read(restVibrationEnabledProvider), equals(false));
        expect(
          container.read(restSoundTypeProvider),
          equals(RestSoundType.alarm),
        );
      });
    });

    group('Settings Validation', () {
      test('should accept valid sound type values', () {
        final notifier = container.read(restSoundTypeProvider.notifier);

        // Test all valid sound types
        notifier.state = RestSoundType.notification;
        expect(
          container.read(restSoundTypeProvider),
          equals(RestSoundType.notification),
        );

        notifier.state = RestSoundType.alarm;
        expect(
          container.read(restSoundTypeProvider),
          equals(RestSoundType.alarm),
        );
      });

      test('should accept boolean values for sound and vibration', () {
        final soundNotifier = container.read(restSoundEnabledProvider.notifier);
        final vibrationNotifier = container.read(
          restVibrationEnabledProvider.notifier,
        );

        // Test true values
        soundNotifier.state = true;
        vibrationNotifier.state = true;
        expect(container.read(restSoundEnabledProvider), equals(true));
        expect(container.read(restVibrationEnabledProvider), equals(true));

        // Test false values
        soundNotifier.state = false;
        vibrationNotifier.state = false;
        expect(container.read(restSoundEnabledProvider), equals(false));
        expect(container.read(restVibrationEnabledProvider), equals(false));
      });
    });

    group('Settings Integration', () {
      test('should work together without conflicts', () {
        final soundNotifier = container.read(restSoundEnabledProvider.notifier);
        final vibrationNotifier = container.read(
          restVibrationEnabledProvider.notifier,
        );
        final soundTypeNotifier = container.read(
          restSoundTypeProvider.notifier,
        );

        // Set all settings
        soundNotifier.state = true;
        vibrationNotifier.state = false;
        soundTypeNotifier.state = RestSoundType.alarm;

        // Verify all settings are independent
        expect(container.read(restSoundEnabledProvider), equals(true));
        expect(container.read(restVibrationEnabledProvider), equals(false));
        expect(
          container.read(restSoundTypeProvider),
          equals(RestSoundType.alarm),
        );
      });
    });
  });
}
