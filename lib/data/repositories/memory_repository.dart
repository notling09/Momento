import '../local/local_database.dart';
import '../models/memory.dart';

/// Schnittstelle zu den Erinnerungen.
///
/// Heute steht dahinter der lokale Speicher. Wenn Momento spaeter in die
/// Cloud soll, wird nur eine zweite Umsetzung dieser vier Methoden gebraucht -
/// der Rest der App bleibt unveraendert.
abstract interface class MemoryRepository {
  Future<List<Memory>> fetchAll();
  Future<void> upsert(Memory memory);
  Future<void> delete(String id);
  Future<void> replaceAll(List<Memory> memories);
}

class LocalMemoryRepository implements MemoryRepository {
  LocalMemoryRepository(this._db);

  final LocalDatabase _db;

  @override
  Future<List<Memory>> fetchAll() async {
    final rows = _db.readList(DbKeys.memories);
    final memories = <Memory>[];
    for (final row in rows) {
      try {
        memories.add(Memory.fromJson(row));
      } catch (_) {
        // Einzelne kaputte Eintraege ueberspringen statt alles zu verlieren.
      }
    }
    memories.sort((a, b) => b.happenedAt.compareTo(a.happenedAt));
    return memories;
  }

  @override
  Future<void> upsert(Memory memory) async {
    final all = await fetchAll();
    final index = all.indexWhere((m) => m.id == memory.id);
    if (index >= 0) {
      all[index] = memory;
    } else {
      all.add(memory);
    }
    await replaceAll(all);
  }

  @override
  Future<void> delete(String id) async {
    final all = await fetchAll();
    all.removeWhere((m) => m.id == id);
    await replaceAll(all);
  }

  @override
  Future<void> replaceAll(List<Memory> memories) async {
    final sorted = [...memories]
      ..sort((a, b) => b.happenedAt.compareTo(a.happenedAt));
    await _db.writeList(DbKeys.memories, sorted.map((m) => m.toJson()).toList());
  }
}
