import 'dart:io';

import 'package:liftly/features/exercise/models/exercise.dart';

/// Helper para generar reportes detallados de los tests de progresión
class ProgressionTestReporter {
  static void generateDetailedReport({
    required String strategyName,
    required String presetName,
    required Exercise exercise,
    required int months,
    required List<SessionResult> progressionHistory,
    required int deloadCount,
    required double totalWeightIncrements,
    required int totalSeriesIncrements,
    required int seriesIncrementCount,
  }) {
    print('\n${'=' * 80}');
    print('REPORTE DETALLADO DE PROGRESIÓN - $months MESES');
    print('=' * 80);

    print('\n📊 CONFIGURACIÓN:');
    print('  • Estrategia: $strategyName');
    print('  • Preset: $presetName');
    print(
      '  • Ejercicio: ${exercise.name} (${exercise.exerciseType.name} + ${exercise.loadType.name})',
    );
    print('  • Duración: $months meses');
    print('  • Total de sesiones: ${progressionHistory.length}');

    print('\n📈 PROGRESIÓN DE PESO:');
    final initialWeight = progressionHistory.first.weight;
    final finalWeight = progressionHistory.last.weight;
    final totalGain = finalWeight - initialWeight;
    print('  • Peso inicial: ${initialWeight.toStringAsFixed(1)}kg');
    print('  • Peso final: ${finalWeight.toStringAsFixed(1)}kg');
    print('  • Ganancia total: ${totalGain.toStringAsFixed(1)}kg');
    print(
      '  • Incrementos aplicados: ${totalWeightIncrements.toStringAsFixed(1)}kg',
    );

    print('\n📊 PROGRESIÓN DE SERIES:');
    final initialSets = progressionHistory.first.sets;
    final finalSets = progressionHistory.last.sets;
    print('  • Series iniciales: $initialSets');
    print('  • Series finales: $finalSets');
    print('  • Incrementos de series: $totalSeriesIncrements');
    print('  • Sesiones con incremento de series: $seriesIncrementCount');

    print('\n🔄 DELOADS:');
    print('  • Total de deloads: $deloadCount');
    if (deloadCount > 0) {
      final deloadFrequency = progressionHistory.length / deloadCount;
      print(
        '  • Frecuencia promedio: cada ${deloadFrequency.toStringAsFixed(1)} sesiones',
      );
    }

    print('\n📅 CRONOLOGÍA DE PROGRESIÓN:');
    _printProgressionTimeline(progressionHistory);

    print('\n🎯 ANÁLISIS DE PATRONES:');
    _analyzeProgressionPatterns(progressionHistory, strategyName);

    print('\n${'=' * 80}');
  }

  static void _printProgressionTimeline(List<SessionResult> history) {
    // Mostrar cada 10 sesiones para no saturar
    final step = (history.length / 20).ceil();

    for (int i = 0; i < history.length; i += step) {
      final session = history[i];
      final status =
          session.isDeload
              ? '🔄 DELOAD'
              : session.incrementApplied
              ? '⬆️ INCREMENTO'
              : '➡️ MANTENER';

      print(
        '  Sesión ${session.session.toString().padLeft(3)}: '
        '${session.weight.toStringAsFixed(1)}kg x ${session.reps} x ${session.sets} '
        '$status',
      );
    }

    // Mostrar siempre la última sesión
    if (history.length > 1) {
      final lastSession = history.last;
      final status =
          lastSession.isDeload
              ? '🔄 DELOAD'
              : lastSession.incrementApplied
              ? '⬆️ INCREMENTO'
              : '➡️ MANTENER';

      print(
        '  Sesión ${lastSession.session.toString().padLeft(3)}: '
        '${lastSession.weight.toStringAsFixed(1)}kg x ${lastSession.reps} x ${lastSession.sets} '
        '$status',
      );
    }
  }

  static void _analyzeProgressionPatterns(
    List<SessionResult> history,
    String strategyName,
  ) {
    // Analizar frecuencia de incrementos
    final incrementSessions = history.where((s) => s.incrementApplied).length;
    final incrementFrequency = history.length / incrementSessions;
    print(
      '  • Frecuencia de incrementos: cada ${incrementFrequency.toStringAsFixed(1)} sesiones',
    );

    // Analizar patrones específicos por estrategia
    switch (strategyName.toLowerCase()) {
      case 'linear':
        _analyzeLinearPattern(history);
        break;
      case 'stepped':
        _analyzeSteppedPattern(history);
        break;
      case 'undulating':
        _analyzeUndulatingPattern(history);
        break;
      case 'wave':
        _analyzeWavePattern(history);
        break;
      case 'double':
        _analyzeDoublePattern(history);
        break;
      case 'autoregulated':
        _analyzeAutoregulatedPattern(history);
        break;
      default:
        _analyzeGenericPattern(history);
    }
  }

