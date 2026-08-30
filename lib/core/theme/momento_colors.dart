import 'package:flutter/material.dart';

/// Die Markenfarben von Momento.
///
/// Aus dem Businessplan (Kapitel 7.2 / 9.2): pastellartige Toene von Orange,
/// Rosa und Violett. Die Werte sind direkt aus dem Logo und dem Konzeptbild
/// der Startseite abgelesen.
abstract final class MomentoColors {
  // --- Markenverlauf: Orange -> Rosa -> Violett ---------------------------
  static const peach = Color(0xFFFFC59B);
  static const apricot = Color(0xFFFBAF9F);
  static const blush = Color(0xFFF7A3BE);
  static const rose = Color(0xFFF08CB4);
  static const orchid = Color(0xFFD79BE0);
  static const violet = Color(0xFFB98BE0);
  static const plum = Color(0xFF9A6FD1);

  /// Kraeftigeres Violett fuer Text und Icons, das auf Weiss lesbar bleibt.
  static const plumInk = Color(0xFF7A54B0);

  /// Warmes Dunkelviolett statt Schwarz - passt zur nostalgischen Stimmung.
  static const ink = Color(0xFF3D3247);
  static const inkSoft = Color(0xFF6B5F77);

  // --- Helle Oberflaeche --------------------------------------------------
  static const lightBackground = Color(0xFFFFF9FB);
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightSurfaceMuted = Color(0xFFFDF1F6);
  static const lightOutline = Color(0xFFF1DFE8);

  // --- Dunkle Oberflaeche -------------------------------------------------
  static const darkBackground = Color(0xFF17121D);
  static const darkSurface = Color(0xFF221B2B);
  static const darkSurfaceMuted = Color(0xFF2C2338);
  static const darkOutline = Color(0xFF3A2F49);
  static const darkInk = Color(0xFFF3EAF6);
  static const darkInkSoft = Color(0xFFB6A7C2);

  // --- Signalfarben -------------------------------------------------------
  static const success = Color(0xFF64B79A);
  static const warning = Color(0xFFE8A33D);
  static const danger = Color(0xFFE0708A);

  /// Die drei Bausteine einer Erinnerung haben je eine eigene Farbe.
  static const memoryAccent = rose;
  static const scentAccent = violet;
  static const soundAccent = Color(0xFFF0A96B);
}

/// Fertige Farbverlaeufe, damit der Look ueberall identisch ist.
abstract final class MomentoGradients {
  /// Der grosse Header-Verlauf von der Startseite (Abbildung 1).
  static const header = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      MomentoColors.peach,
      MomentoColors.blush,
      MomentoColors.orchid,
    ],
    stops: [0.0, 0.55, 1.0],
  );

  /// Kompakter Verlauf fuer Buttons und den Sync-Knopf.
  static const action = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [MomentoColors.blush, MomentoColors.violet],
  );

  /// Sanfter Verlauf fuer Karten auf hellem Grund.
  static const softCard = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFE3CE), Color(0xFFF6C7E4), Color(0xFFDFC4F2)],
  );

  /// Dieselbe Karte, aber abgestimmt auf den Dark-Mode.
  static const softCardDark = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF4A3550), Color(0xFF503354), Color(0xFF3E2F55)],
  );

  static LinearGradient softCardFor(Brightness brightness) =>
      brightness == Brightness.dark ? softCardDark : softCard;
}
