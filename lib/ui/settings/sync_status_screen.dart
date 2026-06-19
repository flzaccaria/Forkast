import 'package:flutter/material.dart';
import 'package:powersync/powersync.dart';

import '../app_scope.dart';

/// Sync status between devices (screen map / ADR-001).
/// Local-first: the UI never depends on the network, this is informational only.
class SyncStatusScreen extends StatelessWidget {
  const SyncStatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final powerSync = AppScope.of(context).database.powerSync;
    return Scaffold(
      appBar: AppBar(title: const Text('Sincronizzazione')),
      body: powerSync == null
          ? const Center(child: Text('Sincronizzazione non disponibile.'))
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
    final scheme = Theme.of(c).colorScheme;
    if (status.connected) {
      return (icon: Icons.cloud_done, label: 'Connesso', color: Colors.green);
    }
    if (status.connecting) {
      return (
        icon: Icons.cloud_sync,
        label: 'Connessione in corso…',
        color: scheme.secondary
      );
    }
    return (
      icon: Icons.cloud_off,
      label: 'Offline',
      color: scheme.outline,
    );
  }

  String _lastSynced() {
    final at = status.lastSyncedAt;
    if (at == null) return 'Mai';
    final local = at.toLocal();
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(local.day)}/${two(local.month)} '
        '${two(local.hour)}:${two(local.minute)}';
  }

  @override
  Widget build(BuildContext context) {
    final conn = _connection(context);
    final error = status.downloadError ?? status.uploadError;
    return ListView(
      children: [
        ListTile(
          leading: Icon(conn.icon, color: conn.color),
          title: Text(conn.label),
          subtitle: Text(status.hasSynced == true
              ? 'Dati sincronizzati almeno una volta'
              : 'In attesa della prima sincronizzazione'),
        ),
        const Divider(height: 1),
        ListTile(
          leading: const Icon(Icons.schedule),
          title: const Text('Ultima sincronizzazione'),
          trailing: Text(_lastSynced()),
        ),
        ListTile(
          leading: const Icon(Icons.download),
          title: const Text('Download'),
          trailing: Text(status.downloading ? 'In corso…' : 'Inattivo'),
        ),
        ListTile(
          leading: const Icon(Icons.upload),
          title: const Text('Upload'),
          trailing: Text(status.uploading ? 'In corso…' : 'Inattivo'),
        ),
        if (error != null) ...[
          const Divider(height: 1),
          ListTile(
            leading: Icon(Icons.error_outline,
                color: Theme.of(context).colorScheme.error),
            title: const Text('Ultimo errore'),
            subtitle: Text(error.toString()),
          ),
        ],
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'L\'app funziona anche offline: le modifiche restano sul '
            'dispositivo e si sincronizzano appena torna la rete.',
            style: TextStyle(fontStyle: FontStyle.italic),
          ),
        ),
      ],
    );
  }
}
