import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:momento/core/l10n/app_texts.dart';
import 'package:momento/core/momento_controller.dart';
import 'package:momento/core/theme/momento_theme.dart';
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
import 'package:shared_preferences/shared_preferences.dart';

/// Rendert jeden Bildschirm der App und legt ihn als Bild unter
/// `test/goldens/` ab.
///
/// Aufruf:  flutter test --update-goldens test/screens_test.dart
///
/// Damit lassen sich Layout und Gestaltung ueberpruefen, ohne jedes Mal ein
/// Geraet anzuschliessen.
void main() {
  late Directory tempDir;
  late MomentoController controller;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await initializeDateFormatting();
    await _loadFonts();

    tempDir = await Directory.systemTemp.createTemp('momento_test');
    _mockPathProvider(tempDir.path);
    _mockAudioPlayers();
    SharedPreferences.setMockInitialValues({});

    controller = await MomentoController.bootstrap();
    await controller.register(
      email: 'sara@momento.ch',
      password: 'momento123',
      displayName: 'Sara',
    );
    await controller.completeOnboarding();
  });

  tearDownAll(() {
    if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
  });

  Future<void> capture(
    WidgetTester tester,
    String name,
    Widget home, {
    ThemeMode themeMode = ThemeMode.light,
    Locale locale = const Locale('de'),
    Future<void> Function(WidgetTester tester)? interact,
  }) async {
    // Der Ton-Abspieler hat im Test keine Gegenstelle. Diese Meldung darf
    // den Bildlauf nicht abbrechen; sie sagt nichts ueber die App aus.
    final reportError = FlutterError.onError;
    FlutterError.onError = (details) {
      if (details.exception is MissingPluginException) return;
      reportError?.call(details);
    };

    await tester.binding.setSurfaceSize(const Size(390, 844));
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;

    await tester.pumpWidget(
      AppScope(
        controller: controller,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: MomentoTheme.light(),
          darkTheme: MomentoTheme.dark(),
          themeMode: themeMode,
          locale: locale,
          supportedLocales: AppTexts.supportedLocales,
          localizationsDelegates: const [
            AppTextsDelegate(),
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: home,
        ),
      ),
    );

    // Bilder muessen echt geladen werden, sonst bleiben sie im Test leer.
    await tester.runAsync(() async {
      final element = tester.element(find.byType(MaterialApp));
      for (final asset in const [
        'assets/brand/logo_wordmark.png',
        'assets/brand/app_icon.png',
        'assets/brand/concept_mockup.jpg',
      ]) {
        await precacheImage(AssetImage(asset), element);
      }
      await Future<void>.delayed(const Duration(milliseconds: 120));
    });
    await tester.pumpAndSettle(const Duration(milliseconds: 60));

    if (interact != null) {
      await interact(tester);
      await tester.pumpAndSettle(const Duration(milliseconds: 60));
    }

    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/$name.png'),
    );
  }

  testWidgets('01 Einfuehrung', (tester) async {
    await capture(tester, '01_onboarding', const OnboardingScreen());
  });

  testWidgets('02 Anmelden', (tester) async {
    await capture(tester, '02_welcome', const WelcomeScreen());
  });

  testWidgets('03 Startseite', (tester) async {
    await capture(tester, '03_home', HomeScreen(onOpenMenu: () {}));
  });

  testWidgets('04 Startseite dunkel', (tester) async {
    await capture(
      tester,
      '04_home_dark',
      HomeScreen(onOpenMenu: () {}),
      themeMode: ThemeMode.dark,
    );
  });

  testWidgets('05 Erinnerungen', (tester) async {
    await capture(tester, '05_memories', const MemoriesScreen());
  });

  testWidgets('06 Erinnerung im Detail', (tester) async {
    final memory = controller.memories.firstWhere((m) => m.hasSound);
    await capture(tester, '06_memory_detail',
        MemoryDetailScreen(memoryId: memory.id));
  });

  testWidgets('07 Erinnerung bearbeiten', (tester) async {
    // Eine bestehende Erinnerung, damit das Bild immer gleich aussieht: bei
    // einer neuen haengt das vorgeschlagene Motiv von Jahres- und Tageszeit ab.
    final memory = controller.memories.firstWhere((m) => m.hasScent);
    await capture(
      tester,
      '07_memory_editor',
      MemoryEditorScreen(memoryId: memory.id),
    );
  });

  testWidgets('08 Suche', (tester) async {
    await capture(
      tester,
      '08_search',
      const SearchScreen(),
      interact: (tester) async {
        await tester.enterText(find.byType(TextField).first, 'sonnenuntergang am wasser');
        await tester.pump(const Duration(milliseconds: 400));
      },
    );
  });

  testWidgets('09 Synchronisieren', (tester) async {
    await capture(tester, '09_sync', const SyncScreen());
  });

  testWidgets('10 Alben', (tester) async {
    await capture(tester, '10_albums', const AlbumsScreen());
  });

  testWidgets('11 Album bearbeiten', (tester) async {
    await capture(tester, '11_album_editor', const AlbumEditorScreen());
  });

  testWidgets('12 Einstellungen', (tester) async {
    await capture(tester, '12_settings', const SettingsScreen());
  });

  testWidgets('13 Ueber Momento', (tester) async {
    await capture(tester, '13_about', const AboutScreen());
  });

  testWidgets('13b Ueber Momento, unterer Teil', (tester) async {
    await capture(
      tester,
      '13b_about_bottom',
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
    await capture(
      tester,
      '14_drawer',
      const Scaffold(drawer: MomentoDrawer(), body: SizedBox.shrink()),
      interact: (tester) async {
        tester.state<ScaffoldState>(find.byType(Scaffold).first).openDrawer();
      },
    );
  });

  testWidgets('15 Startseite auf Englisch', (tester) async {
    await capture(
      tester,
      '15_home_english',
      HomeScreen(onOpenMenu: () {}),
      locale: const Locale('en'),
    );
  });
}

