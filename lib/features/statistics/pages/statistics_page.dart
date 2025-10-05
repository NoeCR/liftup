import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
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
        title: Text(context.tr('statistics.title')),
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
                    error:
                        (e, _) => Center(
                          child: Text(
                            context.tr(
                              'errors.errorLoadingData',
                              namedArgs: {'error': e.toString()},
                            ),
                          ),
                        ),
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
            return Center(child: Text(context.tr('statistics.noData')));
          }
          final pie = <PieChartSectionData>[];
          final total = setsByRoutine.values.fold<int>(0, (a, b) => a + b);
          for (final e in setsByRoutine.entries) {
            final pct = total == 0 ? 0.0 : e.value / total * 100;
            pie.add(
              PieChartSectionData(
                value: e.value.toDouble(),
                title: '${pct.toStringAsFixed(0)}%',
                color: Theme.of(context).colorScheme.primary.withValues(
                  alpha: 0.3 + (pie.length * 0.1).clamp(0, 0.6),
                ),
                radius: 60,
              ),
            );
          }
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
    _selectedExerciseId = allExercisesId; // Default: all exercises
  }

  @override
  Widget build(BuildContext context) {
    final exercisesAsync = ref.watch(exerciseNotifierProvider);
    final sessionsAsync = ref.watch(sessionNotifierProvider);
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Exercise selector
        DropdownButtonFormField<String>(
          value: _selectedExerciseId,
          decoration: InputDecoration(
            labelText: context.tr('statistics.exercise'),
          ),
          items: exercisesAsync.when(
            data:
                (exercises) => [
                  DropdownMenuItem(
                    value: allExercisesId,
                    child: Text(context.tr('statistics.all')),
                  ),
                  ...exercises.map(
                    (e) => DropdownMenuItem(value: e.id, child: Text(e.name)),
                  ),
                ],
            loading: () => const [],
            error: (_, __) => const [],
          ),
          onChanged: (id) => setState(() => _selectedExerciseId = id),
        ),
        const SizedBox(height: 12),
        // Date range selector
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
        // Progress chart
        SizedBox(
          height: 220,
          child: sessionsAsync.when(
            data: (sessions) {
              // Filter by dates and sort chronologically
              final filtered =
                  sessions.where((s) {
                      if (_from != null && s.startTime.isBefore(_from!))
                        return false;
                      if (_to != null && s.startTime.isAfter(_to!))
                        return false;
                      // If a specific exercise is selected, require sessions to include it
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
                return Center(
                  child: Text(context.tr('statistics.noDataInRange')),
                );
              }
              // Compute weighted average (reps × weight) per session
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

              // Apply advanced smoothing algorithm
              final spots = _applyAdvancedSmoothing(rawSpots, filtered);
              if (spots.isEmpty) {
                return Center(
                  child: Text(context.tr('statistics.noDataInRange')),
                );
              }
              // Compute Y range to keep the chart within bounds
              final yValues = spots.map((spot) => spot.y).toList();
              final minY = yValues.reduce((a, b) => a < b ? a : b);
              final maxY = yValues.reduce((a, b) => a > b ? a : b);
              final yRange = maxY - minY;
              final yPadding = yRange * 0.1; // 10% padding
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
                        color: theme.colorScheme.outline.withValues(alpha: 0.2),
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
                              angle: -0.5, // ~30 degrees rotation
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
                          theme.colorScheme.primary.withValues(alpha: 0.9),
                          theme.colorScheme.tertiary.withValues(alpha: 0.9),
                        ],
                      ),
                      dotData: FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            theme.colorScheme.primary.withValues(alpha: 0.25),
                            theme.colorScheme.tertiary.withValues(alpha: 0.05),
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

  /// Calculates an optimal interval to show dates without overlap
  double _calculateDateInterval(int totalSessions) {
    if (totalSessions <= 7) return 1.0; // Show all when few
    if (totalSessions <= 14) return 2.0; // Every 2 days
    if (totalSessions <= 21) return 3.0; // Every 3 days
    if (totalSessions <= 28) return 4.0; // Every 4 days
    return (totalSessions / 7).ceilToDouble(); // Max 7 labels
  }

  /// Calculates an optimal interval for the Y axis
  double _calculateYInterval(double yRange) {
    if (yRange <= 50) return 10.0;
    if (yRange <= 100) return 20.0;
    if (yRange <= 200) return 50.0;
    if (yRange <= 500) return 100.0;
    return (yRange / 5).ceilToDouble();
  }

  /// Applies advanced smoothing to remove jumps and fill gaps
  List<FlSpot> _applyAdvancedSmoothing(
    List<FlSpot> rawSpots,
    List<WorkoutSession> sessions,
  ) {
    if (rawSpots.isEmpty) return rawSpots;

    // Step 1: Linear interpolation to fill temporal gaps
    final interpolatedSpots = _interpolateMissingValues(rawSpots, sessions);

    // Step 2: Apply moving average to smooth the curve
    final smoothedSpots = _applyMovingAverage(interpolatedSpots);

    // Step 3: Final pass to remove sharp jumps
    final finalSpots = _removeSharpJumps(smoothedSpots);

    return finalSpots;
  }

  /// Interpolates missing values between sessions using linear interpolation
  List<FlSpot> _interpolateMissingValues(
    List<FlSpot> rawSpots,
    List<WorkoutSession> sessions,
  ) {
    if (rawSpots.length < 2) return rawSpots;

    final interpolatedSpots = <FlSpot>[];
    final maxDays = sessions.length;

    // Build value-by-day map
    final valuesByDay = <int, double>{};
    for (int i = 0; i < rawSpots.length; i++) {
      valuesByDay[i] = rawSpots[i].y;
    }

    // Interpolate missing values
    for (int day = 0; day < maxDays; day++) {
      if (valuesByDay.containsKey(day)) {
        // Existing value
        interpolatedSpots.add(FlSpot(day.toDouble(), valuesByDay[day]!));
      } else {
        // Find previous and next values for interpolation
        final prevDay = _findPreviousValue(day, valuesByDay);
        final nextDay = _findNextValue(day, valuesByDay);

        if (prevDay != null && nextDay != null) {
          // Linear interpolation between existing values
          final interpolatedValue = _linearInterpolation(
            prevDay.day,
            prevDay.value,
            nextDay.day,
            nextDay.value,
            day,
          );
          interpolatedSpots.add(FlSpot(day.toDouble(), interpolatedValue));
        } else if (prevDay != null) {
          // Use previous value if no next value
          interpolatedSpots.add(FlSpot(day.toDouble(), prevDay.value));
        } else if (nextDay != null) {
          // Use next value if no previous value
          interpolatedSpots.add(FlSpot(day.toDouble(), nextDay.value));
        }
        // If there is neither previous nor next, skip the day
      }
    }

    return interpolatedSpots;
  }

  /// Finds the nearest previous value
  _ValueAtDay? _findPreviousValue(int day, Map<int, double> valuesByDay) {
    for (int i = day - 1; i >= 0; i--) {
      if (valuesByDay.containsKey(i)) {
        return _ValueAtDay(i, valuesByDay[i]!);
      }
    }
    return null;
  }

  /// Finds the nearest next value
  _ValueAtDay? _findNextValue(int day, Map<int, double> valuesByDay) {
    final maxDay = valuesByDay.keys.reduce((a, b) => a > b ? a : b);
    for (int i = day + 1; i <= maxDay; i++) {
      if (valuesByDay.containsKey(i)) {
        return _ValueAtDay(i, valuesByDay[i]!);
      }
    }
    return null;
  }

  /// Linear interpolation between two points
  double _linearInterpolation(int x1, double y1, int x2, double y2, int x) {
    if (x2 == x1) return y1;
    return y1 + (y2 - y1) * (x - x1) / (x2 - x1);
  }

  /// Applies a moving average to smooth the curve
  List<FlSpot> _applyMovingAverage(List<FlSpot> spots) {
    if (spots.length < 3) return spots;

    final smoothedSpots = <FlSpot>[];
    const windowSize = 3; // 3-point window

    for (int i = 0; i < spots.length; i++) {
      double sum = 0;
      int count = 0;

      // Compute average over the window
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

  /// Removes sharp jumps by applying an additional smoothing filter
  List<FlSpot> _removeSharpJumps(List<FlSpot> spots) {
    if (spots.length < 2) return spots;

    final filteredSpots = <FlSpot>[];
    const maxJumpRatio = 0.3; // Max 30% change between consecutive points

    // Keep the first point
    filteredSpots.add(spots.first);

    for (int i = 1; i < spots.length; i++) {
      final current = spots[i];
      final previous = filteredSpots.last;

      // Calculate percentage change
      final change = (current.y - previous.y).abs();
      final changeRatio = previous.y > 0 ? change / previous.y : 0;

      if (changeRatio > maxJumpRatio) {
        // Smooth the sharp jump
        final smoothedY = previous.y + (current.y - previous.y) * maxJumpRatio;
        filteredSpots.add(FlSpot(current.x, smoothedY));
      } else {
        // Keep original value
        filteredSpots.add(current);
      }
    }

    return filteredSpots;
  }
}

/// Helper class to store a value and its day
class _ValueAtDay {
  final int day;
  final double value;

  _ValueAtDay(this.day, this.value);
}
