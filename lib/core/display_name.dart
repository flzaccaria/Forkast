import '../data/database.dart';
import 'seed_name_resolver.dart';

/// Resolves the display name for an [Ingredient], applying seed translations
/// when the name hasn't been user-modified.
String ingredientDisplayName(Ingredient ing, String locale) {
  return SeedNameResolver.instance.resolve(
    storedName: ing.name,
    seedKey: ing.seedKey,
    nameModified: ing.nameModified,
    locale: locale,
  );
}

/// Resolves the display name for a [Dish], applying seed translations
/// when the name hasn't been user-modified.
String dishDisplayName(Dish dish, String locale) {
  return SeedNameResolver.instance.resolve(
    storedName: dish.name,
    seedKey: dish.seedKey,
    nameModified: dish.nameModified,
    locale: locale,
  );
}
