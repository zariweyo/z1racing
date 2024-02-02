import 'dart:ui';
import 'package:collection/collection.dart';
import 'package:flame/cache.dart';
import 'package:flame/extensions.dart';
import 'package:flame_forge2d/flame_forge2d.dart' hide Particle, World;
import 'package:z1racing/extensions/z1useravatar_extension.dart';
import 'package:z1racing/game/car/components/car.dart';
import 'package:z1racing/game/car/components/shadow_trail.dart';
import 'package:z1racing/game/track/components/lap_line.dart';
import 'package:z1racing/game/z1racing_game.dart';
import 'package:z1racing/models/z1car_shadow.dart';
import 'package:z1racing/models/z1user.dart';
import 'package:z1racing/repositories/game_repository.dart';
import 'package:z1racing/repositories/game_repository_impl.dart';

class ShadowCar extends BodyComponent<Z1RacingGame> with ContactCallbacks {
  ShadowCar({
    required this.images,
    required this.avatar,
  }) : super(
          priority: 3,
          paint: Paint(),
        );

  final Z1UserAvatar avatar;
  final Images images;

  final Set<LapLine> passedStartControl = {};
  late final Image _image;
  final size = const Size(7, 12);
  final scale = 10.0;
  late final _renderPosition = -size.toOffset() / 2;
  late final _renderRect = _renderPosition & size;

  bool initiated = false;

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

    shadowTrails.add(
      ShadowTrail(
        tireBody: body,
        isFrontTire: false,
        isLeftTire: true,
        color: avatar.avatarBackgroundColor,
      ),
    );
    shadowTrails.add(
      ShadowTrail(
        tireBody: body,
        isFrontTire: false,
        isLeftTire: false,
        color: avatar.avatarBackgroundColor,
      ),
    );
    game.cameraWorld.addAll(shadowTrails);

    // These params should be loaded from car model
    final image = await images.load(avatar.avatarCar);

    _image = await image.darken(0.3);
  }

  @override
  Body createBody() {
    final def = BodyDef()..type = BodyType.dynamic;
    final body = world.createBody(def)..angularDamping = 3.0;

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
  }

  @override
  void endContact(Object other, Contact contact) {
    if (other is! Car) {
      return;
    }
  }
}
