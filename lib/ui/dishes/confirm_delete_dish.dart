import 'package:flutter/material.dart';

import '../../data/repositories/dish_repository.dart';

/// Shared protected-delete flow for dishes (FR-17 pattern).
///
/// Shows the planned-dinner count when > 0, then confirms.
/// Returns `true` if the dish was deleted, `false` / `null` otherwise.
Future<bool> confirmAndDeleteDish(
  BuildContext context, {
  required DishRepository repo,
  required String dishId,
}) async {
  final plannedCount = await repo.plannedDinnerCount(dishId);

  if (!context.mounted) return false;

  final String content;
  if (plannedCount > 0) {
    content = 'Questo piatto è usato in $plannedCount '
        '${plannedCount == 1 ? 'cena pianificata' : 'cene pianificate'}: '
        'eliminandolo verrà rimosso anche da quelle. Eliminare comunque?';
  } else {
    content = 'Il piatto verrà rimosso dal catalogo. Eliminare?';
  }

  final confirm = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Eliminare il piatto?'),
      content: Text(content),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: const Text('Annulla'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(ctx).pop(true),
          child: const Text('Elimina'),
        ),
      ],
    ),
  );
  if (confirm != true) return false;

  await repo.delete(dishId);
  return true;
}
