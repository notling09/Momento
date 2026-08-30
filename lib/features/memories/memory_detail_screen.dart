import 'package:flutter/material.dart';

import '../../core/l10n/app_texts.dart';
import '../../core/momento_controller.dart';
import '../../core/theme/momento_colors.dart';
import '../../core/theme/momento_theme.dart';
import '../../core/utils/date_format.dart';
import '../../data/models/memory.dart';
import '../../widgets/common.dart';
import '../../widgets/memory_widgets.dart';
import '../../widgets/sound_player.dart';
import '../albums/album_detail_screen.dart';
import 'memory_editor_screen.dart';

/// Eine Erinnerung in voller Groesse: Bild, Text, Duft, Geraeusch, Ort,
/// Menschen und Gefuehl.
class MemoryDetailScreen extends StatelessWidget {
  const MemoryDetailScreen({super.key, required this.memoryId});

  final String memoryId;

  @override
  Widget build(BuildContext context) {
    final t = AppTexts.of(context);
    final theme = Theme.of(context);
    final controller = AppScope.of(context);
    final memory = controller.memoryById(memoryId);

    if (memory == null) {
      // Die Erinnerung wurde geloescht, waehrend die Seite offen war.
      return Scaffold(
        appBar: AppBar(),
        body: EmptyState(
          icon: Icons.search_off_rounded,
          title: t.searchNoResultsTitle,
          body: t.memoriesEmptyBody,
        ),
      );
    }

    final albums = controller.albums
        .where((album) => album.memoryIds.contains(memory.id))
        .toList();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 320,
            pinned: true,
            stretch: true,
            backgroundColor: theme.colorScheme.surface,
            surfaceTintColor: Colors.transparent,
            leading: const _RoundIconButton(icon: Icons.arrow_back_rounded),
            actions: [
              _RoundIconButton(
                icon: memory.isFavorite
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
                color: memory.isFavorite ? MomentoColors.rose : null,
                onTap: () => controller.toggleFavorite(memory.id),
              ),
              const SizedBox(width: 6),
              _RoundIconButton(
                icon: Icons.edit_rounded,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => MemoryEditorScreen(memoryId: memory.id),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              _RoundIconButton(
                icon: Icons.delete_outline_rounded,
                onTap: () => _confirmDelete(context, memory),
              ),
              const SizedBox(width: 10),
            ],
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [StretchMode.zoomBackground],
              background: Stack(
                fit: StackFit.expand,
                children: [
                  MemoryCover(memory: memory),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0x66000000), Colors.transparent, Color(0x40000000)],
                        stops: [0, 0.45, 1],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.fromLTRB(16, 20, 16, MomentoInsets.bottom(context)),
            sliver: SliverList.list(
              children: [
                Text(memory.title, style: theme.textTheme.displaySmall),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.event_rounded,
                        size: 16, color: theme.colorScheme.onSurfaceVariant),
                    const SizedBox(width: 7),
                    Expanded(
                      child: Text(
                        MomentoDates.dayAndTime(memory.happenedAt, t),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
                if (memory.place != null && memory.place!.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.place_outlined,
                          size: 16, color: theme.colorScheme.onSurfaceVariant),
                      const SizedBox(width: 7),
                      Expanded(
                        child: Text(
                          memory.place!,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 16),

                if (memory.feeling != null || memory.people.isNotEmpty) ...[
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (memory.feeling != null)
                        MomentoChip(
                          label: memory.feeling!.label(t),
                          emoji: memory.feeling!.emoji,
                          color: memory.feeling!.color,
                          selected: true,
                        ),
                      for (final person in memory.people)
                        MomentoChip(
                          label: person,
                          icon: Icons.person_rounded,
                          color: MomentoColors.plumInk,
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],

                if (memory.story.trim().isNotEmpty) ...[
                  SoftCard(
                    padding: const EdgeInsets.all(18),
                    child: Text(
                      memory.story,
                      style: theme.textTheme.bodyLarge?.copyWith(height: 1.62),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                if (memory.hasScent) ...[
                  _ScentCard(memory: memory),
                  const SizedBox(height: 16),
                ],

                if (memory.hasSound) ...[
                  SoundPlayerBar(clip: memory.sound!),
                  const SizedBox(height: 16),
                ],

                if (albums.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(t.albums, style: theme.textTheme.titleMedium),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final album in albums)
                        MomentoChip(
                          label: album.name,
                          icon: Icons.folder_rounded,
                          color: MomentoColors.violet,
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => AlbumDetailScreen(albumId: album.id),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],

                _SyncNote(memory: memory),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, Memory memory) async {
    final t = AppTexts.of(context);
    final controller = AppScope.read(context);
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(t.actionDelete),
        content: Text(t.memoryDeleteConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(t.actionCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(
              t.actionDelete,
              style: const TextStyle(color: MomentoColors.danger),
            ),
          ),
        ],
      ),
    );

    if (confirmed ?? false) {
      await controller.deleteMemory(memory.id);
      navigator.pop();
      messenger.showSnackBar(SnackBar(content: Text(t.memoryDeleted)));
    }
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({required this.icon, this.onTap, this.color});

  final IconData icon;
  final VoidCallback? onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) => Center(
        child: Material(
          color: Colors.black.withValues(alpha: 0.34),
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap ?? () => Navigator.of(context).maybePop(),
            child: SizedBox(
              width: 38,
              height: 38,
              child: Icon(icon, size: 20, color: color ?? Colors.white),
            ),
          ),
        ),
      );
}

/// Der Duft als eigene Karte - mit Symbol, Namen und Intensitaet.
class _ScentCard extends StatelessWidget {
  const _ScentCard({required this.memory});

  final Memory memory;

  @override
  Widget build(BuildContext context) {
    final t = AppTexts.of(context);
    final theme = Theme.of(context);
    final scent = memory.scent!;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scent.color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(MomentoRadii.card),
        border: Border.all(color: scent.color.withValues(alpha: 0.30)),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: scent.color.withValues(alpha: 0.22),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(scent.emoji, style: const TextStyle(fontSize: 21)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(t.memoryScent, style: theme.textTheme.labelSmall),
                Text(scent.label(t), style: theme.textTheme.titleMedium),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  for (var i = 1; i <= 3; i++)
                    Padding(
                      padding: const EdgeInsets.only(left: 3),
                      child: Container(
                        width: 7,
                        height: 7 + (i * 5),
                        decoration: BoxDecoration(
                          color: i <= scent.intensity.level
                              ? scent.color
                              : scent.color.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 5),
              Text(scent.intensity.label(t), style: theme.textTheme.labelSmall),
            ],
          ),
        ],
      ),
    );
  }
}

/// Zeigt, ob die Erinnerung schon verarbeitet wurde.
class _SyncNote extends StatelessWidget {
  const _SyncNote({required this.memory});

  final Memory memory;

  @override
  Widget build(BuildContext context) {
    final t = AppTexts.of(context);
    final theme = Theme.of(context);
    final synced = memory.syncState == SyncState.synced;

    return Row(
      children: [
        Icon(
          synced ? Icons.cloud_done_rounded : Icons.cloud_queue_rounded,
          size: 16,
          color: synced ? MomentoColors.success : MomentoColors.warning,
        ),
        const SizedBox(width: 8),
        Text(
          synced ? t.syncStateSynced : t.syncStatePending,
          style: theme.textTheme.labelSmall,
        ),
        const Spacer(),
        Flexible(
          child: Text(
            '${t.memoryCapturedOn} ${MomentoDates.relativeDay(memory.createdAt, t)}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.end,
            style: theme.textTheme.labelSmall,
          ),
        ),
      ],
    );
  }
}
