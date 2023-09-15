import 'dart:math' as Math;

import 'package:flame/extensions.dart';
import 'package:z1racing/track/wall_slot.dart';

class Slot {
  Slot({this.size = 40, required this.position}) {
    walls.add(WallSlot(position: position, radians: Math.pi / 4, radius: 30));
    walls.add(WallSlot(
        position: position.clone()..translate(15, 15),
        radius: 60,
        radians: Math.pi / 4));
  }

  final Vector2 position;
  final double size;

  List<WallSlot> walls = [];

  List<WallSlot> getBodys() {
    return walls;
  }
}
