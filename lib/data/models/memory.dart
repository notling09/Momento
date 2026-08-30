import 'feeling.dart';
import 'scent.dart';
import 'stored_media.dart';

/// Zustand einer Erinnerung in der Warteschlange (Knopf "Synchronisieren").
enum SyncState {
  pending,
  synced,
  failed;

  static SyncState byId(String? id) => switch (id) {
        'synced' => SyncState.synced,
        'failed' => SyncState.failed,
        _ => SyncState.pending,
      };
}

/// Gezeichnete Titelbilder fuer Erinnerungen ohne eigenes Foto.
///
/// Die Bilder werden zur Laufzeit gemalt (siehe `widgets/scene_cover.dart`),
/// damit die App klein bleibt und in jeder Aufloesung scharf ist.
enum CoverScene {
  lakeSunset('lakeSunset'),
  beach('beach'),
  mountains('mountains'),
  cityNight('cityNight'),
  forest('forest'),
  snowfall('snowfall'),
  celebration('celebration'),
  rainWindow('rainWindow'),
  autumnPark('autumnPark'),
  springMeadow('springMeadow');

  const CoverScene(this.id);
  final String id;

  static CoverScene? byId(String? id) {
    if (id == null) return null;
    for (final s in CoverScene.values) {
      if (s.id == id) return s;
    }
    return null;
  }

  /// Vorschlag fuer eine neue Erinnerung: passend zu Jahreszeit und Tageszeit.
  ///
  /// Wer abends im Herbst etwas festhaelt, bekommt zuerst den Sonnenuntergang
  /// bzw. den Herbstpark angeboten - aendern laesst sich das mit einem Tipp.
  static CoverScene suggestFor(DateTime moment) {
    if (moment.hour >= 22 || moment.hour < 5) return CoverScene.cityNight;
    if (moment.hour >= 18) return CoverScene.lakeSunset;
    return switch (moment.month) {
      12 || 1 || 2 => CoverScene.snowfall,
      3 || 4 || 5 => CoverScene.springMeadow,
      6 || 7 || 8 => CoverScene.beach,
      _ => CoverScene.autumnPark,
    };
  }

  /// Wenn eine Erinnerung weder Foto noch Szene hat, waehlen wir anhand der
  /// Id eine feste Szene - so bleibt das Titelbild bei jedem Start gleich.
  static CoverScene stableFor(String seed) {
    var hash = 0;
    for (final unit in seed.codeUnits) {
      hash = (hash * 31 + unit) & 0x7FFFFFFF;
    }
    return CoverScene.values[hash % CoverScene.values.length];
  }
}

/// Eine aufgenommene Tonspur mit Beschreibung.
class SoundClip {
  const SoundClip({required this.media, this.label});

  final StoredMedia media;
  final String? label;

  Duration? get duration => media.duration;

  SoundClip copyWith({StoredMedia? media, String? label}) =>
      SoundClip(media: media ?? this.media, label: label ?? this.label);

  Map<String, dynamic> toJson() => {
        'media': media.toJson(),
        if (label != null) 'label': label,
      };

  static SoundClip? fromJson(Map<String, dynamic>? json) {
    if (json == null) return null;
    final media = StoredMedia.fromJson(
      (json['media'] as Map?)?.cast<String, dynamic>(),
    );
    if (media == null) return null;
    return SoundClip(media: media, label: json['label'] as String?);
  }
}

/// Eine Erinnerung - das Herzstueck von Momento.
class Memory {
  const Memory({
    required this.id,
    required this.title,
    required this.happenedAt,
    required this.createdAt,
    this.story = '',
    this.place,
    this.people = const [],
    this.feeling,
    this.photo,
    this.coverScene,
    this.scent,
    this.sound,
    this.isFavorite = false,
    this.syncState = SyncState.pending,
    this.isDemo = false,
  });

