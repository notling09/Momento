import 'package:flutter/material.dart';

import '../../core/l10n/app_texts.dart';
import '../../core/momento_controller.dart';
import '../../core/utils/date_format.dart';
import '../../data/models/memory.dart';
import '../../widgets/common.dart';
import '../../widgets/memory_widgets.dart';
import 'memory_detail_screen.dart';
import 'memory_editor_screen.dart';

enum _Filter { all, favorites, withScent, withSound }

/// Die vollstaendige Liste aller Erinnerungen, nach Monaten gruppiert.
class MemoriesScreen extends StatefulWidget {
  const MemoriesScreen({super.key});

  @override
  State<MemoriesScreen> createState() => _MemoriesScreenState();
}

class _MemoriesScreenState extends State<MemoriesScreen> {
  _Filter _filter = _Filter.all;

  @override
  Widget build(BuildContext context) {
    final t = AppTexts.of(context);
    final controller = AppScope.of(context);

    final all = controller.memories;
    final filtered = switch (_filter) {
      _Filter.all => all,
      _Filter.favorites => all.where((m) => m.isFavorite).toList(),
      _Filter.withScent => all.where((m) => m.hasScent).toList(),
      _Filter.withSound => all.where((m) => m.hasSound).toList(),
    };

    return Scaffold(
      appBar: AppBar(
        title: Text(t.memories),
        actions: [
          IconButton(
            tooltip: t.newMemory,
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const MemoryEditorScreen()),
            ),
            icon: const Icon(Icons.add_rounded),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: Column(
        children: [
          SizedBox(
            height: 46,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                for (final entry in [
                  (_Filter.all, t.filterAll, Icons.apps_rounded),
                  (_Filter.favorites, t.filterFavorites, Icons.favorite_rounded),
                  (_Filter.withScent, t.filterWithScent, Icons.auto_awesome_rounded),
                  (_Filter.withSound, t.filterWithSound, Icons.graphic_eq_rounded),
                ])
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: MomentoChip(
                      label: entry.$2,
                      icon: entry.$3,
                      selected: _filter == entry.$1,
                      onTap: () => setState(() => _filter = entry.$1),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: filtered.isEmpty
                ? EmptyState(
                    icon: Icons.photo_library_rounded,
                    title: t.memoriesEmptyTitle,
                    body: t.memoriesEmptyBody,
                    action: t.newMemory,
                    onAction: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const MemoryEditorScreen(),
                      ),
                    ),
                  )
                : _GroupedList(memories: filtered),
          ),
        ],
      ),
    );
  }
}

/// Gruppiert die Erinnerungen nach Monat - so wird die Liste zur Zeitreise.
class _GroupedList extends StatelessWidget {
  const _GroupedList({required this.memories});

  final List<Memory> memories;

  @override
  Widget build(BuildContext context) {
    final t = AppTexts.of(context);
    final theme = Theme.of(context);
    final controller = AppScope.read(context);

    final groups = <String, List<Memory>>{};
    for (final memory in memories) {
      final key = MomentoDates.monthYear(memory.happenedAt, t);
      groups.putIfAbsent(key, () => []).add(memory);
    }

    final entries = groups.entries.toList();

    return ListView.builder(
      padding: EdgeInsets.fromLTRB(16, 8, 16, MomentoInsets.bottom(context)),
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final entry = entries[index];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(top: index == 0 ? 4 : 22, bottom: 10),
              child: Row(
                children: [
                  Text(entry.key, style: theme.textTheme.titleMedium),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      height: 1,
                      color: theme.colorScheme.outline,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    t.memoryCount(entry.value.length),
                    style: theme.textTheme.labelSmall,
                  ),
                ],
              ),
            ),
            for (final memory in entry.value)
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
        );
      },
    );
  }
}
