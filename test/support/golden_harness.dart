import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:momento/core/l10n/app_texts.dart';
import 'package:momento/core/momento_controller.dart';
import 'package:momento/core/theme/momento_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Gemeinsamer Unterbau, um Bildschirme der App als Bild abzulegen.
///
/// Wird von zwei Stellen genutzt: von den Golden-Tests, die pruefen, dass sich
/// die Gestaltung nicht unbeabsichtigt aendert, und vom Werkzeug, das die
/// Screenshots fuer die Website erzeugt.
class GoldenHarness {
  GoldenHarness._(this.controller, this._tempDir);

  final MomentoController controller;
  final Directory _tempDir;

  static const size = Size(390, 844);

  /// Ein festes "heute" fuer alle Bilder.
  ///
  /// Ohne das wuerden die Vergleichsbilder jeden Tag fehlschlagen: Auf der
  /// Startseite und in der Liste stehen Datumsangaben, die sich am aktuellen
  /// Tag orientieren.
  static final fixedNow = DateTime(2026, 8, 30, 19, 0);

  /// Baut eine App mit deutschen Beispiel-Erinnerungen und einem angemeldeten
  /// Konto auf.
  static Future<GoldenHarness> start({String userName = 'Sara'}) async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await initializeDateFormatting();
    await _loadFonts();

    final tempDir = await Directory.systemTemp.createTemp('momento_golden');
    _mockPathProvider(tempDir.path);
    _mockAudioPlayers();
    SharedPreferences.setMockInitialValues({});

    final controller = await MomentoController.bootstrap(clock: () => fixedNow);

    // Auf dem Testrechner ist die Systemsprache Englisch. Fuer die Bilder
    // wollen wir aber die deutschen Beispieltexte sehen.
    await controller.setLocale(const Locale('de'));
    await controller.reloadDemoData();

    await controller.register(
      email: 'sara@momento.ch',
      password: 'momento123',
      displayName: userName,
    );
    await controller.completeOnboarding();

    return GoldenHarness._(controller, tempDir);
  }

  void dispose() {
    if (_tempDir.existsSync()) _tempDir.deleteSync(recursive: true);
  }

  /// Zeichnet [home] und legt das Ergebnis unter [goldenPath] ab.
  Future<void> capture(
    WidgetTester tester,
    String goldenPath,
    Widget home, {
    ThemeMode themeMode = ThemeMode.light,
    Locale locale = const Locale('de'),
    double pixelRatio = 1.0,
    Future<void> Function(WidgetTester tester)? interact,
  }) async {
    // Der Ton-Abspieler hat im Test keine Gegenstelle. Diese Meldung darf
    // den Bildlauf nicht abbrechen; sie sagt nichts ueber die App aus.
    final reportError = FlutterError.onError;
    FlutterError.onError = (details) {
      if (details.exception is MissingPluginException) return;
      reportError?.call(details);
    };

    await tester.binding.setSurfaceSize(size);
    tester.view.physicalSize = size * pixelRatio;
    tester.view.devicePixelRatio = pixelRatio;

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

    await expectLater(find.byType(MaterialApp), matchesGoldenFile(goldenPath));
  }
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
    'Noto Color Emoji': [
      '/usr/share/fonts/truetype/noto/NotoColorEmoji.ttf',
      '/System/Library/Fonts/Apple Color Emoji.ttc',
    ],
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
