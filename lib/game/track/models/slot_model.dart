import 'package:flame/extensions.dart';
import 'package:z1racing/game/track/models/curve_model.dart';
import 'package:z1racing/game/track/models/rect_model.dart';

enum TrackModelType { rect, curve }

enum TrackModelSensor { none, finish, sensor }

abstract class SlotModel {
  final Vector2 size;
  final TrackModelType type;
  final TrackModelSensor sensor;
  List<Vector2> get points1;
  List<Vector2> get points2;
  List<Vector2> get inside;
  List<Vector2> get pointsAdded;
  List<Vector2> get pointsAddedPlus;
  List<Vector2> get masterPoints;
  double get inputAngle;
  double get outputAngle;

  SlotModel(
      {required this.size,
      required this.type,
      this.sensor = TrackModelSensor.none});

  factory SlotModel.fromMap(Map<String, dynamic> map) {
    assert(TrackModelType.values.map((e) => e.name).contains(map['type']));
    TrackModelType type = TrackModelType.values
        .firstWhere((element) => element.name == map['type']);
    switch (type) {
      case TrackModelType.curve:
        return CurveModel.fromMap(map);
      case TrackModelType.rect:
        return RectModel.fromMap(map);
    }
  }
}
