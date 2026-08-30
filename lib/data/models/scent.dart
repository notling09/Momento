import 'package:flutter/material.dart';

import '../../core/l10n/app_texts.dart';

/// Eine kuratierte Duftpalette.
///
/// Ein Handy kann Geruch nicht messen - deshalb waehlt man den Duft aus oder
/// beschreibt ihn selbst. Jeder Duft hat ein Symbol und eine Farbe, damit die
/// Erinnerung auch optisch danach riecht.
enum ScentKind {
  seaBreeze('seaBreeze', '\u{1F30A}', Color(0xFF7EC4D8)),
  sunscreen('sunscreen', '\u{1F9F4}', Color(0xFFF6C177)),
  rainOnAsphalt('rainOnAsphalt', '\u{1F327}', Color(0xFF9AA7C7)),
  freshBread('freshBread', '\u{1F956}', Color(0xFFDDA867)),
  pineForest('pineForest', '\u{1F332}', Color(0xFF7FB48B)),
  campfire('campfire', '\u{1F525}', Color(0xFFE2864F)),
  coffee('coffee', '\u{2615}', Color(0xFFB08163)),
  freshLaundry('freshLaundry', '\u{1F455}', Color(0xFF9EC5E8)),
  cutGrass('cutGrass', '\u{1F33F}', Color(0xFF95C46B)),
  vanilla('vanilla', '\u{1F366}', Color(0xFFEED9A8)),
  cinnamon('cinnamon', '\u{1F36A}', Color(0xFFC98A5E)),
  oldBooks('oldBooks', '\u{1F4DA}', Color(0xFFB99C86)),
  grandmasHome('grandmasHome', '\u{1F3E1}', Color(0xFFD8A7BC)),
  snowAir('snowAir', '\u{2744}', Color(0xFFA8C8E8)),
  flowerMeadow('flowerMeadow', '\u{1F338}', Color(0xFFEFA3C4)),
  citrus('citrus', '\u{1F34B}', Color(0xFFEBC85C));

  const ScentKind(this.id, this.emoji, this.color);

  final String id;
  final String emoji;
  final Color color;

  String label(AppTexts t) => switch (this) {
        ScentKind.seaBreeze => t.scentSeaBreeze,
        ScentKind.sunscreen => t.scentSunscreen,
        ScentKind.rainOnAsphalt => t.scentRainOnAsphalt,
        ScentKind.freshBread => t.scentFreshBread,
        ScentKind.pineForest => t.scentPineForest,
        ScentKind.campfire => t.scentCampfire,
        ScentKind.coffee => t.scentCoffee,
        ScentKind.freshLaundry => t.scentFreshLaundry,
        ScentKind.cutGrass => t.scentCutGrass,
        ScentKind.vanilla => t.scentVanilla,
        ScentKind.cinnamon => t.scentCinnamon,
        ScentKind.oldBooks => t.scentOldBooks,
        ScentKind.grandmasHome => t.scentGrandmasHome,
        ScentKind.snowAir => t.scentSnowAir,
        ScentKind.flowerMeadow => t.scentFlowerMeadow,
        ScentKind.citrus => t.scentCitrus,
      };

