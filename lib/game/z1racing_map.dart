import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flame_forge2d/flame_forge2d.dart' hide Particle, World;
import 'package:flutter/material.dart' hide Image, Gradient;
import 'package:z1racing/game/track/track.dart';
import 'package:z1racing/repositories/game_repository_impl.dart';

class Z1RacingMap extends StatelessWidget {
  const Z1RacingMap({super.key});

  @override
  Widget build(BuildContext context) {
    const dimmensions = Size(400, 400);

    return Container(
      height: 400,
      width: 400,
      padding: const EdgeInsets.all(5),
      margin: const EdgeInsets.all(5),
      child: GameWidget<_Z1RacingMap>(
        game: _Z1RacingMap(
          dimmensions: dimmensions,
        ),
      ),
    );
  }
}

class _Z1RacingMap extends Forge2DGame {
  final Size dimmensions;
  _Z1RacingMap({required this.dimmensions}) : super(zoom: 1);

  @override
  Color backgroundColor() => Colors.transparent;

  late final World cameraWorld;
  late CameraComponent startCamera;

  @override
  Future<void> onLoad() async {
    children.register<CameraComponent>();
    cameraWorld = World();
    add(cameraWorld);

    cameraWorld.addAll(
      Track(
        position: Vector2(0, 0),
        size: 30,
        z1track: GameRepositoryImpl().currentTrack,
      ).getComponents(),
    );

    prepareStart(numberOfPlayers: 1);
  }

  void prepareStart({required int numberOfPlayers}) {
    final currentTrack = GameRepositoryImpl().currentTrack;
    final zoomLevel = min(
      currentTrack.width / dimmensions.width,
      currentTrack.height / dimmensions.height,
    );
    startCamera = CameraComponent(
      world: cameraWorld,
    )
      ..viewfinder.position = Vector2(currentTrack.minX, currentTrack.minY)
      ..viewfinder.anchor = Anchor.center
      ..viewfinder.zoom = zoomLevel;
    add(startCamera);
  }

  @override
  void onDispose() {
    return;
  }
}
