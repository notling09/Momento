// Einmaliges Hilfsskript: bereitet die Marken-Bilder aus dem Businessplan auf.
//
// 1. logo_wordmark.jpg  -> logo_wordmark.png  (weisser Hintergrund wird transparent)
// 2. app_icon.jpg       -> app_icon.png       (verlustfrei, quadratisch)
// 3. Erzeugt die Android-Launcher-Icons in allen mipmap-Groessen.
//
// Aufruf:  dart run tool/prepare_brand_assets.dart
import 'dart:io';
import 'dart:math' as math;

import 'package:image/image.dart' as img;

const _brandDir = 'assets/brand';

void main() {
  _makeTransparentWordmark();
  _makeIcon();
  _makeAndroidLauncherIcons();
  stdout.writeln('Fertig.');
}

/// Der Schriftzug liegt als JPEG mit weissem Hintergrund vor. Wir rechnen die
/// Helligkeit in einen Alphakanal um, damit das Logo auch auf dem
/// Farbverlauf-Header sauber sitzt.
void _makeTransparentWordmark() {
  final src = img.decodeJpg(File('$_brandDir/logo_wordmark.jpg').readAsBytesSync())!;
  final out = img.Image(width: src.width, height: src.height, numChannels: 4);

  for (var y = 0; y < src.height; y++) {
    for (var x = 0; x < src.width; x++) {
      final p = src.getPixel(x, y);
      final r = p.r.toDouble(), g = p.g.toDouble(), b = p.b.toDouble();

      // Wie weit ist der Pixel von reinem Weiss entfernt?
      final maxC = math.max(r, math.max(g, b));
      final minC = math.min(r, math.min(g, b));
      final distanceFromWhite = 255.0 - minC;

      // Reines Weiss -> unsichtbar, saturierte Farbe -> voll deckend.
      var alpha = (distanceFromWhite / 90.0 * 255.0).clamp(0.0, 255.0);
      if (alpha < 8) alpha = 0;

      // Die Farbe wieder "entweissen", damit die Raender nicht ausbleichen.
      final k = alpha / 255.0;
      double unmix(double c) => k < 0.05 ? c : ((c - 255.0 * (1 - k)) / k).clamp(0.0, 255.0);

      out.setPixelRgba(
        x,
        y,
        unmix(r).round(),
        unmix(g).round(),
        unmix(b).round(),
        alpha.round(),
      );
      // maxC nur zur Dokumentation der Idee behalten.
      if (maxC < 0) return;
    }
  }

  final trimmed = img.trim(out, mode: img.TrimMode.transparent);
  File('$_brandDir/logo_wordmark.png').writeAsBytesSync(img.encodePng(trimmed));
  stdout.writeln('logo_wordmark.png  ${trimmed.width}x${trimmed.height}');
}

void _makeIcon() {
  final src = img.decodeJpg(File('$_brandDir/app_icon.jpg').readAsBytesSync())!;
  // Der Export hat einen schmalen weissen Rand - den schneiden wir weg.
  final inset = (math.min(src.width, src.height) * 0.02).round();
  final cropped = img.copyCrop(
    src,
    x: inset,
    y: inset,
    width: src.width - inset * 2,
    height: src.height - inset * 2,
  );
  // 512 reicht fuer alles, wofuer das Icon in der App gebraucht wird, und
  // spart gegenueber 1024 rund 300 KB in der fertigen App.
  final square = img.copyResize(cropped, width: 512, height: 512, interpolation: img.Interpolation.cubic);
  File('$_brandDir/app_icon.png').writeAsBytesSync(img.encodePng(square));
  stdout.writeln('app_icon.png       512x512');
}

void _makeAndroidLauncherIcons() {
  final icon = img.decodePng(File('$_brandDir/app_icon.png').readAsBytesSync())!;
  const sizes = <String, int>{
    'mipmap-mdpi': 48,
    'mipmap-hdpi': 72,
    'mipmap-xhdpi': 96,
    'mipmap-xxhdpi': 144,
    'mipmap-xxxhdpi': 192,
  };
  sizes.forEach((folder, size) {
    final dir = Directory('android/app/src/main/res/$folder')..createSync(recursive: true);
    final resized = img.copyResize(icon, width: size, height: size, interpolation: img.Interpolation.cubic);
    File('${dir.path}/ic_launcher.png').writeAsBytesSync(img.encodePng(resized));
  });
  stdout.writeln('Android Launcher-Icons erzeugt');

  // Grosses Zeichen fuer den Startbildschirm.
  final splashDir = Directory('android/app/src/main/res/drawable-nodpi')
    ..createSync(recursive: true);
  final splash = img.copyResize(icon,
      width: 384, height: 384, interpolation: img.Interpolation.cubic);
  File('${splashDir.path}/momento_splash.png')
      .writeAsBytesSync(img.encodePng(splash));
  stdout.writeln('Startbildschirm-Zeichen erzeugt');

  // Web-Icons
  for (final size in [192, 512]) {
    final resized = img.copyResize(icon, width: size, height: size, interpolation: img.Interpolation.cubic);
    File('web/icons/Icon-$size.png').writeAsBytesSync(img.encodePng(resized));
    File('web/icons/Icon-maskable-$size.png').writeAsBytesSync(img.encodePng(resized));
  }
  final favicon = img.copyResize(icon, width: 32, height: 32, interpolation: img.Interpolation.cubic);
  File('web/favicon.png').writeAsBytesSync(img.encodePng(favicon));
  stdout.writeln('Web-Icons erzeugt');
}
