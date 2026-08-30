import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Der lokale Speicher von Momento.
///
/// Alles liegt als JSON auf dem Geraet (Android/iOS) bzw. im Browserspeicher
/// (Web). Wir nutzen bewusst nur eine sehr kleine Schnittstelle - so laesst
/// sich spaeter eine Cloud-Datenbank dahinter haengen, ohne dass die App
/// darueber etwas wissen muss.
class LocalDatabase {
  LocalDatabase._(this._prefs);

  final SharedPreferences _prefs;

  static const _prefix = 'momento.';

  static Future<LocalDatabase> open() async =>
      LocalDatabase._(await SharedPreferences.getInstance());

  // --- Listen ------------------------------------------------------------

  List<Map<String, dynamic>> readList(String key) {
    final raw = _prefs.getString('$_prefix$key');
    if (raw == null || raw.isEmpty) return [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return [];
      return decoded
          .whereType<Map>()
          .map((e) => e.cast<String, dynamic>())
          .toList();
    } on FormatException {
      // Kaputte Daten sollen die App nicht blockieren.
      return [];
    }
  }

  Future<void> writeList(String key, List<Map<String, dynamic>> value) =>
      _prefs.setString('$_prefix$key', jsonEncode(value));

  // --- Einzelne Objekte --------------------------------------------------

  Map<String, dynamic>? readObject(String key) {
    final raw = _prefs.getString('$_prefix$key');
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      return decoded is Map ? decoded.cast<String, dynamic>() : null;
    } on FormatException {
      return null;
    }
  }

  Future<void> writeObject(String key, Map<String, dynamic>? value) async {
    if (value == null) {
      await _prefs.remove('$_prefix$key');
    } else {
      await _prefs.setString('$_prefix$key', jsonEncode(value));
    }
  }

  // --- Einfache Werte ----------------------------------------------------

  String? readString(String key) => _prefs.getString('$_prefix$key');

  Future<void> writeString(String key, String? value) async {
    if (value == null) {
      await _prefs.remove('$_prefix$key');
    } else {
      await _prefs.setString('$_prefix$key', value);
    }
  }

  bool readBool(String key, {bool fallback = false}) =>
      _prefs.getBool('$_prefix$key') ?? fallback;

  Future<void> writeBool(String key, bool value) =>
      _prefs.setBool('$_prefix$key', value);

  Future<void> remove(String key) => _prefs.remove('$_prefix$key');
}

/// Alle Schluessel an einem Ort, damit sich keine Tippfehler einschleichen.
abstract final class DbKeys {
  static const users = 'users';
  static const session = 'session';
  static const memories = 'memories';
  static const albums = 'albums';
  static const themeMode = 'themeMode';
  static const language = 'language';
  static const onboardingDone = 'onboardingDone';
  static const demoSeeded = 'demoSeeded';
  static const lastSync = 'lastSync';
}
