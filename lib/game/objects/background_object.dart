import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';
import 'package:z1racing/repositories/firebase_firestore_repository.dart';
import 'package:z1racing/repositories/game_repository.dart';
import 'package:z1racing/repositories/game_repository_impl.dart';

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
      visibleWorld = GameRepositoryImpl().raceCamera?.visibleWorldRect ??
          camera.visibleWorldRect;
    } else {
      visibleWorld = camera.visibleWorldRect.translate(
        GameRepositoryImpl().startPosition.x,
        GameRepositoryImpl().startPosition.y,
      );
    }

    const extendedSize = 200.0;
    const sideSize = 100.0;

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

  @override
  void update(double dt) {
    //
  }
}
