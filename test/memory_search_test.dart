import 'package:flutter_test/flutter_test.dart';
import 'package:momento/core/utils/memory_search.dart';
import 'package:momento/core/utils/text_tools.dart';
import 'package:momento/data/models/feeling.dart';
import 'package:momento/data/models/memory.dart';
import 'package:momento/data/models/scent.dart';

/// Prueft die Suche aus Kapitel 7.2 des Businessplans: eine Erinnerung soll
/// sich finden lassen, indem man sie beschreibt.
void main() {
  final lake = Memory(
    id: 'lake',
    title: 'Ein perfekter Abend am See',
    story: 'Wir sind geblieben, bis die Sonne ganz weg war.',
    place: 'Zürichsee',
    people: const ['Mara'],
    happenedAt: DateTime(2025, 8, 26, 19, 42),
    createdAt: DateTime(2025, 8, 26),
    feeling: Feeling.calm,
    coverScene: CoverScene.lakeSunset,
    scent: const Scent(kind: ScentKind.seaBreeze),
    sound: null,
  );

  final birthday = Memory(
    id: 'birthday',
    title: 'Geburtstag mit allen',
    story: 'Es roch nach Zimt und Kuchen.',
    place: 'Zuhause',
    people: const ['Sara', 'Blerta'],
    happenedAt: DateTime(2024, 8, 26, 20, 15),
    createdAt: DateTime(2024, 8, 26),
    feeling: Feeling.joy,
    coverScene: CoverScene.celebration,
    scent: const Scent(kind: ScentKind.cinnamon),
  );

  final snow = Memory(
    id: 'snow',
    title: 'Der erste Schnee',
    story: 'Draussen war alles weiss und still.',
    happenedAt: DateTime(2025, 12, 6, 7, 40),
    createdAt: DateTime(2025, 12, 6),
    feeling: Feeling.wistful,
    coverScene: CoverScene.snowfall,
    scent: const Scent(kind: ScentKind.snowAir),
  );

  final all = [lake, birthday, snow];

  String? topResult(String query) {
    final hits = MemorySearch.run(query, all);
    return hits.isEmpty ? null : hits.first.memory.id;
  }

  group('Suche über Beschreibungen', () {
    test('findet über den Ort', () {
      expect(topResult('zürichsee'), 'lake');
    });

    test('findet über einen Oberbegriff, der nirgends wörtlich steht', () {
      // "Wasser" kommt in keiner Erinnerung vor - das Begriffsnetz verbindet
      // es mit See, Meer und der gezeichneten Szene.
      expect(topResult('abend am wasser'), 'lake');
    });

    test('findet über den Duft', () {
      expect(topResult('es roch nach zimt'), 'birthday');
    });

    test('findet über eine Person', () {
      expect(topResult('mit blerta'), 'birthday');
    });

    test('findet über die Jahreszeit', () {
      expect(topResult('im winter'), 'snow');
    });

    test('findet über das Gefühl', () {
      expect(topResult('etwas ruhiges'), 'lake');
    });

    test('verzeiht einen Tippfehler', () {
      expect(topResult('geburtsdag'), 'birthday');
    });

    test('funktioniert auch auf Englisch', () {
      expect(topResult('sunset over the water'), 'lake');
    });

    test('versteht Alltagswörter wie "heiss"', () {
      // "heiss" steht in keiner Erinnerung - das Begriffsnetz verbindet es
      // mit Sonne und Sommer.
      expect(topResult('es war heiss'), isNotNull);
    });

    test('nennt die Felder, über die gefunden wurde', () {
      final hits = MemorySearch.run('zürichsee', all);
      expect(hits.first.matchedFields, contains(MatchField.place));
    });

    test('gibt bei Unsinn nichts zurück', () {
      expect(MemorySearch.run('xyzqwertz', all), isEmpty);
    });

    test('leere Anfrage liefert keine Treffer', () {
      expect(MemorySearch.run('   ', all), isEmpty);
    });
  });

  group('Textwerkzeuge', () {
    test('löst Umlaute auf', () {
      expect(TextTools.normalise('Zürichsee'), 'zuerichsee');
      expect(TextTools.normalise('Grüsse, Düfte!'), 'gruesse duefte');
    });

    test('entfernt Füllwörter', () {
      expect(TextTools.tokenise('der Abend an dem See'), ['abend', 'see']);
    });

    test('kürzt auf den Wortstamm', () {
      expect(TextTools.stem('wellen'), TextTools.stem('welle'));
    });

    test('misst den Abstand zwischen zwei Wörtern', () {
      expect(TextTools.editDistance('sommer', 'somer'), 1);
      expect(TextTools.editDistance('sommer', 'winter'), greaterThan(2));
    });
  });

  group('Jahrestage', () {
    test('erkennt den Jahrestag auf den Tag genau', () {
      expect(lake.anniversaryYears(DateTime(2026, 8, 26)), 1);
      expect(birthday.anniversaryYears(DateTime(2026, 8, 26)), 2);
    });

    test('meldet nichts an einem anderen Tag', () {
      expect(lake.anniversaryYears(DateTime(2026, 8, 27)), isNull);
    });

    test('meldet nichts im selben Jahr', () {
      expect(lake.anniversaryYears(DateTime(2025, 8, 26)), isNull);
    });
  });
}
