import 'package:flutter/material.dart';

import '../../core/l10n/app_texts.dart';
import '../../core/momento_controller.dart';
import '../../core/theme/momento_colors.dart';
import '../../core/theme/momento_theme.dart';
import '../../data/models/album.dart';
import '../../data/models/memory.dart';
import '../../widgets/common.dart';
import '../../widgets/memory_widgets.dart';
import '../../widgets/momento_logo.dart';
import '../../widgets/scene_cover.dart';
import '../albums/album_detail_screen.dart';
import '../albums/album_editor_screen.dart';
import '../albums/albums_screen.dart';
import '../memories/memories_screen.dart';
import '../memories/memory_detail_screen.dart';
import '../memories/memory_editor_screen.dart';

/// Die Startseite - direkt nach dem Konzeptbild aus dem Businessplan gebaut.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.onOpenMenu});

  final VoidCallback onOpenMenu;

  @override
  Widget build(BuildContext context) {
    final t = AppTexts.of(context);
    final controller = AppScope.of(context);
    final memories = controller.memories;
    final albums = controller.albums;

    final today = controller.now();
    final flashbacks = memories
        .where((m) => m.anniversaryYears(today) != null)
        .toList()
      ..sort((a, b) => a.anniversaryYears(today)!.compareTo(b.anniversaryYears(today)!));

    final recent = [...memories]
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: _Header(onOpenMenu: onOpenMenu),
          ),
          SliverPadding(
            padding: EdgeInsets.fromLTRB(16, 22, 16, MomentoInsets.aboveNavBar(context)),
            sliver: SliverList.list(
              children: [
                _StatsRow(memories: memories, albums: albums),
                const SizedBox(height: 26),

                // --- Flashbacks ---------------------------------------
                SectionHeader(
                  title: flashbacks.isEmpty
                      ? t.onThisDay
                      : t.flashbackYearsAgo(flashbacks.first.anniversaryYears(today)!),
                  subtitle: flashbacks.isEmpty
                      ? null
                      : t.memoryCount(flashbacks.length),
                  icon: Icons.history_rounded,
                  action: memories.isEmpty ? null : t.actionShowAll,
                  onAction: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(builder: (_) => const MemoriesScreen()),
                  ),
                ),
                const SizedBox(height: 14),
                if (flashbacks.isEmpty)
                  const _NoFlashbackCard()
                else
                  _FlashbackCarousel(memories: flashbacks),

                const SizedBox(height: 30),

                // --- Alben ---------------------------------------------
                SectionHeader(
                  title: t.albumsSection,
                  subtitle: t.albumsSectionSub,
                  icon: Icons.folder_special_rounded,
                  action: albums.isEmpty ? null : t.actionShowAll,
                  onAction: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(builder: (_) => const AlbumsScreen()),
                  ),
                ),
                const SizedBox(height: 14),
                if (albums.isEmpty)
                  const _CreateAlbumCard()
                else
                  _AlbumStrip(albums: albums),

                const SizedBox(height: 30),

                // --- Zuletzt festgehalten -------------------------------
                if (recent.isNotEmpty) ...[
                  SectionHeader(
                    title: t.recentSection,
                    subtitle: t.recentSectionSub,
                    icon: Icons.auto_awesome_rounded,
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    height: 208,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      clipBehavior: Clip.none,
                      itemCount: recent.length > 8 ? 8 : recent.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (context, index) => MemoryMiniCard(
                        memory: recent[index],
                        onTap: () => _openMemory(context, recent[index]),
                      ),
                    ),
                  ),
                ] else
                  const _EmptyMemoriesCard(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static void _openMemory(BuildContext context, Memory memory) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => MemoryDetailScreen(memoryId: memory.id),
      ),
    );
  }
}

/// Der Farbverlauf-Kopf mit geschwungener Unterkante.
class _Header extends StatelessWidget {
  const _Header({required this.onOpenMenu});

  final VoidCallback onOpenMenu;

