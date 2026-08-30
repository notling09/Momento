import 'dart:typed_data';

/// Packt rohe PCM-Daten in eine abspielbare WAV-Datei.
///
/// Die Tonaufnahme liefert einen Strom aus rohen 16-Bit-Werten. Damit die
/// Aufnahme auf allen Geraeten gleich behandelt und gespeichert werden kann,
/// setzen wir selbst den WAV-Kopf davor - das funktioniert auf Android, iOS
/// und im Browser identisch.
abstract final class WavCodec {
  static Uint8List fromPcm16(
    Uint8List pcm, {
    required int sampleRate,
    int channels = 1,
  }) {
    const headerSize = 44;
    final bytes = ByteData(headerSize + pcm.length);

    void writeAscii(int offset, String value) {
      for (var i = 0; i < value.length; i++) {
        bytes.setUint8(offset + i, value.codeUnitAt(i));
      }
    }

    final byteRate = sampleRate * channels * 2;

    writeAscii(0, 'RIFF');
    bytes.setUint32(4, 36 + pcm.length, Endian.little);
    writeAscii(8, 'WAVE');
    writeAscii(12, 'fmt ');
    bytes.setUint32(16, 16, Endian.little);
    bytes.setUint16(20, 1, Endian.little); // PCM
    bytes.setUint16(22, channels, Endian.little);
    bytes.setUint32(24, sampleRate, Endian.little);
    bytes.setUint32(28, byteRate, Endian.little);
    bytes.setUint16(32, channels * 2, Endian.little);
    bytes.setUint16(34, 16, Endian.little);
    writeAscii(36, 'data');
    bytes.setUint32(40, pcm.length, Endian.little);

    final result = bytes.buffer.asUint8List();
    result.setRange(headerSize, headerSize + pcm.length, pcm);
    return result;
  }

  /// Wie lange dauert die Aufnahme?
  static Duration durationOfPcm16(
    int byteLength, {
    required int sampleRate,
    int channels = 1,
  }) {
    final frames = byteLength ~/ (2 * channels);
    return Duration(milliseconds: (frames * 1000 / sampleRate).round());
  }
}
