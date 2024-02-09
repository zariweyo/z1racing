import 'package:flame/extensions.dart';
import 'package:z1racing/models/slot/curve_model.dart';
import 'package:z1racing/models/slot/rect_model.dart';

enum TrackModelType { rect, curve }

enum TrackModelSensor { none, finish, sensor }

enum SlotModelClosedAdded { none, start, end, both }

enum SlotModelLevel { floor, bridge, both }

abstract class SlotModel {
  final Vector2 size;
  final SlotModelLevel level;
  final TrackModelType type;
  final TrackModelSensor sensor;
  final SlotModelClosedAdded closedAdded;
  List<Vector2> get points1;
  List<Vector2> get points2;
  List<Vector2> get inside;
  List<Vector2> get pointsAdded;
  List<Vector2> get pointsAddedPlus;
  List<Vector2> get masterPoints;
  double get inputAngle;
  double get outputAngle;

  SlotModel({
    required this.size,
    required this.type,
    required this.closedAdded,
    this.level = SlotModelLevel.floor,
    this.sensor = TrackModelSensor.none,
  });

  factory SlotModel.fromMap(dynamic mapDyn) {
    final map = mapDyn as Map<String, dynamic>;
    assert(TrackModelType.values.map((e) => e.name).contains(map['type']));
    final type = TrackModelType.values
        .firstWhere((element) => element.name == map['type']);
    switch (type) {
      case TrackModelType.curve:
        return CurveModel.fromMap(map);
      case TrackModelType.rect:
        return RectModel.fromMap(map);
    }
  }
}
