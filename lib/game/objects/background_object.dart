import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';
import 'package:z1racing/data/game_repository_impl.dart';
import 'package:z1racing/domain/repositories/firebase_firestore_repository.dart';
import 'package:z1racing/domain/repositories/game_repository.dart';

class BackgroundObject extends BodyComponent<Forge2DGame> {
  late final Sprite _sprite;
  final Vector2 gameSize;

  BackgroundObject({required this.gameSize});

  @override
  Future<void> onLoad() async {
    super.onLoad();
    _sprite = await Sprite.load('background.png');
    paint.colorFilter = ColorFilter.mode(
      FirebaseFirestoreRepository.instance.avatarColor.withAlpha(50),
      BlendMode.modulate,
    );

    for (var i = 0; i < 5; i++) {
      add(
        TreeBackground(
          initialPosition: Vector2(
            Random().nextDouble() * 300,
            -Random().nextDouble() * 300,
          ),
        ),
      );
    }
  }

  @override
  Body createBody() {
    final def = BodyDef()..type = BodyType.static;
    final body = world.createBody(def);

    return body;
  }

  @override
  void render(Canvas canvas) {
    var visibleWorld = Rect.zero;
    if (GameRepositoryImpl().status == GameStatus.start) {
      visibleWorld = GameRepositoryImpl().currentTrack.rect;
    } else {
      visibleWorld = camera.visibleWorldRect.translate(
        GameRepositoryImpl().startPosition.x,
        GameRepositoryImpl().startPosition.y,
      );
    }

    const extendedSize = 700.0;
    const sideSize = 50.0;

    final left = (visibleWorld.left ~/ sideSize) * sideSize - extendedSize;
    final right = (visibleWorld.right ~/ sideSize) * sideSize + extendedSize;
    final top = (visibleWorld.top ~/ sideSize) * sideSize - extendedSize;
    final bottom = (visibleWorld.bottom ~/ sideSize) * sideSize + extendedSize;
    for (var i = left; i <= right; i += sideSize) {
      for (var j = top; j < bottom; j += sideSize) {
        _sprite.renderRect(
          canvas,
          Rect.fromLTWH(i, j, sideSize, sideSize),
          overridePaint: paint,
        );
      }
    }
  }

  Vector2 last = Vector2.zero();
  double num = 0;

  @override
  void update(double dt) {
    final pos =
        (GameRepositoryImpl().raceCamera?.viewfinder.position ?? last) - last;
    last = GameRepositoryImpl().raceCamera?.viewfinder.position ?? last;
    position.add(pos * 0.2);
  }
}

class TreeBackground extends PositionComponent {
  Vector2 initialPosition;
  double radius = 20;
  final Paint paint;
  bool grown = true;

  TreeBackground({required this.initialPosition})
      : paint = Paint()
          ..color =
              FirebaseFirestoreRepository.instance.avatarColor.darken(0.7),
        super(
          position: initialPosition,
          size: Vector2.all(20),
        );

  @override
  Future<void> onLoad() async {
    super.onLoad();
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    for (var i = 0; i < 5; i++) {
      paint.color = FirebaseFirestoreRepository.instance.avatarColor
          .darken(0.70 + i * 0.05);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset.zero,
            width: 50 - i * 5,
            height: 50 - i * 5,
          ),
          const Radius.circular(10),
        ),
        paint,
      );
    }
  }
}
