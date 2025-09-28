import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../notifiers/session_notifier.dart';
import '../../../common/widgets/custom_bottom_navigation.dart';

class SessionPage extends ConsumerStatefulWidget {
  const SessionPage({super.key});

  @override
  ConsumerState<SessionPage> createState() => _SessionPageState();
}

class _SessionPageState extends ConsumerState<SessionPage> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sesión de Entrenamiento'),
        backgroundColor: colorScheme.surface,
      ),
      body: Consumer(
        builder: (context, ref, child) {
          final sessionAsync = ref.watch(sessionNotifierProvider);

          return sessionAsync.when(
            data: (sessions) {
              final activeSession = sessions.firstWhere(
                (session) => session.isActive,
                orElse: () => throw Exception('No hay sesión activa'),
              );

              return _buildActiveSession(activeSession);
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => _buildNoActiveSession(),
          );
        },
      ),
      bottomNavigationBar: const CustomBottomNavigation(currentIndex: 2),
    );
  }

  Widget _buildActiveSession(session) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      children: [
        // Session Timer
        _buildSessionTimer(session),

        // Session Content
        Expanded(child: _buildSessionContent(session)),

        // Session Controls
        _buildSessionControls(session),
      ],
    );
  }

  Widget _buildSessionTimer(session) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            'Tiempo de Entrenamiento',
            style: theme.textTheme.titleMedium?.copyWith(
              color: colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '00:00:00', // TODO: Implement timer
            style: theme.textTheme.headlineLarge?.copyWith(
              color: colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionContent(session) {
    return const Center(child: Text('Contenido de la sesión - En desarrollo'));
  }

  Widget _buildSessionControls(session) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {
                // TODO: Implement pause session
              },
              icon: const Icon(Icons.pause),
              label: const Text('Pausar'),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: FilledButton.icon(
              onPressed: () {
                // TODO: Implement complete session
              },
              icon: const Icon(Icons.check),
              label: const Text('Finalizar'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoActiveSession() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.play_circle_outline,
            size: 64,
            color: colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text('No hay sesión activa', style: theme.textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(
            'Inicia una nueva sesión de entrenamiento',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () {
              // TODO: Start new session
            },
            icon: const Icon(Icons.play_arrow),
            label: const Text('Iniciar Sesión'),
          ),
        ],
      ),
    );
  }
}
