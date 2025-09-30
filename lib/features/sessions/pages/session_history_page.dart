import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../notifiers/session_notifier.dart';
import '../../sessions/models/workout_session.dart';
import '../../home/notifiers/routine_notifier.dart';
import '../../home/models/routine.dart';
import 'package:go_router/go_router.dart';

class SessionHistoryPage extends ConsumerStatefulWidget {
  const SessionHistoryPage({super.key});

  @override
  ConsumerState<SessionHistoryPage> createState() => _SessionHistoryPageState();
}

class _SessionHistoryPageState extends ConsumerState<SessionHistoryPage> {
  DateTimeRange? _range;
  String? _routineFilterId; // null = todas

  @override
  Widget build(BuildContext context) {
    final sessionsAsync = ref.watch(sessionNotifierProvider);
    final routinesAsync = ref.watch(routineNotifierProvider);

    return sessionsAsync.when(
      data: (sessions) {
        final sorted = [...sessions]
          ..sort((a, b) => (b.startTime).compareTo(a.startTime));

        // Aplicar filtros
        final filtered =
            sorted.where((s) {
              final inRoutine =
                  _routineFilterId == null || s.routineId == _routineFilterId;
              final inRange =
                  _range == null ||
                  (s.startTime.isAfter(_range!.start) &&
                      s.startTime.isBefore(_range!.end));
              return inRoutine && inRange;
            }).toList();

        return Scaffold(
          appBar: AppBar(title: const Text('Historial de sesiones')),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Expanded(child: _buildRoutineFilter(routinesAsync)),
                    const SizedBox(width: 8),
                    Flexible(child: _buildDateFilterButton()),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child:
                    filtered.isEmpty
                        ? const Center(
                          child: Text(
                            'No hay sesiones para los filtros seleccionados',
                          ),
                        )
                        : ListView.separated(
                          itemCount: filtered.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final s = filtered[index];
                            final isActive =
                                s.status == SessionStatus.active ||
                                s.status == SessionStatus.paused;
                            final subtitle =
                                isActive
                                    ? 'En curso'
                                    : s.endTime != null
                                    ? _formatDuration(
                                      s.endTime!.difference(s.startTime),
                                    )
                                    : 'Sin finalizar';
                            return ListTile(
                              leading: Icon(
                                isActive
                                    ? Icons.play_circle
                                    : Icons.check_circle,
                                color:
                                    isActive
                                        ? Theme.of(context).colorScheme.primary
                                        : Theme.of(
                                          context,
                                        ).colorScheme.secondary,
                              ),
                              title: Text(
                                s.name.isNotEmpty ? s.name : 'Sesión',
                              ),
                              subtitle: Text(
                                '${s.startTime.toLocal()} · $subtitle',
                              ),
                              trailing: const Icon(Icons.chevron_right),
                              onTap:
                                  () => context.push(
                                    '/session-summary?sessionId=${s.id}',
                                  ),
                            );
                          },
                        ),
              ),
            ],
          ),
        );
      },
      loading:
          () =>
              const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('Error: $e'))),
    );
  }

  Widget _buildRoutineFilter(AsyncValue<List<Routine>> routinesAsync) {
    return routinesAsync.when(
      data: (routines) {
        final items = [
          const DropdownMenuItem<String?>(
            value: null,
            child: Text('Todas las rutinas', overflow: TextOverflow.ellipsis),
          ),
          ...routines.map(
            (r) => DropdownMenuItem<String?>(
              value: r.id,
              child: Text(r.name, overflow: TextOverflow.ellipsis),
            ),
          ),
        ];
        return DropdownButtonFormField<String?>(
          value: _routineFilterId,
          items: items,
          onChanged: (value) => setState(() => _routineFilterId = value),
          isDense: true,
          decoration: const InputDecoration(
            labelText: 'Rutina',
            border: OutlineInputBorder(),
            isDense: true,
            contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          ),
          menuMaxHeight: 320,
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (e, _) => const SizedBox.shrink(),
    );
  }

  Widget _buildDateFilterButton() {
    final label =
        _range == null
            ? 'Rango de fechas'
            : '${_range!.start.toLocal().toString().split(' ').first} → ${_range!.end.toLocal().toString().split(' ').first}';
    return OutlinedButton.icon(
      onPressed: () async {
        final now = DateTime.now();
        final firstDate = DateTime(now.year - 3);
        final lastDate = DateTime(now.year + 1);
        final picked = await showDateRangePicker(
          context: context,
          firstDate: firstDate,
          lastDate: lastDate,
          initialDateRange:
              _range ??
              DateTimeRange(
                start: now.subtract(const Duration(days: 30)),
                end: now,
              ),
        );
        if (picked != null) {
          setState(() => _range = picked);
        }
      },
      icon: const Icon(Icons.filter_alt),
      label: Text(label, overflow: TextOverflow.ellipsis),
    );
  }

  String _formatDuration(Duration d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.inHours)}:${two(d.inMinutes % 60)}:${two(d.inSeconds % 60)}';
  }
}
