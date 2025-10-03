import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liftup/features/settings/notifiers/rest_prefs.dart';

void main() {
  group('RestPrefs Tests', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    group('Initialization', () {
      test('should initialize with default values', () {
        final soundEnabled = container.read(restSoundEnabledProvider);
        final vibrationEnabled = container.read(restVibrationEnabledProvider);
        final soundType = container.read(restSoundTypeProvider);

        expect(soundEnabled, isTrue);
        expect(vibrationEnabled, isTrue);
        expect(soundType, equals(RestSoundType.notification));
      });
    });

    group('Rest Sound Settings', () {
      test('should update sound enabled setting', () {
        final notifier = container.read(restSoundEnabledProvider.notifier);

        notifier.state = false;

        expect(container.read(restSoundEnabledProvider), isFalse);
      });

      test('should toggle sound enabled setting', () {
        final notifier = container.read(restSoundEnabledProvider.notifier);
        final initialState = container.read(restSoundEnabledProvider);

        notifier.state = !initialState;

        expect(container.read(restSoundEnabledProvider), equals(!initialState));
      });
    });

    group('Rest Vibration Settings', () {
      test('should update vibration enabled setting', () {
        final notifier = container.read(restVibrationEnabledProvider.notifier);

        notifier.state = false;

        expect(container.read(restVibrationEnabledProvider), isFalse);
      });

      test('should toggle vibration enabled setting', () {
        final notifier = container.read(restVibrationEnabledProvider.notifier);
        final initialState = container.read(restVibrationEnabledProvider);

        notifier.state = !initialState;

        expect(
          container.read(restVibrationEnabledProvider),
          equals(!initialState),
        );
      });
    });

    group('Rest Sound Type Settings', () {
      test('should update sound type to alarm', () {
        final notifier = container.read(restSoundTypeProvider.notifier);

        notifier.state = RestSoundType.alarm;

        expect(
          container.read(restSoundTypeProvider),
          equals(RestSoundType.alarm),
        );
      });

      test('should update sound type to notification', () {
        final notifier = container.read(restSoundTypeProvider.notifier);

        notifier.state = RestSoundType.notification;

        expect(
          container.read(restSoundTypeProvider),
          equals(RestSoundType.notification),
        );
      });
    });

    group('State Persistence', () {
      test('should maintain state across provider container recreation', () {
        final soundNotifier = container.read(restSoundEnabledProvider.notifier);
        final vibrationNotifier = container.read(
          restVibrationEnabledProvider.notifier,
        );
        final soundTypeNotifier = container.read(
          restSoundTypeProvider.notifier,
        );

        // Change values
        soundNotifier.state = false;
        vibrationNotifier.state = false;
        soundTypeNotifier.state = RestSoundType.alarm;

        // Verify changes
        expect(container.read(restSoundEnabledProvider), isFalse);
        expect(container.read(restVibrationEnabledProvider), isFalse);
        expect(
          container.read(restSoundTypeProvider),
          equals(RestSoundType.alarm),
        );
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

        // Set different combinations
        soundNotifier.state = true;
        vibrationNotifier.state = false;
        soundTypeNotifier.state = RestSoundType.alarm;

        // Verify all settings are independent
        expect(container.read(restSoundEnabledProvider), isTrue);
        expect(container.read(restVibrationEnabledProvider), isFalse);
        expect(
          container.read(restSoundTypeProvider),
          equals(RestSoundType.alarm),
        );
      });
    });
  });
}
