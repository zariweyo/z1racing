import 'dart:ui';

import 'package:flame/components.dart';

import 'package:z1racing/game/car/components/car.dart';
import 'package:z1racing/game/car/components/tire.dart';

class Trail extends Component with HasPaint {
  Trail({
    required this.car,
    required this.tire,
  }) : super(priority: 1);

  final Car car;
  final Tire tire;

  final trail = <Offset>[];
  final _trailLength = 10;

  @override
  Future<void> onLoad() async {
    paint
      ..color = (Color.fromARGB(40, 144, 121, 121))
      ..strokeWidth = 2.0;
  }

  @override
  void update(double dt) {
    if (tire.body.linearVelocity.length2 > 100) {
      if (trail.length > _trailLength) {
        trail.removeAt(0);
      }
      final trailPoint = tire.body.position.toOffset();
      trail.add(trailPoint);
    } else if (trail.isNotEmpty) {
      trail.removeAt(0);
    }
  }

  @override
  void render(Canvas canvas) {
    canvas.drawPoints(PointMode.polygon, trail, paint);
  }
}
