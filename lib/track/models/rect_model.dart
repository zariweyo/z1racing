import 'dart:math' as Math;
import 'package:vector_math/vector_math_64.dart';
import 'package:z1racing/track/models/track_model.dart';

class RectModel extends TrackModel {
  RectModel({
    required super.size,
  }) : super(type: TrackModelType.rect);

  factory RectModel.fromMap(Map<String, dynamic> map) {
    assert(map['size'] != null);
    assert(map['size']['x'] != null && map['size']['x'] is double);
    assert(map['size']['y'] != null && map['size']['y'] is double);

    return RectModel(size: Vector2(map['size']['x'], map['size']['y']));
  }

  @override
  double get inputAngle => -Math.pi / 2;

  @override
  double get outputAngle => -Math.pi / 2;

  @override
  List<Vector2> get masterPoints => points1;

  @override
  List<Vector2> get points1 => [Vector2.zero(), Vector2(size.x, 0)];

  @override
  List<Vector2> get points2 => [Vector2(0, 40), Vector2(size.x, 40)];

  @override
  List<Vector2> get pointsAdded => [];

  @override
  List<Vector2> get pointsAddedPlus => [];
}
