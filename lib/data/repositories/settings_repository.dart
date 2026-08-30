import 'package:flutter/material.dart';

import '../local/local_database.dart';

/// Die Einstellungen aus dem Menue: Light-/Dark-Mode und Sprache
/// (Businessplan, Kapitel 7.2).
class MomentoSettings {
  const MomentoSettings({
    this.themeMode = ThemeMode.system,
    this.locale,
    this.onboardingDone = false,
    this.demoSeeded = false,
    this.lastSync,
  });

  final ThemeMode themeMode;

  /// `null` bedeutet: Sprache des Geraets uebernehmen.
  final Locale? locale;

  final bool onboardingDone;
  final bool demoSeeded;
  final DateTime? lastSync;

  MomentoSettings copyWith({
    ThemeMode? themeMode,
    Locale? locale,
    bool? onboardingDone,
    bool? demoSeeded,
    DateTime? lastSync,
    bool clearLocale = false,
  }) =>
      MomentoSettings(
        themeMode: themeMode ?? this.themeMode,
        locale: clearLocale ? null : (locale ?? this.locale),
        onboardingDone: onboardingDone ?? this.onboardingDone,
        demoSeeded: demoSeeded ?? this.demoSeeded,
        lastSync: lastSync ?? this.lastSync,
      );
}

abstract interface class SettingsRepository {
  Future<MomentoSettings> load();
  Future<void> save(MomentoSettings settings);
}

class LocalSettingsRepository implements SettingsRepository {
  LocalSettingsRepository(this._db);

  final LocalDatabase _db;

  @override
  Future<MomentoSettings> load() async {
    final lastSyncRaw = _db.readString(DbKeys.lastSync);
    return MomentoSettings(
      themeMode: switch (_db.readString(DbKeys.themeMode)) {
        'light' => ThemeMode.light,
        'dark' => ThemeMode.dark,
        _ => ThemeMode.system,
      },
      locale: switch (_db.readString(DbKeys.language)) {
        'de' => const Locale('de'),
        'en' => const Locale('en'),
        _ => null,
      },
      onboardingDone: _db.readBool(DbKeys.onboardingDone),
      demoSeeded: _db.readBool(DbKeys.demoSeeded),
      lastSync: lastSyncRaw == null ? null : DateTime.tryParse(lastSyncRaw),
    );
  }

  @override
  Future<void> save(MomentoSettings settings) async {
    await _db.writeString(DbKeys.themeMode, settings.themeMode.name);
    await _db.writeString(DbKeys.language, settings.locale?.languageCode);
    await _db.writeBool(DbKeys.onboardingDone, settings.onboardingDone);
    await _db.writeBool(DbKeys.demoSeeded, settings.demoSeeded);
    await _db.writeString(
      DbKeys.lastSync,
      settings.lastSync?.toIso8601String(),
    );
  }
}
