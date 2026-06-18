import 'package:drift/drift.dart';
import 'package:drift_sqlite_async/drift_sqlite_async.dart';
import 'package:powersync/powersync.dart';

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
  /// drift opera sopra il database gestito da PowerSync: stesso file SQLite,
  /// così le scritture locali finiscono nella coda di upload di PowerSync.
  AppDatabase(PowerSyncDatabase db) : super(SqliteAsyncDriftConnection(db));

  @override
  int get schemaVersion => 1;

  /// È PowerSync a creare e gestire lo schema (viste + trigger). drift non
  /// deve creare né migrare tabelle: le strategie restano vuote.
  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {},
        onUpgrade: (m, from, to) async {},
      );
}
