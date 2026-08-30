/// Ein Album fasst Erinnerungen, Duefte und Geraeusche zusammen
/// (Businessplan, Kapitel 7.2).
class Album {
  const Album({
    required this.id,
    required this.name,
    required this.createdAt,
    this.description = '',
    this.memoryIds = const [],
    this.isDemo = false,
  });

  final String id;
  final String name;
  final String description;
  final List<String> memoryIds;
  final DateTime createdAt;
  final bool isDemo;

  Album copyWith({
    String? name,
    String? description,
    List<String>? memoryIds,
  }) =>
      Album(
        id: id,
        name: name ?? this.name,
        description: description ?? this.description,
        memoryIds: memoryIds ?? this.memoryIds,
        createdAt: createdAt,
        isDemo: isDemo,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'memoryIds': memoryIds,
        'createdAt': createdAt.toIso8601String(),
        'demo': isDemo,
      };

  static Album fromJson(Map<String, dynamic> json) => Album(
        id: json['id'] as String,
        name: json['name'] as String? ?? '',
        description: json['description'] as String? ?? '',
        memoryIds: (json['memoryIds'] as List?)?.cast<String>() ?? const [],
        createdAt: DateTime.parse(json['createdAt'] as String),
        isDemo: json['demo'] as bool? ?? false,
      );
}
