import 'package:flutter/foundation.dart';

import 'scaling.dart';

/// Shopping list generation from the plan: rescaling (FR-11) and
/// aggregation (FR-12). Pure, deterministic module, isolated and tested
/// (§5 ADR): no DB or state access.

/// A raw input line: an ingredient of a dish assigned to an evening,
/// with the guests for that evening.
class ListLineInput {
  ListLineInput({
    required this.ingredientId,
    required this.unit,
    required this.roundingKind,
    required this.isQb,
    required this.qtyBase4,
    required this.guests,
  });

  final String ingredientId;
  final String unit;
  final String roundingKind;
  final bool isQb;

  /// Quantity for 4 people; ignored (and typically null) for "q.b." items.
  final double? qtyBase4;
  final int guests;
}

/// An aggregated row of the generated list.
class GeneratedListRow {
  GeneratedListRow({
    required this.ingredientId,
    required this.unit,
    required this.isQb,
    required this.qty,
  });

  final String ingredientId;
  final String unit;
  final bool isQb;

  /// Final aggregated and rounded quantity; null for "q.b." items.
  final double? qty;
}

/// Aggregates rows by catalog item (FR-12). For each non-"q.b."
/// ingredient it sums the rescaled quantities (FR-11) and applies the
/// rounding rule once on the total. "q.b." items appear
/// once, without a quantity, regardless of dishes and guests.
List<GeneratedListRow> aggregateList(List<ListLineInput> lines) {
  final sums = <String, double>{};
  final units = <String, String>{};
  final roundingKinds = <String, String>{};
  final qbIds = <String>{};

  for (final l in lines) {
    final prev = units[l.ingredientId];
    if (prev != null && prev != l.unit) {
      assert(false,
          'Unit mismatch for ingredient ${l.ingredientId}: "$prev" vs "${l.unit}"');
      debugPrint('aggregateList: unit mismatch for ${l.ingredientId} '
          '("$prev" vs "${l.unit}") — using "$prev"');
      // Keep the first unit seen; the sum will be incoherent but visible.
    } else {
      units[l.ingredientId] = l.unit;
    }
    roundingKinds[l.ingredientId] = l.roundingKind;
    if (l.isQb) {
      qbIds.add(l.ingredientId);
    } else {
      sums[l.ingredientId] = (sums[l.ingredientId] ?? 0) +
          scaleQty(qtyBase4: l.qtyBase4 ?? 0, guests: l.guests);
    }
  }

  final rows = <GeneratedListRow>[];
  final ids = <String>{...qbIds, ...sums.keys};
  for (final id in ids) {
    final unit = units[id]!;
    if (qbIds.contains(id)) {
      rows.add(GeneratedListRow(
          ingredientId: id, unit: unit, isQb: true, qty: null));
    } else {
      rows.add(GeneratedListRow(
        ingredientId: id,
        unit: unit,
        isQb: false,
        qty: roundForUnit(sums[id]!, roundingKinds[id]!, unit),
      ));
    }
  }
  return rows;
}

/// Deterministic fingerprint of the source plan (CLAUDE.md, FR-21). Reflects
/// everything that affects the generated list — evenings, guests and dish
/// content — so that the list is considered "divergent" when, and only when,
/// the result would change. Independent of row order.
String planHash(List<ListLineInput> lines) {
  final canon = lines
      .map((l) =>
          '${l.ingredientId}|${l.isQb}|${l.qtyBase4}|${l.unit}|${l.roundingKind}|${l.guests}')
      .toList()
    ..sort();
  return _fnv1a64(canon.join(';'));
}

/// FNV-1a 64-bit over a string: deterministic on every platform (unlike
/// String.hashCode), suitable for cross-device comparison.
String _fnv1a64(String s) {
  // 64-bit arithmetic via BigInt to avoid differences between VM and web.
  final mask = (BigInt.one << 64) - BigInt.one;
  var hash = BigInt.parse('14695981039346656037');
  final prime = BigInt.parse('1099511628211');
  for (final unit in s.codeUnits) {
    hash = (hash ^ BigInt.from(unit)) & mask;
    hash = (hash * prime) & mask;
  }
  return hash.toRadixString(16).padLeft(16, '0');
}
