import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:momento/features/albums/album_editor_screen.dart';
import 'package:momento/features/albums/albums_screen.dart';
import 'package:momento/features/auth/welcome_screen.dart';
import 'package:momento/features/home/home_screen.dart';
import 'package:momento/features/home/home_shell.dart';
import 'package:momento/features/memories/memories_screen.dart';
import 'package:momento/features/memories/memory_detail_screen.dart';
import 'package:momento/features/memories/memory_editor_screen.dart';
import 'package:momento/features/onboarding/onboarding_screen.dart';
import 'package:momento/features/search/search_screen.dart';
import 'package:momento/features/settings/about_screen.dart';
import 'package:momento/features/settings/settings_screen.dart';
import 'package:momento/features/sync/sync_screen.dart';

import 'support/golden_harness.dart';

/// Rendert jeden Bildschirm der App und vergleicht ihn mit dem Bild unter
/// `test/goldens/`.
///
/// Bilder neu erzeugen:  flutter test --update-goldens test/screens_test.dart
///
/// Damit lassen sich Layout und Gestaltung ueberpruefen, ohne jedes Mal ein
/// Geraet anzuschliessen.
void main() {
  late GoldenHarness harness;

  setUpAll(() async => harness = await GoldenHarness.start());
  tearDownAll(() => harness.dispose());

  testWidgets('01 Einfuehrung', (tester) async {
    await harness.capture(tester, 'goldens/01_onboarding.png', const OnboardingScreen());
  });

  testWidgets('02 Anmelden', (tester) async {
    await harness.capture(tester, 'goldens/02_welcome.png', const WelcomeScreen());
  });

  testWidgets('03 Startseite', (tester) async {
    await harness.capture(tester, 'goldens/03_home.png', HomeScreen(onOpenMenu: () {}));
  });

  testWidgets('04 Startseite dunkel', (tester) async {
    await harness.capture(
      tester,
      'goldens/04_home_dark.png',
      HomeScreen(onOpenMenu: () {}),
      themeMode: ThemeMode.dark,
    );
  });

  testWidgets('05 Erinnerungen', (tester) async {
    await harness.capture(tester, 'goldens/05_memories.png', const MemoriesScreen());
  });

  testWidgets('06 Erinnerung im Detail', (tester) async {
    final memory = harness.controller.memories.firstWhere((m) => m.hasSound);
    await harness.capture(
      tester,
      'goldens/06_memory_detail.png',
      MemoryDetailScreen(memoryId: memory.id),
    );
  });

  testWidgets('07 Erinnerung bearbeiten', (tester) async {
    // Eine bestehende Erinnerung, damit das Bild immer gleich aussieht: bei
    // einer neuen haengt das vorgeschlagene Motiv von Jahres- und Tageszeit ab.
    final memory = harness.controller.memories.firstWhere((m) => m.hasScent);
    await harness.capture(
      tester,
      'goldens/07_memory_editor.png',
      MemoryEditorScreen(memoryId: memory.id),
    );
  });

  testWidgets('08 Suche', (tester) async {
    await harness.capture(
      tester,
      'goldens/08_search.png',
      const SearchScreen(),
      interact: (tester) async {
        await tester.enterText(
            find.byType(TextField).first, 'sonnenuntergang am wasser');
        await tester.pump(const Duration(milliseconds: 400));
      },
    );
  });

  testWidgets('09 Synchronisieren', (tester) async {
    await harness.capture(tester, 'goldens/09_sync.png', const SyncScreen());
  });

  testWidgets('10 Alben', (tester) async {
    await harness.capture(tester, 'goldens/10_albums.png', const AlbumsScreen());
  });

  testWidgets('11 Album bearbeiten', (tester) async {
    await harness.capture(tester, 'goldens/11_album_editor.png', const AlbumEditorScreen());
  });

  testWidgets('12 Einstellungen', (tester) async {
    await harness.capture(tester, 'goldens/12_settings.png', const SettingsScreen());
  });

  testWidgets('13 Ueber Momento', (tester) async {
    await harness.capture(tester, 'goldens/13_about.png', const AboutScreen());
  });

  testWidgets('13b Ueber Momento, unterer Teil', (tester) async {
    await harness.capture(
      tester,
      'goldens/13b_about_bottom.png',
      const AboutScreen(),
      interact: (tester) async {
        // Bis zur Widmung ganz unten scrollen.
        await tester.drag(find.byType(CustomScrollView), const Offset(0, -900));
        await tester.pumpAndSettle();
        await tester.drag(find.byType(CustomScrollView), const Offset(0, -900));
      },
    );
  });

  testWidgets('14 Menue', (tester) async {
    await harness.capture(
      tester,
      'goldens/14_drawer.png',
      const Scaffold(drawer: MomentoDrawer(), body: SizedBox.shrink()),
      interact: (tester) async {
        tester.state<ScaffoldState>(find.byType(Scaffold).first).openDrawer();
      },
    );
  });

  testWidgets('15 Startseite auf Englisch', (tester) async {
    await harness.capture(
      tester,
      'goldens/15_home_english.png',
      HomeScreen(onOpenMenu: () {}),
      locale: const Locale('en'),
    );
  });
}
