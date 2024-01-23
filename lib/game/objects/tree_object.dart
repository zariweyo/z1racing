import 'package:z1racing/game/objects/sprite_object.dart';

class TreeObject extends SpriteObject {
  TreeObject({
    required super.position,
    required super.row,
    required super.column,
  }) : super(
          filename: 'trees_1.png',
          size: 50,
        );
}
