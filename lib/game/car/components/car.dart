import 'dart:ui';
import 'package:flame/cache.dart';
import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame_forge2d/flame_forge2d.dart' hide Particle, World;
import 'package:z1racing/game/car/components/tire.dart';
import 'package:z1racing/game/track/components/lap_line.dart';
import 'package:z1racing/game/track/components/track_slot.dart';
import 'package:z1racing/game/z1racing_game.dart';
import 'package:z1racing/repositories/game_repository_impl.dart';

class Car extends BodyComponent<Z1RacingGame> with ContactCallbacks {
  Car({
    required this.images,
    required this.playerNumber,
    required this.cameraComponent,
  }) : super(
          priority: 3,
          paint: Paint(),
        );

  final Images images;
  late final List<Tire> tires;

  final int playerNumber;
  final Set<LapLine> passedStartControl = {};
  final CameraComponent cameraComponent;
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

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // These params should be loaded from car model
    final image = await images.load('pink_car.png');
    _traction = 0.9;
    _maxSpeed = 250;
    _speed = _maxSpeed;

    _image = image;
  }

  @override
  Body createBody() {
    final startPosition = GameRepositoryImpl().startPosition;
    final startAngle = GameRepositoryImpl().currentTrack.carInitAngle;
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
      ..restitution = 0.9
      ..userData = this;
    body.createFixture(fixtureDef);

    final jointDef = RevoluteJointDef()
      ..bodyA = body
      ..enableLimit = true
      ..lowerAngle = startAngle
      ..upperAngle = startAngle
      ..localAnchorB.setZero();

    tires = List.generate(4, (i) {
      final isFrontTire = i <= 1;
      final isLeftTire = i.isEven;
      return Tire(
        car: this,
        pressedKeys: game.pressedKeySets[playerNumber],
        controlsData: game.controlsDatas[playerNumber],
        isFrontTire: isFrontTire,
        isLeftTire: isLeftTire,
        jointDef: jointDef,
        isTurnableTire: isFrontTire,
      );
    });

    game.cameraWorld.addAll(tires);
    return body;
  }

  @override
  void update(double dt) {
    cameraComponent.viewfinder.position = body.position;
  }

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

  @override
  void beginContact(Object other, Contact contact) {
    if (other is! TrackSlot) {
      return;
    }
    _speed = 50;
  }

  @override
  void endContact(Object other, Contact contact) {
    if (other is! TrackSlot) {
      return;
    }
    _speed = _maxSpeed;
  }
}
