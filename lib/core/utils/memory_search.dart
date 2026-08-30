import '../../data/models/memory.dart';
import '../l10n/app_texts.dart';
import 'text_tools.dart';

/// Die Felder, ueber die eine Erinnerung gefunden werden kann.
/// Sie werden im Suchergebnis als "Gefunden über …" angezeigt.
enum MatchField {
  title,
  story,
  place,
  people,
  scent,
  sound,
  feeling,
  season,
  timeOfDay;

  String label(AppTexts t) => switch (this) {
        MatchField.title => t.matchedTitle,
        MatchField.story => t.matchedStory,
        MatchField.place => t.matchedPlace,
        MatchField.people => t.matchedPeople,
        MatchField.scent => t.matchedScent,
        MatchField.sound => t.matchedSound,
        MatchField.feeling => t.matchedFeeling,
        MatchField.season => t.matchedSeason,
        MatchField.timeOfDay => t.matchedTime,
      };
}

class SearchHit {
  const SearchHit({
    required this.memory,
    required this.score,
    required this.matchedFields,
  });

  final Memory memory;
  final double score;
  final Set<MatchField> matchedFields;
}

/// Die Suche aus dem Businessplan: "Erinnerungen werden gesucht, indem man sie
/// beschreibt."
///
/// Statt nur nach exakten Woertern zu filtern, bewertet die Suche jede
/// Erinnerung ueber mehrere Felder, kennt Synonyme und Oberbegriffe, verzeiht
/// Tippfehler und versteht auch Angaben wie "im Winter" oder "abends".
abstract final class MemorySearch {
  /// Gewicht der einzelnen Felder - der Titel zaehlt am meisten.
  static const _weights = <MatchField, double>{
    MatchField.title: 3.4,
    MatchField.place: 2.6,
    MatchField.people: 2.6,
    MatchField.scent: 2.4,
    MatchField.sound: 2.2,
    MatchField.feeling: 2.0,
    MatchField.story: 1.4,
    MatchField.season: 1.6,
    MatchField.timeOfDay: 1.4,
  };

  static List<SearchHit> run(
    String query,
    List<Memory> memories, {
    double minimumScore = 1.0,
  }) {
    final queryTokens = TextTools.tokenise(query);
    if (queryTokens.isEmpty) return const [];

    // Anfrage um verwandte Begriffe erweitern ("meer" findet auch "salz").
    final expanded = <String>{};
    for (final token in queryTokens) {
      expanded.add(token);
      expanded.addAll(_conceptsFor(token));
    }
    final queryStems = expanded.map(TextTools.stem).toSet();

    final hits = <SearchHit>[];
    for (final memory in memories) {
      final fields = _fieldsOf(memory);
      var score = 0.0;
      final matched = <MatchField>{};

      fields.forEach((field, words) {
        if (words.isEmpty) return;
        final weight = _weights[field] ?? 1.0;
        var fieldScore = 0.0;

        for (final queryStem in queryStems) {
          var best = 0.0;
          for (final word in words) {
            best = _bestOf(best, _similarity(queryStem, word));
            if (best >= 1.0) break;
          }
          fieldScore += best;
        }

        if (fieldScore > 0) {
          matched.add(field);
          // Durch die Wortzahl teilen waere unfair fuer lange Texte, deshalb
          // daempfen wir stattdessen mit der Wurzel.
          score += weight * fieldScore;
        }
      });

      // Wer in mehreren Feldern passt, ist wahrscheinlich wirklich gemeint.
      if (matched.length > 1) score *= 1 + (matched.length - 1) * 0.12;

      // Ein Volltreffer im Titel schlaegt alles.
      final titleNormalised = TextTools.normalise(memory.title);
      if (titleNormalised.contains(TextTools.normalise(query))) score += 4;

      if (score >= minimumScore) {
        hits.add(SearchHit(memory: memory, score: score, matchedFields: matched));
      }
    }

    hits.sort((a, b) {
      final byScore = b.score.compareTo(a.score);
      return byScore != 0
          ? byScore
          : b.memory.happenedAt.compareTo(a.memory.happenedAt);
    });
    return hits;
  }

  static double _bestOf(double a, double b) => a > b ? a : b;