  static void _analyzeLinearPattern(List<SessionResult> history) {
    print('  • Patrón Lineal: Incrementos consistentes cada sesión');

    // Verificar consistencia
    final increments = <double>[];
    for (int i = 1; i < history.length; i++) {
      if (history[i].incrementApplied) {
        increments.add(history[i].weight - history[i - 1].weight);
      }
    }

    if (increments.isNotEmpty) {
      final avgIncrement =
          increments.reduce((a, b) => a + b) / increments.length;
      final incrementVariance =
          increments
              .map((i) => (i - avgIncrement).abs())
              .reduce((a, b) => a + b) /
          increments.length;
      print('  • Incremento promedio: ${avgIncrement.toStringAsFixed(2)}kg');
      print('  • Variabilidad: ${incrementVariance.toStringAsFixed(2)}kg');
    }
  }

  static void _analyzeSteppedPattern(List<SessionResult> history) {
    print('  • Patrón Escalonado: Incrementos cada 2 sesiones');

    // Verificar que los incrementos ocurren cada 2 sesiones
    final incrementSessions =
        history.where((s) => s.incrementApplied).map((s) => s.session).toList();
    if (incrementSessions.length > 1) {
      final intervals = <int>[];
      for (int i = 1; i < incrementSessions.length; i++) {
        intervals.add(incrementSessions[i] - incrementSessions[i - 1]);
      }
      final avgInterval = intervals.reduce((a, b) => a + b) / intervals.length;
      print(
        '  • Intervalo promedio entre incrementos: ${avgInterval.toStringAsFixed(1)} sesiones',
      );
    }
  }

  static void _analyzeUndulatingPattern(List<SessionResult> history) {
    print('  • Patrón Ondulante: Alternancia entre días pesados y ligeros');

    // Analizar patrones de intensidad (peso)
    final weights = history.map((s) => s.weight).toList();
    final weightChanges = <double>[];

    for (int i = 1; i < weights.length; i++) {
      weightChanges.add(weights[i] - weights[i - 1]);
    }

    final positiveChanges = weightChanges.where((c) => c > 0).length;
    final negativeChanges = weightChanges.where((c) => c < 0).length;
    final neutralChanges = weightChanges.where((c) => c == 0).length;

    print('  • Sesiones con aumento de peso: $positiveChanges');
    print('  • Sesiones con reducción de peso: $negativeChanges');
    print('  • Sesiones sin cambio de peso: $neutralChanges');
  }

  static void _analyzeWavePattern(List<SessionResult> history) {
    print('  • Patrón de Oleadas: Progresión en ondas');

    // Identificar picos y valles en la progresión
    final weights = history.map((s) => s.weight).toList();
    var peaks = 0;
    var valleys = 0;

    for (int i = 1; i < weights.length - 1; i++) {
      if (weights[i] > weights[i - 1] && weights[i] > weights[i + 1]) {
        peaks++;
      } else if (weights[i] < weights[i - 1] && weights[i] < weights[i + 1]) {
        valleys++;
      }
    }

    print('  • Picos identificados: $peaks');
    print('  • Valles identificados: $valleys');
  }

  static void _analyzeDoublePattern(List<SessionResult> history) {
    print('  • Patrón Doble: Progresión en peso y repeticiones');

    // Analizar progresión de repeticiones
    final reps = history.map((s) => s.reps).toList();
    final repChanges = <int>[];

    for (int i = 1; i < reps.length; i++) {
      repChanges.add(reps[i] - reps[i - 1]);
    }

    final repIncreases = repChanges.where((c) => c > 0).length;
    final repDecreases = repChanges.where((c) => c < 0).length;

    print('  • Sesiones con aumento de reps: $repIncreases');
    print('  • Sesiones con reducción de reps: $repDecreases');
  }

  static void _analyzeAutoregulatedPattern(List<SessionResult> history) {
    print('  • Patrón Autoregulado: Basado en RPE');

    // En un test real, aquí analizaríamos los valores de RPE
    // Por ahora, analizamos la variabilidad de la progresión
    final weights = history.map((s) => s.weight).toList();
    final weightChanges = <double>[];

    for (int i = 1; i < weights.length; i++) {
      weightChanges.add(weights[i] - weights[i - 1]);
    }

    if (weightChanges.isNotEmpty) {
      final avgChange =
          weightChanges.reduce((a, b) => a + b) / weightChanges.length;
      final variance =
          weightChanges
              .map((c) => (c - avgChange).abs())
              .reduce((a, b) => a + b) /
          weightChanges.length;
      print('  • Variabilidad de progresión: ${variance.toStringAsFixed(2)}kg');
      print('  • Adaptabilidad: ${variance > 1.0 ? 'Alta' : 'Baja'}');
    }
  }

