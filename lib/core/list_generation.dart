import 'scaling.dart';

/// Generazione della lista della spesa dal piano: riscalo (FR-11) e
/// aggregazione (FR-12). Modulo puro e deterministico, isolato e testato
/// (§5 ADR): nessun accesso a DB o stato.

/// Una riga grezza in ingresso: un ingrediente di un piatto assegnato a una
/// serata, con i commensali di quella serata.
class ListLineInput {
  ListLineInput({
    required this.ingredientId,
    required this.unit,
    required this.isQb,
    required this.qtyBase4,
    required this.guests,
  });

  final String ingredientId;
  final String unit;
  final bool isQb;

  /// Quantità per 4 persone; ignorata (e tipicamente null) per i "quanto basta".
  final double? qtyBase4;
  final int guests;
}

/// Una riga aggregata della lista generata.
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

  /// Quantità finale aggregata e arrotondata; null per i "quanto basta".
  final double? qty;
}

/// Aggrega le righe per voce di catalogo (FR-12). Per ogni ingrediente
/// non-"quanto basta" somma le quantità riscalate (FR-11) e applica una sola
/// volta la regola di arrotondamento sul totale. I "quanto basta" compaiono
/// una sola volta, senza quantità, indipendentemente da piatti e commensali.
List<GeneratedListRow> aggregateList(List<ListLineInput> lines) {
  final sums = <String, double>{};
  final units = <String, String>{};
  final qbIds = <String>{};

  for (final l in lines) {
    units[l.ingredientId] = l.unit;
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
        qty: roundForUnit(sums[id]!, unit),
      ));
    }
  }
  return rows;
}

/// Impronta deterministica del piano d'origine (CLAUDE.md, FR-21). Riflette
/// tutto ciò che influenza la lista generata — serate, commensali e contenuto
/// dei piatti — così che la lista risulti "divergente" quando, e solo quando,
/// il risultato cambierebbe. Indipendente dall'ordine delle righe.
String planHash(List<ListLineInput> lines) {
  final canon = lines
      .map((l) =>
          '${l.ingredientId}|${l.isQb}|${l.qtyBase4}|${l.unit}|${l.guests}')
      .toList()
    ..sort();
  return _fnv1a64(canon.join(';'));
}

/// FNV-1a 64-bit su una stringa: deterministico su ogni piattaforma (a
/// differenza di String.hashCode), adatto al confronto tra dispositivi.
String _fnv1a64(String s) {
  // Aritmetica a 64 bit via BigInt per evitare differenze tra VM e web.
  final mask = (BigInt.one << 64) - BigInt.one;
  var hash = BigInt.parse('14695981039346656037');
  final prime = BigInt.parse('1099511628211');
  for (final unit in s.codeUnits) {
    hash = (hash ^ BigInt.from(unit)) & mask;
    hash = (hash * prime) & mask;
  }
  return hash.toRadixString(16).padLeft(16, '0');
}
