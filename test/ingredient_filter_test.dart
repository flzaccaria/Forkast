import 'package:flutter_test/flutter_test.dart';
import 'package:forkast/core/diacritics.dart';
import 'package:forkast/data/database.dart';

/// Minimal simulation of the ingredients screen filtering logic.
/// Uses the same algorithm as _IngredientsScreenState._applySearchAndFilters
/// to validate combined filter behavior without needing a full widget test.

class _Item {
  _Item(this.ingredient, this.usageCount);
  final Ingredient ingredient;
  final int usageCount;
}

Ingredient _ing({
  required String name,
  String unit = 'g',
  bool isQb = false,
  String? category,
}) =>
    Ingredient(
      id: name,
      householdId: 'h',
      name: name,
      unit: unit,
      isQb: isQb,
      category: category,
      roundingKind: isQb ? null : 'weight',
      seedKey: null,
      nameModified: false,
      alwaysInList: false,
      defaultQty: null,
      createdAt: DateTime(2024),
      updatedAt: DateTime(2024),
    );

List<_Item> _filter(
  List<_Item> items, {
  String query = '',
  Set<String?>? departments,
  String? unit,
  bool? qbOnly,
  bool? usedOnly,
}) {
  var result = items;

  if (query.isNotEmpty) {
    final nq = removeDiacritics(query).toLowerCase();
    result = result
        .where((i) =>
            removeDiacritics(i.ingredient.name).toLowerCase().contains(nq))
        .toList();
  }

  if (departments != null && departments.isNotEmpty) {
    result =
        result.where((i) => departments.contains(i.ingredient.category)).toList();
  }

  if (unit != null) {
    result = result.where((i) => i.ingredient.unit == unit).toList();
  }

  if (qbOnly == true) {
    result = result.where((i) => i.ingredient.isQb).toList();
  } else if (qbOnly == false) {
    result = result.where((i) => !i.ingredient.isQb).toList();
  }

  if (usedOnly == true) {
    result = result.where((i) => i.usageCount > 0).toList();
  } else if (usedOnly == false) {
    result = result.where((i) => i.usageCount == 0).toList();
  }

  return result;
}

void main() {
  final items = [
    _Item(_ing(name: 'Caffè', unit: 'g', category: 'Dispensa'), 3),
    _Item(_ing(name: 'Pomodori freschi', unit: 'pz', category: 'Ortofrutta'), 5),
    _Item(_ing(name: 'Basilico', unit: 'pz', isQb: true, category: 'Ortofrutta'), 2),
    _Item(_ing(name: 'Sale', unit: 'g', isQb: true, category: 'Dispensa'), 0),
    _Item(_ing(name: 'Parmigiano', unit: 'g', category: 'Salumi e formaggi'), 0),
  ];

  test('accent-insensitive search: "caffe" finds "Caffè"', () {
    final result = _filter(items, query: 'caffe');
    expect(result.length, 1);
    expect(result.first.ingredient.name, 'Caffè');
  });

  test('combined filter: department + unused', () {
    final result = _filter(items,
        departments: {'Dispensa'}, usedOnly: false);
    expect(result.length, 1);
    expect(result.first.ingredient.name, 'Sale');
  });

  test('combined filter: q.b. + department Ortofrutta', () {
    final result = _filter(items,
        departments: {'Ortofrutta'}, qbOnly: true);
    expect(result.length, 1);
    expect(result.first.ingredient.name, 'Basilico');
  });

  test('combined filter: search + unit pz', () {
    final result = _filter(items, query: 'bas', unit: 'pz');
    expect(result.length, 1);
    expect(result.first.ingredient.name, 'Basilico');
  });

  test('combined filter: used only', () {
    final result = _filter(items, usedOnly: true);
    expect(result.length, 3);
    expect(result.map((i) => i.ingredient.name),
        containsAll(['Caffè', 'Pomodori freschi', 'Basilico']));
  });

  test('empty result when no match', () {
    final result = _filter(items, query: 'xyz');
    expect(result, isEmpty);
  });

  test('multi-department filter', () {
    final result =
        _filter(items, departments: {'Ortofrutta', 'Salumi e formaggi'});
    expect(result.length, 3);
  });
}
