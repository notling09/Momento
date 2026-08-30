import 'package:flutter/material.dart';

import '../../core/l10n/app_texts.dart';
import '../../core/momento_controller.dart';
import '../../core/theme/momento_colors.dart';
import '../../data/models/memory.dart';
import '../../widgets/common.dart';
import '../../widgets/memory_widgets.dart';
import 'album_detail_screen.dart';
import 'album_editor_screen.dart';

/// Uebersicht ueber alle Alben.
class AlbumsScreen extends StatelessWidget {
  const AlbumsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppTexts.of(context);
    final controller = AppScope.of(context);
    final albums = controller.albums;

    return Scaffold(
      appBar: AppBar(
        title: Text(t.albums),
        actions: [
          IconButton(
            tooltip: t.newAlbum,
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const AlbumEditorScreen()),
            ),
            icon: const Icon(Icons.add_rounded),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: albums.isEmpty
          ? EmptyState(
              icon: Icons.folder_special_rounded,
              title: t.albumEmptyTitle,
              body: t.albumEmptyBody,
              action: t.newAlbum,
              onAction: () => Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const AlbumEditorScreen()),
              ),
            )
          : ListView.separated(
              padding: EdgeInsets.fromLTRB(16, 12, 16, MomentoInsets.bottom(context)),
              itemCount: albums.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final album = albums[index];
                final memories = controller.memoriesOf(album);
                return SoftCard(
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
                        height: 128,
                        width: double.infinity,
                        child: _Mosaic(memories: memories),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 13, 16, 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(album.name,
                                style: Theme.of(context).textTheme.headlineSmall),
                            if (album.description.isNotEmpty) ...[
                              const SizedBox(height: 3),
                              Text(
                                album.description,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                            const SizedBox(height: 9),
                            MomentoChip(
                              label: t.albumMemoryCount(memories.length),
                              icon: Icons.photo_library_rounded,
                              dense: true,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}

class _Mosaic extends StatelessWidget {
  const _Mosaic({required this.memories});

  final List<Memory> memories;

  @override
  Widget build(BuildContext context) {
    if (memories.isEmpty) {
      return const DecoratedBox(
        decoration: BoxDecoration(gradient: MomentoGradients.softCard),
        child: Center(child: Icon(Icons.folder_open_rounded, color: Colors.white70)),
      );
    }
    final shown = memories.take(4).toList();
    return Row(
      children: [
        for (var i = 0; i < shown.length; i++) ...[
          if (i > 0) const SizedBox(width: 2),
          Expanded(
            flex: i == 0 ? 4 : 2,
            child: MemoryCover(memory: shown[i]),
          ),
        ],
      ],
    );
  }
}
