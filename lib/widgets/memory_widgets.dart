import 'package:flutter/material.dart';

import '../core/l10n/app_texts.dart';
import '../core/theme/momento_colors.dart';
import '../core/theme/momento_theme.dart';
import '../core/utils/date_format.dart';
import '../data/models/memory.dart';
import 'common.dart';
import 'scene_cover.dart';

/// Das Titelbild einer Erinnerung: das eigene Foto, sonst die gezeichnete Szene.
class MemoryCover extends StatelessWidget {
  const MemoryCover({super.key, required this.memory, this.fit = BoxFit.cover});

  final Memory memory;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    if (memory.hasPhoto) {
      return StoredImageView(
        media: memory.photo!,
        fit: fit,
        fallback: SceneCover(scene: memory.effectiveScene),
      );
    }
    return SceneCover(scene: memory.effectiveScene);
  }
}

/// Die grosse Karte von der Startseite (Abbildung 1 im Businessplan):
/// Bild mit Datumsschild, handschriftlichem Titel und den drei Bausteinen
/// Erinnerung / Duft / Sound darunter.
class FlashbackCard extends StatelessWidget {
  const FlashbackCard({super.key, required this.memory, this.onTap});

  final Memory memory;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final t = AppTexts.of(context);
    final theme = Theme.of(context);

    return SoftCard(
      padding: EdgeInsets.zero,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AspectRatio(
            aspectRatio: 16 / 11,
            child: Stack(
              fit: StackFit.expand,
              children: [
                MemoryCover(memory: memory),
                // Abdunklung, damit der Titel lesbar bleibt - in mehreren
                // Stufen, damit keine sichtbare Kante entsteht.
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Color(0x1A000000),
                        Color(0x59000000),
                        Color(0x99000000),
                      ],
                      stops: [0.0, 0.45, 0.75, 1.0],
                    ),
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: _DateBadge(date: memory.happenedAt),
                ),
                if (memory.isFavorite)
                  const Positioned(top: 12, left: 12, child: _FavoriteBadge()),
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 14,
                  child: _HandwrittenTitle(title: memory.title),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
            child: Row(
              children: [
                Expanded(
                  child: _BuildingBlock(
                    icon: Icons.favorite_rounded,
                    color: MomentoColors.memoryAccent,
                    title: t.memory,
                    value: memory.place ?? MomentoDates.shortDay(memory.happenedAt, t),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _BuildingBlock(
                    icon: Icons.auto_awesome_rounded,
                    color: MomentoColors.scentAccent,
                    title: t.memoryScent,
                    value: memory.hasScent ? memory.scent!.label(t) : '–',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _BuildingBlock(
                    icon: Icons.graphic_eq_rounded,
                    color: MomentoColors.soundAccent,
                    title: t.memorySound,
                    value: memory.hasSound
                        ? (memory.sound!.label ?? t.memorySound)
                        : '–',
                  ),
                ),
              ],
            ),
          ),
          if (memory.story.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(
                memory.story,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall,
              ),
            ),
        ],
      ),
    );
  }
}

class _DateBadge extends StatelessWidget {
  const _DateBadge({required this.date});

  final DateTime date;

  @override
  Widget build(BuildContext context) {
    final t = AppTexts.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.90),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.calendar_today_rounded,
              size: 13, color: MomentoColors.plumInk),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                MomentoDates.shortDay(date, t),
                style: const TextStyle(
                  fontFamily: MomentoFonts.body,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: MomentoColors.ink,
                  height: 1.15,
                ),
              ),
              Text(
                MomentoDates.time(date, t),
                style: const TextStyle(
                  fontFamily: MomentoFonts.body,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w500,
                  color: MomentoColors.inkSoft,
                  height: 1.15,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FavoriteBadge extends StatelessWidget {
  const _FavoriteBadge();

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(7),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.90),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.favorite_rounded,
            size: 15, color: MomentoColors.rose),
      );
}

