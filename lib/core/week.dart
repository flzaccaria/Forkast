// Calcolo settimane ISO-8601, modulo puro e testabile.

/// Numero di settimana ISO-8601 (1..53) della data.
int isoWeekNumber(DateTime date) {
  final d = DateTime.utc(date.year, date.month, date.day);
  final thursday = d.add(Duration(days: 4 - d.weekday));
  final firstDayOfYear = DateTime.utc(thursday.year, 1, 1);
  final diff = thursday.difference(firstDayOfYear).inDays;
  return (diff / 7).floor() + 1;
}

/// Anno ISO-8601 della data (può differire dall'anno civile a cavallo di
/// dicembre/gennaio).
int isoWeekYear(DateTime date) {
  final d = DateTime.utc(date.year, date.month, date.day);
  final thursday = d.add(Duration(days: 4 - d.weekday));
  return thursday.year;
}

/// Data del giorno `weekday` (1=lun..7=dom) nella settimana ISO (anno, week).
DateTime dateOfIsoWeek(int year, int week, int weekday) {
  // Il 4 gennaio cade sempre nella settimana ISO 1.
  final jan4 = DateTime.utc(year, 1, 4);
  final mondayOfWeek1 = jan4.subtract(Duration(days: jan4.weekday - 1));
  final result = mondayOfWeek1.add(Duration(days: (week - 1) * 7 + (weekday - 1)));
  // Aritmetica in UTC per evitare gli scostamenti da ora legale, ma si
  // restituisce una data locale (mezzanotte) coerente con l'uso nella UI.
  return DateTime(result.year, result.month, result.day);
}

/// I 7 giorni della settimana (valori `weekday` 1..7) ordinati secondo il
/// giorno di inizio settimana. `weekStartDay` segue la convenzione
/// `DateTime.weekday`: 1 = lunedì (default), 7 = domenica. Valori fuori range
/// ricadono su lunedì.
List<int> orderedWeekdays(int weekStartDay) {
  final start = (weekStartDay >= 1 && weekStartDay <= 7) ? weekStartDay : 1;
  return List.generate(7, (i) => ((start - 1 + i) % 7) + 1);
}
