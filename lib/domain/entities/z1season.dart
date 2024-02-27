class Z1Season {
  final String id;
  final String name;
  final String version;
  final int number;
  final List<String> z1TrackIds;

  Z1Season({
    required this.id,
    required this.name,
    required this.version,
    required this.number,
    this.z1TrackIds = const [],
  });

  Z1Season copyWith({
    String? id,
    String? name,
    String? version,
    int? number,
    List<String>? z1TrackIds,
  }) {
    return Z1Season(
      id: id ?? this.id,
      name: name ?? this.name,
      version: version ?? this.version,
      number: number ?? this.number,
      z1TrackIds: z1TrackIds ?? this.z1TrackIds,
    );
  }

  factory Z1Season.fromMap(Map<String, dynamic> map) {
    return Z1Season(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      number: int.parse(map['number']?.toString() ?? '0'),
      version: map['version']?.toString() ?? '',
      z1TrackIds:
          (map['z1TrackIds'] as List?)?.map((e) => e.toString()).toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'version': version,
      'number': number,
      'z1TrackIds': z1TrackIds,
    };
  }
}
