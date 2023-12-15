import 'package:collection/collection.dart';
import 'package:vector_math/vector_math_64.dart';
import 'package:z1racing/game/track/models/slot_model.dart';

class Z1Track {
  final String trackId;
  final String name;
  final int numLaps;
  final List<SlotModel> slots;
  final DateTime initialDatetime;
  final int version;
  final double carInitAngle;

  String get id => '${trackId}_$numLaps';

  Z1Track({
    required this.trackId,
    required this.name,
    required this.numLaps,
    required this.slots,
    required this.initialDatetime,
    required this.version,
    this.carInitAngle = 0,
  });

  Z1Track copyWith(
    String? trackId,
    String? name,
    int? numLaps,
    List<SlotModel>? slots,
    DateTime? initialDatetime,
    int? version,
    double? carInitAngle,
  ) {
    return Z1Track(
      trackId: trackId ?? this.trackId,
      name: name ?? this.name,
      numLaps: numLaps ?? this.numLaps,
      slots: slots ?? this.slots,
      initialDatetime: initialDatetime ?? this.initialDatetime,
      version: version ?? this.version,
      carInitAngle: carInitAngle ?? this.carInitAngle,
    );
  }

  factory Z1Track.fromMap(Map<String, dynamic> map) {
    return Z1Track(
      trackId: map['trackId']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      numLaps: int.tryParse(map['numLaps']?.toString() ?? '') ?? 0,
      initialDatetime: map['initialDatetime'] != null
          ? DateTime.parse(map['initialDatetime'].toString())
          : DateTime.utc(1900),
      slots: map['slots'] != null
          ? (map['slots'] as List<dynamic>)
              .map<SlotModel>(SlotModel.fromMap)
              .toList()
          : [],
      version: int.tryParse(map['version']?.toString() ?? '') ?? 0,
      carInitAngle: map['carInitAngle'] != null && map['carInitAngle'] is double
          ? double.tryParse(map['carInitAngle'].toString()) ?? 0.0
          : 0.0,
    );
  }

  factory Z1Track.empty() {
    return Z1Track(
      trackId: '',
      name: '',
      numLaps: 0,
      slots: [],
      initialDatetime: DateTime.now().toUtc(),
      version: 0,
    );
  }

  bool get isActive => DateTime.now().difference(initialDatetime).inSeconds > 0;

  bool get isEmpty => trackId == '';

  List<Vector2> get points =>
      slots.map((slot) => slot.points1).flattened.toList();

  double get width => maxX - minX;
  double get height => maxY - minY;

  double get minX => points.map((e) => e.x).min;
  double get maxX => points.map((e) => e.x).max;
  double get minY => points.map((e) => e.y).min;
  double get maxY => points.map((e) => e.y).max;

  /* dynamic toJson() {
    return {
      "trackId": trackId,
      "name": name,
      "slots": slots.map((e) => e.toJson()).toList()
    };
  } */
}
