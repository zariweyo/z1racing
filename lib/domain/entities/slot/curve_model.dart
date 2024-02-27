import 'dart:math' as math;
import 'dart:math';
import 'package:collection/collection.dart';
import 'package:flame/extensions.dart';
import 'package:z1racing/domain/entities/slot/slot_model.dart';

enum CurveModelDirection { right, left }

class CurveModel extends SlotModel {
  final double radius;
  final CurveModelDirection direction;
  final bool added;
  final double angle;
  CurveModel({
    this.radius = 20,
    this.added = false,
    this.angle = 90,
    super.sensor,
    super.closedAdded = SlotModelClosedAdded.none,
    this.direction = CurveModelDirection.right,
    super.level = SlotModelLevel.floor,
  }) : super(type: TrackModelType.curve, size: Vector2(radius, radius)) {
    calculateData();
  }

  @override
  double get lenght => 2 * pi * radius * angle / 360;

  factory CurveModel.fromMap(dynamic mapDyn) {
    final map = mapDyn as Map<String, dynamic>;
    assert(map['radius'] != null && map['radius'] is num);
    assert(
      CurveModelDirection.values.map((e) => e.name).contains(map['direction']),
    );

    return CurveModel(
      angle: double.tryParse(map['angle'].toString()) ?? 90,
      radius: double.tryParse(map['radius'].toString()) ?? 20,
      sensor: map['sensor'] != null
          ? TrackModelSensor.values.firstWhereOrNull(
                (element) => element.name == map['sensor'],
              ) ??
              TrackModelSensor.none
          : TrackModelSensor.none,
      added: bool.tryParse(map['added']?.toString() ?? 'false') ?? false,
      direction: CurveModelDirection.values
          .firstWhere((element) => element.name == map['direction']),
      closedAdded: map['closedAdded'] != null
          ? SlotModelClosedAdded.values.firstWhere(
              (element) => element.name == map['closedAdded'],
              orElse: () => SlotModelClosedAdded.none,
            )
          : SlotModelClosedAdded.none,
      level: map['level'] != null
          ? SlotModelLevel.values.firstWhere(
              (element) => element.name == map['level'],
              orElse: () => SlotModelLevel.floor,
            )
          : SlotModelLevel.floor,
    );
  }

  double get minRadius => radius - 40;

  double get _angleAddToAdjust =>
      direction == CurveModelDirection.right ? math.pi : 0;

  @override
  double get inputAngle =>
      math.atan2(_firstP2.y - _firstP1.y, _firstP2.x - _firstP1.x) -
      _angleAddToAdjust;
  @override
  double get outputAngle =>
      math.atan2(_lastP2.y - _lastP1.y, _lastP2.x - _lastP1.x) -
      _angleAddToAdjust;

  @override
  List<Vector2> inside = [];
  @override
  List<Vector2> points1 = [];
  @override
  List<Vector2> points2 = [];
  @override
  List<Vector2> pointsAdded = [];
  @override
  List<Vector2> pointsAddedPlus = [];
  @override
  List<List<Vector2>> vias = [];

  @override
  List<Vector2> get masterPoints => _masterPoints;

  Vector2 get vectorPoints1 => _lastP1 - _firstP1;
  Vector2 get vectorPoints2 => _lastP2 - _firstP2;

  late Vector2 _firstP1;
  late Vector2 _firstP2;
  late Vector2 _lastP1;
  late Vector2 _lastP2;
  late List<Vector2> _masterPoints;

  void calculateData() {
    const addedExtend = 5;

    final center =
        _centerOfMedium(pointA: Vector2.zero(), pointB: size, radius: radius);

    inside = points(center, radius);
    inside.addAll(points(center, radius - 40).reversed);
    inside.add(inside.first);

    points1 = points(center, radius);
    _firstP1 = points1.first.clone();
    _lastP1 = points1.last.clone();
    if (direction == CurveModelDirection.right) {
      _masterPoints = points(center, radius);
    }
    points1.addAll(points(center, radius - 2).reversed);
    points1.add(_firstP1);

    points2 = points(center, radius - 40);
    _firstP2 = points2.first.clone();
    _lastP2 = points2.last.clone();
    if (direction == CurveModelDirection.left) {
      _masterPoints = points(center, radius - 40);
    }
    points2.addAll(points(center, radius - 38).reversed);
    points2.add(_firstP2);

    final viasRef = <List<Vector2>>[];
    viasRef.add(points(center, radius - 35));
    viasRef.add(points(center, radius - 30));
    viasRef.add(points(center, radius - 25));
    viasRef.add(points(center, radius - 20));
    viasRef.add(points(center, radius - 15));
    viasRef.add(points(center, radius - 10));
    viasRef.add(points(center, radius - 5));

    if (direction == CurveModelDirection.right) {
      vias.addAll(viasRef);
    } else {
      vias.addAll(viasRef.reversed);
    }

    if (added) {
      final pointsAddedBase = points(center, radius - 45);
      pointsAddedPlus = points(center, radius - 38);
      var limitStart = 0;
      var limitEnd = 0;
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
      pointsAdded.addAll(
        pointsAddedBase.sublist(
          limitStart,
          pointsAddedBase.length - limitEnd,
        ),
      );
      if ([SlotModelClosedAdded.end, SlotModelClosedAdded.both]
          .contains(closedAdded)) {
        pointsAdded.add(pointsAddedPlus.last);
      }
    }
  }

  Vector2 _centerOfMedium({
    required Vector2 pointA,
    required Vector2 pointB,
    required double radius,
  }) {
    final num bX = pointA.x - pointB.x; // c
    final num bY = pointA.y - pointB.y; // d

    final bX2 = math.pow(bX, 2); // c2
    final bY2 = math.pow(bY, 2); // d2

    final r2 = math.pow(radius, 2);

    final a = 4 * bY2 + 4 * bX2;
    final b = 4 * bX * (bY2 + bX2);
    final c = -4 * bY2 * r2 + math.pow(bX2 + bY2, 2);

    final b_2 = math.pow(b, 2);

    final resX = (-b - math.sqrt(b_2 - 4 * a * c)) / (2 * a);
    final resY = (bY2 + bX2 + 2 * bX * resX) / (2 * bY);

    return Vector2(resX, resY);
  }

  List<Vector2> points(Vector2 center, double radius) {
    final angMax = math.acos(center.x.abs() / (radius - (radius - minRadius)));
    final angMin = math.pi / 2 - angMax;

    var vertices = <Vector2>[];
    final xLim = (radius * math.sin((angle / 180) * math.pi)) / 90;
    for (var x = 0; x <= 1 + this.radius * xLim; x++) {
      final xx = math.pow(x - center.x, 2);
      final r_2 = math.pow(radius, 2);
      final k_2 = math.pow(center.y, 2);

      const num a = 1;
      final num b = 2 * center.y;
      final c = k_2 - r_2 + xx;

      final y = (-b - math.sqrt(math.pow(b, 2) - 4 * a * c)) / (2 * a);

      final ang = math.acos((x.abs() + center.x.abs()) / radius);

      if (angMin <= ang && angMax >= ang) {
        vertices.add(Vector2(x.toDouble(), y));
      }
    }

    if (direction == CurveModelDirection.left) {
      vertices = vertices.reversed
          .map(
            (vert) =>
                (vert..rotate(math.pi)).translated(this.radius, this.radius),
          )
          .toList();
    }

    return vertices;
  }
}
