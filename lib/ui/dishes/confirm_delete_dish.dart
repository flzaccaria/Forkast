import 'package:flutter/material.dart';

import '../../data/repositories/dish_repository.dart';
import '../../l10n/generated/app_localizations.dart';

Future<bool> confirmAndDeleteDish(
  BuildContext context, {
  required DishRepository repo,
  required String dishId,
}) async {
  final plannedCount = await repo.plannedDinnerCount(dishId);

  if (!context.mounted) return false;

  final l = AppLocalizations.of(context);

  final String content;
  if (plannedCount > 0) {
    content = l.deleteDishWithPlans(plannedCount);
  } else {
    content = l.deleteDishNoPlan;
  }

  final confirm = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(l.deleteDishTitle),
      content: Text(content),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: Text(l.cancel),
        ),
        FilledButton(
          onPressed: () => Navigator.of(ctx).pop(true),
          child: Text(l.delete),
        ),
      ],
    ),
  );
  if (confirm != true) return false;

  await repo.delete(dishId);
  return true;
}
