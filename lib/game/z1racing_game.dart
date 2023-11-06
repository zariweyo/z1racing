import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flame/camera.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/extensions.dart';
import 'package:flame/input.dart';
import 'package:flame_forge2d/flame_forge2d.dart' hide Particle, World;
import 'package:flutter/material.dart' hide Image, Gradient;
import 'package:flutter/services.dart';
import 'package:z1racing/game/car/components/car.dart';
import 'package:z1racing/game/controls/components/buttons_game.dart';
import 'package:z1racing/game/controls/models/jcontrols_data.dart';
import 'package:z1racing/game/panel/components/countdown_text.dart';
import 'package:z1racing/game/panel/components/lap_text.dart';
import 'package:z1racing/game/panel/components/sublap_list.dart';
import 'package:z1racing/repositories/game_repository.dart';
import 'package:z1racing/repositories/game_repository_impl.dart';
import 'package:z1racing/game/track/track.dart';

final List<Map<LogicalKeyboardKey, LogicalKeyboardKey>> playersKeys = [
  {
    LogicalKeyboardKey.arrowUp: LogicalKeyboardKey.arrowUp,
    LogicalKeyboardKey.arrowDown: LogicalKeyboardKey.arrowDown,
    LogicalKeyboardKey.arrowLeft: LogicalKeyboardKey.arrowLeft,
    LogicalKeyboardKey.arrowRight: LogicalKeyboardKey.arrowRight,
  },
  {
    LogicalKeyboardKey.keyW: LogicalKeyboardKey.arrowUp,
    LogicalKeyboardKey.keyS: LogicalKeyboardKey.arrowDown,
    LogicalKeyboardKey.keyA: LogicalKeyboardKey.arrowLeft,
    LogicalKeyboardKey.keyD: LogicalKeyboardKey.arrowRight,
  },
];

class Z1RacingGame extends Forge2DGame with KeyboardEvents {
  static const String description = '''
     This is an example game that uses Forge2D to handle the physics.
     In this game you should finish 3 laps in as little time as possible, it can
     be played as single player or with two players (on the same keyboard).
     Watch out for the balls, they make your car spin.
  ''';

  Z1RacingGame() : super(gravity: Vector2.zero(), zoom: 1);

  @override
  Color backgroundColor() => Colors.black;

  static final Vector2 trackSize = Vector2.all(500);
  static const double playZoom = 3.0;

  late final World cameraWorld;
  late CameraComponent startCamera;
  late List<Map<LogicalKeyboardKey, LogicalKeyboardKey>> activeKeyMaps;
  late List<Set<LogicalKeyboardKey>> pressedKeySets;
  ButtonsGame? joystick;
  List<ControlsData> controlsDatas = [];
  final cars = <Car>[];
  bool isGameOver = true;
  Car? winner;
  late CountdownText countdownText;
  GameRepository _gameRepository = GameRepositoryImpl();

  @override
  Future<void> onLoad() async {
    _gameRepository.reset();
    children.register<CameraComponent>();
    cameraWorld = World();
    add(cameraWorld);

    cameraWorld.addAll(Track(
            position: Vector2(200, 200),
            size: 30,
            z1track: GameRepositoryImpl().currentTrack)
        .getComponents());

    countdownText = CountdownText();

    openMenu();
  }

  void openMenu() {
    overlays.add('menu');
    overlays.add('timeList');
    overlays.remove('game_control');
    final zoomLevel = min(
      canvasSize.x / trackSize.x,
      canvasSize.y / trackSize.y,
    );
    startCamera = CameraComponent(
      world: cameraWorld,
    )
      ..viewfinder.position = trackSize / 2
      ..viewfinder.anchor = Anchor.center
      ..viewfinder.zoom = zoomLevel - 0.2;
    add(startCamera);
  }

  void prepareStart({required int numberOfPlayers}) {
    startCamera.viewfinder
      ..add(
        ScaleEffect.to(
          Vector2.all(playZoom),
          EffectController(duration: 1.0),
          onComplete: () => start(numberOfPlayers: numberOfPlayers),
        ),
      )
      ..add(
        MoveEffect.to(
          Vector2.all(20),
          EffectController(duration: 1.0),
        ),
      );
  }

