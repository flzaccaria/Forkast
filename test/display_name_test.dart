import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:forkast/core/display_name.dart';
import 'package:forkast/core/seed_name_resolver.dart';
import 'package:forkast/data/database.dart';

void main() {
  final now = DateTime.now();

  setUp(() {
    SeedNameResolver.testInstance(jsonDecode(bundleJson));
  });

  Ingredient makeIng({
    required String name,
    String? seedKey,
    bool nameModified = false,
  }) {
    return Ingredient(
      id: 'i1',
      householdId: 'h1',
      name: name,
      unit: 'g',
      isQb: false,
      seedKey: seedKey,
      nameModified: nameModified,
      alwaysInList: false,
      defaultQty: null,
      createdAt: now,
      updatedAt: now,
    );
  }

  Dish makeDish({
    required String name,
    String? seedKey,
    bool nameModified = false,
  }) {
    return Dish(
      id: 'd1',
      householdId: 'h1',
      name: name,
      seedKey: seedKey,
      nameModified: nameModified,
      createdAt: now,
      updatedAt: now,
    );
  }

  group('ingredientDisplayName', () {
    test('seed item shows IT/EN/DA names', () {
      final ing = makeIng(name: 'Pomodori freschi', seedKey: 'pomodori-freschi');
      expect(ingredientDisplayName(ing, 'it'), 'Pomodori freschi');
      expect(ingredientDisplayName(ing, 'en'), 'Fresh tomatoes');
      expect(ingredientDisplayName(ing, 'da'), 'Friske tomater');
    });

    test('seed item with missing locale falls back to stored name', () {
      final ing = makeIng(name: 'Pomodori freschi', seedKey: 'pomodori-freschi');
      expect(ingredientDisplayName(ing, 'fr'), 'Pomodori freschi');
    });

    test('nameModified true returns stored name in all locales', () {
      final ing = makeIng(
        name: 'Tomaten (meine)',
        seedKey: 'pomodori-freschi',
        nameModified: true,
      );
      expect(ingredientDisplayName(ing, 'it'), 'Tomaten (meine)');
      expect(ingredientDisplayName(ing, 'en'), 'Tomaten (meine)');
      expect(ingredientDisplayName(ing, 'da'), 'Tomaten (meine)');
    });

    test('user-created item (seedKey null) returns stored name', () {
      final ing = makeIng(name: 'Il mio ingrediente');
      expect(ingredientDisplayName(ing, 'it'), 'Il mio ingrediente');
      expect(ingredientDisplayName(ing, 'en'), 'Il mio ingrediente');
      expect(ingredientDisplayName(ing, 'da'), 'Il mio ingrediente');
    });
  });

  group('dishDisplayName', () {
    test('seed dish shows IT/EN/DA names', () {
      final dish = makeDish(name: 'Latte', seedKey: 'latte');
      expect(dishDisplayName(dish, 'it'), 'Latte');
      expect(dishDisplayName(dish, 'en'), 'Milk');
      expect(dishDisplayName(dish, 'da'), 'Mælk');
    });

    test('nameModified true returns stored name', () {
      final dish = makeDish(
        name: 'My milk',
        seedKey: 'latte',
        nameModified: true,
      );
      expect(dishDisplayName(dish, 'en'), 'My milk');
    });

    test('user-created dish (seedKey null) returns stored name', () {
      final dish = makeDish(name: 'Pasta al forno');
      expect(dishDisplayName(dish, 'en'), 'Pasta al forno');
    });
  });

  group('localizedSeedName', () {
    test('generic helper translates seed entries', () {
      expect(
        localizedSeedName(
          storedName: 'Latte',
          seedKey: 'latte',
          locale: 'en',
        ),
        'Milk',
      );
    });

    test('generic helper falls back when no translation', () {
      expect(
        localizedSeedName(
          storedName: 'Unknown',
          seedKey: 'nonexistent',
          locale: 'en',
        ),
        'Unknown',
      );
    });
  });
}

const bundleJson = '''
{
  "pomodori-freschi": { "it": "Pomodori freschi", "en": "Fresh tomatoes", "da": "Friske tomater" },
  "latte": { "it": "Latte", "en": "Milk", "da": "Mælk" }
}
''';
