import 'package:z1racing/game/track/models/slot_model.dart';

class Z1Track {
  final String trackId;
  final String name;
  final int numLaps;
  final List<SlotModel> slots;
  final DateTime initialDatetime;
  final int version;

  String get id => "${trackId}_${numLaps}";

  Z1Track(
      {required this.trackId,
      required this.name,
      required this.numLaps,
      required this.slots,
      required this.initialDatetime,
      required this.version});

  Z1Track copyWith(String? trackId, String? name, int? numLaps,
      List<SlotModel>? slots, DateTime? initialDatetime, int? version) {
    return Z1Track(
      trackId: trackId ?? this.trackId,
      name: name ?? this.name,
      numLaps: numLaps ?? this.numLaps,
      slots: slots ?? this.slots,
      initialDatetime: initialDatetime ?? this.initialDatetime,
      version: version ?? this.version,
    );
  }

  factory Z1Track.fromMap(Map<String, dynamic> map) {
    return Z1Track(
      trackId: map['trackId'] ?? "",
      name: map['name'] ?? "",
      numLaps: map['numLaps'] ?? 0,
      initialDatetime: map['initialDatetime'] != null
          ? DateTime.parse(map['initialDatetime'])
          : DateTime.utc(1900),
      slots: map['slots'] != null
          ? (map['slots'] as List<dynamic>)
              .map((e) => SlotModel.fromMap(e))
              .toList()
          : [],
      version: map['version'] ?? 0,
    );
  }

  factory Z1Track.empty() {
    return Z1Track(
        trackId: "",
        name: "",
        numLaps: 0,
        slots: [],
        initialDatetime: DateTime.now().toUtc(),
        version: 0);
  }

  bool get isActive => DateTime.now().difference(initialDatetime).inSeconds > 0;

  /* dynamic toJson() {
    return {
      "trackId": trackId,
      "name": name,
      "slots": slots.map((e) => e.toJson()).toList()
    };
  } */
}
