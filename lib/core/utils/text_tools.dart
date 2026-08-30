import 'dart:math' as math;

/// Textwerkzeuge fuer die Suche.
abstract final class TextTools {
  static const _umlauts = {
    'ä': 'ae',
    'ö': 'oe',
    'ü': 'ue',
    'ß': 'ss',
    'à': 'a',
    'á': 'a',
    'â': 'a',
    'è': 'e',
    'é': 'e',
    'ê': 'e',
    'ë': 'e',
    'ì': 'i',
    'í': 'i',
    'î': 'i',
    'ò': 'o',
    'ó': 'o',
    'ô': 'o',
    'ù': 'u',
    'ú': 'u',
    'û': 'u',
    'ç': 'c',
    'ñ': 'n',
  };

  /// Woerter, die fuer die Suche nichts beitragen.
  static final Set<String> _stopWords = {
    // Deutsch
    'der', 'die', 'das', 'den', 'dem', 'des', 'ein', 'eine', 'einer', 'eines',
    'einem', 'einen', 'und', 'oder', 'aber', 'mit', 'ohne', 'von', 'vom', 'zu',
    'zum', 'zur', 'im', 'in', 'am', 'an', 'auf', 'aus', 'bei', 'nach', 'ueber',
    'unter', 'vor', 'als', 'wie', 'wo', 'wann', 'ist', 'war', 'sind', 'waren',
    'hat', 'habe', 'haben', 'hatte', 'wir', 'ich', 'du', 'er', 'sie', 'es',
    'man', 'sich', 'mich', 'dich', 'uns', 'euch', 'ihr', 'mein', 'dein', 'sein',
    'da', 'dann', 'noch', 'schon', 'sehr', 'auch', 'nur', 'so', 'fuer',
    'dass', 'weil', 'wenn', 'damals',
    // Englisch
    'the', 'and', 'or', 'but', 'with', 'without', 'of',
    'on', 'at', 'from', 'by', 'for', 'as', 'is', 'was', 'were', 'are', 'has',
    'have', 'had', 'we', 'i', 'you', 'he', 'she', 'it', 'they', 'my', 'your',
    'that', 'this', 'there', 'then', 'when', 'where', 'how', 'very',
    'just', 'also', 'about',
  };

  /// Kleinbuchstaben, Umlaute aufgeloest, Satzzeichen weg.
  static String normalise(String input) {
    final lower = input.toLowerCase();
    final buffer = StringBuffer();
    for (final rune in lower.runes) {
      final char = String.fromCharCode(rune);
      final replacement = _umlauts[char];
      if (replacement != null) {
        buffer.write(replacement);
      } else if (RegExp(r'[a-z0-9]').hasMatch(char)) {
        buffer.write(char);
      } else {
        buffer.write(' ');
      }
    }
    return buffer.toString().replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  /// Zerlegt einen Text in bedeutungstragende Woerter.
  static List<String> tokenise(String input, {bool keepStopWords = false}) {
    final normalised = normalise(input);
    if (normalised.isEmpty) return const [];
    return normalised
        .split(' ')
        .where((w) => w.length > 1)
        .where((w) => keepStopWords || !_stopWords.contains(w))
        .toList();
  }

  /// Sehr einfacher Wortstamm: haengt typische deutsche und englische
  /// Endungen ab, damit "Wellen" und "Welle" zusammenfinden.
  static String stem(String word) {
    if (word.length <= 4) return word;
    for (final suffix in const ['ungen', 'lich', 'isch', 'ende', 'ern', 'est', 'ing', 'ien', 'en', 'er', 'es', 'em', 'et', 'ts', 'e', 'n', 's']) {
      if (word.length - suffix.length >= 4 && word.endsWith(suffix)) {
        return word.substring(0, word.length - suffix.length);
      }
    }
    return word;
  }

  /// Levenshtein-Distanz, begrenzt auf [maxDistance] (danach bricht sie ab).
  static int editDistance(String a, String b, {int maxDistance = 2}) {
    if (a == b) return 0;
    if ((a.length - b.length).abs() > maxDistance) return maxDistance + 1;

    var previous = List<int>.generate(b.length + 1, (i) => i);
    var current = List<int>.filled(b.length + 1, 0);

    for (var i = 1; i <= a.length; i++) {
      current[0] = i;
      var rowMin = current[0];
      for (var j = 1; j <= b.length; j++) {
        final cost = a[i - 1] == b[j - 1] ? 0 : 1;
        current[j] = math.min(
          math.min(current[j - 1] + 1, previous[j] + 1),
          previous[j - 1] + cost,
        );
        rowMin = math.min(rowMin, current[j]);
      }
      if (rowMin > maxDistance) return maxDistance + 1;
      final swap = previous;
      previous = current;
      current = swap;
    }
    return previous[b.length];
  }
}
