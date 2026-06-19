/// Reparti del supermercato: lista fissa predefinita (punto aperto risolto).
///
/// L'ordine di [reparti] è la sequenza tipica del percorso in negozio, così la
/// lista della spesa si può raggruppare e ordinare per reparto e seguire il
/// giro fisico invece di rimbalzare avanti e indietro.
///
/// Il valore salvato su `ingredient.category` è la stringa del reparto (uno di
/// [reparti]) oppure `null` ("Senza reparto"). Si usa la stringa — e non un
/// indice — così il dato resta leggibile e robusto se l'ordine cambia.
library;

/// Elenco canonico dei reparti, nell'ordine del percorso in negozio.
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

/// Etichetta usata per gli ingredienti senza reparto assegnato.
const String repartoNonAssegnato = 'Senza reparto';

/// Indice di ordinamento di un reparto: gli sconosciuti e i `null` finiscono
/// in fondo, così un valore non più previsto non rompe l'ordine.
int repartoSortIndex(String? category) {
  if (category == null) return reparti.length + 1;
  final i = reparti.indexOf(category);
  return i < 0 ? reparti.length : i;
}
