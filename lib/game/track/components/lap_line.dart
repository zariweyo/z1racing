import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/extensions.dart';
import 'package:flame/palette.dart';
import 'package:flame_forge2d/flame_forge2d.dart' hide Particle, World;
import 'package:flutter/material.dart' hide Image, Gradient;
import 'package:z1racing/data/game_repository_impl.dart';
import 'package:z1racing/domain/repositories/game_repository.dart';
import 'package:z1racing/game/car/components/ia_car.dart';
import 'package:z1racing/game/car/components/player_car.dart';
import 'package:z1racing/models/global_priorities.dart';

enum LapLineType { finish, control, start }

class LapLine extends BodyComponent with ContactCallbacks {
  LapLine({
    required this.id,
    required this.position,
    required this.size,
    required this.offsetPotition,
    required this.type,
    this.angle = 0,
  }) : super(priority: GlobalPriorities.slotFloor);

  final int id;
  final LapLineType type;
  @override
  final Vector2 position;
  final Vector2 offsetPotition;
  final Vector2 size;
  @override
  final double angle;
  late final Rect rect = size.toRect();
  Image? _finishOverlay;

  bool get isFinish => type == LapLineType.finish;
  bool get isStart => type == LapLineType.start;
  bool get isControl => type == LapLineType.control;

  @override
  Future<void> onLoad() async {
    super.onLoad();
    if (isFinish) {
      _finishOverlay = await createFinishOverlay();
    }
  }

  @override
  Body createBody() {
    paint.color = (isFinish
        ? const Color.fromARGB(255, 255, 255, 255)
        : const Color.fromARGB(128, 255, 255, 255));
    paint
      ..style = PaintingStyle.fill
      ..shader = Gradient.radial(
        (size / 2).toOffset(),
        math.max(size.x, size.y),
        [
          paint.color,
          Colors.black,
        ],
      );

    final groundBody = world.createBody(
      BodyDef(
        position: position.clone()..add(offsetPotition..rotate(angle)),
        angle: angle,
        userData: this,
      ),
    );

    final shape = PolygonShape()..setAsBoxXY(size.x / 2, size.y / 2);
    final fixtureDef = FixtureDef(shape, isSensor: true);
    return groundBody..createFixture(fixtureDef);
  }

  late final Rect _scaledRect = (size * 10).toRect();
  late final Rect _drawRect = size.toRect();

  Future<Image> createFinishOverlay() async {
    final recorder = PictureRecorder();
    final canvas = Canvas(recorder, _scaledRect);
    final step = _scaledRect.width / 2;
    final black = BasicPalette.black.paint();

    for (var i = 0; i * step < _scaledRect.height; i++) {
      canvas.drawRect(
        Rect.fromLTWH(i.isEven ? 0 : step, i * step, step, step),
        black,
      );
    }
    final picture = recorder.endRecording();
    return picture.toImage(
      _scaledRect.width.toInt(),
      _scaledRect.height.toInt(),
    );
  }

  @override
  void render(Canvas canvas) {
    canvas.translate(-size.x / 2, -size.y / 2);
    canvas.drawRect(rect, paint);
    if (_finishOverlay != null) {
      canvas.drawImageRect(_finishOverlay!, _scaledRect, _drawRect, paint);
    }
  }

  @override
  void beginContact(Object other, Contact contact) {
    if (other is PlayerCar) {
      if (isFinish && other.passedStartControl.length == 2) {
        GameRepositoryImpl().addLap();
        other.passedStartControl.clear();
      } else if (isControl) {
        other.passedStartControl
            .removeWhere((passedControl) => passedControl.id > id);
        other.passedStartControl.add(this);
      }
    } else if (other is IACar && isFinish) {
      if (GameRepositoryImpl().status != GameStatus.gameover) {
        GameRepositoryImpl().addPosition();
      }
    }
  }
}