  Future<void> initJoystick() async {
    joystick = await ButtonsGame.create(game: this, images: images);
    joystick?.stream.listen(onJoystickChange);
  }

  void start({required int numberOfPlayers}) {
    isGameOver = false;
    overlays.remove('menu');
    overlays.remove('timeList');
    overlays.add('game_control');
    startCamera.removeFromParent();
    final isHorizontal = canvasSize.x > canvasSize.y;
    Vector2 alignedVector({
      required double longMultiplier,
      double shortMultiplier = 1.0,
    }) {
      return Vector2(
        isHorizontal
            ? canvasSize.x * longMultiplier
            : canvasSize.x * shortMultiplier,
        !isHorizontal
            ? canvasSize.y * longMultiplier
            : canvasSize.y * shortMultiplier,
      );
    }

    final viewportSize = alignedVector(longMultiplier: 1 / numberOfPlayers);
    final cameras = List.generate(numberOfPlayers, (i) {
      return CameraComponent(
        world: cameraWorld,
        viewport: FixedSizeViewport(viewportSize.x, viewportSize.y)
          ..position = alignedVector(
            longMultiplier: i == 0 ? 0.0 : 1 / (i + 1),
            shortMultiplier: 0.0,
          ),
      )
        ..priority = -1
        ..viewfinder.anchor = Anchor.center
        ..viewfinder.zoom = playZoom;
    });

    // Disabled for performance issues in some devices
    /* final mapCameraSize = Vector2.all(500);
    const mapCameraZoom = 0.3;
    final mapCameras = List.generate(numberOfPlayers, (i) {
      return CameraComponent(
        world: cameraWorld,
        viewport: FixedSizeViewport(mapCameraSize.x, mapCameraSize.y)
          ..position = Vector2(
            viewportSize.x - mapCameraSize.x * mapCameraZoom - 10,
            10,
          ),
      )
        ..viewfinder.anchor = Anchor.topLeft
        ..viewfinder.zoom = mapCameraZoom;
    }); */

    addAll(cameras);

    for (var i = 0; i < numberOfPlayers; i++) {
      final car =
          Car(images: images, playerNumber: i, cameraComponent: cameras[i]);
      final lapText = LapText(
        car: car,
      );

      final sublapText = SubLapList(car: car);

      _gameRepository.getLapNotifier().addListener(() {
        if (_gameRepository.raceIsEnd()) {
          isGameOver = true;
          winner = car;
          overlays.add('game_over');
        }
      });

      initJoystick().then((_) {
        add(joystick!);
      });

      cars.add(car);
      cameraWorld.add(car);
      cameras[i].viewport.addAll([
        lapText,
        sublapText,
        /*mapCameras[i] disabled by performance issue*/
      ]);

      add(countdownText);
      countdownText.onFinish.addListener(() {
        if (countdownText.onFinish.value) {
          remove(countdownText);
        }
      });
    }

    pressedKeySets = List.generate(numberOfPlayers, (_) => {});
    activeKeyMaps = List.generate(numberOfPlayers, (i) => playersKeys[i]);
    controlsDatas = List.generate(numberOfPlayers, (_) => ControlsData.zero());
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (isGameOver) {
      return;
    }
    if (countdownText.onFinish.value) {
      _gameRepository.addTime(dt);
    }
  }

  void onJoystickChange(ControlsData event) {
    controlsDatas[0].updateBy(event);
  }

  @override
  KeyEventResult onKeyEvent(
    RawKeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    super.onKeyEvent(event, keysPressed);
    if (!isLoaded || isGameOver) {
      return KeyEventResult.ignored;
    }

    pressKey(keysPressed);
    return KeyEventResult.handled;
  }

  void pressKey(Set<LogicalKeyboardKey> keysPressed) {
    _clearPressedKeys();
    for (final key in keysPressed) {
      activeKeyMaps.forEachIndexed((i, keyMap) {
        if (keyMap.containsKey(key)) {
          pressedKeySets[i].add(keyMap[key]!);
        }
      });
    }
  }

  void _clearPressedKeys() {
    for (final pressedKeySet in pressedKeySets) {
      pressedKeySet.clear();
    }
  }
}
