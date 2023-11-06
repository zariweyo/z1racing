import 'package:flame/palette.dart';
import 'package:flame_forge2d/flame_forge2d.dart' hide Particle, World;
import 'package:flutter/material.dart' hide Image, Gradient;
import 'package:flutter/services.dart';
import 'package:z1racing/game/car/components/car.dart';
import 'package:z1racing/game/controls/models/jcontrols_data.dart';
import 'package:z1racing/repositories/game_repository.dart';
import 'package:z1racing/repositories/game_repository_impl.dart';
import 'package:z1racing/game/z1racing_game.dart';
import 'package:z1racing/game/car/components/trail.dart';

class Tire extends BodyComponent<Z1RacingGame> {
  Tire({
    required this.car,
    required this.pressedKeys,
    required this.isFrontTire,
    required this.isLeftTire,
    required this.jointDef,
    required this.controlsData,
    this.isTurnableTire = false,
  }) : super(
          paint: Paint()
            ..color = Color.fromARGB(207, 144, 10, 10)
            ..strokeWidth = 0.5
            ..style = PaintingStyle.stroke,
          priority: 2,
        );

  static const double _backTireMaxDriveForce = 300.0;
  static const double _frontTireMaxDriveForce = 600.0;
  static const double _backTireMaxLateralImpulse = 8.5;
  static const double _frontTireMaxLateralImpulse = 7.5;

  final Car car;
  final size = Vector2(0.5, 1.25);
  late final RRect _renderRect = RRect.fromLTRBR(
    -size.x,
    -size.y,
    size.x,
    size.y,
    const Radius.circular(0.3),
  );

  final Set<LogicalKeyboardKey> pressedKeys;
  final ControlsData controlsData;

  late final double _maxDriveForce =
      isFrontTire ? _frontTireMaxDriveForce : _backTireMaxDriveForce;
  late final double _maxLateralImpulse =
      isFrontTire ? _frontTireMaxLateralImpulse : _backTireMaxLateralImpulse;

  // Make mutable if ice or something should be implemented
  late double _currentTraction = car.traction;
  final double _currentInertia = 0.001;

  final double _maxBackwardSpeed = -40.0;

  double currentSpeed = 0;

  final RevoluteJointDef jointDef;
  late final RevoluteJoint joint;
  final bool isTurnableTire;
  final bool isFrontTire;
  final bool isLeftTire;

  final double _lockAngle = 0.6;
  final double _turnSpeedPerSecond = 4;

