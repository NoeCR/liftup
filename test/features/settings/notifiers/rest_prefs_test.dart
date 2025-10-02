import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';

import '../../../test_helpers/test_setup.dart';
import '../../../mocks/database_service_mock.dart';
import '../../../mocks/logging_service_mock.dart';
import '../../../../lib/features/settings/notifiers/rest_prefs.dart';

void main() {
  group('Rest Preferences Tests', () {
    late ProviderContainer container;
    late MockDatabaseService mockDatabaseService;
    late MockLoggingService mockLoggingService;

    setUpAll(() {
      TestSetup.initialize();
      mockDatabaseService = TestSetup.mockDatabaseService;
      mockLoggingService = TestSetup.mockLoggingService;
    });

    setUp(() {
      TestSetup.cleanup();
      container = TestSetup.createTestContainer();
    });

    tearDown(() {
      container.dispose();
    });

    group('Rest Sound Settings', () {
      test('should initialize with default sound enabled', () {
        // Act
        final state = container.read(restSoundEnabledProvider);

        // Assert
        expect(state, isTrue);
      });

      test('should toggle rest sound enabled', () {
        // Arrange
        final notifier = container.read(restSoundEnabledProvider.notifier);
        final initialState = container.read(restSoundEnabledProvider);

        // Act
        notifier.state = !initialState;
        final toggledState = container.read(restSoundEnabledProvider);

        // Assert
        expect(toggledState, equals(!initialState));
      });

      test('should set rest sound to specific value', () {
        // Arrange
        const soundEnabled = false;

        // Act
        final notifier = container.read(restSoundEnabledProvider.notifier);
        notifier.state = soundEnabled;
        final state = container.read(restSoundEnabledProvider);

        // Assert
        expect(state, equals(soundEnabled));
      });

      test('should handle multiple sound setting changes', () {
        // Arrange
        final notifier = container.read(restSoundEnabledProvider.notifier);

        // Act
        notifier.state = true;
        final state1 = container.read(restSoundEnabledProvider);
        
        notifier.state = false;
        final state2 = container.read(restSoundEnabledProvider);
        
        notifier.state = !state2;
        final state3 = container.read(restSoundEnabledProvider);

        // Assert
        expect(state1, equals(true));
        expect(state2, equals(false));
        expect(state3, equals(true));
      });
    });

    group('Rest Vibration Settings', () {
      test('should initialize with default vibration enabled', () {
        // Act
        final state = container.read(restVibrationEnabledProvider);

        // Assert
        expect(state, isTrue);
      });

      test('should toggle rest vibration enabled', () {
        // Arrange
        final notifier = container.read(restVibrationEnabledProvider.notifier);
        final initialState = container.read(restVibrationEnabledProvider);

        // Act
        notifier.state = !initialState;
        final toggledState = container.read(restVibrationEnabledProvider);

        // Assert
        expect(toggledState, equals(!initialState));
      });

      test('should set rest vibration to specific value', () {
        // Arrange
        const vibrationEnabled = false;

        // Act
        final notifier = container.read(restVibrationEnabledProvider.notifier);
        notifier.state = vibrationEnabled;
        final state = container.read(restVibrationEnabledProvider);

        // Assert
        expect(state, equals(vibrationEnabled));
      });
    });

    group('Rest Sound Type Settings', () {
      test('should initialize with default sound type', () {
        // Act
        final state = container.read(restSoundTypeProvider);

        // Assert
        expect(state, equals(RestSoundType.notification));
      });

      test('should change rest sound type', () {
        // Arrange
        final notifier = container.read(restSoundTypeProvider.notifier);

        // Act
        notifier.state = RestSoundType.alarm;
        final state = container.read(restSoundTypeProvider);

        // Assert
        expect(state, equals(RestSoundType.alarm));
      });

      test('should cycle through sound types', () {
        // Arrange
        final notifier = container.read(restSoundTypeProvider.notifier);

        // Act
        notifier.state = RestSoundType.alarm;
        final state1 = container.read(restSoundTypeProvider);
        
        notifier.state = RestSoundType.notification;
        final state2 = container.read(restSoundTypeProvider);

        // Assert
        expect(state1, equals(RestSoundType.alarm));
        expect(state2, equals(RestSoundType.notification));
      });
    });

    group('State Persistence', () {
      test('should persist state changes', () {
        // Arrange
        const soundEnabled = false;
        const vibrationEnabled = false;
        const soundType = RestSoundType.alarm;

        // Act
        final soundNotifier = container.read(restSoundEnabledProvider.notifier);
        final vibrationNotifier = container.read(restVibrationEnabledProvider.notifier);
        final soundTypeNotifier = container.read(restSoundTypeProvider.notifier);
        
        soundNotifier.state = soundEnabled;
        vibrationNotifier.state = vibrationEnabled;
        soundTypeNotifier.state = soundType;
        
        final soundState = container.read(restSoundEnabledProvider);
        final vibrationState = container.read(restVibrationEnabledProvider);
        final soundTypeState = container.read(restSoundTypeProvider);

        // Assert
        expect(soundState, equals(soundEnabled));
        expect(vibrationState, equals(vibrationEnabled));
        expect(soundTypeState, equals(soundType));
      });

      test('should maintain state across multiple operations', () {
        // Arrange
        final soundNotifier = container.read(restSoundEnabledProvider.notifier);
        final vibrationNotifier = container.read(restVibrationEnabledProvider.notifier);
        final soundTypeNotifier = container.read(restSoundTypeProvider.notifier);

        // Act
        soundNotifier.state = false;
        vibrationNotifier.state = false;
        soundTypeNotifier.state = RestSoundType.alarm;
        
        soundNotifier.state = true;
        vibrationNotifier.state = true;
        soundTypeNotifier.state = RestSoundType.notification;
        
        final finalSoundState = container.read(restSoundEnabledProvider);
        final finalVibrationState = container.read(restVibrationEnabledProvider);
        final finalSoundTypeState = container.read(restSoundTypeProvider);

        // Assert
        expect(finalSoundState, equals(true));
        expect(finalVibrationState, equals(true));
        expect(finalSoundTypeState, equals(RestSoundType.notification));
      });
    });

    group('State Updates', () {
      test('should notify listeners on state changes', () {
        // Arrange
        var soundStateChanged = false;
        var vibrationStateChanged = false;
        var soundTypeStateChanged = false;

        // Act
        final soundNotifier = container.read(restSoundEnabledProvider.notifier);
        final vibrationNotifier = container.read(restVibrationEnabledProvider.notifier);
        final soundTypeNotifier = container.read(restSoundTypeProvider.notifier);
        
        container.listen(restSoundEnabledProvider, (previous, next) {
          soundStateChanged = true;
        });
        container.listen(restVibrationEnabledProvider, (previous, next) {
          vibrationStateChanged = true;
        });
        container.listen(restSoundTypeProvider, (previous, next) {
          soundTypeStateChanged = true;
        });
        
        soundNotifier.state = false;
        vibrationNotifier.state = false;
        soundTypeNotifier.state = RestSoundType.alarm;

        // Assert
        expect(soundStateChanged, isTrue);
        expect(vibrationStateChanged, isTrue);
        expect(soundTypeStateChanged, isTrue);
      });

      test('should update state immediately', () {
        // Arrange
        const newSoundState = false;

        // Act
        final notifier = container.read(restSoundEnabledProvider.notifier);
        notifier.state = newSoundState;
        final state = container.read(restSoundEnabledProvider);

        // Assert
        expect(state, equals(newSoundState));
      });
    });

    group('Default Values', () {
      test('should have reasonable default values', () {
        // Act
        final soundState = container.read(restSoundEnabledProvider);
        final vibrationState = container.read(restVibrationEnabledProvider);
        final soundTypeState = container.read(restSoundTypeProvider);

        // Assert
        expect(soundState, isA<bool>());
        expect(vibrationState, isA<bool>());
        expect(soundTypeState, isA<RestSoundType>());
        expect(soundTypeState, equals(RestSoundType.notification));
      });

      test('should maintain consistency across operations', () {
        // Arrange
        final soundNotifier = container.read(restSoundEnabledProvider.notifier);
        final vibrationNotifier = container.read(restVibrationEnabledProvider.notifier);
        final soundTypeNotifier = container.read(restSoundTypeProvider.notifier);

        // Act
        final initialSoundState = container.read(restSoundEnabledProvider);
        final initialVibrationState = container.read(restVibrationEnabledProvider);
        final initialSoundTypeState = container.read(restSoundTypeProvider);
        
        soundNotifier.state = !initialSoundState;
        vibrationNotifier.state = !initialVibrationState;
        soundTypeNotifier.state = RestSoundType.alarm;
        
        soundNotifier.state = initialSoundState;
        vibrationNotifier.state = initialVibrationState;
        soundTypeNotifier.state = initialSoundTypeState;
        
        final finalSoundState = container.read(restSoundEnabledProvider);
        final finalVibrationState = container.read(restVibrationEnabledProvider);
        final finalSoundTypeState = container.read(restSoundTypeProvider);

        // Assert
        expect(finalSoundState, equals(initialSoundState));
        expect(finalVibrationState, equals(initialVibrationState));
        expect(finalSoundTypeState, equals(initialSoundTypeState));
      });
    });

    group('Enum Values', () {
      test('should have all expected sound types', () {
        // Assert
        expect(RestSoundType.values.length, equals(2));
        expect(RestSoundType.values.contains(RestSoundType.notification), isTrue);
        expect(RestSoundType.values.contains(RestSoundType.alarm), isTrue);
      });

      test('should handle enum comparisons correctly', () {
        // Arrange
        final notifier = container.read(restSoundTypeProvider.notifier);

        // Act
        notifier.state = RestSoundType.alarm;
        final state = container.read(restSoundTypeProvider);

        // Assert
        expect(state == RestSoundType.alarm, isTrue);
        expect(state == RestSoundType.notification, isFalse);
      });
    });
  });
}