  /// 1.0 = gleiches Wort, 0.8 = Wortanfang stimmt, 0.6 = ein Tippfehler.
  static double _similarity(String queryStem, String candidateStem) {
    if (queryStem == candidateStem) return 1.0;
    if (candidateStem.length >= 4 && candidateStem.startsWith(queryStem)) return 0.85;
    if (queryStem.length >= 4 && queryStem.startsWith(candidateStem)) return 0.75;
    if (queryStem.length >= 5 && candidateStem.length >= 5) {
      final distance = TextTools.editDistance(queryStem, candidateStem, maxDistance: 1);
      if (distance <= 1) return 0.6;
    }
    return 0.0;
  }

  /// Zerlegt eine Erinnerung in durchsuchbare Wortstaemme pro Feld.
  static Map<MatchField, List<String>> _fieldsOf(Memory memory) {
    List<String> stems(String text) =>
        TextTools.tokenise(text).map(TextTools.stem).toList();

    final scentWords = <String>[];
    if (memory.hasScent) {
      scentWords.addAll(stems(memory.scent!.searchableText));
    }

    final soundWords = <String>[];
    if (memory.hasSound) {
      soundWords
        ..addAll(stems(memory.sound!.label ?? ''))
        ..addAll(['gerausch', 'sound', 'aufnahm', 'ton', 'recording']);
    }

    final feelingWords = <String>[];
    if (memory.feeling != null) {
      feelingWords.addAll(
        memory.feeling!.searchTerms.map((t) => TextTools.stem(TextTools.normalise(t))),
      );
    }

    // Die gezeichnete Szene verraet ebenfalls etwas ueber den Inhalt.
    final sceneWords = _sceneTerms(memory.effectiveScene)
        .map((t) => TextTools.stem(TextTools.normalise(t)))
        .toList();

    return {
      MatchField.title: [...stems(memory.title), ...sceneWords],
      MatchField.story: stems(memory.story),
      MatchField.place: stems(memory.place ?? ''),
      MatchField.people: stems(memory.people.join(' ')),
      MatchField.scent: scentWords,
      MatchField.sound: soundWords,
      MatchField.feeling: feelingWords,
      MatchField.season: _seasonTerms(memory.happenedAt.month)
          .map((t) => TextTools.stem(TextTools.normalise(t)))
          .toList(),
      MatchField.timeOfDay: _timeTerms(memory.happenedAt.hour)
          .map((t) => TextTools.stem(TextTools.normalise(t)))
          .toList(),
    };
  }

  static List<String> _seasonTerms(int month) => switch (month) {
        12 || 1 || 2 => ['winter', 'kalt', 'schnee', 'cold', 'snow'],
        3 || 4 || 5 => ['fruehling', 'lenz', 'spring', 'bluete'],
        6 || 7 || 8 => ['sommer', 'warm', 'hitze', 'ferien', 'summer', 'holiday'],
        _ => ['herbst', 'laub', 'nebel', 'autumn', 'fall', 'leaves'],
      };

  static List<String> _timeTerms(int hour) {
    if (hour < 5) return ['nacht', 'spaet', 'night', 'late'];
    if (hour < 11) return ['morgen', 'frueh', 'sonnenaufgang', 'morning', 'sunrise', 'early'];
    if (hour < 15) return ['mittag', 'tag', 'noon', 'midday'];
    if (hour < 19) return ['nachmittag', 'afternoon'];
    if (hour < 23) return ['abend', 'sonnenuntergang', 'daemmerung', 'evening', 'sunset', 'dusk'];
    return ['nacht', 'spaet', 'night', 'late'];
  }

  static List<String> _sceneTerms(CoverScene scene) => switch (scene) {
        CoverScene.lakeSunset => ['see', 'wasser', 'sonnenuntergang', 'abend', 'ufer', 'lake', 'water', 'sunset', 'shore'],
        CoverScene.beach => ['strand', 'meer', 'sand', 'welle', 'kueste', 'beach', 'sea', 'waves', 'coast'],
        CoverScene.mountains => ['berg', 'gipfel', 'wandern', 'alpen', 'hoehe', 'mountain', 'summit', 'hike', 'peak'],
        CoverScene.cityNight => ['stadt', 'nacht', 'lichter', 'strasse', 'city', 'night', 'lights', 'street'],
        CoverScene.forest => ['wald', 'baum', 'baeume', 'natur', 'forest', 'tree', 'nature', 'woods'],
        CoverScene.snowfall => ['schnee', 'winter', 'kalt', 'flocken', 'snow', 'cold', 'flakes'],
        CoverScene.celebration => ['fest', 'feier', 'geburtstag', 'party', 'freunde', 'celebration', 'birthday', 'friends'],
        CoverScene.rainWindow => ['regen', 'fenster', 'tropfen', 'drinnen', 'rain', 'window', 'drops', 'inside'],
        CoverScene.autumnPark => ['herbst', 'park', 'blaetter', 'laub', 'autumn', 'leaves', 'fall'],
        CoverScene.springMeadow => ['wiese', 'blumen', 'fruehling', 'gras', 'meadow', 'flowers', 'spring', 'grass'],
      };

