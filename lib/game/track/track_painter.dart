import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:z1racing/data/game_repository_impl.dart';

class TrackPainter extends CustomPainter {
  final paintT = Paint()
    ..color = Colors.blue
    ..strokeWidth = 2
    ..style = PaintingStyle.stroke;

  final path = Path();

  TrackPainter() {
    final points = <Vector2>[];

    var angle = 0.0;
    var lastPoint = Vector2.zero();
    GameRepositoryImpl().currentTrack.slots.forEach((slot) {
      final adjust = lastPoint - slot.masterPoints.first;
      angle += slot.outputAngle - slot.inputAngle;

      points.addAll(
        slot.masterPoints.map(
          (e) => e.translated(adjust.x, adjust.y)
            ..rotate(angle, center: lastPoint),
        ),
      );

      lastPoint = points.last.clone();
    });

    path.addPolygon(points.map((e) => e.toOffset()).toList(), false);
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawPath(path, paintT);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
