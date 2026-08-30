import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/l10n/app_texts.dart';
import '../../core/momento_controller.dart';
import '../../core/theme/momento_colors.dart';
import '../../core/theme/momento_theme.dart';
import '../../core/utils/date_format.dart';
import '../../data/models/feeling.dart';
import '../../data/models/memory.dart';
import '../../data/models/scent.dart';
import '../../data/models/stored_media.dart';
import '../../widgets/common.dart';
import '../../widgets/scene_cover.dart';
import '../../widgets/scent_picker_sheet.dart';
import '../../widgets/sound_recorder_field.dart';

/// Erfasst eine neue Erinnerung oder bearbeitet eine bestehende.
class MemoryEditorScreen extends StatefulWidget {
  const MemoryEditorScreen({super.key, this.memoryId});

  final String? memoryId;

  @override
  State<MemoryEditorScreen> createState() => _MemoryEditorScreenState();
}

class _MemoryEditorScreenState extends State<MemoryEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _story = TextEditingController();
  final _place = TextEditingController();
  final _people = TextEditingController();

  DateTime _happenedAt = DateTime.now();
  Feeling? _feeling;
  Scent? _scent;
  SoundClip? _sound;
  StoredMedia? _photo;
  CoverScene? _scene;
  bool _favorite = false;
  bool _busy = false;
  bool _loaded = false;

  bool get _isEditing => widget.memoryId != null;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loaded) return;
    _loaded = true;

    final id = widget.memoryId;
    if (id == null) {
      _scene = CoverScene.suggestFor(_happenedAt);
      return;
    }

    final memory = AppScope.read(context).memoryById(id);
    if (memory == null) return;
    _title.text = memory.title;
    _story.text = memory.story;
    _place.text = memory.place ?? '';
    _people.text = memory.people.join(', ');
    _happenedAt = memory.happenedAt;
    _feeling = memory.feeling;
    _scent = memory.scent;
    _sound = memory.sound;
    _photo = memory.photo;
    _scene = memory.coverScene ?? memory.effectiveScene;
    _favorite = memory.isFavorite;
  }

  @override
  void dispose() {
    _title.dispose();
    _story.dispose();
    _place.dispose();
    _people.dispose();
    super.dispose();
  }

  // --- Aktionen ----------------------------------------------------------

  Future<void> _pickPhoto(ImageSource source) async {
    final controller = AppScope.read(context);
    try {
      final file = await ImagePicker().pickImage(
        source: source,
        maxWidth: 1800,
        imageQuality: 85,
      );
      if (file == null) return;
      final bytes = await file.readAsBytes();
      final media = await controller.storeMedia(
        bytes,
        extension: 'jpg',
        mimeType: 'image/jpeg',
      );
      if (!mounted) return;
      setState(() => _photo = media);
    } catch (_) {
      if (!mounted) return;
      // Kein Zugriff auf Kamera oder Galerie - die App laeuft trotzdem weiter.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppTexts.of(context).memoryPhotoAdd)),
      );
    }
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _happenedAt,
      firstDate: DateTime(1950),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_happenedAt),
    );
    if (!mounted) return;

    setState(() {
      _happenedAt = DateTime(
        date.year,
        date.month,
        date.day,
        time?.hour ?? _happenedAt.hour,
        time?.minute ?? _happenedAt.minute,
      );
    });
  }

  Future<void> _save() async {
    final t = AppTexts.of(context);
    if (!_formKey.currentState!.validate()) return;

    setState(() => _busy = true);
    final controller = AppScope.read(context);
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    final people = _people.text
        .split(',')
        .map((p) => p.trim())
        .where((p) => p.isNotEmpty)
        .toList();

    final draft = Memory(
      id: widget.memoryId ?? '',
      title: _title.text.trim(),
      story: _story.text.trim(),
      place: _place.text.trim().isEmpty ? null : _place.text.trim(),
      people: people,
      happenedAt: _happenedAt,
      createdAt: DateTime.now(),
      feeling: _feeling,
      photo: _photo,
      coverScene: _scene,
      scent: _scent,
      sound: _sound,
      isFavorite: _favorite,
    );

    if (_isEditing) {
      final existing = controller.memoryById(widget.memoryId!);
      await controller.updateMemory(
        Memory(
          id: existing!.id,
          title: draft.title,
          story: draft.story,
          place: draft.place,
          people: draft.people,
          happenedAt: draft.happenedAt,
          createdAt: existing.createdAt,
          feeling: draft.feeling,
          photo: draft.photo,
          coverScene: draft.coverScene,
          scent: draft.scent,
          sound: draft.sound,
          isFavorite: draft.isFavorite,
          syncState: existing.syncState,
          isDemo: existing.isDemo,
        ),
      );
    } else {
      await controller.createMemory(draft);
    }

    navigator.pop();
    messenger.showSnackBar(SnackBar(content: Text(t.memorySaved)));
  }

  // --- Aufbau ------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final t = AppTexts.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? t.editMemory : t.newMemory),
        actions: [
          IconButton(
            onPressed: () => setState(() => _favorite = !_favorite),
            tooltip: t.memoryFavorite,
            icon: Icon(
              _favorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              color: _favorite ? MomentoColors.rose : null,
            ),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
          children: [
            _CoverPicker(
              photo: _photo,
              scene: _scene ?? CoverScene.lakeSunset,
              onPickCamera: () => _pickPhoto(ImageSource.camera),
              onPickGallery: () => _pickPhoto(ImageSource.gallery),
              onRemovePhoto: () => setState(() => _photo = null),
              onSceneChanged: (scene) => setState(() => _scene = scene),
            ),
            const SizedBox(height: 22),

            TextFormField(
              controller: _title,
              textCapitalization: TextCapitalization.sentences,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: t.memoryTitle,
                hintText: t.memoryTitleHint,
                prefixIcon: const Icon(Icons.title_rounded),
              ),
              validator: (value) => (value == null || value.trim().isEmpty)
                  ? t.errorTitleRequired
                  : null,
            ),
            const SizedBox(height: 14),

            TextFormField(
              controller: _story,
              maxLines: 5,
              minLines: 3,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: t.memoryStory,
                hintText: t.memoryStoryHint,
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 14),

            _FieldCard(
              icon: Icons.event_rounded,
              label: t.memoryDate,
              value: MomentoDates.dayAndTime(_happenedAt, t),
              onTap: _pickDate,
            ),
            const SizedBox(height: 14),

            TextFormField(
              controller: _place,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: t.memoryPlace,
                hintText: t.memoryPlaceHint,
                prefixIcon: const Icon(Icons.place_outlined),
              ),
            ),
            const SizedBox(height: 14),

            TextFormField(
              controller: _people,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                labelText: t.memoryPeople,
                hintText: t.memoryPeopleHint,
                prefixIcon: const Icon(Icons.people_alt_outlined),
              ),
            ),
            const SizedBox(height: 24),

            // --- Gefuehl -----------------------------------------------
            Text(t.memoryFeeling, style: theme.textTheme.titleMedium),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final feeling in Feeling.values)
                  MomentoChip(
                    label: feeling.label(t),
                    emoji: feeling.emoji,
                    color: feeling.color,
                    selected: _feeling == feeling,
                    onTap: () => setState(
                      () => _feeling = _feeling == feeling ? null : feeling,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 24),

            // --- Duft ---------------------------------------------------
            Text(t.memoryScent, style: theme.textTheme.titleMedium),
            const SizedBox(height: 10),
            _ScentField(
              scent: _scent,
              onTap: () async {
                final result = await showScentPicker(context, _scent);
                if (!mounted) return;
                setState(() => _scent = result);
              },
            ),
            const SizedBox(height: 24),

            // --- Geraeusch ----------------------------------------------
            Text(t.memorySound, style: theme.textTheme.titleMedium),
            const SizedBox(height: 10),
            SoundRecorderField(
              clip: _sound,
              onChanged: (clip) => setState(() => _sound = clip),
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
          busy: _busy,
          onPressed: _save,
        ),
      ),
    );
  }
}

