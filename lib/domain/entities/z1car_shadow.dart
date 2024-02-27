import 'package:collection/collection.dart';
import 'package:vector_math/vector_math_64.dart';
import 'package:z1racing/base/utils/zip_utils.dart';
import 'package:z1racing/domain/entities/slot/slot_model.dart';
import 'package:z1racing/extensions/double_extension.dart';
import 'package:z1racing/extensions/duration_extension.dart';
import 'package:z1racing/extensions/vector2_extension.dart';

class Z1CarShadow {
  final String id;
  final String uid;
  final String z1UserRaceId;
  final String trackId;
  final int version;
  final List<Z1CarShadowPosition> positions;

  Z1CarShadow({
    required this.id,
    required this.uid,
    required this.z1UserRaceId,
    required this.trackId,
    this.positions = const [],
    this.version = 1,
  });

  void addPosition(Z1CarShadowPosition newPosition) {
    if (positions.isNotEmpty &&
        positions.last.position.isEqual(newPosition.position)) {
      //return;
    }
    positions.add(newPosition);
  }

  factory Z1CarShadow.zero() {
    return Z1CarShadow(
      id: '',
      uid: '',
      z1UserRaceId: '',
      trackId: '',
      positions: [],
    );
  }

  Z1CarShadow clone() {
    return Z1CarShadow(
      version: version,
      id: id,
      uid: uid,
      z1UserRaceId: z1UserRaceId,
      trackId: trackId,
      positions: positions.map((e) => e.clone()).toList(),
    );
  }

  factory Z1CarShadow.fromMap(Map<String, dynamic> map) {
    if (map['version'] == null) {
      return Z1CarShadow(
        version: 0,
        id: map['id']?.toString() ?? '',
        uid: map['uid']?.toString() ?? '',
        trackId: map['trackId']?.toString() ?? '',
        z1UserRaceId: map['z1UserRaceId']?.toString() ?? '',
        positions: map['positions'] != null && map['positions'] is List
            ? (map['positions'] as List)
                .map(Z1CarShadowPosition.fromMap)
                .toList()
            : [],
      );
    } else {
      var positions = <Z1CarShadowPosition>[];
      if (map['positionsZIP'] != null) {
        final jsonUnziped = ZipUtils.unzipJson(map['positionsZIP'] as String);
        if (jsonUnziped['data'] != null && jsonUnziped['data'] is List) {
          positions = (jsonUnziped['data'] as List)
              .map(Z1CarShadowPosition.fromMap)
              .toList();
        }
      }

      return Z1CarShadow(
        version: map['version'] as int? ?? 0,
        id: map['id']?.toString() ?? '',
        uid: map['uid']?.toString() ?? '',
        trackId: map['trackId']?.toString() ?? '',
        z1UserRaceId: map['z1UserRaceId']?.toString() ?? '',
        positions: positions,
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'version': version,
      'id': id,
      'uid': uid,
      'z1UserRaceId': z1UserRaceId,
      'positionsZIP': ZipUtils.zipJson({
        'data': positions.map((e) => e.toJson()).toList(),
      }),
    };
  }
}

class Z1CarShadowPosition {
  final Duration time;
  final Vector2 position;
  final double angle;
  final SlotModelLevel level;

  Z1CarShadowPosition({
    required this.time,
    required this.position,
    required this.angle,
    required this.level,
  });

  factory Z1CarShadowPosition.fromMap(dynamic map) {
    if (map is! Map<String, dynamic>) {
      return Z1CarShadowPosition.zero();
    }

    final reduced = map['reduced'] as String?;
    final reducedTime = reduced != null
        ? DurationExtension.fromMap(int.parse(reduced.split(';')[0]))
        : null;
    final reducedAngle =
        reduced != null ? double.parse(reduced.split(';')[1]) : null;
    final reducedLevel = reduced != null
        ? SlotModelLevel.values.firstWhereOrNull(
              (element) => element.name == reduced.split(';')[2],
            ) ??
            SlotModelLevel.floor
        : null;

    return Z1CarShadowPosition(
      time: reducedTime ?? DurationExtension.fromMap(map['time']),
      angle: reducedAngle ?? map['angle'] as double? ?? 0,
      level: reducedLevel ??
          (map['level'] != null
              ? SlotModelLevel.values.firstWhereOrNull(
                    (element) => element.name == map['level'],
                  ) ??
                  SlotModelLevel.floor
              : SlotModelLevel.floor),
      position: map['positionVector'] != null &&
              map['positionVector'] is List &&
              (map['positionVector'] as List).length > 1
          ? Vector2Extension.fromMapList(map['positionVector'] ?? {}) ??
              Vector2.zero()
          : Vector2Extension.fromMap(map['position'] ?? {}) ?? Vector2.zero(),
    );
  }

  factory Z1CarShadowPosition.zero() {
    return Z1CarShadowPosition(
      time: Duration.zero,
      angle: 0,
      level: SlotModelLevel.floor,
      position: Vector2.zero(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'reduced': '${time.toMap()};${angle.truncateDecimals(2)};${level.name}',
      'positionVector': position.toMapList(),
    };
  }

  Z1CarShadowPosition clone() {
    return Z1CarShadowPosition(
      time: time,
      angle: angle,
      level: level,
      position: position.clone(),
    );
  }
}
