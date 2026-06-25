import '../data/database.dart';
import 'seed_name_resolver.dart';

/// Generic seed-name resolver for any DTO carrying [storedName], [seedKey]
/// and [nameModified]. Use this when you don't have a full [Ingredient] or
/// [Dish] object (e.g. plan DTOs).
String localizedSeedName({
  required String storedName,
  String? seedKey,
  bool nameModified = false,
  required String locale,
}) {
  return SeedNameResolver.instance.resolve(
    storedName: storedName,
    seedKey: seedKey,
    nameModified: nameModified,
    locale: locale,
  );
}

/// Resolves the display name for an [Ingredient], applying seed translations
/// when the name hasn't been user-modified.
String ingredientDisplayName(Ingredient ing, String locale) {
  return localizedSeedName(
    storedName: ing.name,
    seedKey: ing.seedKey,
    nameModified: ing.nameModified ?? false,
    locale: locale,
  );
}

/// Resolves the display name for a [Dish], applying seed translations
/// when the name hasn't been user-modified.
String dishDisplayName(Dish dish, String locale) {
  return localizedSeedName(
    storedName: dish.name,
    seedKey: dish.seedKey,
    nameModified: dish.nameModified ?? false,
    locale: locale,
  );
}
