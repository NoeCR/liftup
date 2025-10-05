import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../core/data_management/data_management.dart';

class BackupSection extends ConsumerStatefulWidget {
  const BackupSection({super.key});

  @override
  ConsumerState<BackupSection> createState() => _BackupSectionState();
}

class _BackupSectionState extends ConsumerState<BackupSection> {
  bool _autoBackupEnabled = false;
  int _backupIntervalHours = 24;
  int _maxBackups = 10;
  bool _backupOnWifiOnly = true;
  bool _compressBackups = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Configuración de backup automático
        _buildBackupConfig(),

        const SizedBox(height: 16),

        // Botones de backup
        Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                onPressed: () => _createManualBackup(context),
                icon: const Icon(Icons.cloud_upload),
                label: Text(context.tr('dataManagement.manualBackup')),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _viewBackupHistory(context),
                icon: const Icon(Icons.history),
                label: Text(context.tr('dataManagement.history')),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBackupConfig() {
    return Column(
      children: [
        _buildCheckboxOption(
          title: context.tr('dataManagement.automaticBackup'),
          subtitle: context.tr('dataManagement.automaticBackupDescription'),
          value: _autoBackupEnabled,
          onChanged: (value) => setState(() => _autoBackupEnabled = value!),
        ),

        if (_autoBackupEnabled) ...[
          const SizedBox(height: 8),

          // Intervalo de backup
          Row(
            children: [
              Expanded(
                child: Text('Intervalo: $_backupIntervalHours horas', style: Theme.of(context).textTheme.bodyMedium),
              ),
              Slider(
                value: _backupIntervalHours.toDouble(),
                min: 1,
                max: 168, // 1 semana
                divisions: 167,
                onChanged: (value) {
                  setState(() => _backupIntervalHours = value.round());
                },
              ),
            ],
          ),

          // Máximo de backups
          Row(
            children: [
              Expanded(child: Text('Máximo backups: $_maxBackups', style: Theme.of(context).textTheme.bodyMedium)),
              Slider(
                value: _maxBackups.toDouble(),
                min: 5,
                max: 50,
                divisions: 45,
                onChanged: (value) {
                  setState(() => _maxBackups = value.round());
                },
              ),
            ],
          ),

          _buildCheckboxOption(
            title: context.tr('dataManagement.wifiOnly'),
            subtitle: context.tr('dataManagement.wifiOnlyDescription'),
            value: _backupOnWifiOnly,
            onChanged: (value) => setState(() => _backupOnWifiOnly = value!),
          ),

          _buildCheckboxOption(
            title: context.tr('dataManagement.compressBackups'),
            subtitle: context.tr('dataManagement.compressBackupsDescription'),
            value: _compressBackups,
            onChanged: (value) => setState(() => _compressBackups = value!),
          ),
        ],
      ],
    );
  }

  Widget _buildCheckboxOption({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool?> onChanged,
  }) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Checkbox(value: value, onChanged: onChanged),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
                Text(subtitle, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _createManualBackup(BuildContext context) async {
    try {
      // Mostrar indicador de progreso
      showDialog(
        context: context,
        barrierDismissible: false,
        builder:
            (context) => AlertDialog(
              content: Row(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(width: 16),
                  Text(context.tr('dataManagement.creatingBackup')),
                ],
              ),
            ),
      );

      // TODO: Implementar backup manual
      // final backupConfig = BackupConfig(
      //   enabled: true,
      //   intervalHours: _backupIntervalHours,
      //   maxBackups: _maxBackups,
      //   backupOnWifiOnly: _backupOnWifiOnly,
      //   compressBackups: _compressBackups,
      //   includeDataTypes: const ['sessions', 'routines', 'exercises'],
      // );

      // Simular tiempo de backup
      await Future.delayed(const Duration(seconds: 2));

      // Cerrar indicador de progreso y mostrar resultado
      if (!context.mounted) return;
      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.tr('dataManagement.backupCreatedSuccessfully')), backgroundColor: Colors.green),
      );
    } catch (e) {
      // Cerrar indicador de progreso si está abierto y mostrar error
      if (!context.mounted) return;
      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.tr('dataManagement.backupCreationError', namedArgs: {'error': e.toString()})),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _viewBackupHistory(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(context.tr('dataManagement.backupHistory')),
            content: SizedBox(
              width: double.maxFinite,
              height: 300,
              child: ListView(
                children: [
                  _buildBackupItem('Backup Manual', 'Hace 2 horas', '2.3 MB', BackupStatus.completed),
                  _buildBackupItem('Backup Automático', 'Hace 1 día', '2.1 MB', BackupStatus.completed),
                  _buildBackupItem('Backup Automático', 'Hace 2 días', '2.0 MB', BackupStatus.completed),
                  _buildBackupItem('Backup Manual', 'Hace 1 semana', '1.8 MB', BackupStatus.completed),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(context.tr('common.close'))),
            ],
          ),
    );
  }

  Widget _buildBackupItem(String name, String date, String size, BackupStatus status) {
    final statusColor =
        status == BackupStatus.completed
            ? Colors.green
            : status == BackupStatus.failed
            ? Colors.red
            : Colors.orange;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: Icon(Icons.cloud_done, color: statusColor),
        title: Text(name),
        subtitle: Text('$date • $size'),
        trailing: IconButton(icon: const Icon(Icons.more_vert), onPressed: () => _showBackupOptions(context, name)),
      ),
    );
  }

  void _showBackupOptions(BuildContext context, String backupName) {
    showModalBottomSheet(
      context: context,
      builder:
          (context) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.download),
                title: Text(context.tr('dataManagement.download')),
                onTap: () {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(context.tr('dataManagement.downloadingBackup'))));
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete),
                title: Text(context.tr('common.delete')),
                onTap: () {
                  Navigator.of(context).pop();
                  _confirmDeleteBackup(context, backupName);
                },
              ),
            ],
          ),
    );
  }

  void _confirmDeleteBackup(BuildContext context, String backupName) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(context.tr('dataManagement.deleteBackup')),
            content: Text(context.tr('dataManagement.confirmDeleteBackup', namedArgs: {'backupName': backupName})),
            actions: [
              TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(context.tr('common.cancel'))),
              FilledButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(context.tr('dataManagement.backupDeleted'))));
                },
                child: Text(context.tr('common.delete')),
              ),
            ],
          ),
    );
  }
}
