import 'package:vector_math/vector_math_64.dart';
import 'package:z1racing/game/objects/sprite_object.dart';

class Tree1Object extends SpriteObject {
  Tree1Object({
    required super.position,
    required super.row,
    required super.column,
  }) : super(
          filename: 'trees_1.png',
          sizeDimmension: Vector2(250, 250),
          sizeToPrint: Vector2(30, 30),
        );
}

class Tree2Object extends SpriteObject {
  Tree2Object({
    required super.position,
    required super.row,
    required super.column,
  }) : super(
          filename: 'trees_2.png',
          sizeDimmension: Vector2(150, 190),
          sizeToPrint: Vector2(10, 20),
        );
}
