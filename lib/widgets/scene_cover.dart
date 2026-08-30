import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../data/models/memory.dart';

/// Gezeichnete Titelbilder fuer Erinnerungen ohne eigenes Foto.
///
/// Die Szenen werden zur Laufzeit gemalt statt als Bilddateien mitgeliefert:
/// so bleibt die App klein, jedes Bild ist in jeder Groesse scharf und die
/// Farben passen immer zur Marke.
class SceneCover extends StatelessWidget {
  const SceneCover({super.key, required this.scene, this.seed = 0});

  final CoverScene scene;
  final int seed;

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: _ScenePainter(scene, seed),
        isComplex: true,
        willChange: false,
        size: Size.infinite,
      );
}

class _ScenePainter extends CustomPainter {
  _ScenePainter(this.scene, this.seed);

  final CoverScene scene;
  final int seed;

  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(scene.index * 1013 + seed);
    canvas.save();
    canvas.clipRect(Offset.zero & size);
    switch (scene) {
      case CoverScene.lakeSunset:
        _lakeSunset(canvas, size, random);
      case CoverScene.beach:
        _beach(canvas, size, random);
      case CoverScene.mountains:
        _mountains(canvas, size, random);
      case CoverScene.cityNight:
        _cityNight(canvas, size, random);
      case CoverScene.forest:
        _forest(canvas, size, random);
      case CoverScene.snowfall:
        _snowfall(canvas, size, random);
      case CoverScene.celebration:
        _celebration(canvas, size, random);
      case CoverScene.rainWindow:
        _rainWindow(canvas, size, random);
      case CoverScene.autumnPark:
        _autumnPark(canvas, size, random);
      case CoverScene.springMeadow:
        _springMeadow(canvas, size, random);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_ScenePainter oldDelegate) =>
      oldDelegate.scene != scene || oldDelegate.seed != seed;

  // --- Bausteine ---------------------------------------------------------

