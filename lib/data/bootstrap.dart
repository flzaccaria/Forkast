import 'package:drift/drift.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import 'database.dart';

const _uuid = Uuid();

/// Assicura una sessione anonima Supabase. Al primo avvio richiede rete;
/// dopo, la sessione è persistita e l'avvio funziona anche offline.
Future<String> ensureAnonAuth() async {
  final auth = Supabase.instance.client.auth;
  if (auth.currentSession == null) {
    await auth.signInAnonymously();
  }
  return auth.currentUser!.id;
}

/// Crea household + membership al primo avvio se non esistono già per questo
/// dispositivo. Scrittura local-first: drift inserisce in locale e PowerSync
/// accoda l'upload. UUID generati dal client (ADR-003).
Future<String> ensureHousehold(AppDatabase db, String deviceId) async {
  final existing = await (db.select(db.memberships)
        ..where((m) => m.deviceId.equals(deviceId)))
      .getSingleOrNull();
  if (existing != null) return existing.householdId;

  final now = DateTime.now().toUtc();
  final householdId = _uuid.v4();

  await db.batch((b) {
    b.insert(
      db.households,
      HouseholdsCompanion.insert(
        id: householdId,
        defaultGuests: const Value(4),
        weekStartDay: const Value(1), // 1 = lunedì (DateTime.weekday)
        autoRegen: const Value(false),
        createdAt: now,
        updatedAt: now,
      ),
    );
    b.insert(
      db.memberships,
      MembershipsCompanion.insert(
        id: _uuid.v4(),
        householdId: householdId,
        deviceId: deviceId,
        role: const Value('member'),
        joinedAt: now,
        updatedAt: now,
      ),
    );
  });

  return householdId;
}
