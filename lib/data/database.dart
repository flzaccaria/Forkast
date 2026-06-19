import 'package:drift/drift.dart';
import 'package:drift_sqlite_async/drift_sqlite_async.dart';
import 'package:powersync/powersync.dart' show PowerSyncDatabase;

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
  /// drift operates on top of the database managed by PowerSync: same SQLite
  /// file, so local writes end up in PowerSync's upload queue.
  AppDatabase(PowerSyncDatabase db)
      : powerSync = db,
        super(SqliteAsyncDriftConnection(db));

  /// Constructor for tests: operates on any connection (e.g. an in-memory
  /// database). Allows replicating the "PowerSync-style" schema (without
  /// drift's DEFAULTs) and verifying that inserts always set explicit
  /// values. Do not use in production.
  AppDatabase.forTesting(super.connection) : powerSync = null;

  /// Underlying PowerSync instance, to observe its sync state.
  /// Null in tests, where there is no sync.
  final PowerSyncDatabase? powerSync;

  @override
  int get schemaVersion => 1;

  /// PowerSync creates and manages the schema (views + triggers). drift must
  /// not create or migrate tables: the strategies stay empty.
  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {},
        onUpgrade: (m, from, to) async {},
      );
}
