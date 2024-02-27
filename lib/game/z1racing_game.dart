import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flame/camera.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flame/extensions.dart';
import 'package:flame/input.dart';
import 'package:flame_forge2d/flame_forge2d.dart' hide Particle, World;
import 'package:flutter/material.dart' hide Image, Gradient;
import 'package:flutter/services.dart';
import 'package:z1racing/data/game_repository_impl.dart';
import 'package:z1racing/domain/entities/z1track.dart';
import 'package:z1racing/domain/entities/z1user.dart';
import 'package:z1racing/domain/repositories/firebase_firestore_repository.dart';
import 'package:z1racing/domain/repositories/game_repository.dart';
import 'package:z1racing/extensions/logicalKeyboardKey_extension.dart';
import 'package:z1racing/game/atmosphere/night_component.dart';
import 'package:z1racing/game/atmosphere/rain_component.dart';
import 'package:z1racing/game/car/components/car.dart';
import 'package:z1racing/game/car/components/ia_car.dart';
import 'package:z1racing/game/car/components/player_car.dart';
import 'package:z1racing/game/car/components/shadow_car.dart';
import 'package:z1racing/game/controls/components/buttons_game.dart';
import 'package:z1racing/game/controls/controllers/game_music.dart';
import 'package:z1racing/game/controls/models/jcontrols_data.dart';
import 'package:z1racing/game/objects/background_object.dart';
import 'package:z1racing/game/panel/components/countdown_text.dart';
import 'package:z1racing/game/panel/components/lap_text.dart';
import 'package:z1racing/game/panel/components/reference_time_text.dart';
import 'package:z1racing/game/track/track.dart';
import 'package:z1racing/models/z1control.dart';

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

class Z1RacingGame extends Forge2DGame
    with KeyboardEvents, MultiTouchDragDetector {
  Z1RacingGame() : super(gravity: Vector2.zero(), zoom: 1);

  @override
  Color backgroundColor() => Colors.black;

  static const double playZoom = 3.0;
  late final World cameraWorld;
  late CameraComponent startCamera;
  late CameraComponent raceCamera;
  late List<Map<LogicalKeyboardKey, LogicalKeyboardKey>> activeKeyMaps;
  Set<Z1Control> pressedKeySet = {};
  ButtonsGame? joystick;

  ControlsData controlsData = ControlsData.zero();
  final cars = <Car>[];
  bool isGameOver = true;
  Car? winner;
  late CountDownText countdownText;
  final GameRepository _gameRepository = GameRepositoryImpl();
  late GameMusic gameMusic;
  ReferenceTimeText? referenceTimeText;
  late Z1Track currentTrack;

  @override
  Future<void> onLoad() async {
    pressedKeySet = {};
    activeKeyMaps = List.generate(1, (i) => playersKeys[i]);

    currentTrack = GameRepositoryImpl().currentTrack;
    gameMusic = GameMusic();
    _gameRepository.reset();
    children.register<CameraComponent>();
    cameraWorld = World();
    add(cameraWorld);

    cameraWorld.add(BackgroundObject(gameSize: canvasSize));

    cameraWorld.addAll(
      Track(
        position: Vector2(200, 200),
        size: 30,
        z1track: currentTrack,
        floorColor: const Color.fromARGB(255, 43, 67, 70),
        floorBridgeColor: const Color.fromARGB(220, 43, 67, 70),
        borderColor: FirebaseFirestoreRepository.instance.avatarColor,
        borderBridgeColor:
            FirebaseFirestoreRepository.instance.avatarColor.withAlpha(128),
        ignoreObjects: false,
      ).getComponents,
    );

    countdownText = CountDownText();

    if (currentTrack.settings.rain > 0) {
      add(
        RainEffect(
          speed: currentTrack.settings.rain,
        ),
      );
    }

    prepareStart();
  }

  void prepareStart() {
    const zoomLevel = 1.0;
    startCamera = CameraComponent(
      world: cameraWorld,
    )
      ..viewfinder.position = GameRepositoryImpl().startPosition
      ..viewfinder.anchor = Anchor.center
      ..viewfinder.angle = pi
      ..viewfinder.zoom = zoomLevel;
    add(startCamera);

    startCamera.viewfinder
      ..add(
        ScaleEffect.to(
          Vector2.all(playZoom),
          EffectController(duration: 1.0),
          onComplete: start,
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

  void start() {
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

    final viewportSize = alignedVector(longMultiplier: 1);
    raceCamera = CameraComponent(
      world: cameraWorld,
      viewport: FixedSizeViewport(viewportSize.x, viewportSize.y)
        ..position = alignedVector(
          longMultiplier: 0.0,
          shortMultiplier: 0.0,
        ),
    )
      ..priority = -1
      ..viewfinder.angle = pi
      ..viewfinder.anchor = Anchor.center
      ..viewfinder.zoom = playZoom;

    GameRepositoryImpl().raceCamera = raceCamera;

    add(raceCamera);

    final shadowCar = ShadowCar(
      images: images,
      avatar: GameRepositoryImpl().z1UserRef?.z1UserAvatar ??
          Z1UserAvatar.values.first,
    );

    cameraWorld.add(shadowCar);

    final car = PlayerCar(
      images: images,
      controlsData: controlsData,
      pressedKeys: pressedKeySet,
      cameraComponent: raceCamera,
      startPosition: GameRepositoryImpl().startPosition.clone()
        ..translate(0, -20),
      avatar: FirebaseFirestoreRepository.instance.currentUser!.z1UserAvatar,
    );

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

    GameRepositoryImpl().currentTrack.iaCars.forEach((iaCarDef) {
      final iaCar = IACar(
        images: images,
        startPosition: GameRepositoryImpl().startPosition.clone(),
        startVia: iaCarDef.via,
        velocity: iaCarDef.speed,
        avatar: iaCarDef.avatar,
        delay: iaCarDef.delay,
      );
      cars.add(iaCar);
      cameraWorld.add(iaCar);
    });

    addAll([LapText()]);

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
        priority: 100,
      ),
    );

    if (currentTrack.settings.dark > 0) {
      add(
        NightComponent(
          holePosition: Vector2(100, 100),
          holeRadius: 50,
          camera: raceCamera,
          cars: cars,
          shadowCar: shadowCar,
          size: Vector2(400, 800),
          dark: currentTrack.settings.dark,
        ),
      );
    }
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
        cars.first.currentLevel,
      );
    }
  }

  void onJoystickChange(ControlsData event) {
    controlsData.updateBy(event);
  }

  @override
  KeyEventResult onKeyEvent(
    KeyEvent event,
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
          pressedKeySet.add(keyMap[key]!.toZ1Control());
        }
      });
    }
  }

  void _clearPressedKeys() {
    pressedKeySet.clear();
  }

  @override
  void onDispose() {
    gameMusic.stop();
    cars.forEach((car) {
      car.onRemove();
    });
    return;
  }

  List<Vector2> dragPoints = [];

  @override
  void onDragUpdate(int pointerId, DragUpdateInfo info) {
    dragPoints.add(raceCamera.globalToLocal(info.eventPosition.global));
    super.onDragUpdate(pointerId, info);
  }

  @override
  void onDragCancel(int pointerId) {
    GameRepositoryImpl().setTap = [];
    super.onDragCancel(pointerId);
  }

  @override
  void onDragStart(int pointerId, DragStartInfo info) {
    dragPoints.clear();
    super.onDragStart(pointerId, info);
  }

  @override
  void onDragEnd(int pointerId, DragEndInfo info) {
    GameRepositoryImpl().setTap = dragPoints;
    super.onDragEnd(pointerId, info);
  }
}
