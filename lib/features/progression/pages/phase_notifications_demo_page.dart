import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liftly/common/enums/progression_type_enum.dart';
import 'package:liftly/features/progression/models/progression_config.dart';
import 'package:liftly/features/progression/models/progression_state.dart';
import 'package:liftly/features/progression/services/phase_notification_service.dart';
import 'package:liftly/features/progression/widgets/phase_notification_widget.dart';
import 'package:liftly/features/progression/widgets/phase_progress_analytics_widget.dart';

class PhaseNotificationsDemoPage extends ConsumerStatefulWidget {
  const PhaseNotificationsDemoPage({super.key});

  @override
  ConsumerState<PhaseNotificationsDemoPage> createState() =>
      _PhaseNotificationsDemoPageState();
}

class _PhaseNotificationsDemoPageState
    extends ConsumerState<PhaseNotificationsDemoPage> {
  final PhaseNotificationService _notificationService =
      PhaseNotificationService();

  // Datos de simulación
  final List<ProgressionConfig> _simulatedConfigs = [];
  final List<ProgressionState> _simulatedStates = [];
  int _currentSimulationWeek = 1;

  @override
  void initState() {
    super.initState();
    _initializeSimulationData();
  }

  void _initializeSimulationData() {
    // Configuración de simulación para hipertrofia
    _simulatedConfigs.add(
      ProgressionConfig(
        id: 'demo-config-1',
        isGlobal: true,
        type: ProgressionType.overload,
        unit: ProgressionUnit.week,
        primaryTarget: ProgressionTarget.volume,
        incrementValue: 0.0,
        incrementFrequency: 1,
        cycleLength: 12,
        deloadWeek: 12,
        deloadPercentage: 0.8,
        customParameters: {
          'overload_type': 'phases',
          'phase_duration_weeks': 4,
          'accumulation_rate': 0.2,
          'intensification_rate': 0.05,
          'peaking_rate': 0.02,
        },
        startDate: DateTime.now().subtract(
          const Duration(days: 84),
        ), // 12 semanas atrás
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 84)),
        updatedAt: DateTime.now(),
      ),
    );

    // Estados de simulación para diferentes ejercicios
    _simulatedStates.addAll([
      ProgressionState(
        id: 'demo-state-1',
        progressionConfigId: 'demo-config-1',
        exerciseId: 'sentadilla',
        routineId: 'demo-routine',
        currentCycle: 1,
        currentWeek: 1,
        currentSession: 1,
        currentWeight: 100.0,
        currentReps: 8,
        currentSets: 4,
        baseWeight: 100.0,
        baseReps: 8,
        baseSets: 4,
        sessionHistory: {},
        lastUpdated: DateTime.now(),
        isDeloadWeek: false,
        customData: {},
      ),
      ProgressionState(
        id: 'demo-state-2',
        progressionConfigId: 'demo-config-1',
        exerciseId: 'press_banca',
        routineId: 'demo-routine',
        currentCycle: 1,
        currentWeek: 1,
        currentSession: 1,
        currentWeight: 80.0,
        currentReps: 8,
        currentSets: 4,
        baseWeight: 80.0,
        baseReps: 8,
        baseSets: 4,
        sessionHistory: {},
        lastUpdated: DateTime.now(),
        isDeloadWeek: false,
        customData: {},
      ),
      ProgressionState(
        id: 'demo-state-3',
        progressionConfigId: 'demo-config-1',
        exerciseId: 'peso_muerto',
        routineId: 'demo-routine',
        currentCycle: 1,
        currentWeek: 1,
        currentSession: 1,
        currentWeight: 120.0,
        currentReps: 8,
        currentSets: 4,
        baseWeight: 120.0,
        baseReps: 8,
        baseSets: 4,
        sessionHistory: {},
        lastUpdated: DateTime.now(),
        isDeloadWeek: false,
        customData: {},
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Demo - Notificaciones de Fase'),
        backgroundColor: colorScheme.surface,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: _showInfoDialog,
          ),
          PopupMenuButton<String>(
            onSelected: _handleMenuAction,
            itemBuilder:
                (context) => [
                  const PopupMenuItem(
                    value: 'simulate',
                    child: ListTile(
                      leading: Icon(Icons.play_arrow),
                      title: Text('Simular Progresión'),
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'clear',
                    child: ListTile(
                      leading: Icon(Icons.clear_all),
                      title: Text('Limpiar Historial'),
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'reset',
                    child: ListTile(
                      leading: Icon(Icons.refresh),
                      title: Text('Reiniciar Demo'),
                    ),
                  ),
                ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Información del demo
            _buildDemoInfo(theme, colorScheme),
            const SizedBox(height: 24),

            // Controles de simulación
            _buildSimulationControls(theme, colorScheme),
            const SizedBox(height: 24),

            // Notificaciones de cambio de fase
            PhaseNotificationWidget(showAllChanges: true, maxDisplayItems: 3),
            const SizedBox(height: 24),

            // Análisis de progresión
            PhaseProgressAnalyticsWidget(showDetailedStats: true),
            const SizedBox(height: 24),

            // Widgets compactos para ejercicios específicos
            _buildExerciseSpecificNotifications(theme, colorScheme),
          ],
        ),
      ),
    );
  }

  Widget _buildDemoInfo(ThemeData theme, ColorScheme colorScheme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.notifications_active, color: colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Sistema de Notificaciones de Fase',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Este demo muestra cómo el sistema detecta y notifica automáticamente los cambios de fase en las estrategias de progresión con periodización automática.',
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
              '• Detección automática de cambios de fase',
              '• Notificaciones en tiempo real',
              '• Historial de cambios de fase',
              '• Análisis de progresión por fase',
              '• Estadísticas detalladas',
              '• Widgets compactos para ejercicios específicos',
            ].map(
              (feature) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(feature, style: theme.textTheme.bodyMedium),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSimulationControls(ThemeData theme, ColorScheme colorScheme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Simulador de Progresión',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Simula el progreso semanal para ver cómo se detectan los cambios de fase',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Semana Actual: $_currentSimulationWeek',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Slider(
                        value: _currentSimulationWeek.toDouble(),
                        min: 1,
                        max: 12,
                        divisions: 11,
                        label: 'Semana $_currentSimulationWeek',
                        onChanged: (value) {
                          setState(() {
                            _currentSimulationWeek = value.round();
                          });
                          _simulateProgression();
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  children: [
                    FilledButton.icon(
                      onPressed: _simulateProgression,
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('Simular'),
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: _resetSimulation,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Reiniciar'),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseSpecificNotifications(
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Notificaciones por Ejercicio',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Widgets compactos que muestran la fase actual para cada ejercicio',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  _simulatedStates.map((state) {
                    return CompactPhaseNotificationWidget(
                      exerciseId: state.exerciseId,
                      routineId: state.routineId,
                      onTap: () => _showExerciseDetails(state.exerciseId),
                    );
                  }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  void _simulateProgression() {
    // Actualizar las semanas en los estados simulados
    for (final state in _simulatedStates) {
      final updatedState = ProgressionState(
        id: state.id,
        progressionConfigId: state.progressionConfigId,
        exerciseId: state.exerciseId,
        routineId: state.routineId,
        currentCycle: state.currentCycle,
        currentWeek: _currentSimulationWeek,
        currentSession: state.currentSession,
        currentWeight: state.currentWeight,
        currentReps: state.currentReps,
        currentSets: state.currentSets,
        baseWeight: state.baseWeight,
        baseReps: state.baseReps,
        baseSets: state.baseSets,
        sessionHistory: state.sessionHistory,
        lastUpdated: DateTime.now(),
        isDeloadWeek: state.isDeloadWeek,
        customData: state.customData,
      );

      // Detectar cambios de fase
      _notificationService.detectPhaseChange(
        config: _simulatedConfigs.first,
        state: updatedState,
        routineId: 'demo-routine',
      );
    }
  }

  void _resetSimulation() {
    setState(() {
      _currentSimulationWeek = 1;
    });
    _notificationService.reset();
    _initializeSimulationData();
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'simulate':
        _simulateProgression();
        break;
      case 'clear':
        _notificationService.clearPhaseChanges();
        break;
      case 'reset':
        _resetSimulation();
        break;
    }
  }

  void _showExerciseDetails(String exerciseId) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Detalles de $exerciseId'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Ejercicio: $exerciseId'),
                const SizedBox(height: 8),
                Text('Semana actual: $_currentSimulationWeek'),
                const SizedBox(height: 8),
                Text('Fase: ${_getCurrentPhaseName()}'),
                const SizedBox(height: 16),
                const Text('Cambios de fase recientes:'),
                const SizedBox(height: 8),
                SizedBox(
                  height: 200,
                  child: PhaseNotificationWidget(
                    exerciseId: exerciseId,
                    routineId: 'demo-routine',
                    showAllChanges: false,
                    maxDisplayItems: 10,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cerrar'),
              ),
            ],
          ),
    );
  }

  String _getCurrentPhaseName() {
    if (_currentSimulationWeek <= 4) {
      return 'Acumulación';
    } else if (_currentSimulationWeek <= 8) {
      return 'Intensificación';
    } else {
      return 'Peaking';
    }
  }

  void _showInfoDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Información sobre Notificaciones de Fase'),
            content: const SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'El sistema de notificaciones de fase detecta automáticamente cuando cambias de una fase a otra en las estrategias de progresión con periodización automática.',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 12),
                  Text('🔵 Acumulación: Enfoque en volumen'),
                  Text('🟠 Intensificación: Enfoque en intensidad'),
                  Text('🔴 Peaking: Máxima intensidad, volumen reducido'),
                  SizedBox(height: 12),
                  Text(
                    'Beneficios:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text('• Seguimiento automático del progreso'),
                  Text('• Notificaciones en tiempo real'),
                  Text('• Análisis de rendimiento por fase'),
                  Text('• Historial completo de cambios'),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cerrar'),
              ),
            ],
          ),
    );
  }
}
