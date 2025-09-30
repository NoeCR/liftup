import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../common/widgets/custom_bottom_navigation.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../sessions/notifiers/session_notifier.dart';
import '../../exercise/notifiers/exercise_notifier.dart';
import '../../home/notifiers/routine_notifier.dart';
import '../../home/models/routine.dart';
import 'package:uuid/uuid.dart';
import '../../exercise/models/exercise_set.dart';
import '../../sessions/models/workout_session.dart';
import '../../sessions/services/session_service.dart';

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
        actions: [
          IconButton(
            tooltip: 'Cargar datos de muestra',
            onPressed: () => _showSeedDialog(context, ref),
            icon: const Icon(Icons.dataset),
          ),
        ],
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
                          _SectionTitle('Evolución de sesiones (duración)'),
                          const SizedBox(height: 12),
                          _SessionsDurationChart(),
                          const SizedBox(height: 24),
                          _SectionTitle('Comparación por rutina (sets totales)'),
                          const SizedBox(height: 12),
                          _RoutineComparisonChart(),
                        ],
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
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error: $e')),
          );
        },
      ),
      bottomNavigationBar: const CustomBottomNavigation(currentIndex: 3),
    );
  }

  void _showSeedDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cargar datos de muestra'),
        content: const Text('Esto creará sesiones de prueba en distintos días y rutinas.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _seedSampleData(ref);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Datos de muestra creados')),
                );
              }
            },
            child: const Text('Crear'),
          ),
        ],
      ),
    );
  }

  Future<void> _seedSampleData(WidgetRef ref) async {
    // Crea 2 rutinas si no existen suficientes
    final routineNotifier = ref.read(routineNotifierProvider.notifier);
    final routines = await ref.read(routineNotifierProvider.future);
    Routine routineA = routines.isNotEmpty ? routines.first : Routine(
      id: const Uuid().v4(),
      name: 'Fuerza A',
      description: 'Pecho/Espalda',
      days: const [],
      sections: const [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      imageUrl: null,
    );
    if (routines.isEmpty) {
      await routineNotifier.addRoutine(routineA);
    }

    Routine routineB = routines.length > 1 ? routines[1] : Routine(
      id: const Uuid().v4(),
      name: 'Fuerza B',
      description: 'Pierna/Hombro',
      days: const [],
      sections: const [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      imageUrl: null,
    );
    if (routines.length < 2) {
      await routineNotifier.addRoutine(routineB);
    }

    // Crear sesiones en días previos
    final sessionNotifier = ref.read(sessionNotifierProvider.notifier);
    final exercises = await ref.read(exerciseNotifierProvider.future);
    final sampleExercise = exercises.isNotEmpty ? exercises.first : null;
    final now = DateTime.now();
    final routineIds = [routineA.id, routineB.id];

    for (int i = 1; i <= 14; i++) {
      final day = now.subtract(Duration(days: i));
      final routineId = routineIds[i % routineIds.length];
      final session = await sessionNotifier.startSession(name: 'Sesión $i', routineId: routineId);
      // Simular duración: pausa + reanudar para setear elapsed
      await Future.delayed(const Duration(milliseconds: 5));
      // Añadir algunos sets
      if (sampleExercise != null) {
        final setsCount = 2 + (i % 4);
        for (int s = 0; s < setsCount; s++) {
          await sessionNotifier.addExerciseSet(
            ExerciseSet(
              id: const Uuid().v4(),
              exerciseId: sampleExercise.id,
              reps: 8 + (i % 3),
              weight: 20 + (i * 1.5),
              restTimeSeconds: 60,
              notes: null,
              completedAt: day.add(Duration(minutes: s * 3)),
              isCompleted: true,
            ),
          );
        }
      }
      // Completar sesión con timestamps manuales
      final sessions = await ref.read(sessionNotifierProvider.future);
      final created = sessions.firstWhere((s) => s.id == session.id);
      final adjusted = created.copyWith(
        startTime: DateTime(day.year, day.month, day.day, 18, 0),
        endTime: DateTime(day.year, day.month, day.day, 19, 5 + (i % 20)),
        status: SessionStatus.completed,
      );
      await ref.read(sessionServiceProvider).saveSession(adjusted);
    }
    // Refrescar providers
    ref.invalidate(sessionNotifierProvider);
    ref.invalidate(routineNotifierProvider);
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

class _SessionsDurationChart extends ConsumerWidget {
  const _SessionsDurationChart();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionsAsync = ref.watch(sessionNotifierProvider);
    return SizedBox(
      height: 220,
      child: sessionsAsync.when(
        data: (sessions) {
          final completed = sessions.where((s) => s.endTime != null).toList()
            ..sort((a, b) => a.startTime.compareTo(b.startTime));
          if (completed.isEmpty) {
            return const Center(child: Text('Sin datos'));
          }
          final spots = <FlSpot>[];
          for (var i = 0; i < completed.length; i++) {
            final d = completed[i].duration?.inMinutes.toDouble() ?? 0;
            spots.add(FlSpot(i.toDouble(), d));
          }
          return LineChart(
            LineChartData(
              borderData: FlBorderData(show: false),
              titlesData: const FlTitlesData(show: false),
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  color: Theme.of(context).colorScheme.primary,
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show: true,
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
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
            setsByRoutine[rid] = (setsByRoutine[rid] ?? 0) + s.exerciseSets.length;
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
                color: Theme.of(context).colorScheme.primary.withOpacity(0.3 + (pie.length * 0.1).clamp(0, 0.6)),
                radius: 60,
              ),
            );
          });
          return PieChart(PieChartData(sections: pie, sectionsSpace: 2, centerSpaceRadius: 34));
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
  ConsumerState<_ExerciseProgressChart> createState() => _ExerciseProgressChartState();
}

class _ExerciseProgressChartState extends ConsumerState<_ExerciseProgressChart> {
  String? _selectedExerciseId;
  DateTime? _from;
  DateTime? _to;

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
            data: (exercises) => exercises.map((e) => DropdownMenuItem(value: e.id, child: Text(e.name))).toList(),
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
                    initialDate: _from ?? DateTime.now().subtract(const Duration(days: 30)),
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) setState(() => _from = picked);
                },
                icon: const Icon(Icons.calendar_today),
                label: Text(_from == null ? 'Desde' : '${_from!.day}/${_from!.month}/${_from!.year}'),
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
                label: Text(_to == null ? 'Hasta' : '${_to!.day}/${_to!.month}/${_to!.year}'),
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
              if (_selectedExerciseId == null) {
                return const Center(child: Text('Selecciona un ejercicio'));
              }
              final filtered = sessions.where((s) {
                if (_from != null && s.startTime.isBefore(_from!)) return false;
                if (_to != null && s.startTime.isAfter(_to!)) return false;
                return s.exerciseSets.any((set) => set.exerciseId == _selectedExerciseId);
              }).toList();
              if (filtered.isEmpty) {
                return const Center(child: Text('Sin datos en el rango'));
              }
              // Calcular media ponderada (reps * peso) por sesión
              final spots = <FlSpot>[];
              for (var i = 0; i < filtered.length; i++) {
                final s = filtered[i];
                final sets = s.exerciseSets.where((set) => set.exerciseId == _selectedExerciseId).toList();
                if (sets.isEmpty) continue;
                final total = sets.fold<double>(0, (a, b) => a + (b.reps * b.weight));
                final avg = total / sets.length;
                spots.add(FlSpot(i.toDouble(), avg));
              }
              return LineChart(
                LineChartData(
                  borderData: FlBorderData(show: false),
                  titlesData: const FlTitlesData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: theme.colorScheme.primary,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: theme.colorScheme.primary.withOpacity(0.2),
                      ),
                    ),
                  ],
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
}
