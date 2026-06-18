import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'tables/household.dart';
import 'tables/membership.dart';
import 'tables/ingredient.dart';
import 'tables/tag.dart';
import 'tables/dish.dart';
import 'tables/dish_tag.dart';
import 'tables/dish_ingredient.dart';
import 'tables/week_plan.dart';
import 'tables/plan_day.dart';
import 'tables/plan_day_dish.dart';
import 'tables/shopping_list.dart';
import 'tables/list_generated_row.dart';
import 'tables/list_override.dart';
import 'tables/list_manual_item.dart';
import 'tables/list_check.dart';

part 'database.g.dart';

@DriftDatabase(tables: [
  Households,
  Memberships,
  Ingredients,
  Tags,
  Dishes,
  DishTags,
  DishIngredients,
  WeekPlans,
  PlanDays,
  PlanDayDishes,
  ShoppingLists,
  ListGeneratedRows,
  ListOverrides,
  ListManualItems,
  ListChecks,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 1;

  static LazyDatabase _openConnection() {
    return LazyDatabase(() async {
      final dbFolder = await getApplicationDocumentsDirectory();
      final file = File(p.join(dbFolder.path, 'forkast.sqlite'));
      return NativeDatabase.createInBackground(file);
    });
  }
}
