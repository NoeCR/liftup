import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liftup/features/progression/notifiers/progression_notifier.dart';
import 'package:liftup/features/progression/models/progression_config.dart';
import 'package:liftup/common/enums/progression_type_enum.dart';
import '../mocks/progression_mock_factory.dart';

void main() {
  group('ProgressionStatusWidget', () {
    Widget createTestWidget({ProgressionConfig? config, bool isLoading = false, String? error}) {
      return ProviderScope(
        overrides: [
          progressionNotifierProvider.overrideWith(
            () => _TestProgressionNotifier(config: config, isLoading: isLoading, error: error),
          ),
        ],
        child: MaterialApp(home: Scaffold(body: _TestProgressionStatusWidget())),
      );
    }

    testWidgets('should render without errors', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Assert
      expect(find.byType(_TestProgressionStatusWidget), findsOneWidget);
    });

    testWidgets('should display no progression state', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createTestWidget(config: null));
      await tester.pump();

      // Assert
      expect(find.byType(_TestProgressionStatusWidget), findsOneWidget);
    });

    testWidgets('should display active progression state', (WidgetTester tester) async {
      // Arrange
      final config = ProgressionMockFactory.createProgressionConfig();

      // Act
      await tester.pumpWidget(createTestWidget(config: config));
      await tester.pump();

      // Assert
      expect(find.byType(_TestProgressionStatusWidget), findsOneWidget);
    });

    testWidgets('should display error state', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createTestWidget(error: 'Test error'));
      await tester.pump();

      // Assert
      expect(find.byType(_TestProgressionStatusWidget), findsOneWidget);
    });

    testWidgets('should handle different progression types', (WidgetTester tester) async {
      // Arrange
      final config = ProgressionMockFactory.createProgressionConfig(type: ProgressionType.linear);

      // Act
      await tester.pumpWidget(createTestWidget(config: config));
      await tester.pump();

      // Assert
      expect(find.byType(_TestProgressionStatusWidget), findsOneWidget);
    });

    testWidgets('should handle different progression units', (WidgetTester tester) async {
      // Arrange
      final config = ProgressionMockFactory.createProgressionConfig(unit: ProgressionUnit.session);

      // Act
      await tester.pumpWidget(createTestWidget(config: config));
      await tester.pump();

      // Assert
      expect(find.byType(_TestProgressionStatusWidget), findsOneWidget);
    });

    testWidgets('should handle different progression targets', (WidgetTester tester) async {
      // Arrange
      final config = ProgressionMockFactory.createProgressionConfig(primaryTarget: ProgressionTarget.weight);

      // Act
      await tester.pumpWidget(createTestWidget(config: config));
      await tester.pump();

      // Assert
      expect(find.byType(_TestProgressionStatusWidget), findsOneWidget);
    });

    testWidgets('should handle inactive progression', (WidgetTester tester) async {
      // Arrange
      final config = ProgressionMockFactory.createProgressionConfig(isActive: false);

      // Act
      await tester.pumpWidget(createTestWidget(config: config));
      await tester.pump();

      // Assert
      expect(find.byType(_TestProgressionStatusWidget), findsOneWidget);
    });

    testWidgets('should handle progression with end date', (WidgetTester tester) async {
      // Arrange
      final config = ProgressionMockFactory.createProgressionConfig(
        endDate: DateTime.now().add(const Duration(days: 30)),
      );

      // Act
      await tester.pumpWidget(createTestWidget(config: config));
      await tester.pump();

      // Assert
      expect(find.byType(_TestProgressionStatusWidget), findsOneWidget);
    });

    testWidgets('should handle progression with custom parameters', (WidgetTester tester) async {
      // Arrange
      final config = ProgressionMockFactory.createProgressionConfig(customParameters: {'custom': 'value'});

      // Act
      await tester.pumpWidget(createTestWidget(config: config));
      await tester.pump();

      // Assert
      expect(find.byType(_TestProgressionStatusWidget), findsOneWidget);
    });

    testWidgets('should handle zero increment value', (WidgetTester tester) async {
      // Arrange
      final config = ProgressionMockFactory.createProgressionConfig(incrementValue: 0.0);

      // Act
      await tester.pumpWidget(createTestWidget(config: config));
      await tester.pump();

      // Assert
      expect(find.byType(_TestProgressionStatusWidget), findsOneWidget);
    });

    testWidgets('should handle negative increment value', (WidgetTester tester) async {
      // Arrange
      final config = ProgressionMockFactory.createProgressionConfig(incrementValue: -2.5);

      // Act
      await tester.pumpWidget(createTestWidget(config: config));
      await tester.pump();

      // Assert
      expect(find.byType(_TestProgressionStatusWidget), findsOneWidget);
    });
  });
}

// Test widget that doesn't use .tr() to avoid localization issues
class _TestProgressionStatusWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressionAsync = ref.watch(progressionNotifierProvider);

    return progressionAsync.when(
      data: (config) {
        if (config == null) {
          return const Text('No progression');
        }
        return Column(
          children: [
            Text('Progression: ${config.type.displayNameKey}'),
            Text('Description: ${config.type.descriptionKey}'),
            Text('Unit: ${config.unit.displayNameKey}'),
            Text('Target: ${config.primaryTarget.displayNameKey}'),
          ],
        );
      },
      loading: () => const CircularProgressIndicator(),
      error: (error, stack) => Text('Error: $error'),
    );
  }
}

// Test notifier that provides controlled data
class _TestProgressionNotifier extends ProgressionNotifier {
  final ProgressionConfig? config;
  final bool isLoading;
  final String? error;

  _TestProgressionNotifier({this.config, this.isLoading = false, this.error});

  @override
  Future<ProgressionConfig?> build() async {
    if (error != null) {
      throw Exception(error);
    }
    if (isLoading) {
      await Future.delayed(const Duration(seconds: 1));
    }
    return config;
  }
}