  /// Suchbegriffe in beiden Sprachen, damit die Suche Duefte auch dann
  /// findet, wenn die App gerade in der anderen Sprache laeuft.
  List<String> get searchTerms => switch (this) {
        ScentKind.seaBreeze => ['seebrise', 'meer', 'salz', 'see', 'strand', 'ozean', 'sea', 'ocean', 'salt', 'beach', 'breeze'],
        ScentKind.sunscreen => ['sonnencreme', 'sonnenmilch', 'sommer', 'ferien', 'sunscreen', 'suncream', 'summer', 'holiday'],
        ScentKind.rainOnAsphalt => ['regen', 'asphalt', 'gewitter', 'nass', 'petrichor', 'rain', 'storm', 'wet'],
        ScentKind.freshBread => ['brot', 'baeckerei', 'bäckerei', 'backen', 'bread', 'bakery', 'baking'],
        ScentKind.pineForest => ['tanne', 'wald', 'harz', 'nadeln', 'pine', 'forest', 'woods', 'resin'],
        ScentKind.campfire => ['lagerfeuer', 'feuer', 'rauch', 'holz', 'campfire', 'fire', 'smoke', 'wood'],
        ScentKind.coffee => ['kaffee', 'espresso', 'cafe', 'coffee'],
        ScentKind.freshLaundry => ['waesche', 'wäsche', 'frisch', 'weichspueler', 'laundry', 'fresh', 'clean'],
        ScentKind.cutGrass => ['gras', 'wiese', 'rasen', 'gemaeht', 'grass', 'lawn', 'meadow'],
        ScentKind.vanilla => ['vanille', 'suess', 'süss', 'glace', 'eis', 'vanilla', 'sweet', 'ice cream'],
        ScentKind.cinnamon => ['zimt', 'weihnachten', 'guetzli', 'cinnamon', 'christmas', 'cookies'],
        ScentKind.oldBooks => ['buecher', 'bücher', 'bibliothek', 'papier', 'books', 'library', 'paper'],
        ScentKind.grandmasHome => ['grossmutter', 'grossmama', 'oma', 'zuhause', 'kindheit', 'grandma', 'grandmother', 'home', 'childhood'],
        ScentKind.snowAir => ['schnee', 'winter', 'kalt', 'frost', 'snow', 'cold'],
        ScentKind.flowerMeadow => ['blumen', 'wiese', 'fruehling', 'frühling', 'bluete', 'blüte', 'flowers', 'spring', 'blossom'],
        ScentKind.citrus => ['zitrone', 'orange', 'zitrus', 'frisch', 'lemon', 'citrus', 'orange'],
      };

  static ScentKind? byId(String? id) {
    if (id == null) return null;
    for (final s in ScentKind.values) {
      if (s.id == id) return s;
    }
    return null;
  }
}

/// Wie stark war der Duft?
enum ScentIntensity {
  light(1),
  clear(2),
  intense(3);

  const ScentIntensity(this.level);
  final int level;

  String label(AppTexts t) => switch (this) {
        ScentIntensity.light => t.intensityLight,
        ScentIntensity.clear => t.intensityClear,
        ScentIntensity.intense => t.intensityIntense,
      };

  static ScentIntensity fromLevel(int? level) => switch (level) {
        1 => ScentIntensity.light,
        3 => ScentIntensity.intense,
        _ => ScentIntensity.clear,
      };
}

/// Der Duft einer Erinnerung: entweder aus der Palette oder frei beschrieben.
class Scent {
  const Scent({
    this.kind,
    this.customLabel,
    this.intensity = ScentIntensity.clear,
  });

  final ScentKind? kind;
  final String? customLabel;
  final ScentIntensity intensity;

  bool get isEmpty => kind == null && (customLabel == null || customLabel!.trim().isEmpty);

  String get emoji => kind?.emoji ?? '\u{1F338}';

  Color get color => kind?.color ?? const Color(0xFFB98BE0);

  String label(AppTexts t) {
    final custom = customLabel?.trim();
    if (custom != null && custom.isNotEmpty) return custom;
    return kind?.label(t) ?? t.scentNone;
  }

  /// Text, den die Suche durchforstet.
  String get searchableText {
    final parts = <String>[
      if (customLabel != null) customLabel!,
      if (kind != null) ...kind!.searchTerms,
    ];
    return parts.join(' ');
  }

  Scent copyWith({
    ScentKind? kind,
    String? customLabel,
    ScentIntensity? intensity,
    bool clearKind = false,
    bool clearCustom = false,
  }) =>
      Scent(
        kind: clearKind ? null : (kind ?? this.kind),
        customLabel: clearCustom ? null : (customLabel ?? this.customLabel),
        intensity: intensity ?? this.intensity,
      );

  Map<String, dynamic> toJson() => {
        if (kind != null) 'kind': kind!.id,
        if (customLabel != null) 'custom': customLabel,
        'intensity': intensity.level,
      };

  static Scent? fromJson(Map<String, dynamic>? json) {
    if (json == null) return null;
    final scent = Scent(
      kind: ScentKind.byId(json['kind'] as String?),
      customLabel: json['custom'] as String?,
      intensity: ScentIntensity.fromLevel((json['intensity'] as num?)?.toInt()),
    );
    return scent.isEmpty ? null : scent;
  }
}
