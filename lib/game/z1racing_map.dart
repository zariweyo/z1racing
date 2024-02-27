import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flame_forge2d/flame_forge2d.dart' hide Particle, World;
import 'package:flutter/material.dart' hide Image, Gradient;
import 'package:z1racing/domain/entities/z1track.dart';
import 'package:z1racing/game/track/track.dart';

class Z1RacingMap extends StatefulWidget {
  final Z1Track z1track;
  final Offset size;
  const Z1RacingMap({
    required this.z1track,
    this.size = const Offset(300, 300),
    super.key,
  });

  @override
  State<Z1RacingMap> createState() => _Z1RacingMapState();
}

class _Z1RacingMapState extends State<Z1RacingMap> {
  late List<Component> trackComponents;
  late Track track;

  @override
  void initState() {
    track = Track(
      position: Vector2(0, 0),
      size: 30,
      z1track: widget.z1track,
      floorColor: Colors.white60,
      floorBridgeColor: Colors.white60.withAlpha(128),
      ignoreObjects: false,
      isMap: true,
    );
    trackComponents = track.getComponents.toList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (track.z1track.slots.isEmpty) {
      return Container();
    }

    return Container(
      height: widget.size.dx,
      width: widget.size.dy,
      padding: const EdgeInsets.all(5),
      margin: const EdgeInsets.all(5),
      child: GameWidget<_Z1RacingMap>(
        game: _Z1RacingMap(
          sizeDim: widget.size,
          dimmensions: track.dimmension,
          trackComponents: trackComponents,
        ),
      ),
    );
  }
}

class _Z1RacingMap extends Forge2DGame {
  final Rect dimmensions;
  final Offset sizeDim;
  final Iterable<Component> trackComponents;
  _Z1RacingMap({
    required this.dimmensions,
    required this.trackComponents,
    required this.sizeDim,
  });

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
      trackComponents,
    );

    prepareStart(numberOfPlayers: 1);
  }

  void prepareStart({required int numberOfPlayers}) {
    final zoomLevel = min(
      sizeDim.dx / dimmensions.width,
      sizeDim.dy / dimmensions.height,
    );
    startCamera = CameraComponent(
      world: cameraWorld,
    )
      ..viewfinder.position =
          Vector2(dimmensions.left - 50, dimmensions.bottom - 50)
      ..viewfinder.anchor = Anchor.topRight
      ..viewfinder.angle = pi
      ..viewfinder.zoom = zoomLevel;

    add(startCamera);
  }

  @override
  void onDispose() {
    return;
  }
}