  void _sky(Canvas canvas, Size size, List<Color> colors, [List<double>? stops]) {
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: colors,
          stops: stops,
        ).createShader(rect),
    );
  }

  void _sun(Canvas canvas, Offset center, double radius, Color core, Color halo) {
    canvas.drawCircle(
      center,
      radius * 3.2,
      Paint()
        ..shader = RadialGradient(
          colors: [halo.withValues(alpha: 0.55), halo.withValues(alpha: 0)],
        ).createShader(Rect.fromCircle(center: center, radius: radius * 3.2)),
    );
    canvas.drawCircle(center, radius, Paint()..color = core);
  }

  /// Weiche Huegelsilhouette ueber die ganze Breite.
  void _hills(
    Canvas canvas,
    Size size, {
    required double baseline,
    required double amplitude,
    required Color color,
    required math.Random random,
    int bumps = 3,
  }) {
    final path = Path()..moveTo(0, size.height);
    path.lineTo(0, baseline);
    final step = size.width / bumps;
    var x = 0.0;
    var y = baseline;
    for (var i = 0; i < bumps; i++) {
      final nextX = x + step;
      final peak = baseline - amplitude * (0.5 + random.nextDouble() * 0.9);
      path.quadraticBezierTo((x + nextX) / 2, peak, nextX, y);
      x = nextX;
    }
    path
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  void _stars(Canvas canvas, Size size, math.Random random, int count, Color color) {
    final paint = Paint()..color = color;
    for (var i = 0; i < count; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height * 0.6;
      final r = 0.6 + random.nextDouble() * 1.4;
      canvas.drawCircle(Offset(x, y), r, paint..color = color.withValues(alpha: 0.35 + random.nextDouble() * 0.6));
    }
  }

  /// Der vierzackige Funkel-Stern aus dem Momento-Logo.
  void _sparkle(Canvas canvas, Offset center, double size, Color color) {
    final path = Path();
    const k = 0.26;
    path.moveTo(center.dx, center.dy - size);
    path.quadraticBezierTo(center.dx + size * k, center.dy - size * k, center.dx + size, center.dy);
    path.quadraticBezierTo(center.dx + size * k, center.dy + size * k, center.dx, center.dy + size);
    path.quadraticBezierTo(center.dx - size * k, center.dy + size * k, center.dx - size, center.dy);
    path.quadraticBezierTo(center.dx - size * k, center.dy - size * k, center.dx, center.dy - size);
    path.close();
    canvas.drawPath(path, Paint()..color = color);
  }

  void _triangleTree(Canvas canvas, Offset base, double width, double height, Color color) {
    final path = Path()
      ..moveTo(base.dx, base.dy - height)
      ..lineTo(base.dx + width / 2, base.dy)
      ..lineTo(base.dx - width / 2, base.dy)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  // --- Szenen ------------------------------------------------------------

  void _lakeSunset(Canvas canvas, Size size, math.Random random) {
    _sky(canvas, size, const [
      Color(0xFF7C5AA6),
      Color(0xFFD98BA8),
      Color(0xFFF6A97E),
      Color(0xFFFBD9A0),
    ]);

    final horizon = size.height * 0.62;
    final sunCenter = Offset(size.width * 0.66, horizon - size.height * 0.10);
    _sun(canvas, sunCenter, size.height * 0.075, const Color(0xFFFFF0C4), const Color(0xFFFFC98A));

    // Ferne Huegel.
    _hills(
      canvas,
      Size(size.width, horizon),
      baseline: horizon,
      amplitude: size.height * 0.10,
      color: const Color(0xFF6B4A78).withValues(alpha: 0.55),
      random: random,
      bumps: 3,
    );

    // Wasser.
    final water = Rect.fromLTRB(0, horizon, size.width, size.height);
    canvas.drawRect(
      water,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFE9A883), Color(0xFF9C6E9E), Color(0xFF4E3963)],
        ).createShader(water),
    );

    // Spiegelung der Sonne.
    for (var i = 0; i < 16; i++) {
      final t = i / 16;
      final y = horizon + t * (size.height - horizon) * 0.95;
      final width = size.width * (0.06 + t * 0.20) * (0.6 + random.nextDouble() * 0.8);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(sunCenter.dx + (random.nextDouble() - 0.5) * size.width * 0.06, y),
            width: width,
            height: math.max(1.2, size.height * 0.008),
          ),
          const Radius.circular(4),
        ),
        Paint()..color = const Color(0xFFFFE0B0).withValues(alpha: 0.55 * (1 - t * 0.7)),
      );
    }

    // Schilf im Vordergrund.
    final reed = Paint()
      ..color = const Color(0xFF33253F)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < 9; i++) {
      final x = size.width * (0.02 + random.nextDouble() * 0.22);
      final height = size.height * (0.18 + random.nextDouble() * 0.22);
      reed.strokeWidth = math.max(1.2, size.height * 0.006);
      final path = Path()
        ..moveTo(x, size.height)
        ..quadraticBezierTo(
          x - size.width * 0.02,
          size.height - height * 0.6,
          x + (random.nextDouble() - 0.5) * size.width * 0.03,
          size.height - height,
        );
      canvas.drawPath(path, reed);
    }

    _sparkle(canvas, Offset(size.width * 0.16, size.height * 0.18), size.height * 0.035, Colors.white.withValues(alpha: 0.8));
    _sparkle(canvas, Offset(size.width * 0.87, size.height * 0.12), size.height * 0.022, Colors.white.withValues(alpha: 0.6));
  }

  void _beach(Canvas canvas, Size size, math.Random random) {
    _sky(canvas, size, const [
      Color(0xFF8FC6E8),
      Color(0xFFBEDCEC),
      Color(0xFFFCE0C0),
    ]);

    final horizon = size.height * 0.48;
    _sun(canvas, Offset(size.width * 0.20, size.height * 0.20), size.height * 0.06,
        const Color(0xFFFFF6DA), const Color(0xFFFFE2A0));

    final sea = Rect.fromLTRB(0, horizon, size.width, size.height * 0.78);
    canvas.drawRect(
      sea,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF3F8FB0), Color(0xFF63B7CB), Color(0xFF9FD8DC)],
        ).createShader(sea),
    );

    // Wellenkaemme.
    final foam = Paint()
      ..color = Colors.white.withValues(alpha: 0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1.0, size.height * 0.006)
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < 7; i++) {
      final y = horizon + (size.height * 0.78 - horizon) * (i / 7 + 0.06);
      final path = Path()..moveTo(0, y);
      for (var x = 0.0; x < size.width; x += size.width / 6) {
        path.quadraticBezierTo(
          x + size.width / 12,
          y + (random.nextDouble() - 0.5) * size.height * 0.02,
          x + size.width / 6,
          y,
        );
      }
      canvas.drawPath(path, foam);
    }

    // Sand.
    final sand = Rect.fromLTRB(0, size.height * 0.76, size.width, size.height);
    canvas.drawPath(
      Path()
        ..moveTo(0, size.height * 0.80)
        ..quadraticBezierTo(size.width * 0.5, size.height * 0.72, size.width, size.height * 0.80)
        ..lineTo(size.width, size.height)
        ..lineTo(0, size.height)
        ..close(),
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFF3DDBB), Color(0xFFE0C199)],
        ).createShader(sand),
    );

    // Muscheln.
    for (var i = 0; i < 5; i++) {
      final x = size.width * (0.1 + random.nextDouble() * 0.8);
      final y = size.height * (0.86 + random.nextDouble() * 0.10);
      canvas.drawCircle(Offset(x, y), size.height * 0.012,
          Paint()..color = const Color(0xFFF6C9B8).withValues(alpha: 0.9));
    }
  }

  void _mountains(Canvas canvas, Size size, math.Random random) {
    _sky(canvas, size, const [
      Color(0xFF4E3E7A),
      Color(0xFF9E7BA6),
      Color(0xFFE9A587),
      Color(0xFFFAD9A6),
    ]);

    _sun(canvas, Offset(size.width * 0.5, size.height * 0.52), size.height * 0.07,
        const Color(0xFFFFF3D2), const Color(0xFFFFC58F));

    void ridge(double baseline, double peakHeight, Color color, Color? snow) {
      final path = Path()..moveTo(-size.width * 0.05, baseline);
      var x = -size.width * 0.05;
      final peaks = <Offset>[];
      while (x < size.width * 1.05) {
        final w = size.width * (0.18 + random.nextDouble() * 0.16);
        final h = peakHeight * (0.6 + random.nextDouble() * 0.7);
        final apex = Offset(x + w / 2, baseline - h);
        peaks.add(apex);
        path.lineTo(apex.dx, apex.dy);
        path.lineTo(x + w, baseline);
        x += w;
      }
      path
        ..lineTo(size.width * 1.05, size.height)
        ..lineTo(-size.width * 0.05, size.height)
        ..close();
      canvas.drawPath(path, Paint()..color = color);

      if (snow == null) return;
      for (final apex in peaks) {
        final capHeight = peakHeight * 0.22;
        final cap = Path()
          ..moveTo(apex.dx, apex.dy)
          ..lineTo(apex.dx + capHeight * 0.75, apex.dy + capHeight)
          ..lineTo(apex.dx + capHeight * 0.3, apex.dy + capHeight * 0.8)
          ..lineTo(apex.dx - capHeight * 0.2, apex.dy + capHeight * 1.05)
          ..lineTo(apex.dx - capHeight * 0.75, apex.dy + capHeight)
          ..close();
        canvas.drawPath(cap, Paint()..color = snow);
      }
    }

    ridge(size.height * 0.70, size.height * 0.26, const Color(0xFF6B5487).withValues(alpha: 0.75), Colors.white.withValues(alpha: 0.55));
    ridge(size.height * 0.86, size.height * 0.30, const Color(0xFF3E2F52), Colors.white.withValues(alpha: 0.8));

    _stars(canvas, size, random, 14, Colors.white);
  }

  void _cityNight(Canvas canvas, Size size, math.Random random) {
    _sky(canvas, size, const [
      Color(0xFF1B1430),
      Color(0xFF3B2A55),
      Color(0xFF7A4E72),
      Color(0xFFC0728A),
    ]);

    _stars(canvas, size, random, 30, Colors.white);
    canvas.drawCircle(Offset(size.width * 0.78, size.height * 0.18), size.height * 0.055,
        Paint()..color = const Color(0xFFFDF3D0));

    // Haeuserzeile.
    var x = -size.width * 0.03;
    final windowPaint = Paint()..color = const Color(0xFFFFD98E);
    while (x < size.width * 1.03) {
      final w = size.width * (0.08 + random.nextDouble() * 0.10);
      final h = size.height * (0.20 + random.nextDouble() * 0.34);
      final top = size.height - h;
      canvas.drawRect(
        Rect.fromLTWH(x, top, w, h),
        Paint()..color = const Color(0xFF241B3A),
      );

      final cols = math.max(2, (w / (size.width * 0.035)).floor());
      final rows = math.max(2, (h / (size.height * 0.075)).floor());
      for (var c = 0; c < cols; c++) {
        for (var r = 0; r < rows; r++) {
          if (random.nextDouble() < 0.45) continue;
          final ww = w / cols * 0.42;
          final wh = h / rows * 0.34;
          canvas.drawRect(
            Rect.fromLTWH(
              x + w / cols * (c + 0.3),
              top + h / rows * (r + 0.35),
              ww,
              wh,
            ),
            windowPaint..color = const Color(0xFFFFD98E).withValues(alpha: 0.5 + random.nextDouble() * 0.5),
          );
        }
      }
      x += w + size.width * 0.012;
    }

    // Nasse Strasse mit Spiegelungen.
    final street = Rect.fromLTRB(0, size.height * 0.90, size.width, size.height);
    canvas.drawRect(street, Paint()..color = const Color(0xFF150F26));
    for (var i = 0; i < 12; i++) {
      final rx = random.nextDouble() * size.width;
      canvas.drawRect(
        Rect.fromLTWH(rx, size.height * 0.90, size.width * 0.012, size.height * 0.10),
        Paint()..color = const Color(0xFFFFD98E).withValues(alpha: 0.10 + random.nextDouble() * 0.16),
      );
    }
  }

  void _forest(Canvas canvas, Size size, math.Random random) {
    _sky(canvas, size, const [
      Color(0xFFCDE3D2),
      Color(0xFFA8CBB4),
      Color(0xFF6E9C82),
    ]);

    // Lichtstrahlen.
    for (var i = 0; i < 4; i++) {
      final x = size.width * (0.15 + i * 0.22);
      final path = Path()
        ..moveTo(x, -size.height * 0.1)
        ..lineTo(x + size.width * 0.10, -size.height * 0.1)
        ..lineTo(x + size.width * 0.24, size.height)
        ..lineTo(x + size.width * 0.06, size.height)
        ..close();
      canvas.drawPath(path, Paint()..color = const Color(0xFFFFF6C9).withValues(alpha: 0.14));
    }

    void layer(double baseline, double scale, Color color) {
      var x = -size.width * 0.05;
      while (x < size.width * 1.08) {
        // Breite an der Hoehe messen, damit die Baeume auch in schmalen
        // Kacheln wie Baeume aussehen und nicht wie Gras.
        final h = size.height * (0.34 + random.nextDouble() * 0.24) * scale;
        final w = h * (0.52 + random.nextDouble() * 0.18);
        _triangleTree(canvas, Offset(x, baseline), w, h, color);
        // Zweite Etage fuer die typische Tannenform.
        _triangleTree(canvas, Offset(x, baseline - h * 0.34), w * 0.72, h * 0.66, color);
        x += w * 0.62;
      }
    }

    layer(size.height * 0.80, 0.85, const Color(0xFF4F7C63).withValues(alpha: 0.75));
    layer(size.height * 0.95, 1.0, const Color(0xFF2F5544));
    layer(size.height * 1.06, 1.15, const Color(0xFF1E3B30));

    // Nebelbaender.
    for (var i = 0; i < 3; i++) {
      final y = size.height * (0.60 + i * 0.10);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(-size.width * 0.1, y, size.width * 1.2, size.height * 0.045),
          Radius.circular(size.height * 0.03),
        ),
        Paint()..color = Colors.white.withValues(alpha: 0.16),
      );
    }
  }

  void _snowfall(Canvas canvas, Size size, math.Random random) {
    _sky(canvas, size, const [
      Color(0xFF6E77A8),
      Color(0xFFA8AFCE),
      Color(0xFFD9DEEC),
    ]);

    _hills(canvas, size,
        baseline: size.height * 0.78,
        amplitude: size.height * 0.10,
        color: const Color(0xFFE9EDF7),
        random: random,
        bumps: 3);
    _hills(canvas, size,
        baseline: size.height * 0.90,
        amplitude: size.height * 0.07,
        color: Colors.white,
        random: random,
        bumps: 2);

    // Kahle Baeume.
    void bareTree(Offset base, double height, Color color) {
      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = math.max(1.4, height * 0.045);
      canvas.drawLine(base, Offset(base.dx, base.dy - height), paint);
      paint.strokeWidth = math.max(1.0, height * 0.028);
      for (var i = 0; i < 4; i++) {
        final t = 0.45 + i * 0.15;
        final y = base.dy - height * t;
        final dir = i.isEven ? 1 : -1;
        canvas.drawLine(
          Offset(base.dx, y),
          Offset(base.dx + dir * height * 0.22, y - height * 0.16),
          paint,
        );
      }
    }

    bareTree(Offset(size.width * 0.18, size.height * 0.84), size.height * 0.34, const Color(0xFF4A4463));
    bareTree(Offset(size.width * 0.82, size.height * 0.90), size.height * 0.26, const Color(0xFF3E3956));

    // Schneeflocken.
    for (var i = 0; i < 60; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final r = 0.8 + random.nextDouble() * 2.2;
      canvas.drawCircle(Offset(x, y), r,
          Paint()..color = Colors.white.withValues(alpha: 0.45 + random.nextDouble() * 0.5));
    }
  }

  void _celebration(Canvas canvas, Size size, math.Random random) {
    _sky(canvas, size, const [
      Color(0xFF6B4C9A),
      Color(0xFFB86EA6),
      Color(0xFFF29A8E),
      Color(0xFFFFC98A),
    ]);

    // Wimpelkette.
    final stringPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.65)
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1.0, size.height * 0.005);
    final path = Path()
      ..moveTo(-size.width * 0.02, size.height * 0.14)
      ..quadraticBezierTo(size.width * 0.5, size.height * 0.30, size.width * 1.02, size.height * 0.12);
    canvas.drawPath(path, stringPaint);

    const flagColors = [
      Color(0xFFFFD3A5),
      Color(0xFFF7A3BE),
      Color(0xFFC5A0EA),
      Color(0xFF9FD8DC),
    ];
    final metric = path.computeMetrics().first;
    for (var i = 1; i < 11; i++) {
      final pos = metric.getTangentForOffset(metric.length * i / 11)!.position;
      final w = size.height * 0.055;
      final h = size.height * 0.085;
      final flag = Path()
        ..moveTo(pos.dx - w / 2, pos.dy)
        ..lineTo(pos.dx + w / 2, pos.dy)
        ..lineTo(pos.dx, pos.dy + h)
        ..close();
      canvas.drawPath(flag, Paint()..color = flagColors[i % flagColors.length]);
    }

    // Konfetti.
    for (var i = 0; i < 46; i++) {
      final x = random.nextDouble() * size.width;
      final y = size.height * (0.28 + random.nextDouble() * 0.72);
      final w = size.height * (0.014 + random.nextDouble() * 0.016);
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(random.nextDouble() * math.pi);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset.zero, width: w, height: w * 0.5),
          Radius.circular(w * 0.25),
        ),
        Paint()
          ..color = flagColors[random.nextInt(flagColors.length)]
              .withValues(alpha: 0.75 + random.nextDouble() * 0.25),
      );
      canvas.restore();
    }

    _sparkle(canvas, Offset(size.width * 0.22, size.height * 0.62), size.height * 0.05, Colors.white.withValues(alpha: 0.85));
    _sparkle(canvas, Offset(size.width * 0.80, size.height * 0.74), size.height * 0.034, Colors.white.withValues(alpha: 0.7));
  }

  void _rainWindow(Canvas canvas, Size size, math.Random random) {
    _sky(canvas, size, const [
      Color(0xFF5C5A78),
      Color(0xFF8C88A6),
      Color(0xFFB9B2C6),
    ]);

    // Verschwommene Lichter draussen.
    for (var i = 0; i < 7; i++) {
      final center = Offset(
        random.nextDouble() * size.width,
        size.height * (0.2 + random.nextDouble() * 0.6),
      );
      final radius = size.height * (0.05 + random.nextDouble() * 0.09);
      canvas.drawCircle(
        center,
        radius,
        Paint()
          ..shader = RadialGradient(
            colors: [
              const Color(0xFFFFDCA8).withValues(alpha: 0.55),
              const Color(0xFFFFDCA8).withValues(alpha: 0),
            ],
          ).createShader(Rect.fromCircle(center: center, radius: radius)),
      );
    }

    // Regenspuren auf der Scheibe.
    final streak = Paint()
      ..color = Colors.white.withValues(alpha: 0.30)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < 26; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height * 0.8;
      final length = size.height * (0.08 + random.nextDouble() * 0.22);
      streak.strokeWidth = math.max(0.8, size.height * (0.004 + random.nextDouble() * 0.005));
      canvas.drawLine(Offset(x, y), Offset(x + size.width * 0.012, y + length), streak);
    }

    // Tropfen.
    for (var i = 0; i < 24; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      canvas.drawCircle(Offset(x, y), 1.0 + random.nextDouble() * 2.4,
          Paint()..color = Colors.white.withValues(alpha: 0.22 + random.nextDouble() * 0.3));
    }

    // Fensterrahmen.
    final frame = Paint()
      ..color = const Color(0xFF3B3550)
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(3.0, size.height * 0.028);
    canvas.drawLine(Offset(size.width * 0.5, 0), Offset(size.width * 0.5, size.height), frame);
    canvas.drawLine(Offset(0, size.height * 0.58), Offset(size.width, size.height * 0.58), frame);
  }

  void _autumnPark(Canvas canvas, Size size, math.Random random) {
    _sky(canvas, size, const [
      Color(0xFFF2C98E),
      Color(0xFFEBAE7C),
      Color(0xFFD98C6A),
    ]);

    // Wiese.
    canvas.drawPath(
      Path()
        ..moveTo(0, size.height * 0.72)
        ..quadraticBezierTo(size.width * 0.5, size.height * 0.66, size.width, size.height * 0.74)
        ..lineTo(size.width, size.height)
        ..lineTo(0, size.height)
        ..close(),
      Paint()..color = const Color(0xFF9C7A4A),
    );

    // Baeume: ein voller Kronenkoerper, darauf viele kleine Blattbuschel.
    void tree(Offset base, double height, List<Color> colors) {
      final trunk = Paint()
        ..color = const Color(0xFF5C3F2E)
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(2.0, height * 0.085);
      canvas.drawLine(base, Offset(base.dx, base.dy - height * 0.58), trunk);

      final crownCenter = Offset(base.dx, base.dy - height * 0.80);
      canvas.drawCircle(crownCenter, height * 0.34,
          Paint()..color = colors[1].withValues(alpha: 0.95));

      for (var i = 0; i < 16; i++) {
        final angle = random.nextDouble() * math.pi * 2;
        final distance = math.sqrt(random.nextDouble()) * height * 0.32;
        final center = Offset(
          crownCenter.dx + math.cos(angle) * distance,
          crownCenter.dy + math.sin(angle) * distance * 0.82,
        );
        canvas.drawCircle(center, height * (0.09 + random.nextDouble() * 0.07),
            Paint()..color = colors[random.nextInt(colors.length)]);
      }
    }

    const canopy = [Color(0xFFE07A3E), Color(0xFFD9A441), Color(0xFFC15A38), Color(0xFFEFB865)];
    tree(Offset(size.width * 0.20, size.height * 0.78), size.height * 0.52, canopy);
    tree(Offset(size.width * 0.78, size.height * 0.82), size.height * 0.46, canopy);
    tree(Offset(size.width * 0.50, size.height * 0.74), size.height * 0.36, canopy);

    // Fallende Blaetter.
    for (var i = 0; i < 22; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final s = size.height * (0.014 + random.nextDouble() * 0.014);
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(random.nextDouble() * math.pi * 2);
      final leaf = Path()
        ..moveTo(0, -s)
        ..quadraticBezierTo(s, 0, 0, s)
        ..quadraticBezierTo(-s, 0, 0, -s);
      canvas.drawPath(leaf, Paint()..color = canopy[random.nextInt(canopy.length)].withValues(alpha: 0.9));
      canvas.restore();
    }
  }

  void _springMeadow(Canvas canvas, Size size, math.Random random) {
    _sky(canvas, size, const [
      Color(0xFF9ED2E8),
      Color(0xFFCDE9E4),
      Color(0xFFEFF3C8),
    ]);

    _sun(canvas, Offset(size.width * 0.80, size.height * 0.18), size.height * 0.06,
        const Color(0xFFFFF8D6), const Color(0xFFFFE9A0));

    // Wiese in zwei Schichten.
    canvas.drawPath(
      Path()
        ..moveTo(0, size.height * 0.60)
        ..quadraticBezierTo(size.width * 0.4, size.height * 0.52, size.width, size.height * 0.62)
        ..lineTo(size.width, size.height)
        ..lineTo(0, size.height)
        ..close(),
      Paint()..color = const Color(0xFF8CC07A),
    );
    canvas.drawPath(
      Path()
        ..moveTo(0, size.height * 0.76)
        ..quadraticBezierTo(size.width * 0.6, size.height * 0.68, size.width, size.height * 0.80)
        ..lineTo(size.width, size.height)
        ..lineTo(0, size.height)
        ..close(),
      Paint()..color = const Color(0xFF6BA45E),
    );

    // Blumen.
    const petals = [Color(0xFFF7A3BE), Color(0xFFFFF1A8), Color(0xFFE3C0F0), Color(0xFFFFFFFF)];
    for (var i = 0; i < 34; i++) {
      final x = random.nextDouble() * size.width;
      final y = size.height * (0.64 + random.nextDouble() * 0.34);
      final r = size.height * (0.010 + random.nextDouble() * 0.012);
      final color = petals[random.nextInt(petals.length)];
      for (var p = 0; p < 5; p++) {
        final angle = p * math.pi * 2 / 5;
        canvas.drawCircle(
          Offset(x + math.cos(angle) * r, y + math.sin(angle) * r),
          r * 0.72,
          Paint()..color = color.withValues(alpha: 0.95),
        );
      }
      canvas.drawCircle(Offset(x, y), r * 0.55, Paint()..color = const Color(0xFFFFD86B));
    }

    _sparkle(canvas, Offset(size.width * 0.14, size.height * 0.22), size.height * 0.030, Colors.white.withValues(alpha: 0.8));
  }
}
