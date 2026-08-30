import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/l10n/app_texts.dart';
import '../../core/momento_controller.dart';
import '../../core/theme/momento_colors.dart';
import '../../core/theme/momento_theme.dart';
import '../../core/utils/memory_search.dart';
import '../../widgets/common.dart';
import '../../widgets/memory_widgets.dart';
import '../memories/memory_detail_screen.dart';

/// "Mit dem Knopf unten rechts kann man nach bestimmten Erinnerungen suchen,
/// indem man sie beschreibt." (Businessplan, Kapitel 7.2)
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _query = TextEditingController();
  final _focus = FocusNode();
  Timer? _debounce;
  List<SearchHit> _hits = const [];
  bool _searched = false;
  bool _thinking = false;

  @override
  void dispose() {
    _debounce?.cancel();
    _query.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    if (value.trim().isEmpty) {
      setState(() {
        _hits = const [];
        _searched = false;
        _thinking = false;
      });
      return;
    }
    setState(() => _thinking = true);
    // Kurz warten, damit nicht bei jedem Buchstaben neu gesucht wird.
    _debounce = Timer(const Duration(milliseconds: 260), () => _run(value));
  }

  void _run(String value) {
    final memories = AppScope.read(context).memories;
    final hits = MemorySearch.run(value, memories);
    if (!mounted) return;
    setState(() {
      _hits = hits;
      _searched = true;
      _thinking = false;
    });
  }

  void _useExample(String example) {
    _query.text = example;
    _focus.unfocus();
    _run(example);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final t = AppTexts.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(t.searchTitle, style: theme.textTheme.displaySmall),
                  const SizedBox(height: 2),
                  Text(t.searchSubtitle, style: theme.textTheme.bodyMedium),
                  const SizedBox(height: 16),
                  _SearchField(
                    controller: _query,
                    focusNode: _focus,
                    onChanged: _onChanged,
                    onClear: () {
                      _query.clear();
                      _onChanged('');
                    },
                  ),
                ],
              ),
            ),
            if (_searched && !_thinking)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
                child: Row(
                  children: [
                    Text(
                      t.searchResultCount(_hits.length),
                      style: theme.textTheme.labelMedium,
                    ),
                  ],
                ),
              ),
            Expanded(child: _body(t, theme)),
          ],
        ),
      ),
    );
  }

  Widget _body(AppTexts t, ThemeData theme) {
    if (_thinking) {
      return const Center(
        child: SizedBox(
          width: 26,
          height: 26,
          child: CircularProgressIndicator(strokeWidth: 2.4),
        ),
      );
    }

    if (!_searched) {
      return ListView(
        padding: EdgeInsets.fromLTRB(16, 10, 16, MomentoInsets.aboveNavBar(context)),
        children: [
          SoftCard(
            padding: const EdgeInsets.all(18),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: const BoxDecoration(
                    gradient: MomentoGradients.action,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.auto_awesome_rounded,
                      color: Colors.white, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(t.searchStartTitle,
                          style: theme.textTheme.titleMedium),
                      const SizedBox(height: 4),
                      Text(t.searchStartBody, style: theme.textTheme.bodySmall),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          _Ideas(texts: t, onPick: _useExample),
        ],
      );
    }

    if (_hits.isEmpty) {
      // Auch ohne Treffer soll die Seite weiterhelfen: die Vorschlaege bleiben
      // sichtbar, damit man sofort etwas ausprobieren kann, das funktioniert.
      return ListView(
        padding: EdgeInsets.fromLTRB(16, 10, 16, MomentoInsets.aboveNavBar(context)),
        children: [
          EmptyState(
            icon: Icons.search_off_rounded,
            title: t.searchNoResultsTitle,
            body: t.searchNoResultsBody,
          ),
          const SizedBox(height: 12),
          _Ideas(texts: t, onPick: _useExample),
        ],
      );
    }

    return ListView.separated(
      padding: EdgeInsets.fromLTRB(16, 4, 16, MomentoInsets.aboveNavBar(context)),
      itemCount: _hits.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final hit = _hits[index];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MemoryTile(
              memory: hit.memory,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => MemoryDetailScreen(memoryId: hit.memory.id),
                ),
              ),
            ),
            if (hit.matchedFields.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 7, 8, 0),
                child: Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      '${t.searchWhyMatched}:',
                      style: theme.textTheme.labelSmall,
                    ),
                    for (final field in hit.matchedFields)
                      MomentoChip(
                        label: field.label(t),
                        dense: true,
                        color: MomentoColors.plumInk,
                      ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}

/// Anfragen, die garantiert etwas finden - als Starthilfe und als Ausweg,
/// wenn eine eigene Anfrage nichts ergeben hat.
class _Ideas extends StatelessWidget {
  const _Ideas({required this.texts, required this.onPick});

  final AppTexts texts;
  final ValueChanged<String> onPick;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(texts.searchIdeas, style: theme.textTheme.titleMedium),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final example in [
              texts.searchExample1,
              texts.searchExample2,
              texts.searchExample3,
              texts.searchExample4,
            ])
              MomentoChip(
                label: example,
                icon: Icons.north_east_rounded,
                onTap: () => onPick(example),
              ),
          ],
        ),
      ],
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final t = AppTexts.of(context);
    return TextField(
      controller: controller,
      focusNode: focusNode,
      onChanged: onChanged,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: t.searchHint,
        prefixIcon: const Icon(Icons.search_rounded),
        suffixIcon: controller.text.isEmpty
            ? null
            : IconButton(
                onPressed: onClear,
                icon: const Icon(Icons.close_rounded, size: 20),
              ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(MomentoRadii.chip),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(MomentoRadii.chip),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(MomentoRadii.chip),
          borderSide: const BorderSide(color: MomentoColors.rose, width: 1.8),
        ),
      ),
    );
  }
}
