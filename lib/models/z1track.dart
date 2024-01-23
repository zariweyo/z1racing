import 'package:collection/collection.dart';
import 'package:vector_math/vector_math_64.dart';
import 'package:z1racing/models/object/object_model.dart';
import 'package:z1racing/models/slot/slot_model.dart';

class Z1Track {
  final String trackId;
  final String name;
  final int numLaps;
  final List<SlotModel> slots;
  final int version;
  final double carInitAngle;
  final int order;
  final bool enabled;
  final List<ObjectModel> objects;

  String get id => '${trackId}_$numLaps';

  Z1Track({
    required this.trackId,
    required this.name,
    required this.numLaps,
    required this.slots,
    required this.order,
    required this.enabled,
    required this.version,
    required this.objects,
    this.carInitAngle = 0,
  });

  Z1Track copyWith({
    String? trackId,
    String? name,
    int? numLaps,
    List<SlotModel>? slots,
    int? order,
    bool? enabled,
    int? version,
    double? carInitAngle,
    List<ObjectModel>? objects,
  }) {
    return Z1Track(
      trackId: trackId ?? this.trackId,
      name: name ?? this.name,
      numLaps: numLaps ?? this.numLaps,
      slots: slots ?? this.slots,
      order: order ?? this.order,
      enabled: enabled ?? this.enabled,
      version: version ?? this.version,
      carInitAngle: carInitAngle ?? this.carInitAngle,
      objects: objects ?? this.objects,
    );
  }

  factory Z1Track.fromMap(Map<String, dynamic> map) {
    return Z1Track(
      trackId: map['trackId']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      numLaps: int.tryParse(map['numLaps']?.toString() ?? '') ?? 0,
      order: int.tryParse(map['order']?.toString() ?? '') ?? 0,
      enabled: bool.tryParse(map['enabled']?.toString() ?? '') ?? false,
      slots: map['slots'] != null
          ? (map['slots'] as List<dynamic>)
              .map<SlotModel>(SlotModel.fromMap)
              .toList()
          : [],
      version: int.tryParse(map['version']?.toString() ?? '') ?? 0,
      carInitAngle: map['carInitAngle'] != null && map['carInitAngle'] is double
          ? double.tryParse(map['carInitAngle'].toString()) ?? 0.0
          : 0.0,
      objects: map['objects'] != null
          ? (map['objects'] as List<dynamic>)
              .map<ObjectModel>(ObjectModel.fromMap)
              .toList()
          : [],
    );
  }

  factory Z1Track.empty() {
    return Z1Track(
      trackId: '',
      name: '',
      numLaps: 0,
      enabled: false,
      slots: [],
      order: 0,
      version: 0,
      objects: [],
    );
  }

  bool get isActive => enabled;

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
