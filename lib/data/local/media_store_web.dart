import 'dart:convert';
import 'dart:typed_data';

import '../models/stored_media.dart';
import 'media_store.dart';

/// Umsetzung fuer den Browser: es gibt kein Dateisystem, also halten wir die
/// Daten direkt in der Erinnerung als Base64.
class InlineMediaStore implements MediaStore {
  const InlineMediaStore();

  @override
  Future<StoredMedia> save(
    Uint8List bytes, {
    required String extension,
    String? mimeType,
    int? durationMs,
  }) async =>
      StoredMedia(
        base64Data: base64Encode(bytes),
        mimeType: mimeType,
        durationMs: durationMs,
      );

  @override
  Future<void> delete(StoredMedia? media) async {
    // Nichts zu tun - die Daten hingen an der Erinnerung.
  }

  @override
  Future<Uint8List?> read(StoredMedia media) async => media.bytes;
}

Future<MediaStore> openMediaStore() async => const InlineMediaStore();
