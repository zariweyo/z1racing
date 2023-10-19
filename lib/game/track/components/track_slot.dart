import 'dart:ui';
import 'package:collection/collection.dart';
import 'package:flame/extensions.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:z1racing/game/track/models/track_model.dart';
import 'package:z1racing/game/z1racing_game.dart';

class TrackSlot extends BodyComponent<Z1RacingGame> {
  TrackSlot(
      {required this.trackModel,
      required this.position,
      required this.angle,
      this.backgroundColor = const Color.fromARGB(0, 0, 0, 0)}) {}

  final Color backgroundColor;
  final TrackModel trackModel;

  late final Image _image;

  final Vector2 position;

  final scale = 10.0;
  late final _scaledRect = (trackModel.size * scale).toRect();
  late final _renderRect = Offset(0, 0) & trackModel.size.toSize();

  final double angle;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    final recorder = PictureRecorder();
    final canvas = Canvas(recorder, _scaledRect);

    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 7.0;
    paint.color = ColorExtension.fromRGBHexString('#cccccc');
    paint.color = paint.color.darken(0.4);

    Path path = Path();

    trackModel.points1.forEachIndexed((index, element) {
      element = element * scale;
      if (index == 0) {
        path.moveTo(element.x, element.y);
      } else {
        path.lineTo(element.x, element.y);
      }
    });

    trackModel.points2.reversed.forEachIndexed((index, element) {
      element = element * scale;
      if (index == 0) {
        path.moveTo(element.x, element.y);
      } else {
        path.lineTo(element.x, element.y);
      }
    });

    canvas.drawPath(path, paint);

    path.reset();
    paint.color = ColorExtension.fromRGBHexString('#cccccc');
    paint.color = paint.color.darken(0.5);
    paint.style = PaintingStyle.fill;
    paint.strokeWidth = 7.0;

    trackModel.pointsAdded.reversed.forEachIndexed((index, element) {
      element = element * scale;
      if (index == 0) {
        path.moveTo(element.x, element.y);
      } else {
        path.lineTo(element.x, element.y);
      }
    });

    trackModel.pointsAddedPlus.forEachIndexed((index, element) {
      element = element * scale;
      path.lineTo(element.x, element.y);
    });

    canvas.drawPath(path, paint);

    canvas.drawColor(backgroundColor, BlendMode.color);

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
      ..angle = angle
      ..position = position;
    final body = world.createBody(def)
      ..userData = this
      ..angularDamping = 3.0;

    final shapeExternal = ChainShape()..createChain(trackModel.points1);
    final shapeInternal = ChainShape()
      ..createChain(trackModel.pointsAdded.isNotEmpty
          ? trackModel.pointsAdded
          : trackModel.points2);

    final fixtureDefExternal = FixtureDef(shapeExternal)..restitution = 0.5;
    final fixtureDefInternal = FixtureDef(shapeInternal)..restitution = 0.5;
    return body
      ..createFixture(fixtureDefInternal)
      ..createFixture(fixtureDefExternal);
  }

  @override
  void render(Canvas canvas) {
    canvas.drawImageNine(
      _image,
      _scaledRect,
      _renderRect,
      paint,
    );
  }
}
