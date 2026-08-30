import 'dart:typed_data';

import '../models/stored_media.dart';
// Auf dem Handy speichern wir Dateien, im Browser Base64. Welche der beiden
// Umsetzungen kompiliert wird, entscheidet der bedingte Import.
import 'media_store_io.dart'
    if (dart.library.js_interop) 'media_store_web.dart' as impl;

/// Legt Bilder und Tonaufnahmen ab.
abstract interface class MediaStore {
  /// Speichert [bytes] und gibt die Referenz zurueck, die in der Erinnerung
  /// abgelegt wird.
  Future<StoredMedia> save(
    Uint8List bytes, {
    required String extension,
    String? mimeType,
    int? durationMs,
  });

  /// Loescht die Datei hinter [media], falls es eine gibt.
  Future<void> delete(StoredMedia? media);

  /// Liest die Daten wieder ein (fuer Wiedergabe oder Anzeige).
  Future<Uint8List?> read(StoredMedia media);

  static Future<MediaStore> open() => impl.openMediaStore();
}
