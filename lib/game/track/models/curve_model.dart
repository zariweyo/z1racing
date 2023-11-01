import 'dart:math' as Math;
import 'package:flame/extensions.dart';
import 'package:z1racing/game/track/models/slot_model.dart';

enum CurveModelDirection { right, left }

enum CurveModelClosedAdded { none, start, end, both }

class CurveModel extends SlotModel {
  final double radius;
  final CurveModelDirection direction;
  final CurveModelClosedAdded closedAdded;
  CurveModel(
      {required super.size,
      this.radius = 20,
      this.closedAdded = CurveModelClosedAdded.none,
      this.direction = CurveModelDirection.right})
      : super(type: TrackModelType.curve) {
    calculateData();
  }

  factory CurveModel.fromMap(Map<String, dynamic> map) {
    assert(map['size'] != null);
    assert(map['size']['x'] != null && map['size']['x'] is double);
    assert(map['size']['y'] != null && map['size']['y'] is double);
    assert(map['radius'] != null && map['radius'] is double);
    assert(CurveModelDirection.values
        .map((e) => e.name)
        .contains(map['direction']));

    return CurveModel(
      size: Vector2(map['size']['x'], map['size']['y']),
      radius: map['radius'],
      direction: CurveModelDirection.values
          .firstWhere((element) => element.name == map['direction']),
      closedAdded: CurveModelClosedAdded.values.firstWhere(
          (element) => element.name == map['closedAdded'],
          orElse: () => CurveModelClosedAdded.none),
    );
  }

  double get minRadius => radius - 40;

  double get _angleAddToAdjust =>
      direction == CurveModelDirection.right ? Math.pi : 0;

  double get inputAngle =>
      Math.atan2(points2.first.y - points1.first.y,
          points2.first.x - points1.first.x) -
      _angleAddToAdjust;
  double get outputAngle =>
      Math.atan2(
          points2.last.y - points1.last.y, points2.last.x - points1.last.x) -
      _angleAddToAdjust;

  List<Vector2> points1 = [];
  List<Vector2> points2 = [];
  List<Vector2> pointsAdded = [];
  List<Vector2> pointsAddedPlus = [];

  List<Vector2> get masterPoints =>
      direction == CurveModelDirection.right ? points1 : points2;

  Vector2 get vectorPoints1 => points1.last - points1.first;
  Vector2 get vectorPoints2 => points2.last - points2.first;

  calculateData() {
    Vector2 center =
        _centerOfMedium(pointA: Vector2.zero(), pointB: size, radius: radius);

    points1 = points(center, radius);
    points2 = points(center, radius - 40);
    List<Vector2> pointsAddedBase = points(center, radius - 45);
    pointsAddedPlus = points(center, radius - 40);
    int limitStart = 0;
    int limitEnd = 0;
    switch (closedAdded) {
      case CurveModelClosedAdded.none:
        limitStart = 0;
        limitEnd = 0;
        break;
      case CurveModelClosedAdded.start:
        limitStart = pointsAddedBase.length > 10 ? 5 : 0;
        limitEnd = 0;
        break;
      case CurveModelClosedAdded.end:
        limitStart = 0;
        limitEnd = pointsAddedBase.length > 10 ? 5 : 0;
        break;
      case CurveModelClosedAdded.both:
        limitStart = pointsAddedBase.length > 10 ? 5 : 0;
        limitEnd = pointsAddedBase.length > 10 ? 5 : 0;
        break;
    }
    if ([CurveModelClosedAdded.start, CurveModelClosedAdded.both]
        .contains(closedAdded)) {
      pointsAdded.add(pointsAddedPlus.first);
    }
    pointsAdded.addAll(
        pointsAddedBase.sublist(limitStart, pointsAddedBase.length - limitEnd));
    if ([CurveModelClosedAdded.end, CurveModelClosedAdded.both]
        .contains(closedAdded)) {
      pointsAdded.add(pointsAddedPlus.last);
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
    for (double x = 0; x <= size.x; x++) {
      num xx = Math.pow((x - center.x), 2);
      num r_2 = Math.pow(radius, 2);
      num k_2 = Math.pow(center.y, 2);

      num a = 1;
      num b = 2 * center.y;
      num c = k_2 - r_2 + xx;

      double y = (-b - Math.sqrt(Math.pow(b, 2) - 4 * a * c)) / (2 * a);

      double ang = Math.acos((x.abs() + center.x.abs()) / radius);

      if (angMin < ang && angMax > ang) vertices.add(Vector2(x, y));
    }

    if (direction == CurveModelDirection.left) {
      vertices = vertices.reversed
          .map((vert) => (vert..rotate(Math.pi)).translated(size.x, size.y))
          .toList();
    }

    return vertices;
  }
}
