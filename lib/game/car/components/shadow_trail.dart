import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:z1racing/models/glabal_priorities.dart';
import 'package:z1racing/models/z1car_shadow.dart';
import 'package:z1racing/repositories/game_repository.dart';
import 'package:z1racing/repositories/game_repository_impl.dart';

class ShadowTrail extends Component with HasPaint {
  ShadowTrail({
    required this.carBody,
    required this.isFrontTire,
    required this.isLeftTire,
    required this.color,
    required this.trailPositions,
  }) : super(priority: GlobalPriorities.shadowCarTrailFloor);

  final Body carBody;
  final bool isFrontTire;
  final bool isLeftTire;
  final Color color;
  final List<Z1CarShadowTrailPosition> trailPositions;

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

  int lastIndex = 1;

  @override
  void update(double dt) {
    if (carBody.linearVelocity.length2 > 100) {
      if (trail.length > _trailLength) {
        trail.removeAt(0);
      }

      if (trailPositions.isEmpty) {
        final adjust = Vector2(0, 2)..rotate(carBody.angle);

        final vertexOffset = Vector2(jointAnchor.x, jointAnchor.y);
        vertexOffset.rotate(carBody.angle);

        final particlePosition = carBody.position + vertexOffset + adjust;

        trail.add(particlePosition.toOffset());
      } else {
        if (GameRepositoryImpl().status != GameStatus.start) {
          return;
        }

        final z1CarShadowPositionIndex = lastIndex + 1;
        if (z1CarShadowPositionIndex < trailPositions.length) {
          lastIndex = z1CarShadowPositionIndex;
          final post =
              trailPositions[z1CarShadowPositionIndex].position.toOffset();
          trail.add(post);
        }
      }
    } else if (trail.isNotEmpty) {
      trail.removeAt(0);
    }
  }

  @override
  void render(Canvas canvas) {
    canvas.drawPoints(PointMode.polygon, trail, paint);
  }
}
