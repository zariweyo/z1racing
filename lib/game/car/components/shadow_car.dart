import 'dart:ui';
import 'package:collection/collection.dart';
import 'package:flame/cache.dart';
import 'package:flame/extensions.dart';
import 'package:flame_forge2d/flame_forge2d.dart' hide Particle, World;
import 'package:z1racing/game/car/components/car.dart';
import 'package:z1racing/game/car/components/shadow_trail.dart';
import 'package:z1racing/game/track/components/lap_line.dart';
import 'package:z1racing/game/z1racing_game.dart';
import 'package:z1racing/models/z1car_shadow.dart';
import 'package:z1racing/repositories/game_repository.dart';
import 'package:z1racing/repositories/game_repository_impl.dart';

class ShadowCar extends BodyComponent<Z1RacingGame> with ContactCallbacks {
  ShadowCar({
    required this.images,
  }) : super(
          priority: 3,
          paint: Paint(),
        );

  final Images images;

  final Set<LapLine> passedStartControl = {};
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

  List<Z1CarShadowPosition> positions = [];
  List<ShadowTrail> shadowTrails = [];

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    positions = GameRepositoryImpl()
            .z1carShadowRef
            ?.positions
            .sorted((a, b) => a.time.inMilliseconds - b.time.inMilliseconds) ??
        [];

    if (positions.isEmpty) {
      game.cameraWorld.remove(this);
      return;
    }

    shadowTrails
        .add(ShadowTrail(tireBody: body, isFrontTire: false, isLeftTire: true));
    shadowTrails.add(
      ShadowTrail(tireBody: body, isFrontTire: false, isLeftTire: false),
    );
    game.cameraWorld.addAll(shadowTrails);

    // These params should be loaded from car model
    final image = await images.load('yellow_car.png')
      ..darken(0.7);
    _traction = 0.9;
    _maxSpeed = 250;
    _speed = _maxSpeed;

    _image = image;
  }

  @override
  Body createBody() {
    final def = BodyDef()..type = BodyType.dynamic;
    final body = world.createBody(def)..angularDamping = 3.0;

    final shape = PolygonShape()
      ..setAsBoxXY(_renderPosition.dx, _renderPosition.dy);
    final fixtureDef = FixtureDef(shape, isSensor: true)
      ..density = 0.04
      ..restitution = 0.9;
    body.createFixture(fixtureDef);

    return body;
  }

  double total = 0;
  int lastIndex = 0;

  @override
  void update(double dt) {
    if (GameRepositoryImpl().status != GameStatus.start) {
      return;
    }

    total += dt * 1000;
    final z1CarShadowPositionIndex = lastIndex + 1;
    if (z1CarShadowPositionIndex < positions.length) {
      final z1CarShadowPosition = positions[z1CarShadowPositionIndex];
      lastIndex = z1CarShadowPositionIndex;

      body.setTransform(
        z1CarShadowPosition.position,
        z1CarShadowPosition.angle,
      );

      body.applyLinearImpulse(z1CarShadowPosition.position);
    } else if (z1CarShadowPositionIndex < 0 &&
        lastIndex >= positions.length - 2) {
      game.cameraWorld.remove(this);
    }
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
  void beginContact(Object other, Contact contact) {
    if (other is! Car) {
      return;
    }
    _speed = 50;
  }

  @override
  void endContact(Object other, Contact contact) {
    if (other is! Car) {
      return;
    }
    _speed = _maxSpeed;
  }
}
