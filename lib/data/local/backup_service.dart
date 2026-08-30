import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';

import '../models/album.dart';
import '../models/memory.dart';
import '../models/stored_media.dart';
import '../repositories/album_repository.dart';
import '../repositories/memory_repository.dart';
import 'media_store.dart';

/// Ergebnis eines eingelesenen Sicherungsarchivs.
class BackupResult {
  const BackupResult({
    required this.memoriesAdded,
    required this.albumsAdded,
    required this.memoriesSkipped,
  });

  final int memoriesAdded;
  final int albumsAdded;

  /// Erinnerungen, die schon vorhanden waren und deshalb uebersprungen wurden.
  final int memoriesSkipped;
}

/// Wird geworfen, wenn die gewaehlte Datei keine Momento-Sicherung ist.
class InvalidBackupException implements Exception {
  const InvalidBackupException();
}

/// Erzeugt und liest Sicherungsdateien.
///
/// Eine Sicherung ist ein ZIP-Archiv:
///
///     momento.json      alle Erinnerungen und Alben
///     media/0001.jpg    die zugehoerigen Bilder
///     media/0002.wav    die zugehoerigen Tonaufnahmen
///
/// Die Medien liegen als echte Dateien im Archiv statt als Base64 im JSON.
/// Das haelt die Datei klein und man kann sie zur Not auch von Hand oeffnen.
class BackupService {
  BackupService({
    required MemoryRepository memories,
    required AlbumRepository albums,
    required MediaStore media,
  })  : _memories = memories,
        _albums = albums,
        _media = media;

  final MemoryRepository _memories;
  final AlbumRepository _albums;
  final MediaStore _media;

  static const _indexFile = 'momento.json';
  static const _mediaDir = 'media';
  static const _appMarker = 'momento';
  static const formatVersion = 1;

  /// Dateiname mit Datum, damit sich mehrere Sicherungen unterscheiden lassen.
  static String fileNameFor(DateTime moment) {
    String two(int value) => value.toString().padLeft(2, '0');
    return 'momento-sicherung-${moment.year}-${two(moment.month)}-${two(moment.day)}.zip';
  }

  // --- Erstellen ---------------------------------------------------------

  Future<Uint8List> create() async {
    final memories = await _memories.fetchAll();
    final albums = await _albums.fetchAll();

    final archive = Archive();
    var mediaCounter = 0;

    /// Legt ein Medium ins Archiv und gibt den Eintrag fuers JSON zurueck.
    Future<Map<String, dynamic>?> pack(StoredMedia? media) async {
      if (media == null || media.isEmpty) return null;
      final bytes = await _media.read(media);
      // Fehlt die Datei (z. B. von Hand geloescht), ueberspringen wir sie,
      // statt die ganze Sicherung scheitern zu lassen.
      if (bytes == null || bytes.isEmpty) return null;

      mediaCounter++;
      final name =
          '$_mediaDir/${mediaCounter.toString().padLeft(4, '0')}.${_extensionFor(media.mimeType)}';
      archive.addFile(ArchiveFile(name, bytes.length, bytes));

      return {
        'file': name,
        if (media.mimeType != null) 'mime': media.mimeType,
        if (media.durationMs != null) 'durationMs': media.durationMs,
      };
    }

    final memoryEntries = <Map<String, dynamic>>[];
    for (final memory in memories) {
      final json = memory.toJson();
      json['photo'] = await pack(memory.photo);
      json['sound'] = memory.hasSound
          ? {
              'media': await pack(memory.sound!.media),
              if (memory.sound!.label != null) 'label': memory.sound!.label,
            }
          : null;
      json.removeWhere((_, value) => value == null);
      memoryEntries.add(json);
    }

    final index = {
      'app': _appMarker,
      'formatVersion': formatVersion,
      'createdAt': DateTime.now().toIso8601String(),
      'memories': memoryEntries,
      'albums': albums.map((a) => a.toJson()).toList(),
    };

    final indexBytes = utf8.encode(jsonEncode(index));
    archive.addFile(ArchiveFile(_indexFile, indexBytes.length, indexBytes));

    final zip = ZipEncoder().encode(archive);
    return Uint8List.fromList(zip);
  }

  // --- Einlesen ----------------------------------------------------------

