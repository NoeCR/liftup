import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../common/enums/progression_type_enum.dart';
import 'progression_configuration_with_templates_integrated.dart';

class ProgressionDemoPage extends ConsumerWidget {
  const ProgressionDemoPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Demo - Sistema de Plantillas'),
        backgroundColor: colorScheme.surface,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Información del demo
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.auto_awesome, color: colorScheme.primary),
                        const SizedBox(width: 8),
                        Text(
                          'Sistema de Plantillas de Progresión',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Este demo muestra el nuevo sistema de plantillas que reemplaza la configuración manual avanzada con plantillas predefinidas optimizadas para diferentes objetivos y niveles de experiencia.',
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Características:',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...const [
                      '• 25+ plantillas predefinidas para todas las estrategias',
                      '• Categorización por objetivo (hipertrofia, fuerza, powerlifting, etc.)',
                      '• Categorización por nivel (principiante, intermedio, avanzado)',
                      '• Información detallada de cada plantilla',
                      '• Toggle entre plantillas y configuración manual',
                      '• Valores coherentes y científicamente fundamentados',
                    ].map(
                      (feature) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(feature, style: theme.textTheme.bodyMedium),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Selector de tipo de progresión
            Text(
              'Selecciona un tipo de progresión para ver el demo:',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Grid de tipos de progresión
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.5,
              children:
                  ProgressionType.values.map((type) {
                    return _buildProgressionTypeCard(context, type);
                  }).toList(),
            ),
            const SizedBox(height: 24),

            // Información adicional
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Próximas Funcionalidades',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...const [
                      '• Filtros por objetivo y nivel en la UI',
                      '• Plantillas personalizadas por usuario',
                      '• Integración con rutinas existentes',
                      '• Análisis de progreso con plantillas',
                      '• Recomendaciones automáticas de plantillas',
                    ].map(
                      (feature) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(feature, style: theme.textTheme.bodyMedium),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressionTypeCard(BuildContext context, ProgressionType type) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () => _navigateToConfiguration(context, type),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _getProgressionIcon(type),
                size: 32,
                color: colorScheme.primary,
              ),
              const SizedBox(height: 8),
              Text(
                context.tr(type.displayNameKey),
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                _getProgressionDescription(type),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getProgressionIcon(ProgressionType type) {
    switch (type) {
      case ProgressionType.linear:
        return Icons.trending_up;
      case ProgressionType.double:
        return Icons.trending_up_outlined;
      case ProgressionType.undulating:
        return Icons.waves;
      case ProgressionType.stepped:
        return Icons.stairs;
      case ProgressionType.wave:
        return Icons.waves;
      case ProgressionType.static:
        return Icons.pause;
      case ProgressionType.reverse:
        return Icons.trending_down;
      case ProgressionType.autoregulated:
        return Icons.auto_awesome;
      case ProgressionType.doubleFactor:
        return Icons.double_arrow;
      case ProgressionType.overload:
        return Icons.fitness_center;
      case ProgressionType.none:
        return Icons.settings;
    }
  }

  String _getProgressionDescription(ProgressionType type) {
    switch (type) {
      case ProgressionType.linear:
        return 'Incremento constante de peso';
      case ProgressionType.double:
        return 'Primero reps, luego peso';
      case ProgressionType.undulating:
        return 'Alterna intensidad';
      case ProgressionType.stepped:
        return 'Progresión escalonada';
      case ProgressionType.wave:
        return 'Ciclos de intensidad';
      case ProgressionType.static:
        return 'Sin progresión';
      case ProgressionType.reverse:
        return 'Progresión inversa';
      case ProgressionType.autoregulated:
        return 'Basado en RPE';
      case ProgressionType.doubleFactor:
        return 'Doble factor';
      case ProgressionType.overload:
        return 'Sobrecarga progresiva';
      case ProgressionType.none:
        return 'Sin progresión';
    }
  }

  void _navigateToConfiguration(BuildContext context, ProgressionType type) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (context) => ProgressionConfigurationWithTemplatesIntegrated(
              progressionType: type,
            ),
      ),
    );
  }
}
