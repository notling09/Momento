import 'package:flutter/material.dart';

import '../../core/l10n/app_texts.dart';
import '../../core/momento_controller.dart';
import '../../core/theme/momento_colors.dart';
import '../../widgets/common.dart';
import '../../widgets/memory_widgets.dart';
import '../memories/memory_detail_screen.dart';
import 'album_editor_screen.dart';

/// Ein Album mit allen Erinnerungen, Duefte und Geraeuschen darin.
class AlbumDetailScreen extends StatelessWidget {
  const AlbumDetailScreen({super.key, required this.albumId});

  final String albumId;

  @override
  Widget build(BuildContext context) {
    final t = AppTexts.of(context);
    final theme = Theme.of(context);
    final controller = AppScope.of(context);
    final album = controller.albumById(albumId);

    if (album == null) {
      return Scaffold(
        appBar: AppBar(),
        body: EmptyState(
          icon: Icons.folder_off_outlined,
          title: t.albumEmptyTitle,
          body: t.albumEmptyBody,
        ),
      );
    }

    final memories = controller.memoriesOf(album);
    final scents = memories.where((m) => m.hasScent).length;
    final sounds = memories.where((m) => m.hasSound).length;

    return Scaffold(
      appBar: AppBar(
        title: Text(album.name),
        actions: [
          IconButton(
            tooltip: t.actionEdit,
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => AlbumEditorScreen(albumId: album.id),
              ),
            ),
            icon: const Icon(Icons.edit_rounded),
          ),
          IconButton(
            tooltip: t.actionDelete,
            onPressed: () async {
              final navigator = Navigator.of(context);
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (dialogContext) => AlertDialog(
                  title: Text(t.actionDelete),
                  content: Text(t.albumDeleteConfirm),
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
                await controller.deleteAlbum(album.id);
                navigator.pop();
              }
            },
            icon: const Icon(Icons.delete_outline_rounded),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(16, 8, 16, MomentoInsets.bottom(context)),
        children: [
          if (album.description.isNotEmpty) ...[
            SoftCard(
              padding: const EdgeInsets.all(16),
              child: Text(
                album.description,
                style: theme.textTheme.bodyLarge?.copyWith(height: 1.55),
              ),
            ),
            const SizedBox(height: 14),
          ],
          // Umbrechen statt abschneiden - auf schmalen Geraeten passen die
          // drei Zahlen sonst nicht nebeneinander.
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              MomentoChip(
                label: t.albumMemoryCount(memories.length),
                icon: Icons.photo_library_rounded,
              ),
              MomentoChip(
                label: '$scents ${t.statsScents}',
                icon: Icons.auto_awesome_rounded,
                color: MomentoColors.scentAccent,
              ),
              MomentoChip(
                label: '$sounds ${t.statsSounds}',
                icon: Icons.graphic_eq_rounded,
                color: MomentoColors.soundAccent,
              ),
            ],
          ),
          const SizedBox(height: 18),
          if (memories.isEmpty)
            EmptyState(
              icon: Icons.photo_library_outlined,
              title: t.memoriesEmptyTitle,
              body: t.errorAlbumNeedsMemories,
            )
          else
            for (final memory in memories)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: MemoryTile(
                  memory: memory,
                  onFavorite: () => controller.toggleFavorite(memory.id),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => MemoryDetailScreen(memoryId: memory.id),
                    ),
                  ),
                ),
              ),
        ],
      ),
    );
  }
}
