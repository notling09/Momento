import 'package:flutter/material.dart';

import '../core/theme/momento_colors.dart';
import '../core/theme/momento_theme.dart';
import '../data/models/stored_media.dart';
import 'file_image_io.dart' if (dart.library.js_interop) 'file_image_web.dart';

/// Platz am unteren Rand, damit nichts hinter der Navigationsleiste des
/// Handys oder der unteren Leiste der App verschwindet.
abstract final class MomentoInsets {
  /// Hoehe der unteren Leiste von Momento (ohne Systemleiste).
  static const navBarHeight = 74.0;

  /// Fuer die drei Hauptbildschirme, die unter der Leiste durchscrollen.
  static double aboveNavBar(BuildContext context) =>
      MediaQuery.paddingOf(context).bottom + navBarHeight + 34;

  /// Fuer alle Seiten, die als eigene Seite geoeffnet werden.
  static double bottom(BuildContext context) =>
      MediaQuery.paddingOf(context).bottom + 34;
}

/// Schneidet die Unterkante des Farbverlauf-Kopfes weich rund ab.
class CurvedHeaderClipper extends CustomClipper<Path> {
  const CurvedHeaderClipper({this.depth = 34, this.overshoot = 20});

  /// Wie weit die Kante an den Seiten nach oben gezogen wird.
  final double depth;

  /// Wie weit sich die Mitte nach unten woelbt.
  final double overshoot;

  @override
  Path getClip(Size size) => Path()
    ..lineTo(0, size.height - depth)
    ..quadraticBezierTo(
      size.width / 2,
      size.height + overshoot,
      size.width,
      size.height - depth,
    )
    ..lineTo(size.width, 0)
    ..close();

  @override
  bool shouldReclip(CurvedHeaderClipper oldClipper) =>
      oldClipper.depth != depth || oldClipper.overshoot != overshoot;
}

/// Zeigt ein gespeichertes Bild an - egal ob als Datei oder als Base64.
class StoredImageView extends StatelessWidget {
  const StoredImageView({
    super.key,
    required this.media,
    this.fit = BoxFit.cover,
    this.fallback,
  });

  final StoredMedia media;
  final BoxFit fit;
  final Widget? fallback;

  @override
  Widget build(BuildContext context) {
    final bytes = media.bytes;
    if (bytes != null) {
      return Image.memory(bytes, fit: fit, filterQuality: FilterQuality.medium);
    }
    final path = media.path;
    if (path != null) return buildFileImage(path, fit, fallback);
    return fallback ?? const SizedBox.shrink();
  }
}

/// Ein kleines Etikett mit Symbol - fuer Duft, Sound und Gefuehl.
class MomentoChip extends StatelessWidget {
  const MomentoChip({
    super.key,
    required this.label,
    this.emoji,
    this.icon,
    this.color,
    this.onTap,
    this.selected = false,
    this.dense = false,
  });

  final String label;
  final String? emoji;
  final IconData? icon;
  final Color? color;
  final VoidCallback? onTap;
  final bool selected;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final accent = color ?? scheme.primary;
    final background = selected
        ? accent.withValues(alpha: 0.20)
        : scheme.surfaceContainerHighest;
    final border = selected ? accent.withValues(alpha: 0.55) : scheme.outline;

    final content = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (emoji != null) ...[
          Text(emoji!, style: TextStyle(fontSize: dense ? 12 : 14)),
          SizedBox(width: dense ? 5 : 7),
        ] else if (icon != null) ...[
          Icon(icon, size: dense ? 14 : 16, color: accent),
          SizedBox(width: dense ? 5 : 7),
        ],
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: (dense
                    ? Theme.of(context).textTheme.labelSmall
                    : Theme.of(context).textTheme.labelMedium)
                ?.copyWith(
              color: selected ? accent : scheme.onSurface,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
            ),
          ),
        ),
      ],
    );

    return Material(
      color: background,
      shape: StadiumBorder(side: BorderSide(color: border, width: selected ? 1.4 : 1)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: dense ? 9 : 12,
            vertical: dense ? 5 : 8,
          ),
          child: content,
        ),
      ),
    );
  }
}

/// Ueberschrift einer Sektion mit Symbol und optionalem Knopf rechts.
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.action,
    this.onAction,
  });

  final String title;
  final String? subtitle;
  final IconData? icon;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, size: 19, color: theme.colorScheme.primary),
          ),
          const SizedBox(width: 11),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(title, style: theme.textTheme.headlineSmall),
              if (subtitle != null)
                Padding(
                  padding: const EdgeInsets.only(top: 1),
                  child: Text(subtitle!, style: theme.textTheme.bodySmall),
                ),
            ],
          ),
        ),
        if (action != null)
          _PillButton(label: action!, onTap: onAction),
      ],
    );
  }
}

class _PillButton extends StatelessWidget {
  const _PillButton({required this.label, this.onTap});

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.secondaryContainer,
      shape: const StadiumBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 8, 10, 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: scheme.onSecondaryContainer,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(width: 2),
              Icon(Icons.chevron_right_rounded,
                  size: 17, color: scheme.onSecondaryContainer),
            ],
          ),
        ),
      ),
    );
  }
}

/// Freundlicher Platzhalter, wenn eine Liste leer ist.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.body,
    this.action,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String body;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 34, vertical: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 84,
              height: 84,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: MomentoGradients.action,
              ),
              child: Icon(icon, size: 38, color: Colors.white),
            ),
            const SizedBox(height: 20),
            Text(title, style: theme.textTheme.headlineSmall, textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(
              body,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            if (action != null) ...[
              const SizedBox(height: 20),
              GradientButton(label: action!, onPressed: onAction, compact: true),
            ],
          ],
        ),
      ),
    );
  }
}

/// Der Hauptknopf der App - im Markenverlauf.
class GradientButton extends StatelessWidget {
  const GradientButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.compact = false,
    this.busy = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool compact;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !busy;
    final child = Row(
      mainAxisSize: compact ? MainAxisSize.min : MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (busy)
          const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2.2, color: Colors.white),
          )
        else if (icon != null)
          Icon(icon, color: Colors.white, size: 20),
        if (busy || icon != null) const SizedBox(width: 10),
        Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
        ),
      ],
    );

    return Opacity(
      opacity: enabled ? 1 : 0.55,
      child: Container(
        decoration: BoxDecoration(
          gradient: MomentoGradients.action,
          borderRadius: BorderRadius.circular(MomentoRadii.chip),
          boxShadow: enabled
              ? [
                  BoxShadow(
                    color: MomentoColors.rose.withValues(alpha: 0.30),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ]
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: enabled ? onPressed : null,
            borderRadius: BorderRadius.circular(MomentoRadii.chip),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: compact ? 24 : 20,
                vertical: compact ? 14 : 17,
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

/// Karte mit weichem Schatten - der Grundbaustein fast aller Bildschirme.
class SoftCard extends StatelessWidget {
  const SoftCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
    this.color,
    this.radius = MomentoRadii.card,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color? color;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: color ?? theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: theme.colorScheme.outline, width: 1),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: const Color(0xFF9A6E86).withValues(alpha: 0.09),
                  blurRadius: 22,
                  offset: const Offset(0, 8),
                ),
              ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}
