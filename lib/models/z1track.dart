import 'package:z1racing/game/track/models/slot_model.dart';

class Z1Track {
  final String trackId;
  final String name;
  final int numLaps;
  final List<SlotModel> slots;

  String get id => "${trackId}_${numLaps}";

  Z1Track(
      {required this.trackId,
      required this.name,
      required this.numLaps,
      required this.slots});

  Z1Track copyWith(
      String? trackId, String? name, int? numLaps, List<SlotModel>? slots) {
    return Z1Track(
        trackId: trackId ?? this.trackId,
        name: name ?? this.name,
        numLaps: numLaps ?? this.numLaps,
        slots: slots ?? this.slots);
  }

  factory Z1Track.fromMap(Map<String, dynamic> map) {
    return Z1Track(
      trackId: map['trackId'] ?? "",
      name: map['name'] ?? "",
      numLaps: map['numLaps'] ?? 0,
      slots: map['slots'] != null
          ? (map['slots'] as List<Map<String, dynamic>>)
              .map((e) => SlotModel.fromMap(e))
              .toList()
          : [],
    );
  }

  factory Z1Track.empty() {
    return Z1Track(trackId: "", name: "", numLaps: 0, slots: []);
  }

  /* dynamic toJson() {
    return {
      "trackId": trackId,
      "name": name,
      "slots": slots.map((e) => e.toJson()).toList()
    };
  } */
}