  /// Kleines Begriffsnetz: verbindet Alltagssprache mit dem, was in den
  /// Erinnerungen wirklich steht.
  static List<String> _conceptsFor(String token) {
    for (final group in _conceptGroups) {
      if (group.contains(token)) {
        return group.where((word) => word != token).toList();
      }
    }
    return const [];
  }

  static const _conceptGroups = <List<String>>[
    ['meer', 'see', 'wasser', 'ozean', 'strand', 'kueste', 'welle', 'wellen', 'sea', 'ocean', 'lake', 'water', 'beach', 'shore', 'wave'],
    ['berg', 'berge', 'gipfel', 'alpen', 'wandern', 'wanderung', 'huette', 'mountain', 'mountains', 'summit', 'hike', 'hiking'],
    ['wald', 'baum', 'baeume', 'natur', 'gruen', 'forest', 'tree', 'trees', 'nature', 'woods'],
    ['stadt', 'strasse', 'lichter', 'city', 'street', 'lights', 'urban'],
    ['schnee', 'winter', 'kalt', 'frost', 'eis', 'snow', 'cold', 'ice'],
    ['regen', 'nass', 'gewitter', 'sturm', 'rain', 'wet', 'storm'],
    ['sonne', 'sonnig', 'warm', 'heiss', 'hitze', 'schwuel', 'sonnenuntergang', 'sonnenaufgang', 'sun', 'sunny', 'hot', 'heat', 'sunset', 'sunrise'],
    ['ruhig', 'frei', 'freiheit', 'leicht', 'unbeschwert', 'weite', 'luft', 'atmen', 'free', 'freedom', 'light', 'space', 'breathe'],
    ['abend', 'abends', 'daemmerung', 'spaet', 'evening', 'dusk', 'late'],
    ['morgen', 'morgens', 'frueh', 'aufwachen', 'morning', 'early', 'wake'],
    ['zuhause', 'daheim', 'wohnung', 'haus', 'home', 'house', 'flat'],
    ['erster', 'erste', 'zum ersten mal', 'neu', 'anfang', 'first', 'new', 'beginning'],
    ['freunde', 'freundin', 'freund', 'kollegen', 'zusammen', 'gemeinsam', 'friends', 'friend', 'together'],
    ['familie', 'mama', 'papa', 'mutter', 'vater', 'schwester', 'bruder', 'grossmutter', 'oma', 'opa', 'family', 'mother', 'father', 'sister', 'brother', 'grandma', 'grandmother'],
    ['fest', 'feier', 'geburtstag', 'party', 'hochzeit', 'celebration', 'birthday', 'wedding'],
    ['reise', 'ferien', 'urlaub', 'ausflug', 'abenteuer', 'unterwegs', 'travel', 'trip', 'holiday', 'vacation', 'adventure'],
    ['essen', 'kochen', 'kuchen', 'brot', 'znacht', 'food', 'cooking', 'cake', 'bread', 'dinner'],
    ['musik', 'lied', 'song', 'tanzen', 'music', 'dance', 'dancing'],
    ['hund', 'katze', 'tier', 'dog', 'cat', 'animal', 'pet'],
    ['lachen', 'lustig', 'spass', 'freude', 'laugh', 'funny', 'fun', 'joy'],
    ['ruhig', 'still', 'entspannt', 'frieden', 'quiet', 'calm', 'peace', 'relaxed'],
    ['feuer', 'lagerfeuer', 'rauch', 'fire', 'campfire', 'smoke'],
    ['blumen', 'wiese', 'gras', 'fruehling', 'flowers', 'meadow', 'grass', 'spring'],
    ['herbst', 'blaetter', 'laub', 'autumn', 'fall', 'leaves'],
  ];
}
