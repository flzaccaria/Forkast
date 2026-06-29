/// Strips diacritics (accents) from a string for case- and accent-insensitive
/// matching. Covers Latin-1/Latin Extended-A characters used in Italian, Danish,
/// and English.
///
/// Danish æ/ø/å are mapped to ae/oe/aa so that a search for "ae" matches "æ"
/// and vice versa.
String removeDiacritics(String input) {
  final buf = StringBuffer();
  for (var i = 0; i < input.length; i++) {
    buf.write(_map[input[i]] ?? input[i]);
  }
  return buf.toString();
}

/// Normalizes [input] for accent- and case-insensitive comparison.
String normalizeForSearch(String input) =>
    removeDiacritics(input).toLowerCase();

const _map = <String, String>{
  // Uppercase accented vowels
  'À': 'A', 'Á': 'A', 'Â': 'A', 'Ã': 'A', 'Ä': 'A',
  'È': 'E', 'É': 'E', 'Ê': 'E', 'Ë': 'E',
  'Ì': 'I', 'Í': 'I', 'Î': 'I', 'Ï': 'I',
  'Ò': 'O', 'Ó': 'O', 'Ô': 'O', 'Õ': 'O', 'Ö': 'O',
  'Ù': 'U', 'Ú': 'U', 'Û': 'U', 'Ü': 'U',
  'Ý': 'Y', 'Ñ': 'N', 'Ç': 'C',
  // Lowercase accented vowels
  'à': 'a', 'á': 'a', 'â': 'a', 'ã': 'a', 'ä': 'a',
  'è': 'e', 'é': 'e', 'ê': 'e', 'ë': 'e',
  'ì': 'i', 'í': 'i', 'î': 'i', 'ï': 'i',
  'ò': 'o', 'ó': 'o', 'ô': 'o', 'õ': 'o', 'ö': 'o',
  'ù': 'u', 'ú': 'u', 'û': 'u', 'ü': 'u',
  'ý': 'y', 'ñ': 'n', 'ç': 'c',
  // Danish special characters
  'Æ': 'Ae', 'æ': 'ae',
  'Ø': 'Oe', 'ø': 'oe',
  'Å': 'Aa', 'å': 'aa',
};
