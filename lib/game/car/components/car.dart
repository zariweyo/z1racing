import 'dart:ui';

import 'package:flame/cache.dart';
import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame_forge2d/flame_forge2d.dart' hide Particle, World;
import 'package:z1racing/game/game_colors.dart';
import 'package:z1racing/game/track/components/lap_line.dart';
import 'package:z1racing/game/z1racing_game.dart';
import 'package:z1racing/game/car/components/tire.dart';

class Car extends BodyComponent<Z1RacingGame> {
  Car(
      {required this.images,
      required this.playerNumber,
      required this.cameraComponent})
      : super(
          priority: 3,
          paint: Paint()..color = colors[playerNumber],
        );

  static final colors = [
    GameColors.green.color,
    GameColors.blue.color,
  ];

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

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    final image = await images.load('ford_mini.png');

    _image = image;
  }

  @override
  Body createBody() {
    final startPosition =
        Vector2(20, 30) + Vector2(15, 0) * playerNumber.toDouble();
    final def = BodyDef()
      ..type = BodyType.dynamic
      ..position = startPosition;
    final body = world.createBody(def)
      ..userData = this
      ..angularDamping = 3.0;

    final shape = PolygonShape()
      ..setAsBoxXY(_renderPosition.dx, _renderPosition.dy);
    final fixtureDef = FixtureDef(shape)
      ..density = 0.04
      ..restitution = 0.9;
    body.createFixture(fixtureDef);

    final jointDef = RevoluteJointDef()
      ..bodyA = body
      ..enableLimit = true
      ..lowerAngle = 0.0
      ..upperAngle = 0.0
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
}
