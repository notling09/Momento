import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:momento/core/momento_controller.dart';
import 'package:momento/data/local/backup_service.dart';
import 'package:momento/data/models/memory.dart';
import 'package:momento/data/models/scent.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Prüft die Sicherung: Lässt sich alles herausschreiben und wieder
/// hereinholen – samt Bildern und Tonaufnahmen?
void main() {
  late Directory tempDir;

  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    tempDir = await Directory.systemTemp.createTemp('momento_backup');
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

  test('Sicherung und Wiederherstellung bringen alles zurück', () async {
    final controller = await MomentoController.bootstrap();
    await controller.createMemory(
      Memory(
        id: '',
        title: 'Meine eigene Erinnerung',
        story: 'Mit Duft und allem.',
        place: 'Zuhause',
        people: const ['Dalila'],
        happenedAt: DateTime(2026, 5, 1, 18, 30),
        createdAt: DateTime(2026, 5, 1, 18, 30),
        scent: const Scent(kind: ScentKind.campfire),
      ),
    );

    final before = controller.memories.length;
    final albumsBefore = controller.albums.length;
    final soundsBefore = controller.memories.where((m) => m.hasSound).length;
    expect(soundsBefore, greaterThan(0), reason: 'Beispiele haben Tonaufnahmen');

    final zip = await controller.createBackup();
    expect(zip.length, greaterThan(1000));

    await controller.deleteEverything();
    expect(controller.memories, isEmpty);

    final result = await controller.restoreBackup(zip);

    expect(result.memoriesAdded, before);
    expect(result.albumsAdded, albumsBefore);
    expect(controller.memories.length, before);
    expect(controller.albums.length, albumsBefore);
    expect(
      controller.memories.where((m) => m.title == 'Meine eigene Erinnerung'),
      hasLength(1),
    );
  });

  test('Die Tonaufnahmen sind nach dem Einlesen wieder abspielbar', () async {
    final controller = await MomentoController.bootstrap();
    final zip = await controller.createBackup();
    await controller.deleteEverything();
    await controller.restoreBackup(zip);

    final withSound = controller.memories.firstWhere((m) => m.hasSound);
    final bytes = await controller.mediaStore.read(withSound.sound!.media);

    expect(bytes, isNotNull);
    expect(bytes!.length, greaterThan(1000));
    // Eine gültige WAV-Datei beginnt mit "RIFF".
    expect(String.fromCharCodes(bytes.sublist(0, 4)), 'RIFF');
  });

  test('Details einer Erinnerung überstehen die Sicherung', () async {
    final controller = await MomentoController.bootstrap();
    final original = controller.memories.firstWhere((m) => m.hasScent);

    final zip = await controller.createBackup();
    await controller.deleteEverything();
    await controller.restoreBackup(zip);

    final restored = controller.memoryById(original.id)!;
    expect(restored.title, original.title);
    expect(restored.story, original.story);
    expect(restored.place, original.place);
    expect(restored.people, original.people);
    expect(restored.happenedAt, original.happenedAt);
    expect(restored.feeling, original.feeling);
    expect(restored.scent!.kind, original.scent!.kind);
    expect(restored.isFavorite, original.isFavorite);
  });

  test('Dazufügen überspringt, was schon vorhanden ist', () async {
    final controller = await MomentoController.bootstrap();
    final before = controller.memories.length;
    final zip = await controller.createBackup();

    final result = await controller.restoreBackup(zip);

    expect(result.memoriesAdded, 0);
    expect(result.memoriesSkipped, before);
    expect(controller.memories.length, before, reason: 'nichts doppelt');
  });

  test('Alles ersetzen wirft Bestehendes weg', () async {
    final controller = await MomentoController.bootstrap();
    final zip = await controller.createBackup();

    await controller.createMemory(
      Memory(
        id: '',
        title: 'Kommt nach der Sicherung dazu',
        happenedAt: DateTime(2026, 6, 1),
        createdAt: DateTime(2026, 6, 1),
      ),
    );

    await controller.restoreBackup(zip, replaceExisting: true);

    expect(
      controller.memories.where((m) => m.title == 'Kommt nach der Sicherung dazu'),
      isEmpty,
    );
  });

  test('Eine fremde Datei wird abgelehnt', () async {
    final controller = await MomentoController.bootstrap();
    expect(
      () => controller.restoreBackup(
        Uint8List.fromList('das ist kein zip'.codeUnits),
      ),
      throwsA(isA<InvalidBackupException>()),
    );
  });

  test('Der Dateiname enthält das Datum', () {
    expect(
      BackupService.fileNameFor(DateTime(2026, 8, 30)),
      'momento-sicherung-2026-08-30.zip',
    );
  });
}
