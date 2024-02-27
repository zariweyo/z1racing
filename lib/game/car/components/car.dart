import 'dart:ui';

import 'package:flame/cache.dart';
import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame_forge2d/flame_forge2d.dart' hide Particle, World;
import 'package:z1racing/data/game_repository_impl.dart';
import 'package:z1racing/domain/entities/slot/slot_model.dart';
import 'package:z1racing/domain/entities/z1user.dart';
import 'package:z1racing/domain/repositories/game_repository.dart';
import 'package:z1racing/extensions/z1useravatar_extension.dart';
import 'package:z1racing/game/car/components/tire.dart';
import 'package:z1racing/game/car/components/trail.dart';
import 'package:z1racing/game/controls/models/jcontrols_data.dart';
import 'package:z1racing/game/track/components/lap_line.dart';
import 'package:z1racing/game/track/components/level_change_line.dart';
import 'package:z1racing/game/z1racing_game.dart';
import 'package:z1racing/models/collision_categorie.dart';
import 'package:z1racing/models/global_priorities.dart';
import 'package:z1racing/models/z1control.dart';

class Car extends BodyComponent<Z1RacingGame> with ContactCallbacks {
  Car({
    required this.images,
    required this.avatar,
    required this.startPosition,
    required this.startAngle,
    this.delay = -1,
    this.startLevel = SlotModelLevel.floor,
    this.cameraComponent,
    this.pressedKeys,
    this.controlsData,
  }) : super(
          priority: GlobalPriorities.carFloor,
          paint: Paint(),
        ) {
    currentLevel = startLevel;
  }

  final String fixCarRace = 'FIXCARRACE';

  final Z1UserAvatar avatar;
  final Images images;
  late final List<Tire> tires;

  final SlotModelLevel startLevel;

  final double delay;
  final Vector2 startPosition;
  final double startAngle;
  final Set<Z1Control>? pressedKeys;
  final ControlsData? controlsData;
  final Set<LapLine> passedStartControl = {};
  final CameraComponent? cameraComponent;
  late final Image _image;
  final size = const Size(7, 12);
  final scale = 10.0;
  late final _renderPosition = -size.toOffset() / 2;
  late final _renderRect = _renderPosition & size;

  late double _maxSpeed;
  late double _traction;
  late double _speed;

  bool initiated = false;

  double get traction => _traction;
  double get speed => _speed;
  late SlotModelLevel currentLevel;
  List<Trail> trails = [];

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // These params should be loaded from car model
    final image = await images.load(avatar.avatarCar);
    _traction = 0.90; // 0..1
    _maxSpeed = 120; // 0..120
    _speed = _maxSpeed;

    _image = image;

    await _addTires();
    await _addTrail();
  }

  void selectVia({required List<int> viasSelected}) {
    tires.forEach((tire) {
      tire.selectVia(viasSelected: viasSelected);
    });
  }

  @override
  Body createBody() {
    final def = BodyDef()
      ..type = BodyType.dynamic
      ..angle = startAngle
      ..position = startPosition;
    final body = world.createBody(def)
      ..userData = this
      ..angularDamping = 3.0;

    final shape = PolygonShape()
      ..setAsBoxXY(_renderPosition.dx, _renderPosition.dy);

    final fixtureDef = FixtureDef(shape, isSensor: true)
      ..density = 0.04
      ..userData = this;
    body.createFixture(fixtureDef);

    final shape2 = PolygonShape()..setAsBoxXY(3, 6);
    final fixtureDef2 = FixtureDef(shape2)
      ..density = 0
      ..userData = fixCarRace
      ..filter.groupIndex = 1
      ..filter.maskBits = CollisionCategorie.getCollisionFromCarFightLevel(
        startLevel,
      )
      ..filter.categoryBits = CollisionCategorie.getCollisionFromCarFightLevel(
        startLevel,
      );
    body.createFixture(fixtureDef2);

    return body;
  }

  double total = 0.0;

  @override
  void update(double dt) {
    if (!initiated) {
      total += dt;
      if (delay >= 0 && delay < total) {
        initiated = true;
      } else if (delay < 0 && GameRepositoryImpl().status == GameStatus.start) {
        initiated = true;
      }
    }
    super.update(dt);
  }

  Future<void> _addTrail() {
    TrailWheel.values.forEach((trailWheel) {
      final trail = Trail(
        carBody: body,
        color: avatar.avatarBackgroundColor,
        trailWheel: trailWheel,
      );
      trails.add(trail);
    });

    return game.cameraWorld.addAll(trails);
  }

  Future<void> _addTires() {
    final jointDef = RevoluteJointDef()
      ..bodyA = body
      ..enableLimit = true
      ..lowerAngle = 0
      ..upperAngle = 0
      ..localAnchorB.setZero();

    tires = List.generate(4, (i) {
      final isFrontTire = i <= 1;
      final isLeftTire = i.isEven;
      return Tire(
        car: this,
        pressedKeys: pressedKeys ?? {},
        controlsData: controlsData,
        isFrontTire: isFrontTire,
        isLeftTire: isLeftTire,
        jointDef: jointDef,
        startAngle: startAngle,
        startLevel: startLevel,
        isTurnableTire: isFrontTire,
        color: avatar.avatarBackgroundColor,
      );
    });

    return game.cameraWorld.addAll(tires);
  }

  //DebugFps debugFps = DebugFps(desiredFps: 30, secondsSteps: 2);

  @override
  void render(Canvas canvas) {
    canvas.drawImageRect(
      _image,
      _image.size.toRect(),
      _renderRect,
      paint,
    );
  }

  @override
  void onRemove() {
    for (final tire in tires) {
      tire.removeFromParent();
    }
  }

  void updatePriority(SlotModelLevel level) {
    if (currentLevel != level) {
      currentLevel = level;
      tires.forEach((tire) {
        tire.changeLevel(level);
      });

      final fixIndex =
          body.fixtures.indexWhere((element) => element.userData == fixCarRace);
      if (fixIndex >= 0) {
        body.fixtures[fixIndex].filterData.groupIndex =
            CollisionCategorie.getCollisionFromCarFightLevel(level);
        body.fixtures[fixIndex].filterData.maskBits =
            CollisionCategorie.getCollisionFromCarFightLevel(level);
        body.fixtures[fixIndex].filterData.categoryBits =
            CollisionCategorie.getCollisionFromCarFightLevel(level);
      }

      trails.forEach((trail) {
        trail.priority = level == SlotModelLevel.floor
            ? GlobalPriorities.carTrailFloor
            : GlobalPriorities.carTrailBridge;
      });

      if ([SlotModelLevel.bridge, SlotModelLevel.both].contains(level)) {
        priority = GlobalPriorities.carBridge;
      } else if (level == SlotModelLevel.floor) {
        priority = GlobalPriorities.carFloor;
      }
    }
  }

  @override
  void beginContact(Object other, Contact contact) {
    var level = currentLevel;
    if (other is LevelChangeLine) {
      level = other.level;
      updatePriority(level);
    }
    super.beginContact(other, contact);
  }
}
