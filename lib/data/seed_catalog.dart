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
/// Each seeded ingredient receives a stable `seed_key` (slug) from the CSV.
/// The seed_key enables display-time localization (L2): UI shows the translated
/// name when available, falling back to the stored Italian name.
///
/// Pass [csvOverride] in tests to avoid [rootBundle] (unavailable in unit tests).
Future<void> seedCatalogIfNeeded(
  AppDatabase db,
  String householdId, {
  String? csvOverride,
}) async {
  final count = await _ingredientCount(db, householdId);
  if (count > 0) return;

  final household = await (db.select(db.households)
        ..where((h) => h.id.equals(householdId)))
      .getSingleOrNull();
  if (household?.seededAt != null) return;

  final csv =
      csvOverride ?? await rootBundle.loadString('assets/seed_ingredienti.csv');
  final rows = parseSeedCsv(csv);
  if (rows.isEmpty) return;

  final now = DateTime.now().toUtc();

  await db.transaction(() async {
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
              roundingKind: Value(unit.roundingKind),
              seedKey: Value(row.seedKey),
              createdAt: now,
              updatedAt: now,
            ),
          );
    }

    await (db.update(db.households)
          ..where((h) => h.id.equals(householdId)))
        .write(HouseholdsCompanion(
      seededAt: Value(now),
      updatedAt: Value(now),
    ));
  });
}

/// Backfills [seedKey] for ingredients that were seeded before the L2
/// localization feature added the column. Matches by exact Italian name from
/// the CSV. Idempotent: only touches rows where seed_key IS NULL.
Future<void> backfillSeedKeys(
  AppDatabase db,
  String householdId, {
  String? csvOverride,
}) async {
  final missing = await (db.select(db.ingredients)
        ..where((i) =>
            i.householdId.equals(householdId) &
            i.seedKey.isNull()))
      .get();
  if (missing.isEmpty) return;

  final csv =
      csvOverride ?? await rootBundle.loadString('assets/seed_ingredienti.csv');
  final rows = parseSeedCsv(csv);
  final nameToKey = <String, String>{};
  for (final row in rows) {
    if (row.seedKey != null && row.seedKey!.isNotEmpty) {
      nameToKey[row.name] = row.seedKey!;
    }
  }

  final now = DateTime.now().toUtc();
  for (final ing in missing) {
    final key = nameToKey[ing.name];
    if (key != null) {
      await (db.update(db.ingredients)
            ..where((i) => i.id.equals(ing.id)))
          .write(IngredientsCompanion(
        seedKey: Value(key),
        updatedAt: Value(now),
      ));
    }
  }
}

/// Backfills [roundingKind] for ingredients that were seeded with a NULL value
/// (q.b. items before the fix). Supabase requires rounding_kind NOT NULL.
/// Idempotent: only touches rows where rounding_kind IS NULL.
Future<void> backfillRoundingKind(AppDatabase db, String householdId) async {
  final missing = await (db.select(db.ingredients)
        ..where((i) =>
            i.householdId.equals(householdId) & i.roundingKind.isNull()))
      .get();
  if (missing.isEmpty) return;

  final now = DateTime.now().toUtc();
  for (final ing in missing) {
    final unit = Unit.tryParse(ing.unit);
    final kind = unit?.roundingKind ?? 'weight';
    await (db.update(db.ingredients)..where((i) => i.id.equals(ing.id)))
        .write(IngredientsCompanion(
      roundingKind: Value(kind),
      updatedAt: Value(now),
    ));
  }
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
    this.seedKey,
  });

  final String name;
  final String? category;
  final String unit;
  final bool isQb;
  final String? seedKey;
}

List<SeedRow> parseSeedCsv(String csv) {
  final lines = csv.split('\n').where((l) => l.trim().isNotEmpty).toList();
  if (lines.isEmpty) return const [];
  final rows = <SeedRow>[];
  for (var i = 1; i < lines.length; i++) {
    final parts = lines[i].split(',');
    if (parts.length < 4) continue;
    rows.add(SeedRow(
      name: parts[0].trim(),
      category: parts[1].trim().isEmpty ? null : parts[1].trim(),
      unit: parts[2].trim(),
      isQb: parts[3].trim().toLowerCase() == 'true',
      seedKey: parts.length > 4 ? parts[4].trim() : null,
    ));
  }
  return rows;
}
