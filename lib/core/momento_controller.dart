import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../data/local/demo_data.dart';
import '../data/local/local_database.dart';
import '../data/local/media_store.dart';
import '../data/models/album.dart';
import '../data/models/app_user.dart';
import '../data/models/memory.dart';
import '../data/models/stored_media.dart';
import '../data/repositories/album_repository.dart';
import '../data/repositories/auth_repository.dart';
import '../data/repositories/memory_repository.dart';
import '../data/repositories/settings_repository.dart';

/// Haelt den gesamten Zustand von Momento zusammen.
///
/// Die Bildschirme sprechen nie direkt mit dem Speicher, sondern immer ueber
/// diesen Controller. Dadurch bleibt genau eine Stelle uebrig, an der spaeter
/// eine Cloud angebunden werden muesste.
class MomentoController extends ChangeNotifier {
  MomentoController._({
    required MemoryRepository memories,
    required AlbumRepository albums,
    required AuthRepository auth,
    required SettingsRepository settings,
    required MediaStore media,
  })  : _memoryRepository = memories,
        _albumRepository = albums,
        _authRepository = auth,
        _settingsRepository = settings,
        _mediaStore = media;

  final MemoryRepository _memoryRepository;
  final AlbumRepository _albumRepository;
  final AuthRepository _authRepository;
  final SettingsRepository _settingsRepository;
  final MediaStore _mediaStore;

  static const _uuid = Uuid();

  MomentoSettings _settings = const MomentoSettings();
  AppUser? _user;
  List<Memory> _memories = const [];
  List<Album> _albums = const [];
  bool _ready = false;
  bool _syncing = false;

  MomentoSettings get settings => _settings;
  AppUser? get user => _user;
  List<Memory> get memories => _memories;
  List<Album> get albums => _albums;
  bool get isReady => _ready;
  bool get isSyncing => _syncing;
  bool get isSignedIn => _user != null;
  MediaStore get mediaStore => _mediaStore;

  /// Baut alle Bausteine auf und laedt den gespeicherten Zustand.
  static Future<MomentoController> bootstrap() async {
    final db = await LocalDatabase.open();
    final media = await MediaStore.open();
    final controller = MomentoController._(
      memories: LocalMemoryRepository(db),
      albums: LocalAlbumRepository(db),
      auth: LocalAuthRepository(db),
      settings: LocalSettingsRepository(db),
      media: media,
    );
    await controller._load();
    return controller;
  }

  /// Momento gibt es auf Deutsch und Englisch. Beim allerersten Start waehlen
  /// wir anhand der Geraetesprache: Deutsch, wenn das Geraet auf Deutsch
  /// steht, sonst Englisch. Danach entscheidet immer die Einstellung in der
  /// App - so landet niemand mit portugiesischem Handy in einer Sprache, die
  /// es hier gar nicht gibt.
  static Locale localeForSystem(String systemLanguageCode) =>
      systemLanguageCode == 'de' ? const Locale('de') : const Locale('en');

  Future<void> _load() async {
    _settings = await _settingsRepository.load();
    _user = await _authRepository.currentUser();

    if (_settings.locale == null) {
      _settings = _settings.copyWith(
        locale: localeForSystem(
          WidgetsBinding.instance.platformDispatcher.locale.languageCode,
        ),
      );
      await _settingsRepository.save(_settings);
    }

    if (!_settings.demoSeeded) {
      await _seedDemo(persistFlag: true);
    }

    _memories = await _memoryRepository.fetchAll();
    _albums = await _albumRepository.fetchAll();
    _ready = true;
    notifyListeners();
  }

  Future<void> _refresh() async {
    _memories = await _memoryRepository.fetchAll();
    _albums = await _albumRepository.fetchAll();
    notifyListeners();
  }

  Future<void> _persistSettings(MomentoSettings next) async {
    _settings = next;
    await _settingsRepository.save(next);
    notifyListeners();
  }

  // --- Anmeldung ---------------------------------------------------------

  Future<void> register({
    required String email,
    required String password,
    required String displayName,
  }) async {
    _user = await _authRepository.register(
      email: email,
      password: password,
      displayName: displayName,
    );
    notifyListeners();
  }

  Future<void> signIn({required String email, required String password}) async {
    _user = await _authRepository.signIn(email: email, password: password);
    notifyListeners();
  }

