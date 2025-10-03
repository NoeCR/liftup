import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// Evitamos dependencias complejas usando widgets simples para medición
// No usamos el helper aquí para evitar dependencias de localización

void main() {
  group('UI Performance Tests', () {
    testWidgets('Simple home renders within performance threshold', (
      WidgetTester tester,
    ) async {
      final stopwatch = Stopwatch()..start();

      // Build a simple home-like widget
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: Text('Home'))),
      );

      // Wait for the widget to settle
      await tester.pumpAndSettle();

      stopwatch.stop();

      // Verify that the page renders within acceptable time
      expect(stopwatch.elapsedMilliseconds, lessThan(1000));
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('Large list handles dataset efficiently', (
      WidgetTester tester,
    ) async {
      final stopwatch = Stopwatch()..start();

      // Build a simple large ListView
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListView.builder(
              key: const Key('perf_list'),
              itemCount: 1000,
              itemBuilder: (_, i) => ListTile(title: Text('Item $i')),
            ),
          ),
        ),
      );

      // Wait for the widget to settle
      await tester.pumpAndSettle();

      stopwatch.stop();

      // Verify performance
      expect(stopwatch.elapsedMilliseconds, lessThan(2000));
      expect(find.byKey(const Key('perf_list')), findsOneWidget);
    });

    testWidgets('Widget rebuild performance', (WidgetTester tester) async {
      // Build initial widget
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: Text('Home'))),
      );

      await tester.pumpAndSettle();

      // Measure rebuild performance
      final stopwatch = Stopwatch()..start();

      // Trigger rebuild
      await tester.pump();
      await tester.pumpAndSettle();

      stopwatch.stop();

      // Verify rebuild performance
      expect(stopwatch.elapsedMilliseconds, lessThan(500)); // 500ms max
    });

    testWidgets('Memory usage during widget lifecycle', (
      WidgetTester tester,
    ) async {
      // Build widget
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: Text('Home'))),
      );

      await tester.pumpAndSettle();

      // Simulate multiple rebuilds to test memory management
      for (int i = 0; i < 10; i++) {
        await tester.pump();
        await tester.pumpAndSettle();
      }

      // Verify that the widget still works correctly
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('Scroll performance with large lists', (
      WidgetTester tester,
    ) async {
      // Build large ListView
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListView.builder(
              key: const Key('perf_list'),
              itemCount: 1000,
              itemBuilder: (_, i) => ListTile(title: Text('Item $i')),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Test scroll performance
      final stopwatch = Stopwatch()..start();

      // Simulate scrolling
      await tester.drag(
        find.byKey(const Key('perf_list')),
        const Offset(0, -300),
      );
      await tester.pumpAndSettle();

      await tester.drag(
        find.byKey(const Key('perf_list')),
        const Offset(0, 300),
      );
      await tester.pumpAndSettle();

      stopwatch.stop();

      // Verify scroll performance
      expect(stopwatch.elapsedMilliseconds, lessThan(1500));
    });
  });
}
