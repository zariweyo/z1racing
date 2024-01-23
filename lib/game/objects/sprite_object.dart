import 'package:flame/components.dart';
import 'package:flame/flame.dart';

class SpriteObject extends SpriteComponent {
  SpriteObject({
    required String filename,
    required double size,
    required int row,
    required int column,
    required super.position,
  }) : super(
          sprite: Sprite(
            Flame.images.fromCache(filename),
            srcPosition: Vector2(size * row, size * column),
            srcSize: Vector2(size, size),
          ),
        );
}
