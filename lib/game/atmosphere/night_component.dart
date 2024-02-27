import 'dart:math';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:z1racing/game/car/components/car.dart';
import 'package:z1racing/game/car/components/shadow_car.dart';

class NightComponent extends PositionComponent {
  final double holeRadius;
  final Vector2 holePosition;
  final CameraComponent camera;
  final List<Car> cars;
  final ShadowCar shadowCar;
  final double dark;

  NightComponent({
    required this.holeRadius,
    required this.holePosition,
    required this.camera,
    required this.cars,
    required this.shadowCar,
    required this.dark,
    Vector2? size,
    Vector2? position,
  }) : super(
          priority: 0,
          size: size ?? Vector2.zero(),
          position: position ?? Vector2.zero(),
        );

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    canvas.saveLayer(Rect.largest, Paint());
    canvas.drawRect(
      camera.viewport.size.toRect(),
      Paint()..color = Colors.black.withOpacity(dark),
    );

    cars.forEach(
      (car) => _drawFrontLight(
        canvas: canvas,
        position: car.position,
        angle: car.angle,
      ),
    );
    /* _drawFrontLight(
      canvas: canvas,
      position: shadowCar.position,
      angle: shadowCar.angle,
    ); */

    canvas.restore();
  }

  void _drawFrontLight({
    required Canvas canvas,
    required Vector2 position,
    required double angle,
  }) {
    const arcRadius = 5.0;
    const pharoMinDiff = 3.0;
    const pharoMaxDiff = 30.0;
    const pharoDist = 50.0;
    final paint = Paint()
      ..blendMode = BlendMode.clear
      ..style = PaintingStyle.fill;
    final vector1 = camera.localToGlobal(
      position.translated(-pharoMinDiff, -3)
        ..rotate(angle + pi, center: position),
    );
    final vector2 = camera.localToGlobal(
      position.translated(-pharoMaxDiff, -pharoDist)
        ..rotate(angle + pi, center: position),
    );
    final vector3 = camera.localToGlobal(
      position.translated(pharoMaxDiff, -pharoDist)
        ..rotate(angle + pi, center: position),
    );
    final vector4 = camera.localToGlobal(
      position.translated(pharoMinDiff, -3)
        ..rotate(angle + pi, center: position),
    );

    final path = Path();
    path.moveTo(vector1.x, vector1.y);
    path.lineTo(vector2.x, vector2.y);
    path.arcToPoint(
      Offset(vector3.x - arcRadius, vector3.y),
      radius: const Radius.circular(arcRadius),
    );
    path.lineTo(vector4.x, vector4.y);
    path.close();

    canvas.drawPath(path, paint);
  }
}
