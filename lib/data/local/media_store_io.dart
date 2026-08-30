import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../models/stored_media.dart';
import 'media_store.dart';

/// Umsetzung fuer Android, iOS und Desktop: echte Dateien im App-Verzeichnis.
class FileMediaStore implements MediaStore {
  FileMediaStore(this._directory);

  final Directory _directory;
  static const _uuid = Uuid();

  @override
  Future<StoredMedia> save(
    Uint8List bytes, {
    required String extension,
    String? mimeType,
    int? durationMs,
  }) async {
    final file = File('${_directory.path}/${_uuid.v4()}.$extension');
    await file.writeAsBytes(bytes, flush: true);
    return StoredMedia(
      path: file.path,
      mimeType: mimeType,
      durationMs: durationMs,
    );
  }

  @override
  Future<void> delete(StoredMedia? media) async {
    final path = media?.path;
    if (path == null) return;
    final file = File(path);
    if (await file.exists()) {
      try {
        await file.delete();
      } on FileSystemException {
        // Nicht schlimm - die Referenz verschwindet ohnehin.
      }
    }
  }

  @override
  Future<Uint8List?> read(StoredMedia media) async {
    if (media.base64Data != null) return media.bytes;
    final path = media.path;
    if (path == null) return null;
    final file = File(path);
    return await file.exists() ? file.readAsBytes() : null;
  }
}

Future<MediaStore> openMediaStore() async {
  final docs = await getApplicationDocumentsDirectory();
  final dir = Directory('${docs.path}/momento_media');
  if (!dir.existsSync()) dir.createSync(recursive: true);
  return FileMediaStore(dir);
}