  final String id;
  final String title;
  final String story;
  final String? place;
  final List<String> people;
  final DateTime happenedAt;
  final DateTime createdAt;
  final Feeling? feeling;
  final StoredMedia? photo;
  final CoverScene? coverScene;
  final Scent? scent;
  final SoundClip? sound;
  final bool isFavorite;
  final SyncState syncState;

  /// Beispiel-Erinnerungen lassen sich damit spaeter gezielt entfernen.
  final bool isDemo;

  bool get hasPhoto => photo != null && photo!.isNotEmpty;
  bool get hasScent => scent != null && !scent!.isEmpty;
  bool get hasSound => sound != null && sound!.media.isNotEmpty;

  CoverScene get effectiveScene => coverScene ?? CoverScene.stableFor(id);

  /// Wie viele volle Jahre ist der Moment an [reference] her?
  /// Gibt `null` zurueck, wenn heute nicht der Jahrestag ist.
  int? anniversaryYears(DateTime reference) {
    if (happenedAt.month != reference.month || happenedAt.day != reference.day) {
      return null;
    }
    final years = reference.year - happenedAt.year;
    return years >= 1 ? years : null;
  }

  Memory copyWith({
    String? title,
    String? story,
    String? place,
    List<String>? people,
    DateTime? happenedAt,
    Feeling? feeling,
    StoredMedia? photo,
    CoverScene? coverScene,
    Scent? scent,
    SoundClip? sound,
    bool? isFavorite,
    SyncState? syncState,
    bool clearFeeling = false,
    bool clearPhoto = false,
    bool clearScent = false,
    bool clearSound = false,
    bool clearPlace = false,
  }) =>
      Memory(
        id: id,
        title: title ?? this.title,
        story: story ?? this.story,
        place: clearPlace ? null : (place ?? this.place),
        people: people ?? this.people,
        happenedAt: happenedAt ?? this.happenedAt,
        createdAt: createdAt,
        feeling: clearFeeling ? null : (feeling ?? this.feeling),
        photo: clearPhoto ? null : (photo ?? this.photo),
        coverScene: coverScene ?? this.coverScene,
        scent: clearScent ? null : (scent ?? this.scent),
        sound: clearSound ? null : (sound ?? this.sound),
        isFavorite: isFavorite ?? this.isFavorite,
        syncState: syncState ?? this.syncState,
        isDemo: isDemo,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'story': story,
        if (place != null) 'place': place,
        'people': people,
        'happenedAt': happenedAt.toIso8601String(),
        'createdAt': createdAt.toIso8601String(),
        if (feeling != null) 'feeling': feeling!.id,
        if (photo != null) 'photo': photo!.toJson(),
        if (coverScene != null) 'scene': coverScene!.id,
        if (scent != null) 'scent': scent!.toJson(),
        if (sound != null) 'sound': sound!.toJson(),
        'favorite': isFavorite,
        'sync': syncState.name,
        'demo': isDemo,
      };

  static Memory fromJson(Map<String, dynamic> json) => Memory(
        id: json['id'] as String,
        title: json['title'] as String? ?? '',
        story: json['story'] as String? ?? '',
        place: json['place'] as String?,
        people: (json['people'] as List?)?.cast<String>() ?? const [],
        happenedAt: DateTime.parse(json['happenedAt'] as String),
        createdAt: DateTime.parse(
          json['createdAt'] as String? ?? json['happenedAt'] as String,
        ),
        feeling: Feeling.byId(json['feeling'] as String?),
        photo: StoredMedia.fromJson((json['photo'] as Map?)?.cast<String, dynamic>()),
        coverScene: CoverScene.byId(json['scene'] as String?),
        scent: Scent.fromJson((json['scent'] as Map?)?.cast<String, dynamic>()),
        sound: SoundClip.fromJson((json['sound'] as Map?)?.cast<String, dynamic>()),
        isFavorite: json['favorite'] as bool? ?? false,
        syncState: SyncState.byId(json['sync'] as String?),
        isDemo: json['demo'] as bool? ?? false,
      );
}
