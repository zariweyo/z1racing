import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/palette.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:z1racing/domain/entities/slot/slot_model.dart';
import 'package:z1racing/models/collision_categorie.dart';

class TrackDynamicVia extends BodyComponent {
  final List<Vector2> positions;

  TrackDynamicVia({
    required this.positions,
  }) : super(priority: 200);

  List<Vector2> get linePositions =>
      positions.length >= 2 ? [positions.first, positions.last] : [];

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 2.0;
    paint.color = BasicPalette.white.color;
  }

  /* @override
  void onRemove() {
    body.fixtures.forEach((fixture) {
      body.destroyFixture(fixture);
    });

    super.onRemove();
  } */

  @override
  Body createBody() {
    final def = BodyDef()..type = BodyType.static;
    final body = world.createBody(def)
      ..userData = this
      ..angularDamping = 3.0;

    if (linePositions.isNotEmpty) {
      final shapeLine = ChainShape()..createChain(linePositions);
      final fixtureDefLine = FixtureDef(shapeLine)
        ..userData = this
        ..filter.maskBits =
            CollisionCategorie.getTrackCollisionFromSlotModelLevel(
          SlotModelLevel.floor,
        );
      final fixtureDefLineSensor = FixtureDef(shapeLine)
        ..userData = this
        ..isSensor = true;
      body
        ..createFixture(fixtureDefLine)
        ..createFixture(fixtureDefLineSensor);
    }

    return body;
  }

  @override
  void render(Canvas canvas) {
    if (linePositions.isNotEmpty) {
      canvas.drawLine(
        linePositions.first.toOffset(),
        linePositions.last.toOffset(),
        paint,
      );
    }
  }
}
