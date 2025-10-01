import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../common/widgets/custom_bottom_navigation.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../sessions/notifiers/session_notifier.dart';
import '../../exercise/notifiers/exercise_notifier.dart';
import '../../home/notifiers/routine_notifier.dart';
import '../../sessions/models/workout_session.dart';

class StatisticsPage extends ConsumerWidget {
  const StatisticsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Estadísticas'),
        backgroundColor: colorScheme.surface,
      ),
      body: Consumer(
        builder: (context, ref, _) {
          final sessionsAsync = ref.watch(sessionNotifierProvider);
          final exercisesAsync = ref.watch(exerciseNotifierProvider);
          final routinesAsync = ref.watch(routineNotifierProvider);

          return sessionsAsync.when(
            data: (sessions) {
              return exercisesAsync.when(
                data: (exercises) {
                  return routinesAsync.when(
                    data: (routines) {
                      return ListView(
                        padding: const EdgeInsets.all(16),
                        children: [
                          _SectionTitle('Progreso de ejercicio (reps × peso)'),
                          const SizedBox(height: 12),
                          _ExerciseProgressChart(),
                          const SizedBox(height: 24),
                          _SectionTitle(
                            'Comparación por rutina (sets totales)',
                          ),
                          const SizedBox(height: 12),
                          _RoutineComparisonChart(),
                        ],
                      );
                    },
                    loading:
                        () => const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Center(child: Text('Error: $e')),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Error: $e')),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error: $e')),
          );
        },
      ),
      bottomNavigationBar: const CustomBottomNavigation(currentIndex: 3),
    );
  }

}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);
  @override
  Widget build(BuildContext context) {
    return Text(text, style: Theme.of(context).textTheme.titleMedium);
  }
}

