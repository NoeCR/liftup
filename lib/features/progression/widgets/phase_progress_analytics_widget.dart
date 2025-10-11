import 'package:flutter/material.dart';
import 'package:liftly/features/progression/services/phase_notification_service.dart';

class PhaseProgressAnalyticsWidget extends StatefulWidget {
  final String? exerciseId;
  final String? routineId;
  final bool showDetailedStats;

  const PhaseProgressAnalyticsWidget({super.key, this.exerciseId, this.routineId, this.showDetailedStats = true});

  @override
  State<PhaseProgressAnalyticsWidget> createState() => _PhaseProgressAnalyticsWidgetState();
}

class _PhaseProgressAnalyticsWidgetState extends State<PhaseProgressAnalyticsWidget> {
  late PhaseNotificationService _notificationService;

  @override
  void initState() {
    super.initState();
    _notificationService = PhaseNotificationService();
    _notificationService.addListener(_onNotificationServiceChanged);
  }

  @override
  void dispose() {
    _notificationService.removeListener(_onNotificationServiceChanged);
    super.dispose();
  }

  void _onNotificationServiceChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final stats = _notificationService.getPhaseChangeStatistics();

    if (stats['totalChanges'] == 0) {
      return _buildEmptyState(theme, colorScheme);
    }

    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(theme, colorScheme),
            const SizedBox(height: 16),
            if (widget.showDetailedStats) ...[
              _buildOverviewStats(theme, colorScheme, stats),
              const SizedBox(height: 16),
              _buildPhaseDistribution(theme, colorScheme, stats),
              const SizedBox(height: 16),
              _buildExerciseStats(theme, colorScheme, stats),
            ] else ...[
              _buildCompactStats(theme, colorScheme, stats),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme, ColorScheme colorScheme) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(Icons.analytics_outlined, size: 48, color: colorScheme.onSurfaceVariant),
            const SizedBox(height: 12),
            Text(
              'Sin datos de progresión',
              style: theme.textTheme.titleMedium?.copyWith(color: colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 4),
            Text(
              'Los datos de progresión por fase aparecerán aquí una vez que comiences a usar plantillas con fases automáticas.',
              style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, ColorScheme colorScheme) {
    return Row(
      children: [
        Icon(Icons.analytics, color: colorScheme.primary, size: 20),
        const SizedBox(width: 8),
        Text(
          'Análisis de Progresión por Fases',
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: colorScheme.primary),
        ),
        const Spacer(),
        IconButton(
          icon: const Icon(Icons.refresh, size: 18),
          onPressed: () => setState(() {}),
          tooltip: 'Actualizar estadísticas',
        ),
      ],
    );
  }

  Widget _buildOverviewStats(ThemeData theme, ColorScheme colorScheme, Map<String, dynamic> stats) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Resumen General', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                theme,
                colorScheme,
                'Total Cambios',
                '${stats['totalChanges']}',
                Icons.swap_horiz,
                Colors.blue,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildStatCard(
                theme,
                colorScheme,
                'Promedio/Semana',
                '${stats['averageChangesPerWeek'].toStringAsFixed(1)}',
                Icons.trending_up,
                Colors.green,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPhaseDistribution(ThemeData theme, ColorScheme colorScheme, Map<String, dynamic> stats) {
    final changesByPhase = stats['changesByPhase'] as Map<String, int>;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Distribución por Fases', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ...changesByPhase.entries.map((entry) {
          final phase = entry.key;
          final count = entry.value;
          final percentage = (count / stats['totalChanges'] * 100).toStringAsFixed(1);
          final color = _getPhaseColor(phase);

          return _buildPhaseDistributionItem(theme, colorScheme, phase, count, percentage, color);
        }),
      ],
    );
  }

  Widget _buildExerciseStats(ThemeData theme, ColorScheme colorScheme, Map<String, dynamic> stats) {
    final changesByExercise = stats['changesByExercise'] as Map<String, int>;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Cambios por Ejercicio', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ...changesByExercise.entries.take(5).map((entry) {
          final exerciseId = entry.key;
          final count = entry.value;

          return _buildExerciseStatItem(theme, colorScheme, exerciseId, count);
        }),
        if (changesByExercise.length > 5) ...[
          const SizedBox(height: 4),
          Text(
            '... y ${changesByExercise.length - 5} ejercicios más',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildCompactStats(ThemeData theme, ColorScheme colorScheme, Map<String, dynamic> stats) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            theme,
            colorScheme,
            'Cambios',
            '${stats['totalChanges']}',
            Icons.swap_horiz,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildStatCard(
            theme,
            colorScheme,
            'Promedio/Sem',
            '${stats['averageChangesPerWeek'].toStringAsFixed(1)}',
            Icons.trending_up,
            Colors.green,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    ThemeData theme,
    ColorScheme colorScheme,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(value, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: color)),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPhaseDistributionItem(
    ThemeData theme,
    ColorScheme colorScheme,
    String phase,
    int count,
    String percentage,
    Color color,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Expanded(child: Text(phase, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500))),
          Text(
            '$count ($percentage%)',
            style: theme.textTheme.bodyMedium?.copyWith(color: color, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseStatItem(ThemeData theme, ColorScheme colorScheme, String exerciseId, int count) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(color: colorScheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(6)),
      child: Row(
        children: [
          Icon(Icons.fitness_center, size: 16, color: colorScheme.onSurfaceVariant),
          const SizedBox(width: 8),
          Expanded(child: Text(exerciseId, style: theme.textTheme.bodyMedium, overflow: TextOverflow.ellipsis)),
          Text(
            '$count cambios',
            style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.primary, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Color _getPhaseColor(String phase) {
    switch (phase) {
      case 'Acumulación':
        return Colors.blue;
      case 'Intensificación':
        return Colors.orange;
      case 'Peaking':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
