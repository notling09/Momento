import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:momento/core/momento_controller.dart';
import 'package:momento/data/models/memory.dart';
import 'package:momento/data/models/scent.dart';
import 'package:momento/data/repositories/auth_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Prueft, dass Konten, Erinnerungen und Alben wirklich gespeichert werden
/// und die Warteschlange des Sync-Knopfes funktioniert.
void main() {
  late Directory tempDir;

  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    tempDir = await Directory.systemTemp.createTemp('momento_storage');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      (call) async => tempDir.path,
    );
    SharedPreferences.setMockInitialValues({});
  });

  tearDown(() {
    if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
  });

  group('Konten', () {
    test('Registrieren meldet direkt an', () async {
      final controller = await MomentoController.bootstrap();
      await controller.register(
        email: 'Sara@Momento.CH',
        password: 'geheim123',
        displayName: 'Sara',
      );
      expect(controller.isSignedIn, isTrue);
      // Die E-Mail wird vereinheitlicht gespeichert.
      expect(controller.user!.email, 'sara@momento.ch');
    });

    test('Das Passwort wird nicht im Klartext abgelegt', () async {
      final controller = await MomentoController.bootstrap();
      await controller.register(
        email: 'sara@momento.ch',
        password: 'geheim123',
        displayName: 'Sara',
      );
      expect(controller.user!.passwordHash, isNot(contains('geheim123')));
    });

    test('Dieselbe E-Mail lässt sich nicht zweimal registrieren', () async {
      final controller = await MomentoController.bootstrap();
      await controller.register(
        email: 'sara@momento.ch',
        password: 'geheim123',
        displayName: 'Sara',
      );
      expect(
        () => controller.register(
          email: 'sara@momento.ch',
          password: 'anderes123',
          displayName: 'Sara',
        ),
        throwsA(
          isA<AuthException>()
              .having((e) => e.error, 'Grund', AuthError.emailTaken),
        ),
      );
    });

    test('Falsches Passwort wird abgewiesen', () async {
      final controller = await MomentoController.bootstrap();
      await controller.register(
        email: 'sara@momento.ch',
        password: 'geheim123',
        displayName: 'Sara',
      );
      await controller.signOut();
      expect(
        () => controller.signIn(email: 'sara@momento.ch', password: 'falsch1'),
        throwsA(isA<AuthException>()),
      );
    });

    test('Anmeldung überdauert einen Neustart der App', () async {
      final first = await MomentoController.bootstrap();
      await first.register(
        email: 'sara@momento.ch',
        password: 'geheim123',
        displayName: 'Sara',
      );

      final second = await MomentoController.bootstrap();
      expect(second.isSignedIn, isTrue);
      expect(second.user!.displayName, 'Sara');
    });
  });

  group('Erinnerungen', () {
    test('Beispiel-Erinnerungen werden beim ersten Start angelegt', () async {
      final controller = await MomentoController.bootstrap();
      expect(controller.memories, isNotEmpty);
      expect(controller.albums, isNotEmpty);
      expect(controller.memories.every((m) => m.isDemo), isTrue);
    });

    test('Eine neue Erinnerung überdauert einen Neustart', () async {
      final first = await MomentoController.bootstrap();
      await first.createMemory(
        Memory(
          id: '',
          title: 'Ein Testmoment',
          happenedAt: DateTime(2026, 5, 1, 12),
          createdAt: DateTime(2026, 5, 1, 12),
          scent: const Scent(kind: ScentKind.coffee),
        ),
      );

      final second = await MomentoController.bootstrap();
      final saved = second.memories.where((m) => m.title == 'Ein Testmoment');
      expect(saved, hasLength(1));
      expect(saved.first.scent!.kind, ScentKind.coffee);
    });

    test('Löschen entfernt die Erinnerung auch aus allen Alben', () async {
      final controller = await MomentoController.bootstrap();
      final memory = controller.memories.first;
      final album = await controller.saveAlbum(
        name: 'Test',
        description: '',
        memoryIds: [memory.id],
      );

      await controller.deleteMemory(memory.id);

      expect(controller.memoryById(memory.id), isNull);
      expect(controller.albumById(album.id)!.memoryIds, isEmpty);
    });

    test('Beispiele neu laden lässt eigene Erinnerungen stehen', () async {
      // Regression: Das Neuladen hat früher alles ersetzt und damit selbst
      // erfasste Erinnerungen gelöscht.
      final controller = await MomentoController.bootstrap();
      await controller.createMemory(
        Memory(
          id: '',
          title: 'Meine eigene',
          happenedAt: DateTime(2026, 5, 1),
          createdAt: DateTime(2026, 5, 1),
        ),
      );
      final album = await controller.saveAlbum(
        name: 'Mein Album',
        description: '',
        memoryIds: [controller.memories.firstWhere((m) => !m.isDemo).id],
      );

      await controller.reloadDemoData();

      expect(
        controller.memories.where((m) => m.title == 'Meine eigene'),
        hasLength(1),
      );
      expect(controller.albumById(album.id), isNotNull);
      // Und die Beispiele sind trotzdem einmal vorhanden, nicht doppelt.
      expect(
        controller.memories.where((m) => m.isDemo).length,
        controller.memories.where((m) => m.isDemo).map((m) => m.title).toSet().length,
      );
    });

    test('Beispiele entfernen lässt eigene Erinnerungen stehen', () async {
      final controller = await MomentoController.bootstrap();
      await controller.createMemory(
        Memory(
          id: '',
          title: 'Meine eigene',
          happenedAt: DateTime(2026, 5, 1),
          createdAt: DateTime(2026, 5, 1),
        ),
      );

      await controller.removeDemoData();

      expect(controller.memories, hasLength(1));
      expect(controller.memories.first.title, 'Meine eigene');
    });
  });

  group('Sprache', () {
    test('Deutsches Gerät startet auf Deutsch', () {
      expect(MomentoController.localeForSystem('de').languageCode, 'de');
    });

    test('Jede andere Systemsprache startet auf Englisch', () {
      // Momento gibt es nur auf Deutsch und Englisch - ein portugiesisches
      // Gerät darf nicht in einer Sprache landen, die es hier nicht gibt.
      for (final code in ['pt', 'fr', 'it', 'sq', 'en']) {
        expect(MomentoController.localeForSystem(code).languageCode, 'en');
      }
    });

    test('Nach dem ersten Start ist eine Sprache festgelegt', () async {
      final controller = await MomentoController.bootstrap();
      expect(controller.settings.locale, isNotNull);
    });
  });

  group('Warteschlange des Sync-Knopfes', () {
    test('Neue Erinnerungen warten zuerst', () async {
      final controller = await MomentoController.bootstrap();
      await controller.createMemory(
        Memory(
          id: '',
          title: 'Wartet noch',
          happenedAt: DateTime(2026, 5, 1),
          createdAt: DateTime(2026, 5, 1),
        ),
      );
      expect(controller.pendingMemories, hasLength(1));
      expect(controller.pendingMemories.first.syncState, SyncState.pending);
    });

    test('Synchronisieren leert die Warteschlange', () async {
      final controller = await MomentoController.bootstrap();
      await controller.createMemory(
        Memory(
          id: '',
          title: 'Wartet noch',
          happenedAt: DateTime(2026, 5, 1),
          createdAt: DateTime(2026, 5, 1),
        ),
      );

      final done = await controller.synchronise();

      expect(done, 1);
      expect(controller.pendingMemories, isEmpty);
      expect(controller.settings.lastSync, isNotNull);
    });

    test('Bearbeiten stellt eine Erinnerung zurück in die Warteschlange',
        () async {
      final controller = await MomentoController.bootstrap();
      final created = await controller.createMemory(
        Memory(
          id: '',
          title: 'Erst mal so',
          happenedAt: DateTime(2026, 5, 1),
          createdAt: DateTime(2026, 5, 1),
        ),
      );
      await controller.synchronise();

      await controller.updateMemory(
        controller.memoryById(created.id)!.copyWith(title: 'Doch anders'),
      );

      expect(controller.pendingMemories, hasLength(1));
    });
  });
}