  static void _analyzeGenericPattern(List<SessionResult> history) {
    print('  • Patrón Genérico: Análisis básico de progresión');

    final weights = history.map((s) => s.weight).toList();
    final totalGain = weights.last - weights.first;
    final avgGainPerSession = totalGain / history.length;

    print(
      '  • Ganancia promedio por sesión: ${avgGainPerSession.toStringAsFixed(3)}kg',
    );
  }

  /// Genera un reporte CSV para análisis posterior
  static void generateCSVReport({
    required String fileName,
    required String strategyName,
    required String presetName,
    required Exercise exercise,
    required List<SessionResult> progressionHistory,
  }) {
    final file = File('test_reports/$fileName.csv');
    file.createSync(recursive: true);

    final buffer = StringBuffer();

    // Headers
    buffer.writeln('Session,Weight,Reps,Sets,IncrementApplied,IsDeload,Reason');

    // Data
    for (final session in progressionHistory) {
      buffer.writeln(
        '${session.session},${session.weight},${session.reps},${session.sets},${session.incrementApplied},${session.isDeload},"${session.reason}"',
      );
    }

    file.writeAsStringSync(buffer.toString());
    print('\n📄 Reporte CSV generado: test_reports/$fileName.csv');
  }

  /// Genera un resumen ejecutivo de todos los tests
  static void generateExecutiveSummary({required List<TestSummary> summaries}) {
    print('\n${'=' * 100}');
    print('RESUMEN EJECUTIVO - TESTS DE PROGRESIÓN A LARGO PLAZO');
    print('=' * 100);

    print('\n📊 ESTADÍSTICAS GENERALES:');
    print('  • Total de tests ejecutados: ${summaries.length}');

    final totalWeightGains =
        summaries.map((s) => s.finalWeight - s.initialWeight).toList();
    final avgWeightGain =
        totalWeightGains.reduce((a, b) => a + b) / totalWeightGains.length;
    final maxWeightGain = totalWeightGains.reduce((a, b) => a > b ? a : b);
    final minWeightGain = totalWeightGains.reduce((a, b) => a < b ? a : b);

    print(
      '  • Ganancia promedio de peso: ${avgWeightGain.toStringAsFixed(1)}kg',
    );
    print('  • Ganancia máxima de peso: ${maxWeightGain.toStringAsFixed(1)}kg');
    print('  • Ganancia mínima de peso: ${minWeightGain.toStringAsFixed(1)}kg');

    final totalDeloads = summaries
        .map((s) => s.deloadCount)
        .reduce((a, b) => a + b);
    print('  • Total de deloads aplicados: $totalDeloads');

    print('\n🏆 MEJORES ESTRATEGIAS POR CATEGORÍA:');

    // Mejor ganancia de peso
    final bestWeightGain = summaries.reduce(
      (a, b) =>
          (b.finalWeight - b.initialWeight) > (a.finalWeight - a.initialWeight)
              ? b
              : a,
    );
    print(
      '  • Mayor ganancia de peso: ${bestWeightGain.strategy} (${(bestWeightGain.finalWeight - bestWeightGain.initialWeight).toStringAsFixed(1)}kg)',
    );

    // Menor variabilidad
    final leastVariable = summaries.reduce(
      (a, b) => b.weightVariance < a.weightVariance ? b : a,
    );
    print(
      '  • Menor variabilidad: ${leastVariable.strategy} (${leastVariable.weightVariance.toStringAsFixed(2)}kg)',
    );

    // Más deloads (mayor recuperación)
    final mostDeloads = summaries.reduce(
      (a, b) => b.deloadCount > a.deloadCount ? b : a,
    );
    print(
      '  • Mayor frecuencia de deloads: ${mostDeloads.strategy} ($mostDeloads.deloadCount deloads)',
    );

    print('\n📈 RECOMENDACIONES:');
    print('  • Para principiantes: Estrategias con menor variabilidad');
    print('  • Para avanzados: Estrategias con mayor ganancia de peso');
    print('  • Para recuperación: Estrategias con mayor frecuencia de deloads');

    print('\n${'=' * 100}');
  }
}

/// Clase para resumir resultados de tests
class TestSummary {
  final String strategy;
  final String preset;
  final String exerciseType;
  final String loadType;
  final double initialWeight;
  final double finalWeight;
  final int deloadCount;
  final double weightVariance;
  final int totalSessions;

  const TestSummary({
    required this.strategy,
    required this.preset,
    required this.exerciseType,
    required this.loadType,
    required this.initialWeight,
    required this.finalWeight,
    required this.deloadCount,
    required this.weightVariance,
    required this.totalSessions,
  });
}

/// Clase para resultados de sesión (reutilizada del test principal)
class SessionResult {
  final int session;
  final double weight;
  final int reps;
  final int sets;
  final bool incrementApplied;
  final bool isDeload;
  final String reason;

  const SessionResult({
    required this.session,
    required this.weight,
    required this.reps,
    required this.sets,
    required this.incrementApplied,
    required this.isDeload,
    required this.reason,
  });
}
