import 'package:flutter/material.dart';
import 'package:liftly/features/progression/services/phase_notification_service.dart';

class PhaseNotificationWidget extends StatefulWidget {
  final String? exerciseId;
  final String? routineId;
  final bool showAllChanges;
  final int maxDisplayItems;
  final VoidCallback? onDismiss;

  const PhaseNotificationWidget({
    super.key,
    this.exerciseId,
    this.routineId,
    this.showAllChanges = false,
    this.maxDisplayItems = 5,
    this.onDismiss,
  });

  @override
  State<PhaseNotificationWidget> createState() =>
      _PhaseNotificationWidgetState();
}

class _PhaseNotificationWidgetState extends State<PhaseNotificationWidget> {
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

    final changes = _getRelevantChanges();

    if (changes.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(theme, colorScheme),
            const SizedBox(height: 12),
            ...changes
                .take(widget.maxDisplayItems)
                .map(
                  (change) => _buildPhaseChangeItem(theme, colorScheme, change),
                ),
            if (changes.length > widget.maxDisplayItems) ...[
              const SizedBox(height: 8),
              _buildShowMoreButton(theme, colorScheme, changes.length),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, ColorScheme colorScheme) {
    return Row(
      children: [
        Icon(Icons.auto_awesome, color: colorScheme.primary, size: 20),
        const SizedBox(width: 8),
        Text(
          'Cambios de Fase Recientes',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.primary,
          ),
        ),
        const Spacer(),
        if (widget.onDismiss != null)
          IconButton(
            icon: const Icon(Icons.close, size: 18),
            onPressed: widget.onDismiss,
            tooltip: 'Cerrar notificaciones',
          ),
      ],
    );
  }

  Widget _buildPhaseChangeItem(
    ThemeData theme,
    ColorScheme colorScheme,
    PhaseChangeInfo change,
  ) {
    final phaseColor = _getPhaseColor(change.currentPhase);
    final timeAgo = _getTimeAgo(change.changeDate);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: phaseColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: phaseColor.withOpacity(0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: phaseColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${change.currentPhase} - Semana ${change.weekInPhase}/${change.totalWeeksInPhase}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: phaseColor,
                  ),
                ),
              ),
              Text(
                timeAgo,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            change.phaseDescription,
            style: theme.textTheme.bodySmall,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            change.progressionDetails,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShowMoreButton(
    ThemeData theme,
    ColorScheme colorScheme,
    int totalChanges,
  ) {
    return Center(
      child: TextButton.icon(
        onPressed: () => _showAllChangesDialog(theme, colorScheme),
        icon: const Icon(Icons.expand_more, size: 16),
        label: Text('Ver ${totalChanges - widget.maxDisplayItems} cambios más'),
        style: TextButton.styleFrom(foregroundColor: colorScheme.primary),
      ),
    );
  }

  void _showAllChangesDialog(ThemeData theme, ColorScheme colorScheme) {
    final changes = _getRelevantChanges();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Row(
              children: [
                Icon(Icons.history, color: colorScheme.primary),
                const SizedBox(width: 8),
                const Text('Historial de Cambios de Fase'),
              ],
            ),
            content: SizedBox(
              width: double.maxFinite,
              height: 400,
              child: ListView.builder(
                itemCount: changes.length,
                itemBuilder: (context, index) {
                  final change = changes[index];
                  return _buildPhaseChangeItem(theme, colorScheme, change);
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cerrar'),
              ),
              TextButton(
                onPressed: () {
                  _notificationService.clearPhaseChanges();
                  Navigator.of(context).pop();
                },
                child: const Text('Limpiar Historial'),
              ),
            ],
          ),
    );
  }

  List<PhaseChangeInfo> _getRelevantChanges() {
    if (widget.showAllChanges) {
      return _notificationService.phaseChanges;
    } else if (widget.exerciseId != null && widget.routineId != null) {
      return _notificationService.getPhaseChangesForExercise(
        widget.exerciseId!,
        widget.routineId!,
      );
    } else {
      return _notificationService.getRecentPhaseChanges(days: 7);
    }
  }

  Color _getPhaseColor(String phaseName) {
    switch (phaseName) {
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

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return 'hace ${difference.inDays} día${difference.inDays == 1 ? '' : 's'}';
    } else if (difference.inHours > 0) {
      return 'hace ${difference.inHours} hora${difference.inHours == 1 ? '' : 's'}';
    } else if (difference.inMinutes > 0) {
      return 'hace ${difference.inMinutes} minuto${difference.inMinutes == 1 ? '' : 's'}';
    } else {
      return 'ahora';
    }
  }
}

/// Widget compacto para mostrar solo el último cambio de fase
class CompactPhaseNotificationWidget extends StatelessWidget {
  final String exerciseId;
  final String routineId;
  final VoidCallback? onTap;

  const CompactPhaseNotificationWidget({
    super.key,
    required this.exerciseId,
    required this.routineId,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final notificationService = PhaseNotificationService();

    return StreamBuilder(
      stream: Stream.periodic(const Duration(seconds: 1)),
      builder: (context, snapshot) {
        final changes = notificationService.getPhaseChangesForExercise(
          exerciseId,
          routineId,
        );

        if (changes.isEmpty) {
          return const SizedBox.shrink();
        }

        final latestChange = changes.first;
        final phaseColor = _getPhaseColor(latestChange.currentPhase);

        return GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: phaseColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: phaseColor.withOpacity(0.3), width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: phaseColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  latestChange.currentPhase,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: phaseColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  'S${latestChange.weekInPhase}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Color _getPhaseColor(String phaseName) {
    switch (phaseName) {
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
