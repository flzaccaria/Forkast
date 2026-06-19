import 'package:powersync/powersync.dart';

/// Schema PowerSync: rispecchia le tabelle drift.
///
/// In PowerSync la colonna `id` (UUID) è implicita su ogni tabella e non va
/// dichiarata. I boolean sono interi (0/1), i timestamp sono testo ISO-8601.
/// `pairing_code` è escluso di proposito: vive solo lato server.
const forkastSchema = Schema([
  Table('household', [
    Column.text('name'),
    Column.integer('default_guests'),
    Column.integer('week_start_day'),
    Column.integer('auto_regen'),
    Column.text('created_at'),
    Column.text('updated_at'),
  ]),
  Table('membership', [
    Column.text('household_id'),
    Column.text('device_id'),
    Column.text('role'),
    Column.text('joined_at'),
    Column.text('updated_at'),
  ], indexes: [
    Index('membership_device', [IndexedColumn('device_id')]),
  ]),
  Table('ingredient', [
    Column.text('household_id'),
    Column.text('name'),
    Column.text('unit'),
    Column.integer('is_qb'),
    Column.text('category'),
    Column.text('created_at'),
    Column.text('updated_at'),
  ], indexes: [
    Index('ingredient_household', [IndexedColumn('household_id')]),
  ]),
  Table('tag', [
    Column.text('household_id'),
    Column.text('name'),
    Column.text('group'),
    Column.text('color'),
    Column.integer('sort_order'),
    Column.text('created_at'),
    Column.text('updated_at'),
  ], indexes: [
    Index('tag_household', [IndexedColumn('household_id')]),
  ]),
  Table('dish', [
    Column.text('household_id'),
    Column.text('name'),
    Column.text('created_at'),
    Column.text('updated_at'),
  ], indexes: [
    Index('dish_household', [IndexedColumn('household_id')]),
  ]),
  Table('dish_tag', [
    Column.text('dish_id'),
    Column.text('tag_id'),
    Column.text('household_id'),
    Column.text('created_at'),
  ], indexes: [
    Index('dish_tag_dish', [IndexedColumn('dish_id')]),
  ]),
  Table('dish_ingredient', [
    Column.text('dish_id'),
    Column.text('ingredient_id'),
    Column.text('household_id'),
    Column.real('qty_base4'),
    Column.text('created_at'),
    Column.text('updated_at'),
  ], indexes: [
    Index('dish_ingredient_dish', [IndexedColumn('dish_id')]),
  ]),
  Table('week_plan', [
    Column.text('household_id'),
    Column.integer('year'),
    Column.integer('week'),
    Column.text('created_at'),
    Column.text('updated_at'),
  ], indexes: [
    Index('week_plan_household', [IndexedColumn('household_id')]),
  ]),
  Table('plan_day', [
    Column.text('week_plan_id'),
    Column.text('household_id'),
    Column.integer('day_of_week'),
    Column.integer('guests'),
    Column.text('created_at'),
    Column.text('updated_at'),
  ], indexes: [
    Index('plan_day_week_plan', [IndexedColumn('week_plan_id')]),
  ]),
  Table('plan_day_dish', [
    Column.text('plan_day_id'),
    Column.text('dish_id'),
    Column.text('household_id'),
    Column.integer('sort_order'),
    Column.text('created_at'),
  ], indexes: [
    Index('plan_day_dish_plan_day', [IndexedColumn('plan_day_id')]),
  ]),
  Table('shopping_list', [
    Column.text('household_id'),
    Column.text('week_plan_id'),
    Column.text('generated_at'),
    Column.text('plan_hash'),
    Column.text('created_at'),
    Column.text('updated_at'),
  ], indexes: [
    Index('shopping_list_week_plan', [IndexedColumn('week_plan_id')]),
  ]),
  Table('list_generated_row', [
    Column.text('shopping_list_id'),
    Column.text('ingredient_id'),
    Column.text('household_id'),
    Column.real('qty'),
    Column.text('unit'),
    Column.integer('is_qb'),
    Column.text('created_at'),
  ], indexes: [
    Index('list_generated_row_list', [IndexedColumn('shopping_list_id')]),
  ]),
  Table('list_override', [
    Column.text('shopping_list_id'),
    Column.text('ingredient_id'),
    Column.text('household_id'),
    Column.real('qty_override'),
    Column.integer('removed'),
    Column.text('created_at'),
    Column.text('updated_at'),
  ], indexes: [
    Index('list_override_list', [IndexedColumn('shopping_list_id')]),
  ]),
  Table('list_manual_item', [
    Column.text('shopping_list_id'),
    Column.text('household_id'),
    Column.text('name'),
    Column.real('qty'),
    Column.text('unit'),
    Column.text('created_at'),
    Column.text('updated_at'),
  ], indexes: [
    Index('list_manual_item_list', [IndexedColumn('shopping_list_id')]),
  ]),
  Table('list_check', [
    Column.text('shopping_list_id'),
    Column.text('ingredient_id'),
    Column.text('manual_item_id'),
    Column.text('household_id'),
    Column.integer('checked'),
    Column.text('updated_at'),
  ], indexes: [
    Index('list_check_list', [IndexedColumn('shopping_list_id')]),
  ]),
]);
