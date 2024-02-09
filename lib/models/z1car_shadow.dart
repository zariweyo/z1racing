import 'package:collection/collection.dart';
import 'package:vector_math/vector_math_64.dart';
import 'package:z1racing/extensions/duration_extension.dart';
import 'package:z1racing/extensions/vector2_extension.dart';
import 'package:z1racing/models/slot/slot_model.dart';

class Z1CarShadow {
  final String id;
  final String uid;
  final String z1UserRaceId;
  final List<Z1CarShadowPosition> positions;

  Z1CarShadow({
    required this.id,
    required this.uid,
    required this.z1UserRaceId,
    this.positions = const [],
  });

  void addPosition(Z1CarShadowPosition newPosition) {
    if (positions.isNotEmpty &&
        positions.last.position.isEqual(newPosition.position)) {
      //return;
    }
    positions.add(newPosition);
  }

  factory Z1CarShadow.fromMap(Map<String, dynamic> map) {
    return Z1CarShadow(
      id: map['id']?.toString() ?? '',
      uid: map['uid']?.toString() ?? '',
      z1UserRaceId: map['z1UserRaceId']?.toString() ?? '',
      positions: map['positions'] != null && map['positions'] is List
          ? (map['positions'] as List).map(Z1CarShadowPosition.fromMap).toList()
          : [],
    );
  }

  Z1CarShadow clone() {
    return Z1CarShadow(
      id: id,
      uid: uid,
      z1UserRaceId: z1UserRaceId,
      positions: positions.map((e) => e.clone()).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'uid': uid,
      'z1UserRaceId': z1UserRaceId,
      'positions': positions.map((e) => e.toJson()).toList(),
    };
  }
}

class Z1CarShadowPosition {
  final Duration time;
  final Vector2 position;
  final double angle;
  final SlotModelLevel level;
  final List<Z1CarShadowTrailPosition> trailPositions;

  Z1CarShadowPosition({
    required this.time,
    required this.position,
    required this.angle,
    required this.level,
    required this.trailPositions,
  });

  factory Z1CarShadowPosition.fromMap(dynamic map) {
    if (map is! Map<String, dynamic>) {
      return Z1CarShadowPosition.zero();
    }
    return Z1CarShadowPosition(
      time: DurationExtension.fromMap(map['time']),
      angle: map['angle'] as double? ?? 0,
      level: map['level'] != null
          ? SlotModelLevel.values.firstWhereOrNull(
                (element) => element.name == map['level'],
              ) ??
              SlotModelLevel.floor
          : SlotModelLevel.floor,
      position:
          Vector2Extension.fromMap(map['position'] ?? {}) ?? Vector2.zero(),
      trailPositions:
          map['trailPositions'] != null && map['trailPositions'] is List
              ? (map['trailPositions'] as List)
                  .map(Z1CarShadowTrailPosition.fromMap)
                  .toList()
              : [],
    );
  }

  factory Z1CarShadowPosition.zero() {
    return Z1CarShadowPosition(
      time: Duration.zero,
      angle: 0,
      level: SlotModelLevel.floor,
      position: Vector2.zero(),
      trailPositions: [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'time': time.toMap(),
      'angle': angle,
      'level': level.name,
      'position': position.toMap(),
      'trailPositions': trailPositions.map((e) => e.toJson()).toList(),
    };
  }

  Z1CarShadowPosition clone() {
    return Z1CarShadowPosition(
      time: time,
      angle: angle,
      level: level,
      position: position.clone(),
      trailPositions: trailPositions.map((e) => e.clone()).toList(),
    );
  }
}

class Z1CarShadowTrailPosition {
  final Vector2 position;
  Z1CarShadowTrailPosition({required this.position});

  factory Z1CarShadowTrailPosition.fromMap(dynamic map) {
    if (map is! Map<String, dynamic>) {
      return Z1CarShadowTrailPosition.zero();
    }
    return Z1CarShadowTrailPosition(
      position:
          Vector2Extension.fromMap(map['position'] ?? {}) ?? Vector2.zero(),
    );
  }

  factory Z1CarShadowTrailPosition.zero() {
    return Z1CarShadowTrailPosition(
      position: Vector2.zero(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'position': position.toMap(),
    };
  }

  Z1CarShadowTrailPosition clone() {
    return Z1CarShadowTrailPosition(
      position: position.clone(),
    );
  }
}
