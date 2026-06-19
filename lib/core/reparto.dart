/// Supermarket departments: fixed predefined list (open point resolved).
///
/// The order of [reparti] is the typical sequence of the store route, so the
/// shopping list can be grouped and sorted by department and follow the
/// physical walk instead of bouncing back and forth.
///
/// The value stored in `ingredient.category` is the department string (one of
/// [reparti]) or `null` ("Senza reparto"). A string is used — not an
/// index — so the data stays readable and robust if the order changes.
library;

/// Canonical list of departments, in store-route order.
const List<String> reparti = [
  'Ortofrutta',
  'Macelleria',
  'Pescheria',
  'Salumi e formaggi',
  'Latticini e uova',
  'Pane e forno',
  'Dispensa',
  'Surgelati',
  'Bevande',
  'Cura della casa',
  'Cura della persona',
  'Altro',
];

/// Label used for ingredients without an assigned department.
const String repartoNonAssegnato = 'Senza reparto';

/// Sort index of a department: unknown ones and `null` end up
/// at the bottom, so a no-longer-expected value doesn't break the order.
int repartoSortIndex(String? category) {
  if (category == null) return reparti.length + 1;
  final i = reparti.indexOf(category);
  return i < 0 ? reparti.length : i;
}
