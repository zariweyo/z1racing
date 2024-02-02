import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';
import 'package:z1racing/repositories/firebase_firestore_repository.dart';
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
      FirebaseFirestoreRepository.instance.avatarColor.shade900.withAlpha(200),
      BlendMode.darken,
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
    final visibleWorld = GameRepositoryImpl().raceCamera?.visibleWorldRect ??
        camera.visibleWorldRect;
    final left = (visibleWorld.left ~/ 100) * 100.0 - 200;
    final right = (visibleWorld.right ~/ 100) * 100.0 + 200;
    final top = (visibleWorld.top ~/ 100) * 100.0 - 200;
    final bottom = (visibleWorld.bottom ~/ 100) * 100.0 + 200;
    for (var i = left; i <= right; i += 100.0) {
      for (var j = top; j < bottom; j += 100.0) {
        _sprite.renderRect(
          canvas,
          Rect.fromLTWH(i, j, 100, 100),
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
