import 'dart:convert';
import 'dart:typed_data';

/// Ein gespeichertes Medium (Bild oder Tonaufnahme).
///
/// Auf Android und iOS liegen die Dateien im App-Verzeichnis und wir merken
/// uns nur den Pfad. Im Browser gibt es kein Dateisystem, dort halten wir die
/// Daten direkt als Base64. Beide Faelle stecken in derselben Klasse, damit der
/// Rest der App den Unterschied nicht kennen muss.
class StoredMedia {
  const StoredMedia({this.path, this.base64Data, this.mimeType, this.durationMs});

  /// Pfad im App-Verzeichnis (mobil).
  final String? path;

  /// Inline gespeicherte Daten (Web).
  final String? base64Data;

  final String? mimeType;

  /// Nur fuer Tonaufnahmen.
  final int? durationMs;

  bool get isEmpty => path == null && base64Data == null;
  bool get isNotEmpty => !isEmpty;

  Uint8List? get bytes =>
      base64Data == null ? null : base64Decode(base64Data!);

  Duration? get duration =>
      durationMs == null ? null : Duration(milliseconds: durationMs!);

  StoredMedia copyWith({
    String? path,
    String? base64Data,
    String? mimeType,
    int? durationMs,
  }) =>
      StoredMedia(
        path: path ?? this.path,
        base64Data: base64Data ?? this.base64Data,
        mimeType: mimeType ?? this.mimeType,
        durationMs: durationMs ?? this.durationMs,
      );

  Map<String, dynamic> toJson() => {
        if (path != null) 'path': path,
        if (base64Data != null) 'data': base64Data,
        if (mimeType != null) 'mime': mimeType,
        if (durationMs != null) 'durationMs': durationMs,
      };

  static StoredMedia? fromJson(Map<String, dynamic>? json) {
    if (json == null) return null;
    final media = StoredMedia(
      path: json['path'] as String?,
      base64Data: json['data'] as String?,
      mimeType: json['mime'] as String?,
      durationMs: (json['durationMs'] as num?)?.toInt(),
    );
    return media.isEmpty ? null : media;
  }
}