  @override
  Widget build(BuildContext context) {
    final t = AppTexts.of(context);
    final user = AppScope.of(context).user;
    final topPadding = MediaQuery.paddingOf(context).top;

    return ClipPath(
      clipper: _CurvedBottomClipper(),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.fromLTRB(16, topPadding + 10, 16, 46),
        decoration: const BoxDecoration(gradient: MomentoGradients.header),
        child: Column(
          children: [
            Row(
              children: [
                _GlassButton(
                  icon: Icons.menu_rounded,
                  label: t.menuOpen,
                  onTap: onOpenMenu,
                ),
                const Spacer(),
                _GlassButton(
                  icon: Icons.add_rounded,
                  label: t.newMemory,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const MemoryEditorScreen(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            MomentoWordmark(height: 62, tint: Colors.white),
            const SizedBox(height: 10),
            Text(
              user == null
                  ? t.homeWelcome
                  : '${t.homeWelcome.replaceAll('!', '')}, ${user.displayName}!',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: MomentoFonts.display,
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              t.homeWelcomeSub,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: MomentoFonts.body,
                fontSize: 13.5,
                color: Colors.white.withValues(alpha: 0.92),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Weiche Rundung am unteren Rand des Kopfbereichs.
class _CurvedBottomClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) => Path()
    ..lineTo(0, size.height - 34)
    ..quadraticBezierTo(size.width / 2, size.height + 20, size.width, size.height - 34)
    ..lineTo(size.width, 0)
    ..close();

  @override
  bool shouldReclip(_CurvedBottomClipper oldClipper) => false;
}

class _GlassButton extends StatelessWidget {
  const _GlassButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;

  /// Wird vorgelesen und als Tooltip angezeigt - der Knopf zeigt sonst nur
  /// ein Symbol.
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Tooltip(
        message: label,
        child: Material(
          color: Colors.white.withValues(alpha: 0.30),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: Semantics(
              button: true,
              label: label,
              child: SizedBox(
                width: 44,
                height: 44,
                child: Icon(icon, color: Colors.white, size: 23),
              ),
            ),
          ),
        ),
      );
}

/// Vier kleine Zahlen: Erinnerungen, Alben, Duefte, Sounds.
class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.memories, required this.albums});

  final List<Memory> memories;
  final List<Album> albums;

  @override
  Widget build(BuildContext context) {
    final t = AppTexts.of(context);
    final scents = memories.where((m) => m.hasScent).length;
    final sounds = memories.where((m) => m.hasSound).length;

    return Row(
      children: [
        Expanded(child: _StatTile(value: memories.length, label: t.statsMemories, color: MomentoColors.rose)),
        const SizedBox(width: 9),
        Expanded(child: _StatTile(value: albums.length, label: t.statsAlbums, color: MomentoColors.violet)),
        const SizedBox(width: 9),
        Expanded(child: _StatTile(value: scents, label: t.statsScents, color: MomentoColors.orchid)),
        const SizedBox(width: 9),
        Expanded(child: _StatTile(value: sounds, label: t.statsSounds, color: MomentoColors.soundAccent)),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.value, required this.label, required this.color});

  final int value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: theme.brightness == Brightness.dark ? 0.18 : 0.12),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            '$value',
            style: theme.textTheme.headlineMedium?.copyWith(
              color: theme.brightness == Brightness.dark
                  ? theme.colorScheme.onSurface
                  : color,
            ),
          ),
          // Lange Woerter wie "Erinnerungen" duerfen schrumpfen statt
          // abgeschnitten zu werden.
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              maxLines: 1,
              style: theme.textTheme.labelSmall,
            ),
          ),
        ],
      ),
    );
  }
}

/// Mehrere Flashbacks werden als wischbare Karten gezeigt - mit Punkten
/// darunter, genau wie im Konzeptbild.
class _FlashbackCarousel extends StatefulWidget {
  const _FlashbackCarousel({required this.memories});

  final List<Memory> memories;

  @override
  State<_FlashbackCarousel> createState() => _FlashbackCarouselState();
}

class _FlashbackCarouselState extends State<_FlashbackCarousel> {
  final _controller = PageController(viewportFraction: 0.995);
  int _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final single = widget.memories.length == 1;

    return Column(
      children: [
        SizedBox(
          height: 372,
          child: PageView.builder(
            controller: _controller,
            itemCount: widget.memories.length,
            onPageChanged: (index) => setState(() => _page = index),
            itemBuilder: (context, index) {
              final memory = widget.memories[index];
              return FlashbackCard(
                memory: memory,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => MemoryDetailScreen(memoryId: memory.id),
                  ),
                ),
              );
            },
          ),
        ),
        if (!single) ...[
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 0; i < widget.memories.length; i++)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 240),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: i == _page ? 18 : 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: i == _page
                        ? MomentoColors.rose
                        : theme.colorScheme.outline,
                    borderRadius: BorderRadius.circular(7),
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }
}

class _NoFlashbackCard extends StatelessWidget {
  const _NoFlashbackCard();

