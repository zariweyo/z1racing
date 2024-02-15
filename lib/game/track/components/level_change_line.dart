import 'package:flame/extensions.dart';
import 'package:flame_forge2d/flame_forge2d.dart' hide Particle, World;
import 'package:flutter/material.dart' hide Image, Gradient;
import 'package:z1racing/models/glabal_priorities.dart';
import 'package:z1racing/models/slot/slot_model.dart';

class LevelChangeLine extends BodyComponent {
  LevelChangeLine({
    required this.id,
    required this.position,
    required this.size,
    required this.offsetPotition,
    required this.level,
    this.angle = 0,
  }) : super(priority: GlobalPriorities.slotBridge);

  final int id;
  @override
  final Vector2 position;
  final Vector2 offsetPotition;
  final Vector2 size;
  final SlotModelLevel level;
  @override
  final double angle;
  late final Rect rect = size.toRect();

  @override
  Body createBody() {
    // Enable only for testing
    paint.color = Colors.transparent;

    final groundBody = world.createBody(
      BodyDef(
        position: position.clone()..add(offsetPotition..rotate(angle)),
        angle: angle,
        userData: this,
      ),
    );

    final shape = PolygonShape()..setAsBoxXY(size.x / 2, size.y / 2);
    final fixtureDef = FixtureDef(shape, isSensor: true);
    return groundBody..createFixture(fixtureDef);
  }

  @override
  void render(Canvas canvas) {
    canvas.translate(-size.x / 2, -size.y / 2);
    canvas.drawRect(rect, paint);
  }
}
