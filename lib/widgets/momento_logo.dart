import 'package:flutter/material.dart';

/// Der Momento-Schriftzug aus dem Businessplan.
///
/// Das Original hat einen Farbverlauf von Orange nach Violett. Auf dem
/// Farbverlauf-Header wuerde er untergehen, deshalb laesst er sich mit
/// [tint] einfaerben - im Konzeptbild ist er dort weiss.
class MomentoWordmark extends StatelessWidget {
  const MomentoWordmark({super.key, this.height = 56, this.tint});

  final double height;
  final Color? tint;

  @override
  Widget build(BuildContext context) {
    final image = Image.asset(
      'assets/brand/logo_wordmark.png',
      height: height,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.medium,
    );

    if (tint == null) return image;
    return ColorFiltered(
      colorFilter: ColorFilter.mode(tint!, BlendMode.srcIn),
      child: image,
    );
  }
}

/// Das App-Icon als runde Kachel - fuer den Startbildschirm und "Über Momento".
class MomentoAppIcon extends StatelessWidget {
  const MomentoAppIcon({super.key, this.size = 96});

  final double size;

  @override
  Widget build(BuildContext context) => ClipRRect(
        borderRadius: BorderRadius.circular(size * 0.24),
        child: Image.asset(
          'assets/brand/app_icon.png',
          width: size,
          height: size,
          fit: BoxFit.cover,
          filterQuality: FilterQuality.medium,
        ),
      );
}
