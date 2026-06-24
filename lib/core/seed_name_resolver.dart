import 'dart:convert';

import 'package:flutter/services.dart';

/// Resolves display names for seeded content at render time.
///
/// The bundle is loaded once from `assets/seed_translations.json` and cached.
/// Format: `{ "seed-key": { "it": "Nome", "en": "Name", "da": "Navn" }, ... }`
///
/// Resolution order:
///   1. If [nameModified] is true → return stored name (user edited it)
///   2. If [seedKey] is non-null → look up translation for current locale
///   3. Fallback → stored name (covers user-created entries and missing translations)
class SeedNameResolver {
  SeedNameResolver._();

  static SeedNameResolver? _instance;
  Map<String, Map<String, String>>? _bundle;

  static SeedNameResolver get instance {
    _instance ??= SeedNameResolver._();
    return _instance!;
  }

  Future<void> load() async {
    if (_bundle != null) return;
    try {
      final json = await rootBundle.loadString('assets/seed_translations.json');
      final raw = jsonDecode(json) as Map<String, dynamic>;
      _bundle = raw.map((key, val) => MapEntry(
            key,
            (val as Map<String, dynamic>)
                .map((k, v) => MapEntry(k, v as String)),
          ));
    } catch (_) {
      _bundle = const {};
    }
  }

  /// Returns the localized display name for a seeded item, or the stored name
  /// if no translation is available.
  String resolve({
    required String storedName,
    required String? seedKey,
    required bool nameModified,
    required String locale,
  }) {
    if (nameModified || seedKey == null) return storedName;
    final translations = _bundle?[seedKey];
    if (translations == null) return storedName;
    final lang = locale.split('_').first;
    return translations[lang] ?? translations['it'] ?? storedName;
  }
}