/// Der Titel auf dem Bild - wie handgeschrieben, mit Unterstrich und Herz.
class _HandwrittenTitle extends StatelessWidget {
  const _HandwrittenTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: MomentoFonts.display,
              fontSize: 21,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              height: 1.15,
              shadows: [
                Shadow(color: Color(0x66000000), blurRadius: 10, offset: Offset(0, 2)),
              ],
            ),
          ),
          const SizedBox(height: 5),
          Row(
            children: [
              Container(
                width: 74,
                height: 2.4,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 7),
              Icon(Icons.favorite_rounded,
                  size: 13, color: Colors.white.withValues(alpha: 0.9)),
            ],
          ),
        ],
      );
}

/// Einer der drei Bausteine unter dem Bild.
class _BuildingBlock extends StatelessWidget {
  const _BuildingBlock({
    required this.icon,
    required this.color,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 9),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.18),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 13, color: color),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurface,
                    height: 1.1,
                  ),
                ),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontSize: 9.8,
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Eintrag in der Erinnerungsliste.
class MemoryTile extends StatelessWidget {
  const MemoryTile({
    super.key,
    required this.memory,
    this.onTap,
    this.onFavorite,
    this.trailing,
  });

  final Memory memory;
  final VoidCallback? onTap;
  final VoidCallback? onFavorite;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final t = AppTexts.of(context);
    final theme = Theme.of(context);

    return SoftCard(
      padding: const EdgeInsets.all(10),
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: SizedBox(
              width: 78,
              height: 78,
              child: MemoryCover(memory: memory),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        memory.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium,
                      ),
                    ),
                    if (trailing != null) trailing!,
                    if (trailing == null && onFavorite != null)
                      GestureDetector(
                        onTap: onFavorite,
                        behavior: HitTestBehavior.opaque,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 6, bottom: 4),
                          child: Icon(
                            memory.isFavorite
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                            size: 19,
                            color: memory.isFavorite
                                ? MomentoColors.rose
                                : theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  [
                    MomentoDates.shortDay(memory.happenedAt, t),
                    if (memory.place != null && memory.place!.isNotEmpty)
                      memory.place!,
                  ].join('  ·  '),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall,
                ),
                const SizedBox(height: 7),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    if (memory.feeling != null)
                      MomentoChip(
                        label: memory.feeling!.label(t),
                        emoji: memory.feeling!.emoji,
                        color: memory.feeling!.color,
                        dense: true,
                      ),
                    if (memory.hasScent)
                      MomentoChip(
                        label: memory.scent!.label(t),
                        emoji: memory.scent!.emoji,
                        color: memory.scent!.color,
                        dense: true,
                      ),
                    if (memory.hasSound)
                      MomentoChip(
                        label: memory.sound!.label ?? t.memorySound,
                        icon: Icons.graphic_eq_rounded,
                        color: MomentoColors.soundAccent,
                        dense: true,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Kompakte Kachel fuer waagrechte Listen.
class MemoryMiniCard extends StatelessWidget {
  const MemoryMiniCard({super.key, required this.memory, this.onTap, this.width = 150});

  final Memory memory;
  final VoidCallback? onTap;
  final double width;

  @override
  Widget build(BuildContext context) {
    final t = AppTexts.of(context);
    final theme = Theme.of(context);
    return SizedBox(
      width: width,
      child: SoftCard(
        padding: EdgeInsets.zero,
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 1.25,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  MemoryCover(memory: memory),
                  if (memory.hasSound)
                    Positioned(
                      right: 7,
                      top: 7,
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.88),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.graphic_eq_rounded,
                            size: 12, color: MomentoColors.soundAccent),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(11, 10, 11, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    memory.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall?.copyWith(height: 1.25),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    MomentoDates.shortDay(memory.happenedAt, t),
                    style: theme.textTheme.labelSmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
