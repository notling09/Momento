import 'package:flutter/material.dart';

import '../core/l10n/app_texts.dart';
import '../core/theme/momento_colors.dart';
import '../data/models/scent.dart';

/// Auswahl eines Dufts.
///
/// Ein Handy kann keinen Geruch messen - deshalb waehlt man hier aus einer
/// Palette oder beschreibt den Duft selbst. Das ist der ehrliche Weg, die
/// Idee aus dem Businessplan umzusetzen.
Future<Scent?> showScentPicker(BuildContext context, Scent? current) =>
    showModalBottomSheet<Scent?>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _ScentPickerSheet(initial: current),
    );

class _ScentPickerSheet extends StatefulWidget {
  const _ScentPickerSheet({this.initial});

  final Scent? initial;

  @override
  State<_ScentPickerSheet> createState() => _ScentPickerSheetState();
}

class _ScentPickerSheetState extends State<_ScentPickerSheet> {
  late ScentKind? _kind = widget.initial?.kind;
  late ScentIntensity _intensity =
      widget.initial?.intensity ?? ScentIntensity.clear;
  late final _custom =
      TextEditingController(text: widget.initial?.customLabel ?? '');

  @override
  void dispose() {
    _custom.dispose();
    super.dispose();
  }

  void _apply() {
    final custom = _custom.text.trim();
    final scent = Scent(
      kind: _kind,
      customLabel: custom.isEmpty ? null : custom,
      intensity: _intensity,
    );
    Navigator.of(context).pop(scent.isEmpty ? null : scent);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppTexts.of(context);
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        bottom: MediaQuery.viewInsetsOf(context).bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(t.scentPickerTitle, style: theme.textTheme.headlineSmall),
            const SizedBox(height: 5),
            Text(t.scentPickerSub, style: theme.textTheme.bodySmall),
            const SizedBox(height: 18),
            Wrap(
              spacing: 9,
              runSpacing: 9,
              children: [
                for (final kind in ScentKind.values)
                  _ScentBubble(
                    kind: kind,
                    selected: _kind == kind,
                    onTap: () => setState(
                      () => _kind = _kind == kind ? null : kind,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _custom,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: t.scentCustom,
                hintText: t.scentCustomHint,
                prefixIcon: const Icon(Icons.edit_note_rounded),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 22),
            Text(t.memoryScentIntensity, style: theme.textTheme.titleSmall),
            const SizedBox(height: 10),
            Row(
              children: [
                for (final intensity in ScentIntensity.values) ...[
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _intensity = intensity),
                      behavior: HitTestBehavior.opaque,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          gradient: _intensity == intensity
                              ? MomentoGradients.action
                              : null,
                          color: _intensity == intensity
                              ? null
                              : theme.colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          intensity.label(t),
                          textAlign: TextAlign.center,
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: _intensity == intensity
                                ? Colors.white
                                : theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (intensity != ScentIntensity.values.last)
                    const SizedBox(width: 8),
                ],
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(null),
                    child: Text(t.scentNone),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: _apply,
                    child: Text(t.actionSave),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _ScentBubble extends StatelessWidget {
  const _ScentBubble({
    required this.kind,
    required this.selected,
    required this.onTap,
  });

  final ScentKind kind;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = AppTexts.of(context);
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
        decoration: BoxDecoration(
          color: selected
              ? kind.color.withValues(alpha: 0.24)
              : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? kind.color : theme.colorScheme.outline,
            width: selected ? 1.8 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(kind.emoji, style: const TextStyle(fontSize: 15)),
            const SizedBox(width: 8),
            Text(
              kind.label(t),
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
