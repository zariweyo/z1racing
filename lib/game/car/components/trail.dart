import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame_forge2d/flame_forge2d.dart';

enum TrailWheel { leftFront, leftBack, rightFront, rightBack }

class Trail extends Component with HasPaint {
  Trail({
    required this.carBody,
    required this.color,
    required this.trailWheel,
  }) : super(priority: 3);

  final Body carBody;
  final Color color;
  final TrailWheel trailWheel;

  final trail = <Offset>[];
  final _trailLength = 20;

  Vector2 get relativePosition => Vector2(
        [TrailWheel.leftBack, TrailWheel.leftFront].contains(trailWheel)
            ? 3.0
            : -3.0,
        [TrailWheel.leftFront, TrailWheel.rightFront].contains(trailWheel)
            ? 3.5
            : -4.25,
      );

  @override
  Future<void> onLoad() async {
    paint
      ..color = color.withAlpha(50)
      ..strokeWidth = 2.0;
  }

  @override
  void update(double dt) {
    if (carBody.linearVelocity.length2 > 100) {
      if (trail.length > _trailLength) {
        trail.removeAt(0);
      }
      final trailPoint = carBody.position
          .translated(relativePosition.x, relativePosition.y)
        ..rotate(carBody.angle, center: carBody.position);
      trail.add(trailPoint.toOffset());
    } else if (trail.isNotEmpty) {
      trail.removeAt(0);
    }
  }

  @override
  void render(Canvas canvas) {
    canvas.drawPoints(PointMode.polygon, trail, paint);
  }
}
