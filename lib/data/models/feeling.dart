import 'package:flutter/material.dart';

import '../../core/l10n/app_texts.dart';

/// Die Gefuehle, die der Businessplan der Marke zuschreibt (Kapitel 7.1):
/// Nostalgie, Glueck, Freude, Spass, Liebe und das Gefuehl, lebendig zu sein.
enum Feeling {
  joy('joy', '\u{1F604}', Color(0xFFF5B461)),
  nostalgia('nostalgia', '\u{1F30C}', Color(0xFFB98BE0)),
  love('love', '\u{1F49C}', Color(0xFFF08CB4)),
  calm('calm', '\u{1F343}', Color(0xFF7FC5A8)),
  excitement('excitement', '\u{2728}', Color(0xFFF29B7E)),
  gratitude('gratitude', '\u{1F64F}', Color(0xFFE0A6C8)),
  wistful('wistful', '\u{1F642}', Color(0xFF9DA8DE)),
  proud('proud', '\u{1F31F}', Color(0xFFE8C05A));

  const Feeling(this.id, this.emoji, this.color);

  final String id;
  final String emoji;
  final Color color;

  String label(AppTexts t) => switch (this) {
        Feeling.joy => t.feelingJoy,
        Feeling.nostalgia => t.feelingNostalgia,
        Feeling.love => t.feelingLove,
        Feeling.calm => t.feelingCalm,
        Feeling.excitement => t.feelingExcitement,
        Feeling.gratitude => t.feelingGratitude,
        Feeling.wistful => t.feelingWistful,
        Feeling.proud => t.feelingProud,
      };

  /// Alle Woerter, unter denen dieses Gefuehl gefunden werden soll.
  List<String> get searchTerms => switch (this) {
        Feeling.joy => ['freude', 'glueck', 'glück', 'gluecklich', 'lachen', 'spass', 'spaß', 'joy', 'happy', 'fun', 'laugh'],
        Feeling.nostalgia => ['nostalgie', 'nostalgisch', 'frueher', 'früher', 'damals', 'nostalgia', 'back then'],
        Feeling.love => ['liebe', 'verliebt', 'herz', 'love', 'in love', 'heart'],
        Feeling.calm => ['ruhe', 'ruhig', 'entspannt', 'frieden', 'calm', 'quiet', 'peaceful', 'relaxed'],
        Feeling.excitement => ['aufregung', 'aufregend', 'abenteuer', 'excitement', 'exciting', 'adventure'],
        Feeling.gratitude => ['dankbar', 'dankbarkeit', 'gratitude', 'thankful', 'grateful'],
        Feeling.wistful => ['wehmut', 'wehmuetig', 'wehmütig', 'vermissen', 'wistful', 'bittersweet', 'miss'],
        Feeling.proud => ['stolz', 'erfolg', 'geschafft', 'proud', 'pride', 'achievement'],
      };

  static Feeling? byId(String? id) {
    if (id == null) return null;
    for (final f in Feeling.values) {
      if (f.id == id) return f;
    }
    return null;
  }
}
