import 'dart:math' as Math;
import 'dart:ui';

import 'package:flame/extensions.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:z1racing/z1racing_game.dart';

class WallSlot extends BodyComponent<Z1RacingGame> {
  WallSlot(
      {required this.position,
      this.radians = Math.pi / 2,
      double radius = 60}) {
    this.size = Vector2(radius, radius);
  }

  late final Image _image;

  late Vector2 size;
  final Vector2 position;

  final scale = 10.0;
  late final _renderPosition = -size.toOffset() / 2;
  late final _scaledRect = (size * scale).toRect();
  late final _renderRect = _renderPosition & Vector2(size.x, size.y).toSize();

  final double radians;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    paint.color = ColorExtension.fromRGBHexString('#14F596');

    final recorder = PictureRecorder();
    final canvas = Canvas(recorder, _scaledRect);

    canvas.rotate(Math.pi / 4);

    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 5.0;

    canvas.drawArc(
      Rect.fromCircle(center: Offset(0, 0), radius: _scaledRect.width),
      0,
      radians,
      false,
      paint,
    );
    canvas.drawArc(
      Rect.fromCircle(center: Offset(0, 0), radius: _scaledRect.width - 50),
      0,
      radians,
      false,
      paint,
    );

    paint.color = paint.color.darken(0.5);

    //canvas.drawColor(Color.fromARGB(255, 46, 46, 74), BlendMode.color);

    final picture = recorder.endRecording();
    _image = await picture.toImage(
      _scaledRect.width.toInt(),
      _scaledRect.height.toInt(),
    );
  }

  @override
  Body createBody() {
    final def = BodyDef()
      ..type = BodyType.static
      ..position = position;
    final body = world.createBody(def)
      ..userData = this
      ..angularDamping = 3.0;

    final shapeInternal = _createShapeFromArc(radio: size.y);
    final shapeExternal = _createShapeFromArc(radio: size.y - 5);

    final fixtureDefInternal = FixtureDef(shapeInternal)..restitution = 0.5;
    final fixtureDefExternal = FixtureDef(shapeExternal)..restitution = 0.5;
    return body
      ..createFixture(fixtureDefInternal)
      ..createFixture(fixtureDefExternal);
  }

  @override
  void render(Canvas canvas) {
    canvas.drawImageRect(
      _image,
      _scaledRect,
      _renderRect,
      paint,
    );
  }

  _createShapeFromArc({required double radio}) {
    List<Vector2> vertices = [];

    for (double ang = 0; ang < radians; ang += (Math.pi / 100)) {
      double x = radio * Math.cos(ang) - (size.x / 2);
      double y = radio * Math.sin(ang) - (size.y / 2);
      vertices.add(Vector2(x, y));
    }

    return ChainShape()..createChain(vertices);
  }
}
