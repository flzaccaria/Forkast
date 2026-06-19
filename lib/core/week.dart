/// Calcolo settimane ISO-8601, modulo puro e testabile.
///
/// Una settimana è identificata da (anno ISO, numero settimana ISO). Il giorno
/// è rappresentato come `DateTime.weekday`: 1 = lunedì … 7 = domenica.
/// La settimana ISO inizia di lunedì; l'ordine di *visualizzazione* può però
/// partire da domenica a seconda dell'impostazione utente (FR-20).

/// Numero di settimana ISO-8601 (1..53) della data.
int isoWeekNumber(DateTime date) {
  final d = DateTime(date.year, date.month, date.day);
  // Il giovedì della settimana determina l'anno/settimana ISO.
  final thursday = d.add(Duration(days: 4 - d.weekday));
  final firstDayOfYear = DateTime(thursday.year, 1, 1);
  final diff = thursday.difference(firstDayOfYear).inDays;
  return (diff / 7).floor() + 1;
}

/// Anno ISO-8601 della data (può differire dall'anno civile a cavallo di
/// dicembre/gennaio).
int isoWeekYear(DateTime date) {
  final d = DateTime(date.year, date.month, date.day);
  final thursday = d.add(Duration(days: 4 - d.weekday));
  return thursday.year;
}

/// Data del giorno `weekday` (1=lun..7=dom) nella settimana ISO (anno, week).
DateTime dateOfIsoWeek(int year, int week, int weekday) {
  // Il 4 gennaio cade sempre nella settimana ISO 1.
  final jan4 = DateTime(year, 1, 4);
  final mondayOfWeek1 = jan4.subtract(Duration(days: jan4.weekday - 1));
  return mondayOfWeek1.add(Duration(days: (week - 1) * 7 + (weekday - 1)));
}

/// I 7 giorni della settimana (valori `weekday` 1..7) ordinati secondo il
/// giorno di inizio settimana. `weekStartDay` segue la convenzione
/// `DateTime.weekday`: 1 = lunedì (default), 7 = domenica. Valori fuori range
/// ricadono su lunedì.
List<int> orderedWeekdays(int weekStartDay) {
  final start = (weekStartDay >= 1 && weekStartDay <= 7) ? weekStartDay : 1;
  return List.generate(7, (i) => ((start - 1 + i) % 7) + 1);
}