  /// Liest [zipBytes] ein.
  ///
  /// Bei [replaceExisting] wird alles Bisherige ersetzt, sonst kommen nur
  /// Erinnerungen dazu, die es noch nicht gibt.
  Future<BackupResult> restore(
    Uint8List zipBytes, {
    bool replaceExisting = false,
  }) async {
    final Archive archive;
    try {
      archive = ZipDecoder().decodeBytes(zipBytes);
    } catch (_) {
      throw const InvalidBackupException();
    }

    final indexEntry = _findFile(archive, _indexFile);
    if (indexEntry == null) throw const InvalidBackupException();

    final Map<String, dynamic> index;
    try {
      final decoded = jsonDecode(utf8.decode(indexEntry.content as List<int>));
      if (decoded is! Map) throw const InvalidBackupException();
      index = decoded.cast<String, dynamic>();
    } catch (_) {
      throw const InvalidBackupException();
    }

    if (index['app'] != _appMarker) throw const InvalidBackupException();

    /// Holt ein Medium aus dem Archiv und legt es im Gerätespeicher ab.
    Future<StoredMedia?> unpack(Map<String, dynamic>? entry) async {
      if (entry == null) return null;
      final name = entry['file'] as String?;
      if (name == null) return null;
      final file = _findFile(archive, name);
      if (file == null) return null;

      final mime = entry['mime'] as String?;
      return _media.save(
        Uint8List.fromList(file.content as List<int>),
        extension: _extensionFor(mime),
        mimeType: mime,
        durationMs: (entry['durationMs'] as num?)?.toInt(),
      );
    }

    final imported = <Memory>[];
    for (final raw in (index['memories'] as List? ?? const [])) {
      if (raw is! Map) continue;
      final json = raw.cast<String, dynamic>();

      final photo = await unpack((json['photo'] as Map?)?.cast<String, dynamic>());
      final soundRaw = (json['sound'] as Map?)?.cast<String, dynamic>();
      final soundMedia = await unpack(
        (soundRaw?['media'] as Map?)?.cast<String, dynamic>(),
      );

      json['photo'] = photo?.toJson();
      json['sound'] = soundMedia == null
          ? null
          : {
              'media': soundMedia.toJson(),
              if (soundRaw?['label'] != null) 'label': soundRaw!['label'],
            };
      json.removeWhere((_, value) => value == null);

      try {
        imported.add(Memory.fromJson(json));
      } catch (_) {
        // Einzelne unlesbare Eintraege ueberspringen.
      }
    }

    final importedAlbums = <Album>[];
    for (final raw in (index['albums'] as List? ?? const [])) {
      if (raw is! Map) continue;
      try {
        importedAlbums.add(Album.fromJson(raw.cast<String, dynamic>()));
      } catch (_) {
        // Ueberspringen.
      }
    }

    if (replaceExisting) {
      await _memories.replaceAll(imported);
      await _albums.replaceAll(importedAlbums);
      return BackupResult(
        memoriesAdded: imported.length,
        albumsAdded: importedAlbums.length,
        memoriesSkipped: 0,
      );
    }

    final existingMemories = await _memories.fetchAll();
    final existingIds = existingMemories.map((m) => m.id).toSet();
    final newMemories = imported.where((m) => !existingIds.contains(m.id)).toList();

    final existingAlbums = await _albums.fetchAll();
    final existingAlbumIds = existingAlbums.map((a) => a.id).toSet();
    final newAlbums =
        importedAlbums.where((a) => !existingAlbumIds.contains(a.id)).toList();

    await _memories.replaceAll([...existingMemories, ...newMemories]);
    await _albums.replaceAll([...existingAlbums, ...newAlbums]);

    return BackupResult(
      memoriesAdded: newMemories.length,
      albumsAdded: newAlbums.length,
      memoriesSkipped: imported.length - newMemories.length,
    );
  }

  // --- Hilfsfunktionen ---------------------------------------------------

  static ArchiveFile? _findFile(Archive archive, String name) {
    for (final file in archive.files) {
      if (file.isFile && file.name == name) return file;
    }
    return null;
  }

  static String _extensionFor(String? mimeType) => switch (mimeType) {
        'image/jpeg' => 'jpg',
        'image/png' => 'png',
        'image/webp' => 'webp',
        'audio/wav' => 'wav',
        'audio/mpeg' => 'mp3',
        'audio/aac' => 'aac',
        _ => 'bin',
      };
}
