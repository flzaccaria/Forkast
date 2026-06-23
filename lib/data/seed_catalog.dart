import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';

import '../core/unit.dart';
import 'database.dart';

const _uuid = Uuid();

/// Seeds the ingredient catalog from [assets/seed_ingredienti.csv] once per
/// household (P6). The guard is [Household.seededAt]: once set, the seed is
/// never re-run — not on restart, not on a paired device.
///
/// Call after [ensureHousehold] and after PowerSync has started connecting
/// (so the household row may arrive from sync). If the household row is not
/// yet local (first launch), the ingredient-count check is the fallback
/// guard against duplicates.
///
/// Pass [csvOverride] in tests to avoid [rootBundle] (unavailable in unit tests).
Future<void> seedCatalogIfNeeded(
  AppDatabase db,
  String householdId, {
  String? csvOverride,
}) async {
  // Fast path: if ingredients already exist (previous seed or sync), skip.
  final count = await _ingredientCount(db, householdId);
  if (count > 0) return;

  // Check seeded_at flag (protects paired devices whose household row arrives
  // before the ingredient rows).
  final household = await (db.select(db.households)
        ..where((h) => h.id.equals(householdId)))
      .getSingleOrNull();
  if (household?.seededAt != null) return;

  // Parse the CSV.
  final csv =
      csvOverride ?? await rootBundle.loadString('assets/seed_ingredienti.csv');
  final rows = parseSeedCsv(csv);
  if (rows.isEmpty) return;

  final now = DateTime.now().toUtc();

  await db.transaction(() async {
    // Double-check inside the transaction (idempotency).
    final recheck = await _ingredientCount(db, householdId);
    if (recheck > 0) return;

    for (final row in rows) {
      final unit = Unit.tryParse(row.unit);
      if (unit == null) {
        debugPrint('seedCatalog: unknown unit "${row.unit}" for "${row.name}"');
        continue;
      }
      await db.into(db.ingredients).insert(
            IngredientsCompanion.insert(
              id: _uuid.v4(),
              householdId: householdId,
              name: row.name,
              unit: row.isQb ? 'q.b.' : unit.dbValue,
              isQb: Value(row.isQb),
              category: Value(row.category),
              roundingKind: Value(row.isQb ? null : unit.roundingKind),
              createdAt: now,
              updatedAt: now,
            ),
          );
    }

    // Mark household as seeded (if the row exists locally).
    await (db.update(db.households)
          ..where((h) => h.id.equals(householdId)))
        .write(HouseholdsCompanion(
      seededAt: Value(now),
      updatedAt: Value(now),
    ));
  });
}

Future<int> _ingredientCount(AppDatabase db, String householdId) async {
  final cnt = db.ingredients.id.count();
  final query = db.selectOnly(db.ingredients)
    ..addColumns([cnt])
    ..where(db.ingredients.householdId.equals(householdId));
  final row = await query.getSingle();
  return row.read(cnt) ?? 0;
}

class SeedRow {
  SeedRow({
    required this.name,
    required this.category,
    required this.unit,
    required this.isQb,
  });

  final String name;
  final String? category;
  final String unit;
  final bool isQb;
}

List<SeedRow> parseSeedCsv(String csv) {
  final lines = csv.split('\n').where((l) => l.trim().isNotEmpty).toList();
  if (lines.isEmpty) return const [];
  // Skip header.
  final rows = <SeedRow>[];
  for (var i = 1; i < lines.length; i++) {
    final parts = lines[i].split(',');
    if (parts.length < 4) continue;
    rows.add(SeedRow(
      name: parts[0].trim(),
      category: parts[1].trim().isEmpty ? null : parts[1].trim(),
      unit: parts[2].trim(),
      isQb: parts[3].trim().toLowerCase() == 'true',
    ));
  }
  return rows;
}
