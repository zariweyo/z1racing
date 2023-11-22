import 'dart:math' as Math;
import 'package:collection/collection.dart';
import 'package:vector_math/vector_math_64.dart';
import 'package:z1racing/game/track/models/slot_model.dart';

enum RectModelClosedSide { none, left, right }

class RectModel extends SlotModel {
  final RectModelClosedSide closedSide;
  RectModel({
    required super.size,
    super.sensor,
    this.closedSide = RectModelClosedSide.none,
    super.closedAdded = SlotModelClosedAdded.none,
  }) : super(type: TrackModelType.rect);

  factory RectModel.fromMap(Map<String, dynamic> map) {
    assert(map['size'] != null);
    assert(map['size']['x'] != null && map['size']['x'] is num);
    assert(map['size']['y'] != null && map['size']['y'] is num);

    return RectModel(
      size: Vector2(double.tryParse(map['size']['x'].toString()) ?? 0,
          double.tryParse(map['size']['y'].toString()) ?? 0),
      closedSide: map['closedSide'] != null
          ? RectModelClosedSide.values.firstWhereOrNull(
                  (element) => element.name == map['closedSide']) ??
              RectModelClosedSide.none
          : RectModelClosedSide.none,
      closedAdded: map['closedAdded'] != null
          ? SlotModelClosedAdded.values.firstWhere(
              (element) => element.name == map['closedAdded'],
              orElse: () => SlotModelClosedAdded.none)
          : SlotModelClosedAdded.none,
      sensor: map['sensor'] != null
          ? TrackModelSensor.values.firstWhereOrNull(
                  (element) => element.name == map['sensor']) ??
              TrackModelSensor.none
          : TrackModelSensor.none,
    );
  }

  @override
  double get inputAngle => -Math.pi / 2;

  @override
  double get outputAngle => -Math.pi / 2;

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
        Vector2(0, 5)
      ];

  _generatePoint(int num) {
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
    List<Vector2> _points = [];

    double addedStart = 0;
    double addedEnd = 0;

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
        return _points;
      case RectModelClosedSide.left:
        _points = [
          Vector2(0, 7),
          Vector2(addedStart, 0),
          Vector2(size.x - addedEnd, 0),
          Vector2(size.x, 7)
        ];
        break;
      case RectModelClosedSide.right:
        _points = [
          Vector2(0, 43),
          Vector2(addedStart, 50),
          Vector2(size.x - addedEnd, 50),
          Vector2(size.x, 43)
        ];
        break;
    }

    if ([SlotModelClosedAdded.none, SlotModelClosedAdded.end]
        .contains(closedAdded)) {
      _points.remove(_points.first);
    }

    if ([SlotModelClosedAdded.none, SlotModelClosedAdded.start]
        .contains(closedAdded)) {
      _points.remove(_points.last);
    }

    return _points;
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