  @override
  Widget build(BuildContext context) {
    final t = AppTexts.of(context);
    final theme = Theme.of(context);
    return SoftCard(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              gradient: MomentoGradients.action,
              borderRadius: BorderRadius.circular(17),
            ),
            child: const Icon(Icons.hourglass_empty_rounded,
                color: Colors.white, size: 24),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(t.flashbackNoneTitle, style: theme.textTheme.titleMedium),
                const SizedBox(height: 3),
                Text(t.flashbackNoneBody, style: theme.textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Die Alben-Karte aus dem Konzeptbild: Farbverlauf, Text und ein Knopf.
class _CreateAlbumCard extends StatelessWidget {
  const _CreateAlbumCard();

  @override
  Widget build(BuildContext context) {
    final t = AppTexts.of(context);
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 12, 20),
      decoration: BoxDecoration(
        gradient: MomentoGradients.softCardFor(theme.brightness),
        borderRadius: BorderRadius.circular(MomentoRadii.card),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  t.albumsEmptyCardTitle,
                  style: theme.textTheme.headlineSmall?.copyWith(height: 1.25),
                ),
                const SizedBox(height: 16),
                GradientButton(
                  label: t.createAlbum,
                  icon: Icons.add_rounded,
                  compact: true,
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(builder: (_) => const AlbumEditorScreen()),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Expanded(flex: 3, child: _AlbumArtwork()),
        ],
      ),
    );
  }
}

/// Kleine Illustration: drei gestapelte Erinnerungen mit einem Herz.
class _AlbumArtwork extends StatelessWidget {
  const _AlbumArtwork();

  @override
  Widget build(BuildContext context) => SizedBox(
        height: 116,
        child: Stack(
          alignment: Alignment.center,
          children: [
            for (final entry in const [
              (CoverScene.beach, -0.26, Offset(-26, 4)),
              (CoverScene.springMeadow, 0.24, Offset(26, 4)),
              (CoverScene.lakeSunset, 0.0, Offset(0, -6)),
            ])
              Transform.translate(
                offset: entry.$3,
                child: Transform.rotate(
                  angle: entry.$2,
                  child: Container(
                    width: 62,
                    height: 78,
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: MomentoColors.plum.withValues(alpha: 0.24),
                          blurRadius: 14,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: SceneCover(scene: entry.$1),
                    ),
                  ),
                ),
              ),
            Positioned(
              bottom: 10,
              child: Container(
                padding: const EdgeInsets.all(7),
                decoration: const BoxDecoration(
                  gradient: MomentoGradients.action,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.favorite_rounded,
                    size: 15, color: Colors.white),
              ),
            ),
          ],
        ),
      );
}

/// Waagrechte Liste der vorhandenen Alben.
class _AlbumStrip extends StatelessWidget {
  const _AlbumStrip({required this.albums});

  final List<Album> albums;

  @override
  Widget build(BuildContext context) {
    final t = AppTexts.of(context);
    final controller = AppScope.of(context);
    final theme = Theme.of(context);

    return SizedBox(
      height: 158,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        itemCount: albums.length + 1,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          if (index == albums.length) {
            return SizedBox(
              width: 132,
              child: SoftCard(
                padding: const EdgeInsets.all(14),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(builder: (_) => const AlbumEditorScreen()),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        gradient: MomentoGradients.action,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.add_rounded,
                          color: Colors.white, size: 22),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      t.newAlbum,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleSmall,
                    ),
                  ],
                ),
              ),
            );
          }

          final album = albums[index];
          final memories = controller.memoriesOf(album);
          return SizedBox(
            width: 176,
            child: SoftCard(
              padding: EdgeInsets.zero,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => AlbumDetailScreen(albumId: album.id),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 92,
                    width: double.infinity,
                    child: _AlbumMosaic(memories: memories),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 9, 12, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          album.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleSmall,
                        ),
                        Text(
                          t.albumMemoryCount(memories.length),
                          style: theme.textTheme.labelSmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Titelbild eines Albums: bis zu drei Erinnerungen nebeneinander.
class _AlbumMosaic extends StatelessWidget {
  const _AlbumMosaic({required this.memories});

  final List<Memory> memories;

  @override
  Widget build(BuildContext context) {
    if (memories.isEmpty) {
      return const DecoratedBox(
        decoration: BoxDecoration(gradient: MomentoGradients.softCard),
        child: Center(
          child: Icon(Icons.folder_open_rounded, color: Colors.white70),
        ),
      );
    }
    final shown = memories.take(3).toList();
    return Row(
      children: [
        for (var i = 0; i < shown.length; i++) ...[
          if (i > 0) const SizedBox(width: 2),
          Expanded(
            flex: i == 0 ? 3 : 2,
            child: MemoryCover(memory: shown[i]),
          ),
        ],
      ],
    );
  }
}

class _EmptyMemoriesCard extends StatelessWidget {
  const _EmptyMemoriesCard();

  @override
  Widget build(BuildContext context) {
    final t = AppTexts.of(context);
    return SoftCard(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: EmptyState(
        icon: Icons.auto_awesome_rounded,
        title: t.memoriesEmptyTitle,
        body: t.memoriesEmptyBody,
        action: t.newMemory,
        onAction: () => Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => const MemoryEditorScreen()),
        ),
      ),
    );
  }
}
