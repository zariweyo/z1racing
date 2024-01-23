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
import 'package:z1racing/game/car/components/shadow_car.dart';
import 'package:z1racing/game/controls/components/buttons_game.dart';
import 'package:z1racing/game/controls/controllers/game_music.dart';
import 'package:z1racing/game/controls/models/jcontrols_data.dart';
import 'package:z1racing/game/panel/components/countdown_text.dart';
import 'package:z1racing/game/panel/components/lap_text.dart';
import 'package:z1racing/game/panel/components/reference_time_text.dart';
import 'package:z1racing/game/panel/components/sublap_list.dart';
import 'package:z1racing/game/track/track.dart';
import 'package:z1racing/repositories/game_repository.dart';
import 'package:z1racing/repositories/game_repository_impl.dart';

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
  Z1RacingGame() : super(gravity: Vector2.zero(), zoom: 1);

  @override
  Color backgroundColor() => Colors.black;

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
  late CountDownText countdownText;
  final GameRepository _gameRepository = GameRepositoryImpl();
  late GameMusic gameMusic;
  ReferenceTimeText? referenceTimeText;

  @override
  Future<void> onLoad() async {
    gameMusic = GameMusic();
    _gameRepository.reset();
    children.register<CameraComponent>();
    cameraWorld = World();
    add(cameraWorld);

    cameraWorld.addAll(
      Track(
        position: Vector2(200, 200),
        size: 30,
        z1track: GameRepositoryImpl().currentTrack,
        floorColor: const Color.fromARGB(255, 43, 67, 70),
        ignoreObjects: false,
      ).getComponents(),
    );

    countdownText = CountDownText();

    prepareStart(numberOfPlayers: 1);
  }

  void prepareStart({required int numberOfPlayers}) {
    final currentTrack = GameRepositoryImpl().currentTrack;
    final zoomLevel = min(
      currentTrack.width / canvasSize.x,
      currentTrack.height / canvasSize.y,
    );
    startCamera = CameraComponent(
      world: cameraWorld,
    )
      ..viewfinder.position =
          Vector2(canvasSize.x / 3, canvasSize.y - currentTrack.height / 2)
      ..viewfinder.anchor = Anchor.center
      ..viewfinder.zoom = zoomLevel;
    add(startCamera);

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
    gameMusic.start();
  }

  Future<void> initJoystick() async {
    joystick = await ButtonsGame.create(game: this, images: images);
    joystick?.stream.listen(onJoystickChange);
  }

  void start({required int numberOfPlayers}) {
    isGameOver = false;
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

    addAll(cameras);

    final shadowCar = ShadowCar(images: images);

    cameraWorld.add(shadowCar);

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
        } else {
          Future.delayed(const Duration(milliseconds: 100), addReferenceTime);
        }
      });

      cars.add(car);
      cameraWorld.add(car);
      cameras[i].viewport.addAll([lapText, sublapText]);
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

    add(
      FpsTextComponent(
        position: Vector2(size.x - 124, 20),
        scale: Vector2.all(0.8),
      ),
    );

    pressedKeySets = List.generate(numberOfPlayers, (_) => {});
    activeKeyMaps = List.generate(numberOfPlayers, (i) => playersKeys[i]);
    controlsDatas = List.generate(numberOfPlayers, (_) => ControlsData.zero());
  }

  void addReferenceTime() {
    final lap = _gameRepository.getLapNotifier().value - 1;
    final durationLapDiff = _gameRepository.getReferenceDelayLap(lap: lap);
    referenceTimeText = ReferenceTimeText(duration: durationLapDiff);
    add(referenceTimeText!);
    Future.delayed(const Duration(seconds: 3), () {
      if (referenceTimeText != null) {
        remove(referenceTimeText!);
      }
    });
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (isGameOver) {
      return;
    }
    if (countdownText.onFinish.value) {
      _gameRepository.addTime(dt);
      _gameRepository.addNewShadowPosition(
        cars.first.body.position,
        cars.first.body.angle,
      );
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

  @override
  void onDispose() {
    gameMusic.stop();
    cars.forEach((car) {
      car.onRemove();
    });
    return;
  }
}