/// Ohne echte Schriften rendert der Test nur Kaestchen.
Future<void> _loadFonts() async {
  // Symbole und Emoji kommen nicht aus dem Projekt, sondern vom System bzw.
  // aus dem Flutter-Zwischenspeicher. Wenn sie fehlen, ist das nur im Test
  // ein Problem - auf dem Geraet sind sie immer vorhanden.
  final extras = <String, List<String>>{
    'MaterialIcons': [
      '${_flutterCacheDir()}/artifacts/material_fonts/materialicons-regular.otf',
    ],
    'Segoe UI Emoji': ['C:/Windows/Fonts/seguiemj.ttf'],
  };
  for (final entry in extras.entries) {
    final files = entry.value.map(File.new).where((f) => f.existsSync());
    if (files.isEmpty) continue;
    final loader = FontLoader(entry.key);
    for (final file in files) {
      loader.addFont(Future.value(file.readAsBytesSync().buffer.asByteData()));
    }
    await loader.load();
  }

  const fonts = {
    'Quicksand': [
      'assets/fonts/Quicksand-Regular.ttf',
      'assets/fonts/Quicksand-Medium.ttf',
      'assets/fonts/Quicksand-SemiBold.ttf',
      'assets/fonts/Quicksand-Bold.ttf',
    ],
    'Baloo': [
      'assets/fonts/Baloo2-SemiBold.ttf',
      'assets/fonts/Baloo2-Bold.ttf',
      'assets/fonts/Baloo2-ExtraBold.ttf',
    ],
  };

  for (final entry in fonts.entries) {
    final loader = FontLoader(entry.key);
    for (final path in entry.value) {
      loader.addFont(
        Future.value(File(path).readAsBytesSync().buffer.asByteData()),
      );
    }
    await loader.load();
  }
}

void _mockPathProvider(String path) {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
    const MethodChannel('plugins.flutter.io/path_provider'),
    (call) async => path,
  );
}

/// Der Abspieler wird im Test nicht gebraucht - wir beantworten seine
/// Aufrufe einfach mit "nichts passiert".
void _mockAudioPlayers() {
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  for (final name in const [
    'xyz.luan/audioplayers',
    'xyz.luan/audioplayers.global',
  ]) {
    messenger.setMockMethodCallHandler(MethodChannel(name), (call) async => null);
  }
  messenger.setMockStreamHandler(
    const EventChannel('xyz.luan/audioplayers/events'),
    MockStreamHandler.inline(onListen: (_, __) {}),
  );
  messenger.setMockStreamHandler(
    const EventChannel('xyz.luan/audioplayers.global/events'),
    MockStreamHandler.inline(onListen: (_, __) {}),
  );
}

/// Sucht den Flutter-Zwischenspeicher ausgehend von der laufenden Dart-Datei.
String _flutterCacheDir() {
  var dir = File(Platform.resolvedExecutable).parent;
  for (var i = 0; i < 6; i++) {
    if (Directory('${dir.path}/artifacts/material_fonts').existsSync()) {
      return dir.path;
    }
    dir = dir.parent;
  }
  final root = Platform.environment['FLUTTER_ROOT'];
  return root == null ? '' : '$root/bin/cache';
}
