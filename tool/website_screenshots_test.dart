import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:momento/features/albums/albums_screen.dart';
import 'package:momento/features/home/home_screen.dart';
import 'package:momento/features/memories/memory_detail_screen.dart';
import 'package:momento/features/memories/memory_editor_screen.dart';
import 'package:momento/features/search/search_screen.dart';

import '../test/support/golden_harness.dart';

/// Erzeugt die Screenshots fuer die Website in doppelter Aufloesung.
///
///     flutter test --update-goldens tool/website_screenshots_test.dart
///
/// Liegt bewusst ausserhalb von `test/`, damit `flutter test` diese Bilder
/// nicht bei jedem Durchlauf mitprueft - fuer die Website reicht es, sie neu
/// zu erzeugen, wenn sich die App sichtbar veraendert hat.
void main() {
  late GoldenHarness harness;

  setUpAll(() async => harness = await GoldenHarness.start(userName: 'Dalila'));
  tearDownAll(() => harness.dispose());

  const target = '../website/screens';

  testWidgets('Startseite', (tester) async {
    await harness.capture(
      tester,
      '$target/start.png',
      HomeScreen(onOpenMenu: () {}),
      pixelRatio: 2,
    );
  });

  testWidgets('Startseite dunkel', (tester) async {
    await harness.capture(
      tester,
      '$target/start-dunkel.png',
      HomeScreen(onOpenMenu: () {}),
      themeMode: ThemeMode.dark,
      pixelRatio: 2,
    );
  });

  testWidgets('Erinnerung', (tester) async {
    final memory = harness.controller.memories.firstWhere((m) => m.hasSound);
    await harness.capture(
      tester,
      '$target/erinnerung.png',
      MemoryDetailScreen(memoryId: memory.id),
      pixelRatio: 2,
    );
  });

  testWidgets('Erfassen', (tester) async {
    final memory = harness.controller.memories.firstWhere((m) => m.hasScent);
    await harness.capture(
      tester,
      '$target/erfassen.png',
      MemoryEditorScreen(memoryId: memory.id),
      pixelRatio: 2,
    );
  });

  testWidgets('Suche', (tester) async {
    await harness.capture(
      tester,
      '$target/suche.png',
      const SearchScreen(),
      pixelRatio: 2,
      interact: (tester) async {
        await tester.enterText(
            find.byType(TextField).first, 'sonnenuntergang am wasser');
        await tester.pump(const Duration(milliseconds: 400));
      },
    );
  });

  testWidgets('Alben', (tester) async {
    await harness.capture(
      tester,
      '$target/alben.png',
      const AlbumsScreen(),
      pixelRatio: 2,
    );
  });
}
