import 'package:flame/components.dart';
import 'package:flame/flame.dart';

class SpriteObject extends SpriteComponent {
  SpriteObject({
    required String filename,
    required Vector2 sizeDimmension,
    required Vector2 sizeToPrint,
    required int row,
    required int column,
    required super.position,
  }) : super(
          sprite: Sprite(
            Flame.images.fromCache(filename),
            srcPosition:
                Vector2(sizeDimmension.x * column, sizeDimmension.y * row),
            srcSize: Vector2(sizeDimmension.x, sizeDimmension.y),
          ),
          size: sizeToPrint,
        );
}