/// Bild oben im Editor: eigenes Foto oder eine der gezeichneten Szenen.
class _CoverPicker extends StatefulWidget {
  const _CoverPicker({
    required this.photo,
    required this.scene,
    required this.onPickCamera,
    required this.onPickGallery,
    required this.onRemovePhoto,
    required this.onSceneChanged,
  });

  final StoredMedia? photo;
  final CoverScene scene;
  final VoidCallback onPickCamera;
  final VoidCallback onPickGallery;
  final VoidCallback onRemovePhoto;
  final ValueChanged<CoverScene> onSceneChanged;

  @override
  State<_CoverPicker> createState() => _CoverPickerState();
}

class _CoverPickerState extends State<_CoverPicker> {
  static const _itemWidth = 74.0;
  static const _itemGap = 8.0;

  /// So startet die Motivleiste beim gerade gewaehlten Motiv statt ganz links.
  late final _sceneScroll = ScrollController(
    initialScrollOffset:
        (widget.scene.index * (_itemWidth + _itemGap) - _itemWidth).clamp(
      0.0,
      (CoverScene.values.length - 3) * (_itemWidth + _itemGap),
    ),
  );

  @override
  void dispose() {
    _sceneScroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final photo = widget.photo;
    final scene = widget.scene;
    final onPickCamera = widget.onPickCamera;
    final onPickGallery = widget.onPickGallery;
    final onRemovePhoto = widget.onRemovePhoto;
    final onSceneChanged = widget.onSceneChanged;
    final t = AppTexts.of(context);
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(MomentoRadii.card),
          child: AspectRatio(
            aspectRatio: 16 / 10,
            child: photo != null
                ? StoredImageView(media: photo)
                : SceneCover(scene: scene),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onPickGallery,
                icon: const Icon(Icons.photo_library_outlined, size: 19),
                label: Text(t.memoryFromGallery),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onPickCamera,
                icon: const Icon(Icons.photo_camera_outlined, size: 19),
                label: Text(t.memoryFromCamera),
              ),
            ),
          ],
        ),
        if (photo != null) ...[
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: onRemovePhoto,
            icon: const Icon(Icons.close_rounded, size: 18),
            label: Text(t.memoryPhotoRemove),
          ),
        ] else ...[
          const SizedBox(height: 14),
          Text(
            t.memorySceneLabel,
            style: theme.textTheme.labelSmall,
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 58,
            child: ListView.separated(
              controller: _sceneScroll,
              scrollDirection: Axis.horizontal,
              itemCount: CoverScene.values.length,
              separatorBuilder: (_, __) => const SizedBox(width: _itemGap),
              itemBuilder: (context, index) {
                final option = CoverScene.values[index];
                final selected = option == scene;
                return GestureDetector(
                  onTap: () => onSceneChanged(option),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: _itemWidth,
                    padding: EdgeInsets.all(selected ? 3 : 0),
                    decoration: BoxDecoration(
                      color: selected ? MomentoColors.rose : Colors.transparent,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: SceneCover(scene: option),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }
}

/// Zeile, die wie ein Eingabefeld aussieht, aber etwas oeffnet.
class _FieldCard extends StatelessWidget {
  const _FieldCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(MomentoRadii.tile),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: theme.brightness == Brightness.dark
              ? theme.colorScheme.surfaceContainerHighest
              : Colors.white,
          borderRadius: BorderRadius.circular(MomentoRadii.tile),
          border: Border.all(color: theme.colorScheme.outline, width: 1.2),
        ),
        child: Row(
          children: [
            Icon(icon, size: 21, color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(label, style: theme.textTheme.labelSmall),
                  Text(value, style: theme.textTheme.bodyLarge),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                color: theme.colorScheme.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}

class _ScentField extends StatelessWidget {
  const _ScentField({required this.scent, required this.onTap});

  final Scent? scent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = AppTexts.of(context);
    final theme = Theme.of(context);
    final hasScent = scent != null && !scent!.isEmpty;
    final color = hasScent ? scent!.color : theme.colorScheme.onSurfaceVariant;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        decoration: BoxDecoration(
          color: hasScent
              ? color.withValues(alpha: 0.10)
              : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: hasScent ? color.withValues(alpha: 0.38) : theme.colorScheme.outline,
            width: 1.3,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: hasScent
                    ? color.withValues(alpha: 0.20)
                    : theme.colorScheme.surface,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: hasScent
                  ? Text(scent!.emoji, style: const TextStyle(fontSize: 19))
                  : Icon(Icons.auto_awesome_rounded,
                      size: 19, color: theme.colorScheme.onSurfaceVariant),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    hasScent ? scent!.label(t) : t.memoryScentHint,
                    style: theme.textTheme.titleMedium,
                  ),
                  if (hasScent)
                    Text(scent!.intensity.label(t),
                        style: theme.textTheme.bodySmall),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                color: theme.colorScheme.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}
