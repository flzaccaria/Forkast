import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:forkast/core/seed_name_resolver.dart';

void main() {
  late SeedNameResolver resolver;

  setUp(() {
    resolver = SeedNameResolver.testInstance(jsonDecode(_bundleJson));
  });

  group('seed item translation', () {
    test('shows Italian name when locale is it', () {
      expect(
        resolver.resolve(
          storedName: 'Pomodori freschi',
          seedKey: 'pomodori-freschi',
          nameModified: false,
          locale: 'it',
        ),
        'Pomodori freschi',
      );
    });

    test('shows English name when locale is en', () {
      expect(
        resolver.resolve(
          storedName: 'Pomodori freschi',
          seedKey: 'pomodori-freschi',
          nameModified: false,
          locale: 'en',
        ),
        'Fresh tomatoes',
      );
    });

    test('shows Danish name when locale is da', () {
      expect(
        resolver.resolve(
          storedName: 'Pomodori freschi',
          seedKey: 'pomodori-freschi',
          nameModified: false,
          locale: 'da',
        ),
        'Friske tomater',
      );
    });

    test('handles locale with country code (en_US → en)', () {
      expect(
        resolver.resolve(
          storedName: 'Latte',
          seedKey: 'latte',
          nameModified: false,
          locale: 'en_US',
        ),
        'Milk',
      );
    });
  });

  group('user-modified seed item', () {
    test('returns stored name when nameModified is true', () {
      expect(
        resolver.resolve(
          storedName: 'My custom tomatoes',
          seedKey: 'pomodori-freschi',
          nameModified: true,
          locale: 'en',
        ),
        'My custom tomatoes',
      );
    });

    test('returns stored name when nameModified is true regardless of locale', () {
      for (final locale in ['it', 'en', 'da']) {
        expect(
          resolver.resolve(
            storedName: 'Nome utente',
            seedKey: 'latte',
            nameModified: true,
            locale: locale,
          ),
          'Nome utente',
        );
      }
    });
  });

  group('user-created item (no seed key)', () {
    test('returns stored name regardless of locale', () {
      for (final locale in ['it', 'en', 'da']) {
        expect(
          resolver.resolve(
            storedName: 'Il mio ingrediente',
            seedKey: null,
            nameModified: false,
            locale: locale,
          ),
          'Il mio ingrediente',
        );
      }
    });
  });

  group('missing translation', () {
    test('falls back to Italian when locale translation missing', () {
      expect(
        resolver.resolve(
          storedName: 'Pomodori freschi',
          seedKey: 'pomodori-freschi',
          nameModified: false,
          locale: 'fr',
        ),
        'Pomodori freschi',
      );
    });

    test('falls back to stored name when seed key not in bundle', () {
      expect(
        resolver.resolve(
          storedName: 'Unknown item',
          seedKey: 'nonexistent-key',
          nameModified: false,
          locale: 'en',
        ),
        'Unknown item',
      );
    });
  });
}

const _bundleJson = '''
{
  "pomodori-freschi": { "it": "Pomodori freschi", "en": "Fresh tomatoes", "da": "Friske tomater" },
  "latte": { "it": "Latte", "en": "Milk", "da": "Mælk" }
}
''';
