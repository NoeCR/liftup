import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../notifiers/session_notifier.dart';
import '../../sessions/models/workout_session.dart';
import 'package:go_router/go_router.dart';

class SessionHistoryPage extends ConsumerWidget {
  const SessionHistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionsAsync = ref.watch(sessionNotifierProvider);

    return sessionsAsync.when(
      data: (sessions) {
        if (sessions.isEmpty) {
          return Scaffold(
            appBar: AppBar(title: const Text('Historial de sesiones')),
            body: const Center(child: Text('No hay sesiones')),
          );
        }

        final sorted = [...sessions]
          ..sort((a, b) => (b.startTime).compareTo(a.startTime));

        return Scaffold(
          appBar: AppBar(title: const Text('Historial de sesiones')),
          body: ListView.separated(
            itemCount: sorted.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final s = sorted[index];
              final isActive = s.status == SessionStatus.active || s.status == SessionStatus.paused;
              final subtitle = isActive
                  ? 'En curso'
                  : s.endTime != null
                      ? _formatDuration(s.endTime!.difference(s.startTime))
                      : 'Sin finalizar';
              return ListTile(
                leading: Icon(
                  isActive ? Icons.play_circle : Icons.check_circle,
                  color: isActive ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.secondary,
                ),
                title: Text(s.name.isNotEmpty ? s.name : 'Sesión'),
                subtitle: Text('${s.startTime.toLocal()} · $subtitle'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/session-summary?sessionId=${s.id}'),
              );
            },
          ),
        );
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('Error: $e'))),
    );
  }

  String _formatDuration(Duration d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.inHours)}:${two(d.inMinutes % 60)}:${two(d.inSeconds % 60)}';
  }
}
