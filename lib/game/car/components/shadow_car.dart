import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:flame/cache.dart';
import 'package:flame/extensions.dart';
import 'package:flame_forge2d/flame_forge2d.dart' hide Particle, World;
import 'package:z1racing/data/game_repository_impl.dart';
import 'package:z1racing/domain/entities/slot/slot_model.dart';
import 'package:z1racing/domain/entities/z1car_shadow.dart';
import 'package:z1racing/domain/entities/z1user.dart';
import 'package:z1racing/domain/repositories/game_repository.dart';
import 'package:z1racing/extensions/z1useravatar_extension.dart';
import 'package:z1racing/game/car/components/car.dart';
import 'package:z1racing/game/car/components/trail.dart';
import 'package:z1racing/game/track/components/lap_line.dart';
import 'package:z1racing/game/z1racing_game.dart';
import 'package:z1racing/models/global_priorities.dart';

class ShadowCar extends BodyComponent<Z1RacingGame> with ContactCallbacks {
  ShadowCar({
    required this.images,
    required this.avatar,
  }) : super(
          priority: GlobalPriorities.shadowCarFloor,
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
  SlotModelLevel currentLevel = SlotModelLevel.floor;

  bool initiated = false;

  List<Z1CarShadowPosition> positions = [];
  List<Trail> trails = [];

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    if (positions.isEmpty) {
      game.cameraWorld.remove(this);
      return;
    }

    // These params should be loaded from car model
    final image = await images.load(avatar.avatarCar);

    _image = await image.darken(0.3);

    TrailWheel.values.forEach((trailWheel) {
      final trail = Trail(
        carBody: body,
        color: avatar.avatarBackgroundColor,
        trailWheel: trailWheel,
      );
      trails.add(trail);
      game.cameraWorld.add(trail);
    });
  }

  @override
  Body createBody() {
    final def = BodyDef()..type = BodyType.dynamic;
    final body = world.createBody(def)..angularDamping = 3.0;

    positions = GameRepositoryImpl()
            .z1carShadowRef
            ?.positions
            .sorted((a, b) => a.time.inMilliseconds - b.time.inMilliseconds) ??
        [];

    return body;
  }

  int lastIndex = 0;
  Duration total = Duration.zero;

  @override
  void update(double dt) {
    super.update(dt);
    if (GameRepositoryImpl().status != GameStatus.start) {
      return;
    }

    total += Duration(milliseconds: (dt * 1000).toInt());

    final z1CarShadowPosition = positions.firstWhereIndexedOrNull(
      (index, element) =>
          index >= lastIndex &&
          element.time.inMilliseconds > total.inMilliseconds,
    );

    if (z1CarShadowPosition != null) {
      lastIndex++;

      body.linearVelocity =
          (z1CarShadowPosition.position - position.clone()) / 0.03;

      body.setTransform(
        z1CarShadowPosition.position,
        z1CarShadowPosition.angle,
      );

      updatePriority(z1CarShadowPosition.level);
    } else if (lastIndex >= positions.length) {
      game.cameraWorld.remove(this);
    }
  }

  void updatePriority(SlotModelLevel level) {
    if (currentLevel != level) {
      currentLevel = level;
      priority = level == SlotModelLevel.floor
          ? GlobalPriorities.shadowCarFloor
          : GlobalPriorities.shadowCarBridge;
      trails.forEach((trail) {
        trail.priority = level == SlotModelLevel.floor
            ? GlobalPriorities.shadowCarTrailFloor
            : GlobalPriorities.shadowCarTrailBridge;
      });
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
