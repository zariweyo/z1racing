import 'dart:math' as math;
import 'package:collection/collection.dart';
import 'package:vector_math/vector_math_64.dart';
import 'package:z1racing/models/slot/slot_model.dart';

enum RectModelClosedSide { none, left, right }

class RectModel extends SlotModel {
  final RectModelClosedSide closedSide;
  RectModel({
    required super.size,
    super.sensor,
    this.closedSide = RectModelClosedSide.none,
    super.closedAdded = SlotModelClosedAdded.none,
    super.level = SlotModelLevel.floor,
  }) : super(type: TrackModelType.rect);

  factory RectModel.fromMap(dynamic mapDyn) {
    final map = mapDyn as Map<String, dynamic>;
    assert(map['length'] != null || map['size'] != null);
    assert(
      (map['length'] != null && map['length'] is num) ||
          ((map['size'] as Map<String, dynamic>)['x'] != null &&
              (map['size'] as Map<String, dynamic>)['x'] is num),
    );
    assert(
      (map['length'] != null && map['length'] is num) ||
          ((map['size'] as Map<String, dynamic>)['y'] != null &&
              (map['size'] as Map<String, dynamic>)['y'] is num),
    );

    return RectModel(
      size: map['length'] != null
          ? Vector2(double.tryParse(map['length'].toString()) ?? 0, 60)
          : Vector2(
              double.tryParse(
                    (map['size'] as Map<String, dynamic>)['x'].toString(),
                  ) ??
                  0,
              double.tryParse(
                    (map['size'] as Map<String, dynamic>)['y'].toString(),
                  ) ??
                  0,
            ),
      closedSide: map['closedSide'] != null
          ? RectModelClosedSide.values.firstWhereOrNull(
                (element) => element.name == map['closedSide'],
              ) ??
              RectModelClosedSide.none
          : RectModelClosedSide.none,
      closedAdded: map['closedAdded'] != null
          ? SlotModelClosedAdded.values.firstWhere(
              (element) => element.name == map['closedAdded'],
              orElse: () => SlotModelClosedAdded.none,
            )
          : SlotModelClosedAdded.none,
      sensor: map['sensor'] != null
          ? TrackModelSensor.values.firstWhereOrNull(
                (element) => element.name == map['sensor'],
              ) ??
              TrackModelSensor.none
          : TrackModelSensor.none,
      level: map['level'] != null
          ? SlotModelLevel.values.firstWhere(
              (element) => element.name == map['level'],
              orElse: () => SlotModelLevel.floor,
            )
          : SlotModelLevel.floor,
    );
  }

  @override
  double get inputAngle => -math.pi / 2;

  @override
  double get outputAngle => -math.pi / 2;

  @override
  List<Vector2> get masterPoints => [Vector2(0, 5), Vector2(size.x, 5)];

  @override
  List<Vector2> get points1 => closedSide == RectModelClosedSide.left
      ? _generatePoint(2)
      : _generatePoint(1);

  @override
  List<Vector2> get points2 => closedSide == RectModelClosedSide.left
      ? _generatePoint(1)
      : _generatePoint(2);

  @override
  List<Vector2> get inside => [
        Vector2.zero(),
        Vector2(0, 45),
        Vector2(size.x, 45),
        Vector2(size.x, 5),
        Vector2(0, 5),
      ];

  List<Vector2> _generatePoint(int num) {
    if (num == 1) {
      return [
        Vector2(0, 5),
        Vector2(size.x, 5),
        Vector2(size.x, 7),
        Vector2(0, 7),
        Vector2(0, 5),
      ];
    } else {
      return [
        Vector2(0, 45),
        Vector2(size.x, 45),
        Vector2(size.x, 43),
        Vector2(0, 43),
        Vector2(0, 45),
      ];
    }
  }

  @override
  List<Vector2> get pointsAdded {
    var points = <Vector2>[];

    var addedStart = 0.0;
    var addedEnd = 0.0;

    if ([SlotModelClosedAdded.start, SlotModelClosedAdded.both]
        .contains(closedAdded)) {
      addedStart = 10;
    }

    if ([SlotModelClosedAdded.end, SlotModelClosedAdded.both]
        .contains(closedAdded)) {
      addedEnd = 10;
    }

    switch (closedSide) {
      case RectModelClosedSide.none:
        return points;
      case RectModelClosedSide.left:
        points = [
          Vector2(0, 7),
          Vector2(addedStart, 0),
          Vector2(size.x - addedEnd, 0),
          Vector2(size.x, 7),
        ];
        break;
      case RectModelClosedSide.right:
        points = [
          Vector2(0, 43),
          Vector2(addedStart, 50),
          Vector2(size.x - addedEnd, 50),
          Vector2(size.x, 43),
        ];
        break;
    }

    if ([SlotModelClosedAdded.none, SlotModelClosedAdded.end]
        .contains(closedAdded)) {
      points.remove(points.first);
    }

    if ([SlotModelClosedAdded.none, SlotModelClosedAdded.start]
        .contains(closedAdded)) {
      points.remove(points.last);
    }

    return points;
  }

  @override
  List<Vector2> get pointsAddedPlus => closedSide == RectModelClosedSide.left
      ? [
          Vector2(0, 7),
          Vector2(size.x, 7),
        ]
      : closedSide == RectModelClosedSide.right
          ? [Vector2(0, 43), Vector2(size.x, 43)]
          : [];
}
