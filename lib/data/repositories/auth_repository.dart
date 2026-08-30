import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';

import '../local/local_database.dart';
import '../models/app_user.dart';

/// Was bei der An- oder Abmeldung schiefgehen kann.
enum AuthError { emailTaken, wrongCredentials }

class AuthException implements Exception {
  const AuthException(this.error);
  final AuthError error;
}

abstract interface class AuthRepository {
  Future<AppUser?> currentUser();
  Future<AppUser> register({
    required String email,
    required String password,
    required String displayName,
  });
  Future<AppUser> signIn({required String email, required String password});
  Future<void> signOut();
  Future<AppUser> updateProfile(AppUser user);
}

/// Konten auf diesem Geraet.
///
/// Das Passwort wird nie im Klartext gespeichert, sondern nur als
/// Hash mit zufaelligem Salt. Fuer eine lokale App ist das der richtige
/// Umgang; sobald ein Server dazukommt, uebernimmt dieser die Anmeldung.
class LocalAuthRepository implements AuthRepository {
  LocalAuthRepository(this._db);

  final LocalDatabase _db;
  static const _uuid = Uuid();

  List<AppUser> _users() {
    final rows = _db.readList(DbKeys.users);
    final users = <AppUser>[];
    for (final row in rows) {
      try {
        users.add(AppUser.fromJson(row));
      } catch (_) {
        // Ueberspringen.
      }
    }
    return users;
  }

  Future<void> _saveUsers(List<AppUser> users) =>
      _db.writeList(DbKeys.users, users.map((u) => u.toJson()).toList());

  static String _hash(String password, String salt) {
    final digest = sha256.convert(utf8.encode('$salt:$password'));
    return '$salt\$${digest.toString()}';
  }

  static bool _matches(String password, String stored) {
    final parts = stored.split('\$');
    if (parts.length != 2) return false;
    return _hash(password, parts.first) == stored;
  }

  static String _normalise(String email) => email.trim().toLowerCase();

  @override
  Future<AppUser?> currentUser() async {
    final id = _db.readString(DbKeys.session);
    if (id == null) return null;
    for (final user in _users()) {
      if (user.id == id) return user;
    }
    return null;
  }

  @override
  Future<AppUser> register({
    required String email,
    required String password,
    required String displayName,
  }) async {
    final users = _users();
    final normalised = _normalise(email);
    if (users.any((u) => u.email == normalised)) {
      throw const AuthException(AuthError.emailTaken);
    }
    final salt = _uuid.v4().replaceAll('-', '').substring(0, 16);
    final user = AppUser(
      id: _uuid.v4(),
      email: normalised,
      displayName: displayName.trim(),
      passwordHash: _hash(password, salt),
      createdAt: DateTime.now(),
    );
    users.add(user);
    await _saveUsers(users);
    await _db.writeString(DbKeys.session, user.id);
    return user;
  }

  @override
  Future<AppUser> signIn({
    required String email,
    required String password,
  }) async {
    final normalised = _normalise(email);
    for (final user in _users()) {
      if (user.email == normalised && _matches(password, user.passwordHash)) {
        await _db.writeString(DbKeys.session, user.id);
        return user;
      }
    }
    throw const AuthException(AuthError.wrongCredentials);
  }

  @override
  Future<void> signOut() => _db.remove(DbKeys.session);

  @override
  Future<AppUser> updateProfile(AppUser user) async {
    final users = _users();
    final index = users.indexWhere((u) => u.id == user.id);
    if (index >= 0) {
      users[index] = user;
    } else {
      users.add(user);
    }
    await _saveUsers(users);
    return user;
  }
}