class _RoutineComparisonChart extends ConsumerWidget {
  const _RoutineComparisonChart();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionsAsync = ref.watch(sessionNotifierProvider);
    return SizedBox(
      height: 220,
      child: sessionsAsync.when(
        data: (sessions) {
          final setsByRoutine = <String, int>{};
          for (final s in sessions) {
            final rid = s.routineId ?? 'Sin rutina';
            setsByRoutine[rid] =
                (setsByRoutine[rid] ?? 0) + s.exerciseSets.length;
          }
          if (setsByRoutine.isEmpty) {
            return const Center(child: Text('Sin datos'));
          }
          final pie = <PieChartSectionData>[];
          final total = setsByRoutine.values.fold<int>(0, (a, b) => a + b);
          setsByRoutine.entries.forEach((e) {
            final pct = total == 0 ? 0.0 : e.value / total * 100;
            pie.add(
              PieChartSectionData(
                value: e.value.toDouble(),
                title: '${pct.toStringAsFixed(0)}%',
                color: Theme.of(context).colorScheme.primary.withOpacity(
                  0.3 + (pie.length * 0.1).clamp(0, 0.6),
                ),
                radius: 60,
              ),
            );
          });
          return PieChart(
            PieChartData(
              sections: pie,
              sectionsSpace: 2,
              centerSpaceRadius: 34,
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

class _ExerciseProgressChart extends ConsumerStatefulWidget {
  const _ExerciseProgressChart();
  @override
  ConsumerState<_ExerciseProgressChart> createState() =>
      _ExerciseProgressChartState();
}

class _ExerciseProgressChartState
    extends ConsumerState<_ExerciseProgressChart> {
  static const String allExercisesId = '__all__';
  String? _selectedExerciseId;
  DateTime? _from;
  DateTime? _to;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _to = now;
    _from = now.subtract(const Duration(days: 28));
    _selectedExerciseId = allExercisesId; // Default: Todos los ejercicios
  }

  @override
  Widget build(BuildContext context) {
    final exercisesAsync = ref.watch(exerciseNotifierProvider);
    final sessionsAsync = ref.watch(sessionNotifierProvider);
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Selector de ejercicio
        DropdownButtonFormField<String>(
          value: _selectedExerciseId,
          decoration: const InputDecoration(labelText: 'Ejercicio'),
          items: exercisesAsync.when(
            data:
                (exercises) => [
                  const DropdownMenuItem(
                    value: allExercisesId,
                    child: Text('Todos'),
                  ),
                  ...exercises
                      .map(
                        (e) =>
                            DropdownMenuItem(value: e.id, child: Text(e.name)),
                      )
                      .toList(),
                ],
            loading: () => const [],
            error: (_, __) => const [],
          ),
          onChanged: (id) => setState(() => _selectedExerciseId = id),
        ),
        const SizedBox(height: 12),
        // Selector de rango de fechas
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate:
                        _from ??
                        DateTime.now().subtract(const Duration(days: 30)),
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) setState(() => _from = picked);
                },
                icon: const Icon(Icons.calendar_today),
                label: Text(
                  _from == null
                      ? 'Desde'
                      : '${_from!.day}/${_from!.month}/${_from!.year}',
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _to ?? DateTime.now(),
                    firstDate: _from ?? DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) setState(() => _to = picked);
                },
                icon: const Icon(Icons.calendar_today),
                label: Text(
                  _to == null
                      ? 'Hasta'
                      : '${_to!.day}/${_to!.month}/${_to!.year}',
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Gráfico de progreso
        SizedBox(
          height: 220,
          child: sessionsAsync.when(
            data: (sessions) {
              // Filtrar por fechas y ordenar cronológicamente
              final filtered =
                  sessions.where((s) {
                      if (_from != null && s.startTime.isBefore(_from!))
                        return false;
                      if (_to != null && s.startTime.isAfter(_to!))
                        return false;
                      // Si se selecciona ejercicio específico, exige que la sesión lo tenga
                      if (_selectedExerciseId != null &&
                          _selectedExerciseId != allExercisesId) {
                        return s.exerciseSets.any(
                          (set) => set.exerciseId == _selectedExerciseId,
                        );
                      }
                      return true;
                    }).toList()
                    ..sort((a, b) => a.startTime.compareTo(b.startTime));
              if (filtered.isEmpty) {
                return const Center(child: Text('Sin datos en el rango'));
              }
              // Calcular media ponderada (reps * peso) por sesión
              final rawSpots = <FlSpot>[];
              for (var i = 0; i < filtered.length; i++) {
                final s = filtered[i];
                final sets =
                    (_selectedExerciseId == allExercisesId)
                        ? s.exerciseSets
                        : s.exerciseSets
                            .where(
                              (set) => set.exerciseId == _selectedExerciseId,
                            )
                            .toList();
                if (sets.isEmpty) continue;
                final total = sets.fold<double>(
                  0,
                  (a, b) => a + (b.reps * b.weight),
                );
                final avg = total / sets.length;
                rawSpots.add(FlSpot(i.toDouble(), avg));
              }

              // Aplicar algoritmo de suavizado mejorado
              final spots = _applyAdvancedSmoothing(rawSpots, filtered);
              if (spots.isEmpty) {
                return const Center(child: Text('Sin datos en el rango'));
              }
              // Calcular rango Y para evitar que se salga del marco
              final yValues = spots.map((spot) => spot.y).toList();
              final minY = yValues.reduce((a, b) => a < b ? a : b);
              final maxY = yValues.reduce((a, b) => a > b ? a : b);
              final yRange = maxY - minY;
              final yPadding = yRange * 0.1; // 10% de padding
              final yMin = (minY - yPadding).clamp(0, double.infinity);
              final yMax = maxY + yPadding;

              return LineChart(
                LineChartData(
                  borderData: FlBorderData(show: true),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: _calculateYInterval(yMax - yMin),
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: theme.colorScheme.outline.withOpacity(0.2),
                        strokeWidth: 1,
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 50,
                        interval: _calculateYInterval(yMax - yMin),
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toInt().toString(),
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontSize: 10,
                            ),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        interval: _calculateDateInterval(filtered.length),
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= 0 &&
                              value.toInt() < filtered.length) {
                            final session = filtered[value.toInt()];
                            final date = session.startTime;
                            return Transform.rotate(
                              angle: -0.5, // Rotación de ~30 grados
                              child: Text(
                                '${date.day}/${date.month}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontSize: 10,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true, // Usar curva nativa de fl_chart
                      curveSmoothness: 0.5, // Suavizado moderado
                      // Sample2-style stroke
                      barWidth: 4,
                      isStrokeCapRound: true,
                      gradient: LinearGradient(
                        colors: [
                          theme.colorScheme.primary.withOpacity(0.9),
                          theme.colorScheme.tertiary.withOpacity(0.9),
                        ],
                      ),
                      dotData: FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            theme.colorScheme.primary.withOpacity(0.25),
                            theme.colorScheme.tertiary.withOpacity(0.05),
                          ],
                        ),
                      ),
                    ),
                  ],
                  minY: yMin.toDouble(),
                  maxY: yMax.toDouble(),
                  // Touch/tooltip similar to sample
                  lineTouchData: LineTouchData(
                    enabled: true,
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipItems:
                          (touchedSpots) =>
                              touchedSpots
                                  .map(
                                    (ts) => LineTooltipItem(
                                      ts.y.toStringAsFixed(0),
                                      theme.textTheme.labelMedium!,
                                    ),
                                  )
                                  .toList(),
                    ),
                  ),
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error: $e')),
          ),
        ),
      ],
    );
  }

  /// Calcula el intervalo óptimo para mostrar fechas sin solapamiento
  double _calculateDateInterval(int totalSessions) {
    if (totalSessions <= 7) return 1.0; // Mostrar todas si son pocas
    if (totalSessions <= 14) return 2.0; // Cada 2 días
    if (totalSessions <= 21) return 3.0; // Cada 3 días
    if (totalSessions <= 28) return 4.0; // Cada 4 días
    return (totalSessions / 7).ceilToDouble(); // Máximo 7 etiquetas
  }

  /// Calcula el intervalo óptimo para el eje Y
  double _calculateYInterval(double yRange) {
    if (yRange <= 50) return 10.0;
    if (yRange <= 100) return 20.0;
    if (yRange <= 200) return 50.0;
    if (yRange <= 500) return 100.0;
    return (yRange / 5).ceilToDouble();
  }

  /// Aplica algoritmo de suavizado avanzado para eliminar saltos y valores vacíos
  List<FlSpot> _applyAdvancedSmoothing(
    List<FlSpot> rawSpots,
    List<WorkoutSession> sessions,
  ) {
    if (rawSpots.isEmpty) return rawSpots;

    // Paso 1: Interpolación lineal para llenar huecos temporales
    final interpolatedSpots = _interpolateMissingValues(rawSpots, sessions);

    // Paso 2: Aplicar media móvil para suavizar la curva
    final smoothedSpots = _applyMovingAverage(interpolatedSpots);

    // Paso 3: Ajuste final para eliminar saltos bruscos
    final finalSpots = _removeSharpJumps(smoothedSpots);

    return finalSpots;
  }

  /// Interpola valores faltantes entre sesiones usando interpolación lineal
  List<FlSpot> _interpolateMissingValues(
    List<FlSpot> rawSpots,
    List<WorkoutSession> sessions,
  ) {
    if (rawSpots.length < 2) return rawSpots;

    final interpolatedSpots = <FlSpot>[];
    final maxDays = sessions.length;

    // Crear mapa de valores por día
    final valuesByDay = <int, double>{};
    for (int i = 0; i < rawSpots.length; i++) {
      valuesByDay[i] = rawSpots[i].y;
    }

    // Interpolar valores faltantes
    for (int day = 0; day < maxDays; day++) {
      if (valuesByDay.containsKey(day)) {
        // Valor existente
        interpolatedSpots.add(FlSpot(day.toDouble(), valuesByDay[day]!));
      } else {
        // Buscar valores anteriores y posteriores para interpolación
        final prevDay = _findPreviousValue(day, valuesByDay);
        final nextDay = _findNextValue(day, valuesByDay);

        if (prevDay != null && nextDay != null) {
          // Interpolación lineal entre valores existentes
          final interpolatedValue = _linearInterpolation(
            prevDay.day,
            prevDay.value,
            nextDay.day,
            nextDay.value,
            day,
          );
          interpolatedSpots.add(FlSpot(day.toDouble(), interpolatedValue));
        } else if (prevDay != null) {
          // Usar valor anterior si no hay siguiente
          interpolatedSpots.add(FlSpot(day.toDouble(), prevDay.value));
        } else if (nextDay != null) {
          // Usar valor siguiente si no hay anterior
          interpolatedSpots.add(FlSpot(day.toDouble(), nextDay.value));
        }
        // Si no hay valores anteriores ni posteriores, omitir el día
      }
    }

    return interpolatedSpots;
  }

  /// Encuentra el valor anterior más cercano
  _ValueAtDay? _findPreviousValue(int day, Map<int, double> valuesByDay) {
    for (int i = day - 1; i >= 0; i--) {
      if (valuesByDay.containsKey(i)) {
        return _ValueAtDay(i, valuesByDay[i]!);
      }
    }
    return null;
  }

  /// Encuentra el valor siguiente más cercano
  _ValueAtDay? _findNextValue(int day, Map<int, double> valuesByDay) {
    final maxDay = valuesByDay.keys.reduce((a, b) => a > b ? a : b);
    for (int i = day + 1; i <= maxDay; i++) {
      if (valuesByDay.containsKey(i)) {
        return _ValueAtDay(i, valuesByDay[i]!);
      }
    }
    return null;
  }

  /// Interpolación lineal entre dos puntos
  double _linearInterpolation(int x1, double y1, int x2, double y2, int x) {
    if (x2 == x1) return y1;
    return y1 + (y2 - y1) * (x - x1) / (x2 - x1);
  }

  /// Aplica media móvil para suavizar la curva
  List<FlSpot> _applyMovingAverage(List<FlSpot> spots) {
    if (spots.length < 3) return spots;

    final smoothedSpots = <FlSpot>[];
    const windowSize = 3; // Ventana de 3 puntos

    for (int i = 0; i < spots.length; i++) {
      double sum = 0;
      int count = 0;

      // Calcular media en la ventana
      for (int j = i - windowSize ~/ 2; j <= i + windowSize ~/ 2; j++) {
        if (j >= 0 && j < spots.length) {
          sum += spots[j].y;
          count++;
        }
      }

      final average = sum / count;
      smoothedSpots.add(FlSpot(spots[i].x, average));
    }

    return smoothedSpots;
  }

  /// Elimina saltos bruscos aplicando un filtro de suavizado adicional
  List<FlSpot> _removeSharpJumps(List<FlSpot> spots) {
    if (spots.length < 2) return spots;

    final filteredSpots = <FlSpot>[];
    const maxJumpRatio = 0.3; // Máximo 30% de cambio entre puntos consecutivos

    // Mantener el primer punto
    filteredSpots.add(spots.first);

    for (int i = 1; i < spots.length; i++) {
      final current = spots[i];
      final previous = filteredSpots.last;

      // Calcular el cambio porcentual
      final change = (current.y - previous.y).abs();
      final changeRatio = previous.y > 0 ? change / previous.y : 0;

      if (changeRatio > maxJumpRatio) {
        // Suavizar el salto brusco
        final smoothedY = previous.y + (current.y - previous.y) * maxJumpRatio;
        filteredSpots.add(FlSpot(current.x, smoothedY));
      } else {
        // Mantener el valor original
        filteredSpots.add(current);
      }
    }

    return filteredSpots;
  }
}

/// Clase auxiliar para almacenar valor y día
class _ValueAtDay {
  final int day;
  final double value;

  _ValueAtDay(this.day, this.value);
}
