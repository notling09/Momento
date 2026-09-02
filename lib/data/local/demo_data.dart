import 'package:uuid/uuid.dart';

import '../models/album.dart';
import '../models/feeling.dart';
import '../models/memory.dart';
import '../models/scent.dart';
import '../repositories/album_repository.dart';
import '../repositories/memory_repository.dart';
import 'ambience_synth.dart';
import 'media_store.dart';

/// Die Beispiel-Erinnerungen, mit denen Momento startet.
///
/// Sie sind so datiert, dass die Flashback-Funktion auf der Startseite sofort
/// etwas zu zeigen hat, und decken alle Bausteine ab: Bild, Duft, Geraeusch,
/// Ort, Menschen und Gefuehl.
abstract final class DemoData {
  static const _uuid = Uuid();

  static Future<void> seed({
    required MemoryRepository memories,
    required AlbumRepository albums,
    required MediaStore media,
    required bool english,
    required DateTime now,
  }) async {

    DateTime at(int yearsAgo, int month, int day, int hour, int minute) =>
        DateTime(now.year - yearsAgo, month, day, hour, minute);

    /// Genau heute, nur vor [yearsAgo] Jahren - das loest den Flashback aus.
    DateTime today(int yearsAgo, int hour, int minute) =>
        DateTime(now.year - yearsAgo, now.month, now.day, hour, minute);

    final specs = <_DemoSpec>[
      _DemoSpec(
        titleDe: 'Ein perfekter Abend am See',
        titleEn: 'A perfect evening by the lake',
        storyDe:
            'Wir sind geblieben, bis die Sonne ganz weg war. Niemand hat etwas gesagt, '
            'der Hund lag zwischen uns im Gras und das Wasser wurde langsam golden. '
            'So einen ruhigen Abend hatte ich lange nicht mehr.',
        storyEn:
            'We stayed until the sun was completely gone. Nobody said a word, the dog '
            'lay between us in the grass and the water slowly turned golden. I had not '
            'had such a quiet evening in a long time.',
        placeDe: 'Zürichsee',
        placeEn: 'Lake Zurich',
        people: ['Mara'],
        scene: CoverScene.lakeSunset,
        feeling: Feeling.calm,
        scent: ScentKind.seaBreeze,
        soundDe: 'Wellenrauschen',
        soundEn: 'Waves rolling in',
        ambience: Ambience.waves,
        happenedAt: today(1, 19, 42),
        favorite: true,
      ),
      _DemoSpec(
        titleDe: 'Geburtstag mit allen',
        titleEn: 'A birthday with everyone',
        storyDe:
            'Alle sind gekommen, sogar die, von denen ich es nicht gedacht hätte. '
            'Es roch nach Zimt und Kuchen und irgendwann hat jemand die Musik zu laut gedreht.',
        storyEn:
            'Everyone came, even the ones I did not expect. It smelled of cinnamon and '
            'cake, and at some point somebody turned the music up far too loud.',
        placeDe: 'Zuhause',
        placeEn: 'At home',
        people: ['Sara', 'Djellza', 'Blerta', 'Dalila'],
        scene: CoverScene.celebration,
        feeling: Feeling.joy,
        scent: ScentKind.cinnamon,
        happenedAt: today(2, 20, 15),
        favorite: true,
      ),
      _DemoSpec(
        titleDe: 'Erster Sprung ins Meer',
        titleEn: 'First jump into the sea',
        storyDe:
            'Kalt, salzig, viel zu laut gelacht. Danach lagen wir stundenlang auf dem '
            'warmen Stein und haben uns nicht bewegt.',
        storyEn:
            'Cold, salty, and we laughed far too loudly. Afterwards we lay on the warm '
            'stone for hours without moving.',
        placeDe: 'Lignano',
        placeEn: 'Lignano',
        people: ['Luca', 'Nina'],
        scene: CoverScene.beach,
        feeling: Feeling.joy,
        scent: ScentKind.sunscreen,
        soundDe: 'Brandung und Möwen',
        soundEn: 'Surf and seagulls',
        ambience: Ambience.waves,
        happenedAt: at(1, 7, 14, 11, 20),
      ),
      _DemoSpec(
        titleDe: 'Sonnenaufgang auf dem Gipfel',
        titleEn: 'Sunrise on the summit',
        storyDe:
            'Um vier Uhr losgelaufen, dreimal gedacht, dass es keine gute Idee war. '
            'Und dann standen wir oben, als es hell wurde.',
        storyEn:
            'We set off at four, and three times I thought it was a bad idea. And then '
            'we stood at the top as the light came.',
        placeDe: 'Pilatus',
        placeEn: 'Mount Pilatus',
        people: ['Jonas'],
        scene: CoverScene.mountains,
        feeling: Feeling.proud,
        scent: ScentKind.snowAir,
        soundDe: 'Wind über dem Grat',
        soundEn: 'Wind over the ridge',
        ambience: Ambience.wind,
        happenedAt: at(2, 6, 28, 5, 48),
      ),
      _DemoSpec(
        titleDe: 'Nachtspaziergang durch die Stadt',
        titleEn: 'A night walk through the city',
        storyDe:
            'Der Regen hatte gerade aufgehört und alles hat geglänzt. Wir sind einfach '
            'weitergelaufen, obwohl der letzte Zug längst weg war.',
        storyEn:
            'The rain had just stopped and everything was glistening. We simply kept '
            'walking, even though the last train had long since gone.',
        placeDe: 'Bern',
        placeEn: 'Bern',
        people: ['Elif'],
        scene: CoverScene.cityNight,
        feeling: Feeling.nostalgia,
        scent: ScentKind.rainOnAsphalt,
        happenedAt: at(1, 10, 3, 23, 30),
      ),
      _DemoSpec(
        titleDe: 'Im Tannenwald verlaufen',
        titleEn: 'Lost in the pine forest',
        storyDe:
            'Wir haben den Weg verloren und es war überhaupt nicht schlimm. Es roch '
            'nach Harz und der Boden war weich vom Moos.',
        storyEn:
            'We lost the path and it did not matter at all. It smelled of resin and the '
            'ground was soft with moss.',
        placeDe: 'Emmental',
        placeEn: 'Emmental',
        people: [],
        scene: CoverScene.forest,
        feeling: Feeling.calm,
        scent: ScentKind.pineForest,
        soundDe: 'Vögel zwischen den Bäumen',
        soundEn: 'Birds between the trees',
        ambience: Ambience.birds,
        happenedAt: at(2, 5, 12, 15, 5),
      ),
      _DemoSpec(
        titleDe: 'Der erste Schnee',
        titleEn: 'The first snow',
        storyDe:
            'Morgens aufgewacht und draussen war alles weiss und still. Ich bin extra '
            'früher losgegangen, nur um als Erste durch den Schnee zu laufen.',
        storyEn:
            'Woke up and outside everything was white and silent. I left earlier than '
            'needed, just to be the first to walk through the snow.',
        placeDe: 'Vor der Haustür',
        placeEn: 'Just outside the door',
        people: [],
        scene: CoverScene.snowfall,
        feeling: Feeling.wistful,
        scent: ScentKind.snowAir,
        happenedAt: at(1, 12, 6, 7, 40),
      ),
      _DemoSpec(
        titleDe: 'Regen am Fenster',
        titleEn: 'Rain on the window',
        storyDe:
            'Ein ganzer Nachmittag, an dem nichts passiert ist. Tee, ein Buch und der '
            'Regen. Genau das wollte ich mir merken.',
        storyEn:
            'A whole afternoon in which nothing happened. Tea, a book and the rain. '
            'That is exactly what I wanted to keep.',
        placeDe: 'Zuhause',
        placeEn: 'At home',
        people: [],
        scene: CoverScene.rainWindow,
        feeling: Feeling.calm,
        scent: ScentKind.oldBooks,
        soundDe: 'Regen auf dem Fensterbrett',
        soundEn: 'Rain on the windowsill',
        ambience: Ambience.rain,
        happenedAt: at(0, 4, 18, 16, 10),
      ),
      _DemoSpec(
        titleDe: 'Herbstblätter im Park',
        titleEn: 'Autumn leaves in the park',
        storyDe:
            'Die Bäume waren komplett orange. Wir haben Kastanien gesammelt wie früher, '
            'obwohl wir längst zu alt dafür sind.',
        storyEn:
            'The trees were completely orange. We collected chestnuts like we used to, '
            'even though we are far too old for that now.',
        placeDe: 'Stadtpark',
        placeEn: 'City park',
        people: ['Mama'],
        scene: CoverScene.autumnPark,
        feeling: Feeling.nostalgia,
        scent: ScentKind.cutGrass,
        happenedAt: at(2, 10, 21, 14, 30),
      ),
      _DemoSpec(
        titleDe: 'Blumenwiese im Frühling',
        titleEn: 'Flower meadow in spring',
        storyDe:
            'Der erste richtig warme Tag. Wir haben uns einfach in die Wiese gelegt und '
            'sind fast eingeschlafen.',
        storyEn:
            'The first properly warm day. We just lay down in the meadow and nearly '
            'fell asleep.',
        placeDe: 'Oberland',
        placeEn: 'The highlands',
        people: ['Sara'],
        scene: CoverScene.springMeadow,
        feeling: Feeling.gratitude,
        scent: ScentKind.flowerMeadow,
        happenedAt: at(1, 4, 27, 13, 15),
      ),
      _DemoSpec(
        titleDe: 'Lagerfeuer bis spät',
        titleEn: 'Campfire until late',
        storyDe:
            'Irgendwann hat niemand mehr geredet und wir haben nur noch ins Feuer '
            'geschaut. Der Rauch hing tagelang in der Jacke.',
        storyEn:
            'At some point nobody talked any more and we just watched the fire. The '
            'smoke stayed in my jacket for days.',
        placeDe: 'Am Fluss',
        placeEn: 'By the river',
        people: ['Luca', 'Nina', 'Jonas'],
        scene: CoverScene.forest,
        feeling: Feeling.love,
        scent: ScentKind.campfire,
        soundDe: 'Knisterndes Feuer',
        soundEn: 'Crackling fire',
        ambience: Ambience.fire,
        happenedAt: at(3, 8, 9, 22, 5),
        favorite: true,
      ),
      _DemoSpec(
        titleDe: 'Grossmutters Küche',
        titleEn: 'Grandmother\'s kitchen',
        storyDe:
            'Es roch genau wie damals. Ich habe nichts gesagt und einfach in der Tür '
            'gestanden, bis sie mich bemerkt hat.',
        storyEn:
            'It smelled exactly like it used to. I said nothing and just stood in the '
            'doorway until she noticed me.',
        placeDe: 'Bei Grossmutter',
        placeEn: 'At grandmother\'s',
        people: ['Grossmutter'],
        scene: CoverScene.springMeadow,
        feeling: Feeling.nostalgia,
        scent: ScentKind.grandmasHome,
        happenedAt: at(4, 3, 2, 11, 0),
      ),
    ];

    final created = <Memory>[];
    for (final spec in specs) {
      created.add(await spec.build(media: media, english: english));
    }

    // Wichtig: Nur die alten Beispiele ersetzen. Alles, was die Person selbst
    // festgehalten hat, bleibt unangetastet - sonst waeren beim Neuladen der
    // Beispiele echte Erinnerungen verloren.
    final existing = await memories.fetchAll();
    final ownMemories = existing.where((m) => !m.isDemo).toList();
    await memories.replaceAll([...ownMemories, ...created]);

    Memory byTitleDe(String titleDe) =>
        created[specs.indexWhere((s) => s.titleDe == titleDe)];

    final ownAlbums =
        (await albums.fetchAll()).where((a) => !a.isDemo).toList();

    await albums.replaceAll([
      ...ownAlbums,
      Album(
        id: _uuid.v4(),
        name: english ? 'Summer by the water' : 'Sommer am Wasser',
        description: english
            ? 'Everything that smelled of salt and sunscreen.'
            : 'Alles, was nach Salz und Sonnencreme gerochen hat.',
        memoryIds: [
          byTitleDe('Ein perfekter Abend am See').id,
          byTitleDe('Erster Sprung ins Meer').id,
          byTitleDe('Lagerfeuer bis spät').id,
        ],
        createdAt: now.subtract(const Duration(days: 40)),
        isDemo: true,
      ),
      Album(
        id: _uuid.v4(),
        name: english ? 'Quiet moments' : 'Ruhige Momente',
        description: english
            ? 'Days on which nothing happened - and that was the point.'
            : 'Tage, an denen nichts passiert ist. Und genau das war schön.',
        memoryIds: [
          byTitleDe('Regen am Fenster').id,
          byTitleDe('Der erste Schnee').id,
          byTitleDe('Im Tannenwald verlaufen').id,
          byTitleDe('Blumenwiese im Frühling').id,
        ],
        createdAt: now.subtract(const Duration(days: 12)),
        isDemo: true,
      ),
    ]);
  }
}

