import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../common/enums/progression_type_enum.dart';
import '../models/progression_config.dart';
import 'advanced_progression_config.dart';

/// Ejemplo de uso del widget de configuración avanzada con presets filtrados
///
/// Este widget demuestra cómo usar AdvancedProgressionConfig en una página
/// de configuración de progresión, mostrando solo los presets relevantes
/// para el tipo de progresión seleccionado.
class AdvancedConfigExample extends ConsumerStatefulWidget {
  const AdvancedConfigExample({super.key});

  @override
  ConsumerState<AdvancedConfigExample> createState() => _AdvancedConfigExampleState();
}

class _AdvancedConfigExampleState extends ConsumerState<AdvancedConfigExample> {
  ProgressionType _selectedProgressionType = ProgressionType.linear;
  ProgressionConfig? _selectedConfig;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración Avanzada con Presets'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título principal
            Text(
              'Configuración Avanzada Filtrada',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Selecciona un tipo de progresión para ver solo los presets relevantes para esa estrategia.',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7)),
            ),

            const SizedBox(height: 24),

            // Selector de tipo de progresión
            _buildProgressionTypeSelector(),

            const SizedBox(height: 24),

            // Widget de configuración avanzada filtrada
            AdvancedProgressionConfig(
              progressionType: _selectedProgressionType,
              initialConfig: _selectedConfig,
              onConfigChanged: (config) {
                setState(() {
                  _selectedConfig = config;
                });
              },
              showManualOptions: true,
            ),

            const SizedBox(height: 24),

            // Resumen de configuración seleccionada
            if (_selectedConfig != null) ...[_buildConfigSummary()],

            const SizedBox(height: 24),

            // Botón para aplicar configuración
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed:
                    _selectedConfig != null
                        ? () {
                          _showConfigDetails();
                        }
                        : null,
                icon: const Icon(Icons.info_outline),
                label: const Text('Ver Detalles de la Configuración'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressionTypeSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tipo de Progresión',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Selecciona el tipo de progresión para filtrar los presets disponibles.',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 16),

            DropdownButtonFormField<ProgressionType>(
              value: _selectedProgressionType,
              decoration: const InputDecoration(labelText: 'Estrategia de Progresión', border: OutlineInputBorder()),
              items:
                  ProgressionType.values.map((type) {
                    return DropdownMenuItem(value: type, child: Text(type.displayName));
                  }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedProgressionType = value;
                    _selectedConfig = null; // Reset config when changing type
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfigSummary() {
    final config = _selectedConfig!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.check_circle, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Configuración Seleccionada',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),

            _buildSummaryRow('Tipo', config.type.displayName),
            _buildSummaryRow('Unidad', config.unit.name),
            _buildSummaryRow('Valor de Incremento', '${config.incrementValue} kg'),
            _buildSummaryRow(
              'Frecuencia',
              'Cada ${config.incrementFrequency} ${config.unit == ProgressionUnit.session ? 'sesiones' : 'semanas'}',
            ),
            _buildSummaryRow('Longitud del Ciclo', '${config.cycleLength} semanas'),
            _buildSummaryRow('Semana de Deload', config.deloadWeek == 0 ? 'Sin deload' : 'Semana ${config.deloadWeek}'),
            _buildSummaryRow('Porcentaje de Deload', '${(config.deloadPercentage * 100).toInt()}%'),
            _buildSummaryRow('Rango de Repeticiones', '${config.minReps}-${config.maxReps} reps'),
            _buildSummaryRow('Series Base', '${config.baseSets} series'),

            if (config.customParameters.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                'Parámetros Personalizados:',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...config.customParameters.entries.map((entry) {
                return _buildSummaryRow(entry.key, entry.value.toString());
              }),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(child: Text(value, style: Theme.of(context).textTheme.bodyMedium)),
        ],
      ),
    );
  }

  void _showConfigDetails() {
    final config = _selectedConfig!;

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Detalles de la Configuración'),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Esta configuración está optimizada para:',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),

                  if (config.customParameters['description'] != null) ...[
                    Text(
                      config.customParameters['description'] as String,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 16),
                  ],

                  if (config.customParameters['best_for'] != null) ...[
                    Text(
                      'Ideal para:',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    ...(config.customParameters['best_for'] as List<dynamic>).map((item) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          children: [
                            Icon(Icons.check, size: 16, color: Theme.of(context).colorScheme.primary),
                            const SizedBox(width: 8),
                            Expanded(child: Text(item.toString(), style: Theme.of(context).textTheme.bodyMedium)),
                          ],
                        ),
                      );
                    }),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cerrar')),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Configuración aplicada: ${config.type.displayName}'),
                      backgroundColor: Theme.of(context).colorScheme.primary,
                    ),
                  );
                },
                child: const Text('Aplicar'),
              ),
            ],
          ),
    );
  }
}
