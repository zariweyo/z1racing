import 'dart:math' as Math;
import 'package:collection/collection.dart';
import 'package:flame/extensions.dart';
import 'package:z1racing/game/track/models/slot_model.dart';

enum CurveModelDirection { right, left }

class CurveModel extends SlotModel {
  final double radius;
  final CurveModelDirection direction;
  final bool added;
  final double angle;
  CurveModel(
      {this.radius = 20,
      this.added = false,
      this.angle = 90,
      super.sensor,
      super.closedAdded = SlotModelClosedAdded.none,
      this.direction = CurveModelDirection.right})
      : super(type: TrackModelType.curve, size: Vector2(radius, radius)) {
    calculateData();
  }

  factory CurveModel.fromMap(Map<String, dynamic> map) {
    assert(map['radius'] != null && map['radius'] is num);
    assert(CurveModelDirection.values
        .map((e) => e.name)
        .contains(map['direction']));

    return CurveModel(
      angle: double.tryParse(map['angle'].toString()) ?? 90,
      radius: double.tryParse(map['radius'].toString()) ?? 20,
      sensor: map['sensor'] != null
          ? TrackModelSensor.values.firstWhereOrNull(
                  (element) => element.name == map['sensor']) ??
              TrackModelSensor.none
          : TrackModelSensor.none,
      added: map['added'] ?? false,
      direction: CurveModelDirection.values
          .firstWhere((element) => element.name == map['direction']),
      closedAdded: map['closedAdded'] != null
          ? SlotModelClosedAdded.values.firstWhere(
              (element) => element.name == map['closedAdded'],
              orElse: () => SlotModelClosedAdded.none)
          : SlotModelClosedAdded.none,
    );
  }

  double get minRadius => radius - 40;

  double get _angleAddToAdjust =>
      direction == CurveModelDirection.right ? Math.pi : 0;

  double get inputAngle =>
      Math.atan2(_firstP2.y - _firstP1.y, _firstP2.x - _firstP1.x) -
      _angleAddToAdjust;
  double get outputAngle =>
      Math.atan2(_lastP2.y - _lastP1.y, _lastP2.x - _lastP1.x) -
      _angleAddToAdjust;

  List<Vector2> inside = [];
  List<Vector2> points1 = [];
  List<Vector2> points2 = [];
  List<Vector2> pointsAdded = [];
  List<Vector2> pointsAddedPlus = [];

  List<Vector2> get masterPoints => _masterPoints;

  Vector2 get vectorPoints1 => _lastP1 - _firstP1;
  Vector2 get vectorPoints2 => _lastP2 - _firstP2;

  late Vector2 _firstP1;
  late Vector2 _firstP2;
  late Vector2 _lastP1;
  late Vector2 _lastP2;
  late List<Vector2> _masterPoints;

  calculateData() {
    int addedExtend = 5;

    Vector2 center =
        _centerOfMedium(pointA: Vector2.zero(), pointB: size, radius: radius);

    inside = points(center, radius);
    inside.addAll(points(center, radius - 40).reversed);

    points1 = points(center, radius);
    _firstP1 = points1.first.clone();
    _lastP1 = points1.last.clone();
    if (direction == CurveModelDirection.right)
      _masterPoints = points(center, radius);
    points1.addAll(points(center, radius - 2).reversed);
    points1.add(_firstP1);

    points2 = points(center, radius - 40);
    _firstP2 = points2.first.clone();
    _lastP2 = points2.last.clone();
    if (direction == CurveModelDirection.left)
      _masterPoints = points(center, radius - 40);
    points2.addAll(points(center, radius - 38).reversed);
    points2.add(_firstP2);

    if (added) {
      List<Vector2> pointsAddedBase = points(center, radius - 45);
      pointsAddedPlus = points(center, radius - 38);
      int limitStart = 0;
      int limitEnd = 0;
      switch (closedAdded) {
        case SlotModelClosedAdded.none:
          limitStart = 0;
          limitEnd = 0;
          break;
        case SlotModelClosedAdded.start:
          limitStart = pointsAddedBase.length > 10 ? addedExtend : 0;
          limitEnd = 0;
          break;
        case SlotModelClosedAdded.end:
          limitStart = 0;
          limitEnd = pointsAddedBase.length > 10 ? addedExtend : 0;
          break;
        case SlotModelClosedAdded.both:
          limitStart = pointsAddedBase.length > 10 ? addedExtend : 0;
          limitEnd = pointsAddedBase.length > 10 ? addedExtend : 0;
          break;
      }
      if ([SlotModelClosedAdded.start, SlotModelClosedAdded.both]
          .contains(closedAdded)) {
        pointsAdded.add(pointsAddedPlus.first);
      }
      pointsAdded.addAll(pointsAddedBase.sublist(
          limitStart, pointsAddedBase.length - limitEnd));
      if ([SlotModelClosedAdded.end, SlotModelClosedAdded.both]
          .contains(closedAdded)) {
        pointsAdded.add(pointsAddedPlus.last);
      }
    }
  }

  Vector2 _centerOfMedium(
      {required Vector2 pointA,
      required Vector2 pointB,
      required double radius}) {
    num B_X = pointA.x - pointB.x; // c
    num B_Y = pointA.y - pointB.y; // d

    num B_X_2 = Math.pow(B_X, 2); // c2
    num B_Y_2 = Math.pow(B_Y, 2); // d2

    num R_2 = Math.pow(radius, 2);

    num a = 4 * B_Y_2 + 4 * B_X_2;
    num b = 4 * B_X * (B_Y_2 + B_X_2);
    num c = -4 * B_Y_2 * R_2 + Math.pow((B_X_2 + B_Y_2), 2);

    num b_2 = Math.pow(b, 2);

    double resX = (-b - Math.sqrt(b_2 - 4 * a * c)) / (2 * a);
    double resY = (B_Y_2 + B_X_2 + 2 * B_X * resX) / (2 * B_Y);

    return Vector2(resX, resY);
  }

  List<Vector2> points(Vector2 center, double radius) {
    double angMax = Math.acos(center.x.abs() / (radius - (radius - minRadius)));
    double angMin = Math.pi / 2 - angMax;

    List<Vector2> vertices = [];
    double xLim = (radius * Math.sin((this.angle / 180) * Math.pi)) / 90;
    for (double x = 0; x <= 1 + this.radius * xLim; x++) {
      num xx = Math.pow((x - center.x), 2);
      num r_2 = Math.pow(radius, 2);
      num k_2 = Math.pow(center.y, 2);

      num a = 1;
      num b = 2 * center.y;
      num c = k_2 - r_2 + xx;

      double y = (-b - Math.sqrt(Math.pow(b, 2) - 4 * a * c)) / (2 * a);

      double ang = Math.acos((x.abs() + center.x.abs()) / radius);

      if (angMin <= ang && angMax >= ang) vertices.add(Vector2(x, y));
    }

    if (direction == CurveModelDirection.left) {
      vertices = vertices.reversed
          .map((vert) =>
              (vert..rotate(Math.pi)).translated(this.radius, this.radius))
          .toList();
    }

    return vertices;
  }
}