/// Bauplan fuer eine Beispiel-Erinnerung in beiden Sprachen.
class _DemoSpec {
  const _DemoSpec({
    required this.titleDe,
    required this.titleEn,
    required this.storyDe,
    required this.storyEn,
    required this.placeDe,
    required this.placeEn,
    required this.people,
    required this.scene,
    required this.feeling,
    required this.scent,
    required this.happenedAt,
    this.soundDe,
    this.soundEn,
    this.ambience,
    this.favorite = false,
  });

  final String titleDe;
  final String titleEn;
  final String storyDe;
  final String storyEn;
  final String placeDe;
  final String placeEn;
  final List<String> people;
  final CoverScene scene;
  final Feeling feeling;
  final ScentKind scent;
  final DateTime happenedAt;
  final String? soundDe;
  final String? soundEn;
  final Ambience? ambience;
  final bool favorite;

  Future<Memory> build({
    required MediaStore media,
    required bool english,
  }) async {
    SoundClip? clip;
    if (ambience != null) {
      const seconds = 5.0;
      final bytes = AmbienceSynth.build(ambience!, seconds: seconds);
      final stored = await media.save(
        bytes,
        extension: 'wav',
        mimeType: 'audio/wav',
        durationMs: (seconds * 1000).round(),
      );
      clip = SoundClip(
        media: stored,
        label: english ? soundEn : soundDe,
      );
    }

    return Memory(
      id: DemoData._uuid.v4(),
      title: english ? titleEn : titleDe,
      story: english ? storyEn : storyDe,
      place: english ? placeEn : placeDe,
      people: people,
      happenedAt: happenedAt,
      createdAt: happenedAt,
      feeling: feeling,
      coverScene: scene,
      scent: Scent(kind: scent, intensity: ScentIntensity.clear),
      sound: clip,
      isFavorite: favorite,
      syncState: SyncState.synced,
      isDemo: true,
    );
  }
}
