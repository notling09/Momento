import 'package:flutter/material.dart';

import '../../core/l10n/app_texts.dart';
import '../../core/momento_controller.dart';
import '../../core/theme/momento_colors.dart';
import '../../widgets/common.dart';
import '../../widgets/memory_widgets.dart';

/// Album anlegen oder bearbeiten: Name, Beschreibung und die Auswahl der
/// Erinnerungen, die hineingehoeren.
class AlbumEditorScreen extends StatefulWidget {
  const AlbumEditorScreen({super.key, this.albumId});

  final String? albumId;

  @override
  State<AlbumEditorScreen> createState() => _AlbumEditorScreenState();
}

class _AlbumEditorScreenState extends State<AlbumEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _description = TextEditingController();
  final _selected = <String>{};
  bool _loaded = false;
  bool _showSelectionError = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loaded) return;
    _loaded = true;

    final id = widget.albumId;
    if (id == null) return;
    final album = AppScope.read(context).albumById(id);
    if (album == null) return;
    _name.text = album.name;
    _description.text = album.description;
    _selected.addAll(album.memoryIds);
  }

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final t = AppTexts.of(context);
    final valid = _formKey.currentState!.validate();
    setState(() => _showSelectionError = _selected.isEmpty);
    if (!valid || _selected.isEmpty) return;

    final controller = AppScope.read(context);
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    // Reihenfolge nach Datum, damit das Album eine Geschichte erzaehlt.
    final ordered = controller.memories
        .where((m) => _selected.contains(m.id))
        .map((m) => m.id)
        .toList();

    await controller.saveAlbum(
      id: widget.albumId,
      name: _name.text.trim(),
      description: _description.text.trim(),
      memoryIds: ordered,
    );

    navigator.pop();
    messenger.showSnackBar(SnackBar(content: Text(t.albumSaved)));
  }

  @override
  Widget build(BuildContext context) {
    final t = AppTexts.of(context);
    final theme = Theme.of(context);
    final memories = AppScope.of(context).memories;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.albumId == null ? t.newAlbum : t.editAlbum),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
          children: [
            TextFormField(
              controller: _name,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: t.albumName,
                hintText: t.albumNameHint,
                prefixIcon: const Icon(Icons.folder_outlined),
              ),
              validator: (value) => (value == null || value.trim().isEmpty)
                  ? t.errorAlbumNameRequired
                  : null,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _description,
              minLines: 2,
              maxLines: 4,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: t.albumDescription,
                hintText: t.albumDescriptionHint,
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: Text(t.albumPickMemories,
                      style: theme.textTheme.titleMedium),
                ),
                Text(
                  t.albumMemoryCount(_selected.length),
                  style: theme.textTheme.labelSmall,
                ),
              ],
            ),
            if (_showSelectionError) ...[
              const SizedBox(height: 6),
              Text(
                t.errorAlbumNeedsMemories,
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: MomentoColors.danger),
              ),
            ],
            const SizedBox(height: 12),
            if (memories.isEmpty)
              EmptyState(
                icon: Icons.photo_library_outlined,
                title: t.memoriesEmptyTitle,
                body: t.memoriesEmptyBody,
              )
            else
              for (final memory in memories)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: MemoryTile(
                    memory: memory,
                    onTap: () => setState(() {
                      if (!_selected.remove(memory.id)) {
                        _selected.add(memory.id);
                      }
                      _showSelectionError = false;
                    }),
                    trailing: _SelectionMark(
                      selected: _selected.contains(memory.id),
                    ),
                  ),
                ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(
          16,
          12,
          16,
          12 + MediaQuery.paddingOf(context).bottom,
        ),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          border: Border(top: BorderSide(color: theme.colorScheme.outline)),
        ),
        child: GradientButton(
          label: t.actionSave,
          icon: Icons.check_rounded,
          onPressed: _save,
        ),
      ),
    );
  }
}

class _SelectionMark extends StatelessWidget {
  const _SelectionMark({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: selected ? MomentoColors.rose : Colors.transparent,
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? MomentoColors.rose : theme.colorScheme.outline,
          width: 1.8,
        ),
      ),
      child: selected
          ? const Icon(Icons.check_rounded, size: 15, color: Colors.white)
          : null,
    );
  }
}
