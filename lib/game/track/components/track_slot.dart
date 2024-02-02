import 'dart:ui';
import 'package:collection/collection.dart';
import 'package:flame/extensions.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:z1racing/models/slot/slot_model.dart';
import 'package:z1racing/repositories/firebase_firestore_repository.dart';

class TrackSlot extends BodyComponent<Forge2DGame> {
  TrackSlot({
    required this.slotModel,
    required this.position,
    required this.angle,
    this.backgroundColor = const Color.fromARGB(0, 0, 0, 0),
    this.floorColor = const Color.fromARGB(255, 74, 59, 74),
  });

  final Color backgroundColor;
  final SlotModel slotModel;
  final Color floorColor;

  late final Image _image;

  @override
  final Vector2 position;

  final scale = 10.0;
  late final _scaledRect = (slotModel.size * scale).toRect();
  late final _renderRect = Offset.zero & slotModel.size.toSize();

  @override
  final double angle;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    final recorder = PictureRecorder();
    final canvas = Canvas(recorder, _scaledRect);

    paint.style = PaintingStyle.fill;
    paint.strokeWidth = 7.0;

    final path = Path();

    paint.style = PaintingStyle.fill;
    paint.color = floorColor;
    paint.color = paint.color.darken(0.4);

    slotModel.inside.forEachIndexed((index, element) {
      element = element * scale;
      if (index == 0) {
        path.moveTo(element.x, element.y);
      } else {
        path.lineTo(element.x, element.y);
      }
    });

    canvas.drawPath(path, paint);

    path.reset();
    paint.style = PaintingStyle.fill;
    paint.color = FirebaseFirestoreRepository.instance.avatarColor;
    paint.color = paint.color.darken(0.4);

    slotModel.points1.forEachIndexed((index, element) {
      element = element * scale;
      if (index == 0) {
        path.moveTo(element.x, element.y);
      } else {
        path.lineTo(element.x, element.y);
      }

      if (index == slotModel.points1.length - 1) {
        path.lineTo(slotModel.points1.first.x, slotModel.points1.first.y);
      }
    });

    if (slotModel.pointsAdded.isEmpty) {
      slotModel.points2.reversed.forEachIndexed((index, element) {
        element = element * scale;
        if (index == 0) {
          path.moveTo(element.x, element.y);
        } else {
          path.lineTo(element.x, element.y);
        }

        if (index == slotModel.points2.length - 1) {
          path.lineTo(slotModel.points2.first.x, slotModel.points2.first.y);
        }
      });
    }
    canvas.drawPath(path, paint);

    path.reset();
    paint.color = ColorExtension.fromRGBHexString('#33cccc');
    paint.color = paint.color.darken(0.5);
    paint.style = PaintingStyle.fill;
    paint.strokeWidth = 20.0;

    Vector2? firstaddedPoint;

    slotModel.pointsAdded.reversed.forEachIndexed((index, element) {
      element = element * scale;
      if (index == 0) {
        path.moveTo(element.x, element.y);
        firstaddedPoint = Vector2(element.x, element.y);
      } else {
        path.lineTo(element.x, element.y);
      }
    });

    slotModel.pointsAddedPlus.forEachIndexed((index, element) {
      element = element * scale;
      path.lineTo(element.x, element.y);
    });

    if (firstaddedPoint != null) {
      path.lineTo(firstaddedPoint!.x, firstaddedPoint!.y);
    }

    canvas.drawPath(path, paint);

    paint.style = PaintingStyle.stroke;
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

    final shapeExternal = ChainShape()..createChain(slotModel.points1);
    final shapeInternal = ChainShape()
      ..createChain(
        slotModel.pointsAdded.isNotEmpty
            ? slotModel.pointsAdded
            : slotModel.points2,
      );

    final fixtureDefExternal = FixtureDef(shapeExternal)
      ..restitution = 0.5
      ..userData = this
      ..friction = 0.1;
    final fixtureDefInternal = FixtureDef(shapeInternal)
      ..restitution = 0.5
      ..userData = this
      ..friction = 0.1;

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