  final Paint _black = BasicPalette.black.paint();

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    game.cameraWorld.add(Trail(car: car, tire: this));
  }

  @override
  Body createBody() {
    final jointAnchor = Vector2(
      isLeftTire ? -3.0 : 3.0,
      isFrontTire ? 3.5 : -4.25,
    );

    final def = BodyDef()
      ..type = BodyType.dynamic
      ..position = car.body.position + jointAnchor;
    final body = world.createBody(def)..userData = this;

    final polygonShape = PolygonShape()..setAsBoxXY(0.5, 1.25);
    body.createFixtureFromShape(polygonShape, 1.0).userData = this;

    jointDef.bodyB = body;
    jointDef.localAnchorA.setFrom(jointAnchor);
    world.createJoint(joint = RevoluteJoint(jointDef));
    joint.setLimits(0, 0);
    return body;
  }

  @override
  void update(double dt) {
    if (GameRepositoryImpl().getStatus() == GameStatus.start &&
        (body.isAwake ||
            pressedKeys.isNotEmpty ||
            controlsData.hasHorizontal() ||
            controlsData.hasVertical())) {
      _updateTurn(dt);
      _updateFriction();
      if (!game.isGameOver) {
        _updateDrive();
      }
    }
  }

  @override
  void render(Canvas canvas) {
    canvas.drawRRect(_renderRect, _black);
    canvas.drawRRect(_renderRect, paint);
  }

  void _updateFriction() {
    final impulse = _lateralVelocity
      ..scale(-body.mass)
      ..clampScalar(-_maxLateralImpulse, _maxLateralImpulse)
      ..scale(_currentTraction);
    body.applyLinearImpulse(impulse);
    body.applyAngularImpulse(
      0.1 * _currentTraction * body.getInertia() * -body.angularVelocity,
    );

    final currentForwardNormal = _forwardVelocity;
    final currentForwardSpeed = currentForwardNormal.length;
    currentForwardNormal.normalize();
    final dragForceMagnitude = -2 * currentForwardSpeed;
    body.applyForce(
      currentForwardNormal..scale(_currentTraction * dragForceMagnitude),
    );
  }

  void _updateDrive() {
    var desiredSpeed = 0.0;

    if (controlsData.upValue > 0) {
      desiredSpeed = car.speed * controlsData.upValue;
    }
    if (controlsData.downValue > 0) {
      desiredSpeed += _maxBackwardSpeed * controlsData.downValue;
    }

    if (pressedKeys.contains(LogicalKeyboardKey.arrowUp)) {
      desiredSpeed = car.speed;
    }
    if (pressedKeys.contains(LogicalKeyboardKey.arrowDown)) {
      desiredSpeed += _maxBackwardSpeed;
    }

    final currentForwardNormal = body.worldVector(Vector2(0.0, 1.0));
    currentSpeed = _forwardVelocity.dot(currentForwardNormal);
    var force = 0.0;
    var traction = _currentTraction;

    if (desiredSpeed < currentSpeed) {
      force = -_maxDriveForce;
      if (desiredSpeed < 0) {
        traction = _currentTraction;
      } else {
        traction = _currentInertia;
      }
    } else if (desiredSpeed > currentSpeed) {
      force = _maxDriveForce;
      traction = _currentTraction;
    }

    if (force.abs() > 0) {
      body.applyForce(currentForwardNormal..scale(1 * traction * force));
    }
  }

  void _updateTurn(double dt) {
    var desiredAngle = 0.0;
    var desiredTorque = 0.0;
    var isTurning = false;

    if (controlsData.leftValue > 0) {
      desiredTorque = -15.0;
      desiredAngle = -(_lockAngle * controlsData.leftValue);
      isTurning = true;
    }
    if (controlsData.rightValue > 0) {
      desiredTorque += 15.0;
      desiredAngle += (_lockAngle * controlsData.rightValue);
      isTurning = true;
    }

    if (pressedKeys.contains(LogicalKeyboardKey.arrowLeft)) {
      desiredTorque = -15.0;
      desiredAngle = -_lockAngle;
      isTurning = true;
    }
    if (pressedKeys.contains(LogicalKeyboardKey.arrowRight)) {
      desiredTorque += 15.0;
      desiredAngle += _lockAngle;
      isTurning = true;
    }
    if (isTurnableTire && isTurning) {
      final turnPerTimeStep = _turnSpeedPerSecond * dt;
      final angleNow = joint.jointAngle();
      final angleToTurn =
          (desiredAngle - angleNow).clamp(-turnPerTimeStep, turnPerTimeStep);
      final angle = angleNow + angleToTurn;
      joint.setLimits(angle, angle);
    } else {
      joint.setLimits(0, 0);
    }
    body.applyTorque(desiredTorque);
  }

  // Cached Vectors to reduce unnecessary object creation.
  final Vector2 _worldLeft = Vector2(1.0, 0.0);
  final Vector2 _worldUp = Vector2(0.0, -1.0);

  Vector2 get _lateralVelocity {
    final currentRightNormal = body.worldVector(_worldLeft);
    return currentRightNormal
      ..scale(currentRightNormal.dot(body.linearVelocity));
  }

  Vector2 get _forwardVelocity {
    final currentForwardNormal = body.worldVector(_worldUp);
    return currentForwardNormal
      ..scale(currentForwardNormal.dot(body.linearVelocity));
  }
}