  Future<void> signOut() async {
    await _authRepository.signOut();
    _user = null;
    notifyListeners();
  }

  Future<void> updateProfile({
    String? displayName,
    DateTime? birthday,
    bool clearBirthday = false,
    StoredMedia? avatar,
    bool clearAvatar = false,
  }) async {
    final current = _user;
    if (current == null) return;
    if (clearAvatar) await _mediaStore.delete(current.avatar);
    final updated = current.copyWith(
      displayName: displayName,
      birthday: birthday,
      clearBirthday: clearBirthday,
      avatar: avatar,
      clearAvatar: clearAvatar,
    );
    _user = await _authRepository.updateProfile(updated);
    notifyListeners();
  }

  // --- Einstellungen -----------------------------------------------------

  Future<void> setThemeMode(ThemeMode mode) =>
      _persistSettings(_settings.copyWith(themeMode: mode));

  Future<void> setLocale(Locale locale) =>
      _persistSettings(_settings.copyWith(locale: locale));

  Future<void> completeOnboarding() =>
      _persistSettings(_settings.copyWith(onboardingDone: true));

  // --- Erinnerungen ------------------------------------------------------

  Memory? memoryById(String id) {
    for (final memory in _memories) {
      if (memory.id == id) return memory;
    }
    return null;
  }

  /// Legt eine neue Erinnerung an. Sie startet als "wartet" und wandert damit
  /// in die Warteschlange unter dem Sync-Knopf.
  Future<Memory> createMemory(Memory draft) async {
    final memory = Memory(
      id: _uuid.v4(),
      title: draft.title,
      story: draft.story,
      place: draft.place,
      people: draft.people,
      happenedAt: draft.happenedAt,
      createdAt: DateTime.now(),
      feeling: draft.feeling,
      photo: draft.photo,
      coverScene: draft.coverScene,
      scent: draft.scent,
      sound: draft.sound,
      isFavorite: draft.isFavorite,
      syncState: SyncState.pending,
    );
    await _memoryRepository.upsert(memory);
    await _refresh();
    return memory;
  }

  Future<void> updateMemory(Memory memory) async {
    await _memoryRepository.upsert(
      memory.syncState == SyncState.synced
          ? memory.copyWith(syncState: SyncState.pending)
          : memory,
    );
    await _refresh();
  }

  Future<void> deleteMemory(String id) async {
    final memory = memoryById(id);
    if (memory != null) {
      await _mediaStore.delete(memory.photo);
      await _mediaStore.delete(memory.sound?.media);
    }
    await _memoryRepository.delete(id);

    // Die Erinnerung auch aus allen Alben nehmen.
    final updatedAlbums = <Album>[];
    for (final album in _albums) {
      if (album.memoryIds.contains(id)) {
        updatedAlbums.add(album.copyWith(
          memoryIds: album.memoryIds.where((m) => m != id).toList(),
        ));
      } else {
        updatedAlbums.add(album);
      }
    }
    await _albumRepository.replaceAll(updatedAlbums);
    await _refresh();
  }

  Future<void> toggleFavorite(String id) async {
    final memory = memoryById(id);
    if (memory == null) return;
    await _memoryRepository.upsert(
      memory.copyWith(isFavorite: !memory.isFavorite),
    );
    await _refresh();
  }

  /// Speichert Bild- oder Tondaten und gibt die Referenz zurueck.
  Future<StoredMedia> storeMedia(
    Uint8List bytes, {
    required String extension,
    String? mimeType,
    int? durationMs,
  }) =>
      _mediaStore.save(
        bytes,
        extension: extension,
        mimeType: mimeType,
        durationMs: durationMs,
      );

  // --- Alben -------------------------------------------------------------

  Album? albumById(String id) {
    for (final album in _albums) {
      if (album.id == id) return album;
    }
    return null;
  }

  List<Memory> memoriesOf(Album album) {
    final byId = {for (final memory in _memories) memory.id: memory};
    return album.memoryIds
        .map((id) => byId[id])
        .whereType<Memory>()
        .toList();
  }

  Future<Album> saveAlbum({
    String? id,
    required String name,
    required String description,
    required List<String> memoryIds,
  }) async {
    final album = Album(
      id: id ?? _uuid.v4(),
      name: name,
      description: description,
      memoryIds: memoryIds,
      createdAt: id == null
          ? DateTime.now()
          : (albumById(id)?.createdAt ?? DateTime.now()),
    );
    await _albumRepository.upsert(album);
    await _refresh();
    return album;
  }

