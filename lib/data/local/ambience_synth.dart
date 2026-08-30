import 'dart:math' as math;
import 'dart:typed_data';

/// Erzeugt kurze Umgebungsgeraeusche als WAV-Datei.
///
/// Die Beispiel-Erinnerungen sollen sich wirklich anhoeren lassen. Statt
/// fremde Audiodateien mitzuliefern, rechnen wir die Klaenge selbst aus:
/// gefiltertes Rauschen ergibt erstaunlich ueberzeugende Wellen, Regen,
/// Wind und ein Lagerfeuer.
enum Ambience { waves, rain, fire, wind, birds }

abstract final class AmbienceSynth {
  static const _sampleRate = 16000;

  /// Baut [seconds] Sekunden des gewuenschten Klangs als WAV-Bytes.
  static Uint8List build(Ambience kind, {double seconds = 6}) {
    final count = (_sampleRate * seconds).round();
    final samples = Float64List(count);
    final random = math.Random(kind.index * 7919 + 13);

    switch (kind) {
      case Ambience.waves:
        _waves(samples, random);
      case Ambience.rain:
        _rain(samples, random);
      case Ambience.fire:
        _fire(samples, random);
      case Ambience.wind:
        _wind(samples, random);
      case Ambience.birds:
        _birds(samples, random);
    }

    _fade(samples, _sampleRate ~/ 2);
    return _encodeWav(samples);
  }

  // --- Klangrezepte ------------------------------------------------------

  /// Breites Rauschen, langsam an- und abschwellend wie Brandung.
  static void _waves(Float64List out, math.Random random) {
    var low = 0.0;
    var lower = 0.0;
    for (var i = 0; i < out.length; i++) {
      final noise = random.nextDouble() * 2 - 1;
      low += (noise - low) * 0.06;
      lower += (low - lower) * 0.10;
      final t = i / _sampleRate;
      // Zwei ueberlagerte Wellenzyklen, damit es nicht mechanisch klingt.
      final swell = 0.5 +
          0.32 * math.sin(2 * math.pi * t / 5.5) +
          0.18 * math.sin(2 * math.pi * t / 2.3 + 1.1);
      out[i] = lower * 3.2 * swell.clamp(0.05, 1.0);
    }
  }

  /// Feines, helles Rauschen mit vereinzelten Tropfen.
  static void _rain(Float64List out, math.Random random) {
    var high = 0.0;
    var previous = 0.0;
    for (var i = 0; i < out.length; i++) {
      final noise = random.nextDouble() * 2 - 1;
      // Hochpass: aktueller minus geglaetteter Wert.
      high += (noise - high) * 0.45;
      final bright = noise - high;
      var value = bright * 0.55 + previous * 0.15;
      // Einzelne Tropfen.
      if (random.nextDouble() < 0.0007) {
        value += (random.nextDouble() * 0.8 + 0.2) * (random.nextBool() ? 1 : -1);
      }
      previous = value;
      out[i] = value;
    }
  }

  /// Dumpfes Grundrauschen plus knackende Funken.
  static void _fire(Float64List out, math.Random random) {
    var low = 0.0;
    var crackle = 0.0;
    var crackleDecay = 0.0;
    for (var i = 0; i < out.length; i++) {
      final noise = random.nextDouble() * 2 - 1;
      low += (noise - low) * 0.05;
      if (random.nextDouble() < 0.0016) {
        crackle = (random.nextDouble() * 0.9 + 0.1) * (random.nextBool() ? 1 : -1);
        crackleDecay = 0.9985 - random.nextDouble() * 0.02;
      }
      crackle *= crackleDecay;
      out[i] = low * 2.4 + crackle * (random.nextDouble() * 2 - 1) * 0.9;
    }
  }

  /// Tiefes Rauschen mit langen Boeen.
  static void _wind(Float64List out, math.Random random) {
    var low = 0.0;
    var lower = 0.0;
    for (var i = 0; i < out.length; i++) {
      final noise = random.nextDouble() * 2 - 1;
      low += (noise - low) * 0.03;
      lower += (low - lower) * 0.08;
      final t = i / _sampleRate;
      final gust = 0.45 + 0.4 * math.sin(2 * math.pi * t / 7.0 + 0.6);
      out[i] = lower * 4.0 * gust.clamp(0.05, 1.0);
    }
  }

  /// Sanftes Blaetterrauschen mit kurzen Vogelrufen darueber.
  static void _birds(Float64List out, math.Random random) {
    var low = 0.0;
    for (var i = 0; i < out.length; i++) {
      final noise = random.nextDouble() * 2 - 1;
      low += (noise - low) * 0.35;
      out[i] = (noise - low) * 0.16;
    }

    // Ein paar kurze Pfiffe mit gleitender Tonhoehe.
    final chirps = 9 + random.nextInt(5);
    for (var c = 0; c < chirps; c++) {
      final start = random.nextInt(math.max(1, out.length - _sampleRate));
      final length = (_sampleRate * (0.08 + random.nextDouble() * 0.10)).round();
      final baseHz = 1600 + random.nextDouble() * 1400;
      final slide = (random.nextDouble() * 2 - 1) * 700;
      for (var i = 0; i < length && start + i < out.length; i++) {
        final progress = i / length;
        final envelope = math.sin(math.pi * progress);
        final hz = baseHz + slide * progress;
        out[start + i] +=
            0.22 * envelope * math.sin(2 * math.pi * hz * (i / _sampleRate));
      }
    }
  }

  // --- Hilfsfunktionen ---------------------------------------------------

  /// Sanft ein- und ausblenden, damit es kein Knacken gibt.
  static void _fade(Float64List samples, int fadeLength) {
    final n = math.min(fadeLength, samples.length ~/ 2);
    for (var i = 0; i < n; i++) {
      final factor = i / n;
      samples[i] *= factor;
      samples[samples.length - 1 - i] *= factor;
    }
  }

  static Uint8List _encodeWav(Float64List samples) {
    // Auf einen angenehmen Pegel normalisieren.
    var peak = 0.0;
    for (final s in samples) {
      final a = s.abs();
      if (a > peak) peak = a;
    }
    final gain = peak < 1e-6 ? 0.0 : 0.82 / peak;

    const headerSize = 44;
    final dataSize = samples.length * 2;
    final bytes = ByteData(headerSize + dataSize);

    void writeAscii(int offset, String value) {
      for (var i = 0; i < value.length; i++) {
        bytes.setUint8(offset + i, value.codeUnitAt(i));
      }
    }

    writeAscii(0, 'RIFF');
    bytes.setUint32(4, 36 + dataSize, Endian.little);
    writeAscii(8, 'WAVE');
    writeAscii(12, 'fmt ');
    bytes.setUint32(16, 16, Endian.little); // Groesse des fmt-Blocks
    bytes.setUint16(20, 1, Endian.little); // PCM
    bytes.setUint16(22, 1, Endian.little); // Mono
    bytes.setUint32(24, _sampleRate, Endian.little);
    bytes.setUint32(28, _sampleRate * 2, Endian.little); // Bytes pro Sekunde
    bytes.setUint16(32, 2, Endian.little); // Block-Ausrichtung
    bytes.setUint16(34, 16, Endian.little); // Bits pro Sample
    writeAscii(36, 'data');
    bytes.setUint32(40, dataSize, Endian.little);

    for (var i = 0; i < samples.length; i++) {
      final value = (samples[i] * gain * 32767).clamp(-32768.0, 32767.0).round();
      bytes.setInt16(headerSize + i * 2, value, Endian.little);
    }

    return bytes.buffer.asUint8List();
  }
}
