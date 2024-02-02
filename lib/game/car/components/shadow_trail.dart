import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flame_forge2d/flame_forge2d.dart';

class ShadowTrail extends Component with HasPaint {
  ShadowTrail({
    required this.tireBody,
    required this.isFrontTire,
    required this.isLeftTire,
    required this.color,
  }) : super(priority: 1);

  final Body tireBody;
  final bool isFrontTire;
  final bool isLeftTire;
  final Color color;

  final trail = <Offset>[];
  final _trailLength = 20;

  Vector2 jointAnchor = Vector2.zero();

  @override
  Future<void> onLoad() async {
    paint
      ..color = color.withAlpha(50)
      ..strokeWidth = 2.0;
    jointAnchor = Vector2(
      isLeftTire ? -3.0 : 3.0,
      isFrontTire ? 3.5 : -4.25,
    );
  }

  @override
  void update(double dt) {
    if (tireBody.linearVelocity.length2 > 100) {
      if (trail.length > _trailLength) {
        trail.removeAt(0);
      }
      final trailPoint = tireBody.position;

      final rotatedOffset = jointAnchor.clone();
      rotatedOffset.rotate(tireBody.angle);
      trail.add((trailPoint + rotatedOffset).toOffset());
    } else if (trail.isNotEmpty) {
      trail.removeAt(0);
    }
  }

  @override
  void render(Canvas canvas) {
    canvas.drawPoints(PointMode.polygon, trail, paint);
  }
}
