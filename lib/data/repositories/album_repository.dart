import '../local/local_database.dart';
import '../models/album.dart';

abstract interface class AlbumRepository {
  Future<List<Album>> fetchAll();
  Future<void> upsert(Album album);
  Future<void> delete(String id);
  Future<void> replaceAll(List<Album> albums);
}

class LocalAlbumRepository implements AlbumRepository {
  LocalAlbumRepository(this._db);

  final LocalDatabase _db;

  @override
  Future<List<Album>> fetchAll() async {
    final rows = _db.readList(DbKeys.albums);
    final albums = <Album>[];
    for (final row in rows) {
      try {
        albums.add(Album.fromJson(row));
      } catch (_) {
        // Beschaedigte Eintraege ueberspringen.
      }
    }
    albums.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return albums;
  }

  @override
  Future<void> upsert(Album album) async {
    final all = await fetchAll();
    final index = all.indexWhere((a) => a.id == album.id);
    if (index >= 0) {
      all[index] = album;
    } else {
      all.add(album);
    }
    await replaceAll(all);
  }

  @override
  Future<void> delete(String id) async {
    final all = await fetchAll();
    all.removeWhere((a) => a.id == id);
    await replaceAll(all);
  }

  @override
  Future<void> replaceAll(List<Album> albums) =>
      _db.writeList(DbKeys.albums, albums.map((a) => a.toJson()).toList());
}
