import 'package:flutter/material.dart';
import 'package:liftly/features/progression/models/progression_template.dart';

class PhaseVisualizationWidget extends StatelessWidget {
  final ProgressionTemplate template;
  final int? currentWeek;

  const PhaseVisualizationWidget({super.key, required this.template, this.currentWeek});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Solo mostrar para plantillas de overload con fases
    if (template.progressionType.name != 'overload' || template.customParameters['overload_type'] != 'phases') {
      return const SizedBox.shrink();
    }

    final phaseDurationWeeks = template.customParameters['phase_duration_weeks'] as int? ?? 4;
    final cycleLength = template.cycleLength;
    final phases = _generatePhases(phaseDurationWeeks, cycleLength);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.timeline, color: colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Visualización de Fases',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Esta plantilla utiliza periodización automática con ${phases.length} fases:',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            ...phases.asMap().entries.map((entry) {
              final index = entry.key;
              final phase = entry.value;
              final isCurrentPhase =
                  currentWeek != null && currentWeek! >= phase.startWeek && currentWeek! <= phase.endWeek;

              return _buildPhaseCard(context, phase, index, isCurrentPhase, colorScheme);
            }),
            const SizedBox(height: 16),
            _buildPhaseLegend(context, colorScheme),
          ],
        ),
      ),
    );
  }

  Widget _buildPhaseCard(
    BuildContext context,
    PhaseInfo phase,
    int index,
    bool isCurrentPhase,
    ColorScheme colorScheme,
  ) {
    final theme = Theme.of(context);
    final phaseColors = [
      Colors.blue, // Acumulación
      Colors.orange, // Intensificación
      Colors.red, // Peaking
    ];

    final phaseColor = phaseColors[index % phaseColors.length];
    final cardColor = isCurrentPhase ? phaseColor.withOpacity(0.1) : colorScheme.surfaceContainerHighest;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isCurrentPhase ? phaseColor : colorScheme.outline.withOpacity(0.2),
          width: isCurrentPhase ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          // Indicador de fase
          Container(width: 12, height: 12, decoration: BoxDecoration(color: phaseColor, shape: BoxShape.circle)),
          const SizedBox(width: 12),
          // Información de la fase
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      phase.name,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isCurrentPhase ? phaseColor : null,
                      ),
                    ),
                    if (isCurrentPhase) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: phaseColor, borderRadius: BorderRadius.circular(4)),
                        child: Text(
                          'ACTUAL',
                          style: theme.textTheme.labelSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Semanas ${phase.startWeek}-${phase.endWeek} (${phase.duration} semanas)',
                  style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                ),
                const SizedBox(height: 4),
                Text(phase.description, style: theme.textTheme.bodySmall),
                const SizedBox(height: 4),
                Text(
                  phase.progression,
                  style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500, color: phaseColor),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhaseLegend(BuildContext context, ColorScheme colorScheme) {
    final theme = Theme.of(context);
    final legendItems = [
      ('Acumulación', Colors.blue, 'Enfoque en volumen'),
      ('Intensificación', Colors.orange, 'Enfoque en intensidad'),
      ('Peaking', Colors.red, 'Máxima intensidad, volumen reducido'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Leyenda:', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ...legendItems.map((item) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              children: [
                Container(width: 12, height: 12, decoration: BoxDecoration(color: item.$2, shape: BoxShape.circle)),
                const SizedBox(width: 8),
                Text(item.$1, style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500)),
                const SizedBox(width: 8),
                Text('- ${item.$3}', style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant)),
              ],
            ),
          );
        }),
      ],
    );
  }

  List<PhaseInfo> _generatePhases(int phaseDurationWeeks, int cycleLength) {
    final phases = <PhaseInfo>[];
    final phaseNames = ['Acumulación', 'Intensificación', 'Peaking'];
    final phaseDescriptions = [
      'Construye base de volumen progresivamente',
      'Desarrolla fuerza máxima con incrementos de peso',
      'Maximiza rendimiento con volumen reducido',
    ];
    final progressions = [
      'Volumen +${(template.customParameters['accumulation_rate'] as num? ?? 0.15) * 100}% semanal',
      'Peso +${(template.customParameters['intensification_rate'] as num? ?? 0.1) * 100}% semanal',
      'Peso +${(template.customParameters['peaking_rate'] as num? ?? 0.05) * 100}% semanal, Volumen -20%',
    ];

    for (int i = 0; i < 3; i++) {
      final startWeek = (i * phaseDurationWeeks) + 1;
      final endWeek = ((i + 1) * phaseDurationWeeks).clamp(1, cycleLength);
      final duration = endWeek - startWeek + 1;

      phases.add(
        PhaseInfo(
          phase: i,
          weekInPhase: 1,
          phaseDuration: phaseDurationWeeks,
          name: phaseNames[i],
          description: phaseDescriptions[i],
          progression: progressions[i],
          startWeek: startWeek,
          endWeek: endWeek,
          duration: duration,
        ),
      );
    }

    return phases;
  }
}

/// Información extendida sobre la fase para visualización
class PhaseInfo {
  final int phase;
  final int weekInPhase;
  final int phaseDuration;
  final String name;
  final String description;
  final String progression;
  final int startWeek;
  final int endWeek;
  final int duration;

  PhaseInfo({
    required this.phase,
    required this.weekInPhase,
    required this.phaseDuration,
    required this.name,
    required this.description,
    required this.progression,
    required this.startWeek,
    required this.endWeek,
    required this.duration,
  });
}
