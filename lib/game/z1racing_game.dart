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
import 'package:flame_audio/flame_audio.dart';

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

  static const double playZoom = 3.0;

  late AudioPool pool;
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

    startBgmMusic();

    openMenu();
  }

  void startBgmMusic() async {
    try {
      if (!FlameAudio.bgm.isPlaying) {
        FlameAudio.bgm.initialize();
        FlameAudio.bgm.play('background_sound1.mp3');
      }
    } catch (ex) {
      //
    }
  }

  void openMenu() {
    FlameAudio.bgm.resume();
    Vector2 trackSize = GameRepositoryImpl().trackSize;
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
      ..viewfinder.position =
          Vector2(canvasSize.x / 3, canvasSize.y - trackSize.y / 2)
      ..viewfinder.anchor = Anchor.center
      ..viewfinder.zoom = zoomLevel;
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
          GameRepositoryImpl().startPosition,
          EffectController(duration: 1.0),
        ),
      );
  }

  Future<void> initJoystick() async {
    joystick = await ButtonsGame.create(game: this, images: images);
    joystick?.stream.listen(onJoystickChange);
  }

  void start({required int numberOfPlayers}) {
    FlameAudio.bgm.pause();
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
      final lapText = LapText();

      final sublapText = SubLapList();

      _gameRepository.getLapNotifier().addListener(() {
        if (_gameRepository.raceIsEnd()) {
          isGameOver = true;
          winner = car;
          overlays.add('game_over');
        }
      });

      cars.add(car);
      cameraWorld.add(car);
      cameras[i].viewport.addAll([
        lapText,
        sublapText,
        /*mapCameras[i] disabled by performance issue*/
      ]);
    }

    initJoystick().then((_) {
      add(joystick!);
    });

    add(countdownText);
    countdownText.onFinish.addListener(() {
      if (countdownText.onFinish.value) {
        remove(countdownText);
      }
    });

    add(FpsTextComponent(
        position: Vector2(size.x - 124, 20), scale: Vector2.all(0.8)));

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
