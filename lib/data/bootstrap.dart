import 'package:drift/drift.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import 'database.dart';

const _uuid = Uuid();

/// Ensures an anonymous Supabase session. The first launch requires network;
/// afterwards, the session is persisted and startup works offline too.
Future<String> ensureAnonAuth() async {
  final auth = Supabase.instance.client.auth;
  if (auth.currentSession == null) {
    await auth.signInAnonymously();
  }
  return auth.currentUser!.id;
}

/// Creates household + membership on first launch if they don't already exist
/// for this device. Local-first write: drift inserts locally and PowerSync
/// queues the upload. Client-generated UUIDs (ADR-003).
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
        weekStartDay: const Value(1), // 1 = Monday (DateTime.weekday)
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
