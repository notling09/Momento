import 'stored_media.dart';

/// Ein Konto auf diesem Geraet.
///
/// Bewusst schlank: E-Mail und Passwort, wie im Businessplan beschrieben.
/// Das dort erwaehnte Ausweisfoto haben wir weggelassen - fuer eine
/// Erinnerungs-App gibt es keinen Grund, einen Ausweis zu verlangen
/// (Datensparsamkeit, revDSG Art. 6).
class AppUser {
  const AppUser({
    required this.id,
    required this.email,
    required this.displayName,
    required this.passwordHash,
    required this.createdAt,
    this.birthday,
    this.avatar,
  });

  final String id;
  final String email;
  final String displayName;
  final String passwordHash;
  final DateTime createdAt;
  final DateTime? birthday;
  final StoredMedia? avatar;

  String get initials {
    final parts = displayName
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }

  AppUser copyWith({
    String? displayName,
    DateTime? birthday,
    StoredMedia? avatar,
    bool clearBirthday = false,
    bool clearAvatar = false,
  }) =>
      AppUser(
        id: id,
        email: email,
        displayName: displayName ?? this.displayName,
        passwordHash: passwordHash,
        createdAt: createdAt,
        birthday: clearBirthday ? null : (birthday ?? this.birthday),
        avatar: clearAvatar ? null : (avatar ?? this.avatar),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'displayName': displayName,
        'passwordHash': passwordHash,
        'createdAt': createdAt.toIso8601String(),
        if (birthday != null) 'birthday': birthday!.toIso8601String(),
        if (avatar != null) 'avatar': avatar!.toJson(),
      };

  static AppUser fromJson(Map<String, dynamic> json) => AppUser(
        id: json['id'] as String,
        email: json['email'] as String,
        displayName: json['displayName'] as String? ?? '',
        passwordHash: json['passwordHash'] as String? ?? '',
        createdAt: DateTime.parse(json['createdAt'] as String),
        birthday: json['birthday'] == null
            ? null
            : DateTime.parse(json['birthday'] as String),
        avatar: StoredMedia.fromJson((json['avatar'] as Map?)?.cast<String, dynamic>()),
      );
}

