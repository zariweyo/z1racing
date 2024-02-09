import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame_forge2d/flame_forge2d.dart';

class Trail extends Component with HasPaint {
  Trail({required this.tireBody, required this.color}) : super(priority: 3);

  final Body tireBody;
  final Color color;

  final trail = <Offset>[];
  final _trailLength = 20;

  @override
  Future<void> onLoad() async {
    paint
      ..color = color.withAlpha(50)
      ..strokeWidth = 2.0;
  }

  @override
  void update(double dt) {
    if (tireBody.linearVelocity.length2 > 100) {
      if (trail.length > _trailLength) {
        trail.removeAt(0);
      }
      final trailPoint = tireBody.position.toOffset();
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