  Future<void> deleteAlbum(String id) async {
    await _albumRepository.delete(id);
    await _refresh();
  }

  // --- Synchronisieren ---------------------------------------------------

  List<Memory> get pendingMemories =>
      _memories.where((m) => m.syncState != SyncState.synced).toList();

  /// Verarbeitet die Warteschlange.
  ///
  /// Heute passiert das lokal: jede wartende Erinnerung wird durchgegangen und
  /// als verarbeitet markiert. Genau an dieser Stelle wuerde spaeter der
  /// Upload zu einem Server stehen - der Rest der App bliebe gleich.
  Future<int> synchronise({
    void Function(int done, int total)? onProgress,
  }) async {
    if (_syncing) return 0;
    final pending = pendingMemories;
    if (pending.isEmpty) {
      await _persistSettings(_settings.copyWith(lastSync: DateTime.now()));
      return 0;
    }

    _syncing = true;
    notifyListeners();

    var done = 0;
    for (final memory in pending) {
      // Kurze Pause, damit der Fortschritt sichtbar ist.
      await Future<void>.delayed(const Duration(milliseconds: 260));
      await _memoryRepository.upsert(memory.copyWith(syncState: SyncState.synced));
      done++;
      onProgress?.call(done, pending.length);
      _memories = await _memoryRepository.fetchAll();
      notifyListeners();
    }

    _syncing = false;
    await _persistSettings(_settings.copyWith(lastSync: DateTime.now()));
    await _refresh();
    return done;
  }

  // --- Beispiel-Daten und Aufraeumen -------------------------------------

  bool get hasDemoData => _memories.any((m) => m.isDemo);

  Future<void> _seedDemo({required bool persistFlag}) async {
    await DemoData.seed(
      memories: _memoryRepository,
      albums: _albumRepository,
      media: _mediaStore,
      english: (_settings.locale?.languageCode ??
              WidgetsBinding.instance.platformDispatcher.locale.languageCode) ==
          'en',
    );
    if (persistFlag) {
      _settings = _settings.copyWith(demoSeeded: true);
      await _settingsRepository.save(_settings);
    }
  }

  Future<void> reloadDemoData() async {
    // Die Mediendateien der alten Beispiele aufraeumen, bevor neue entstehen.
    for (final memory in _memories.where((m) => m.isDemo)) {
      await _mediaStore.delete(memory.photo);
      await _mediaStore.delete(memory.sound?.media);
    }
    await _seedDemo(persistFlag: true);
    await _refresh();
  }

  Future<void> removeDemoData() async {
    final keptMemories = <Memory>[];
    for (final memory in _memories) {
      if (memory.isDemo) {
        await _mediaStore.delete(memory.photo);
        await _mediaStore.delete(memory.sound?.media);
      } else {
        keptMemories.add(memory);
      }
    }
    await _memoryRepository.replaceAll(keptMemories);

    final keptIds = keptMemories.map((m) => m.id).toSet();
    final keptAlbums = _albums
        .where((a) => !a.isDemo)
        .map((a) => a.copyWith(
              memoryIds: a.memoryIds.where(keptIds.contains).toList(),
            ))
        .toList();
    await _albumRepository.replaceAll(keptAlbums);
    await _refresh();
  }

  Future<void> deleteEverything() async {
    for (final memory in _memories) {
      await _mediaStore.delete(memory.photo);
      await _mediaStore.delete(memory.sound?.media);
    }
    await _memoryRepository.replaceAll(const []);
    await _albumRepository.replaceAll(const []);
    await _refresh();
  }
}

/// Stellt den Controller im Widget-Baum zur Verfuegung.
class AppScope extends InheritedNotifier<MomentoController> {
  const AppScope({
    super.key,
    required MomentoController controller,
    required super.child,
  }) : super(notifier: controller);

  static MomentoController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope fehlt ueber diesem Widget.');
    return scope!.notifier!;
  }

  /// Zugriff ohne Neuaufbau bei Aenderungen - fuer Aktionen in Callbacks.
  static MomentoController read(BuildContext context) {
    final scope = context.getInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope fehlt ueber diesem Widget.');
    return scope!.notifier!;
  }
}
