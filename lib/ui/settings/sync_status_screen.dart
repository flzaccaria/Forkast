import 'package:flutter/material.dart';
import 'package:powersync/powersync.dart';

import '../../l10n/generated/app_localizations.dart';
import '../app_scope.dart';

class SyncStatusScreen extends StatelessWidget {
  const SyncStatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final powerSync = AppScope.of(context).database.powerSync;
    return Scaffold(
      appBar: AppBar(title: Text(l.syncTitle)),
      body: powerSync == null
          ? Center(child: Text(l.syncUnavailable))
          : StreamBuilder<SyncStatus>(
              stream: powerSync.statusStream,
              initialData: powerSync.currentStatus,
              builder: (context, snapshot) {
                final status = snapshot.data;
                if (status == null) {
                  return const Center(child: CircularProgressIndicator());
                }
                return _StatusView(status: status);
              },
            ),
    );
  }
}

class _StatusView extends StatelessWidget {
  const _StatusView({required this.status});

  final SyncStatus status;

  ({IconData icon, String label, Color color}) _connection(BuildContext c) {
    final l = AppLocalizations.of(c);
    final scheme = Theme.of(c).colorScheme;
    if (status.connected) {
      return (icon: Icons.cloud_done, label: l.syncConnected, color: Colors.green);
    }
    if (status.connecting) {
      return (
        icon: Icons.cloud_sync,
        label: l.syncConnecting,
        color: scheme.secondary
      );
    }
    return (
      icon: Icons.cloud_off,
      label: l.syncOffline,
      color: scheme.outline,
    );
  }

  String _lastSynced(AppLocalizations l) {
    final at = status.lastSyncedAt;
    if (at == null) return l.syncNever;
    final local = at.toLocal();
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(local.day)}/${two(local.month)} '
        '${two(local.hour)}:${two(local.minute)}';
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final conn = _connection(context);
    final error = status.downloadError ?? status.uploadError;
    return ListView(
      children: [
        ListTile(
          leading: Icon(conn.icon, color: conn.color),
          title: Text(conn.label),
          subtitle: Text(status.hasSynced == true
              ? l.syncSyncedOnce
              : l.syncWaitingFirst),
        ),
        const Divider(height: 1),
        ListTile(
          leading: const Icon(Icons.schedule),
          title: Text(l.syncLastSync),
          trailing: Text(_lastSynced(l)),
        ),
        ListTile(
          leading: const Icon(Icons.download),
          title: Text(l.syncDownload),
          trailing: Text(status.downloading ? l.syncInProgress : l.syncIdle),
        ),
        ListTile(
          leading: const Icon(Icons.upload),
          title: Text(l.syncUpload),
          trailing: Text(status.uploading ? l.syncInProgress : l.syncIdle),
        ),
        if (error != null) ...[
          const Divider(height: 1),
          ListTile(
            leading: Icon(Icons.error_outline,
                color: Theme.of(context).colorScheme.error),
            title: Text(l.syncLastError),
            subtitle: Text(error.toString()),
          ),
        ],
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            l.syncOfflineNote,
            style: const TextStyle(fontStyle: FontStyle.italic),
          ),
        ),
      ],
    );
  }
}
