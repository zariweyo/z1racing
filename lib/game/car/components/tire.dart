import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/palette.dart';
import 'package:flame_forge2d/flame_forge2d.dart' hide Particle, World;
import 'package:flutter/material.dart' hide Image, Gradient;
import 'package:z1racing/data/game_repository_impl.dart';
import 'package:z1racing/domain/entities/slot/slot_model.dart';
import 'package:z1racing/game/car/components/car.dart';
import 'package:z1racing/game/car/components/trail.dart';
import 'package:z1racing/game/controls/models/jcontrols_data.dart';
import 'package:z1racing/game/z1racing_game.dart';
import 'package:z1racing/models/collision_categorie.dart';
import 'package:z1racing/models/global_priorities.dart';
import 'package:z1racing/models/z1control.dart';

class Tire extends BodyComponent<Z1RacingGame> {
  Tire({
    required this.car,
    required this.pressedKeys,
    required this.isFrontTire,
    required this.isLeftTire,
    required this.jointDef,
    required this.color,
    required this.startAngle,
    this.startLevel = SlotModelLevel.floor,
    this.controlsData,
    this.isTurnableTire = false,
  }) : super(
          paint: Paint()
            ..color = const Color.fromARGB(256, 3, 0, 0)
            ..strokeWidth = 0.5
            ..style = PaintingStyle.fill,
          priority: GlobalPriorities.carShadowFloor,
        );

  static const double _backTireMaxDriveForce = 300.0;
  static const double _frontTireMaxDriveForce = 600.0;
  static const double _backTireMaxLateralImpulse = 8.5;
  static const double _frontTireMaxLateralImpulse = 7.5;
  double _coefTireSquash = 0.3;

  final Car car;
  final size = Vector2(0.5, 1.25);
  late final RRect _renderRect = RRect.fromLTRBR(
    -size.x,
    -size.y,
    size.x,
    size.y,
    const Radius.circular(0.3),
  );

  final Set<Z1Control> pressedKeys;
  final ControlsData? controlsData;
  final Color color;
  final double startAngle;
  final SlotModelLevel startLevel;

  late final double _maxDriveForce =
      isFrontTire ? _frontTireMaxDriveForce : _backTireMaxDriveForce;
  late final double _maxLateralImpulse =
      isFrontTire ? _frontTireMaxLateralImpulse : _backTireMaxLateralImpulse;

  // Make mutable if ice or something should be implemented
  late final double _currentTraction = car.traction;
  final double _currentInertia = 0.0005;

  final double _maxBackwardSpeed = -40.0;

  double currentSpeed = 0;

  final RevoluteJointDef jointDef;
  late final RevoluteJoint joint;
  final bool isTurnableTire;
  final bool isFrontTire;
  final bool isLeftTire;

  final double _lockAngle = 0.6;
  final double _turnSpeedPerSecond = 0.05;

  final Paint _black = BasicPalette.black.paint();

  Trail? trail;

  Vector2 get _jointAnchor => Vector2(
        isLeftTire ? -3.0 : 3.0,
        isFrontTire ? 3.5 : -4.25,
      );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _coefTireSquash =
        max(2.5 - GameRepositoryImpl().currentTrack.settings.slide, 0.3);
  }

  SlotModelLevel lastLevel = SlotModelLevel.floor;

  List<int> _viasSelected = [];

  void changeLevel(SlotModelLevel level) {
    lastLevel = level;
    priority = level == SlotModelLevel.floor
        ? GlobalPriorities.carShadowFloor
        : GlobalPriorities.carShadowBridge;
    body.fixtures.first.filterData.categoryBits =
        _setCollisionLevel(level, viasSelected: _viasSelected);
    trail?.priority = level == SlotModelLevel.floor
        ? GlobalPriorities.carTrailFloor
        : GlobalPriorities.carTrailBridge;
  }

  void selectVia({required List<int> viasSelected}) {
    _viasSelected = viasSelected;
    body.fixtures.first.filterData.categoryBits =
        _setCollisionLevel(lastLevel, viasSelected: viasSelected);
  }

  void translatePosition(Vector2 translate) {
    body.setTransform(
      position.clone().translated(translate.x, translate.y),
      angle,
    );
  }

  SlotModelLevel get level => CollisionCategorie.getSlotModelLevelFromCollision(
        body.fixtures.first.filterData.categoryBits,
      );

  int _setCollisionLevel(
    SlotModelLevel level, {
    List<int> viasSelected = const [],
  }) {
    if (isFrontTire) {
      var viasSum = 0;
      if (viasSelected.isNotEmpty) {
        viasSelected.forEach((via) {
          viasSum += CollisionCategorie.getViaCollisionFromSlotModelLevel(
            level,
            via,
          );
        });
      }
      return CollisionCategorie.getCollisionFromCarLevel(level) + viasSum;
    }
    return 0;
  }

  @override
  Body createBody() {
    final def = BodyDef()
      ..type = BodyType.dynamic
      ..angle = startAngle
      ..position = car.body.position + _jointAnchor;
    final body = world.createBody(def)..userData = this;

    final polygonShape = PolygonShape()..setAsBoxXY(0.5, 1.25);
    body.createFixtureFromShape(polygonShape).userData = this;
    body.fixtures.first.filterData.categoryBits =
        _setCollisionLevel(startLevel);

    jointDef.bodyB = body;
    jointDef.localAnchorA.setFrom(_jointAnchor);
    world.createJoint(joint = RevoluteJoint(jointDef));
    joint.setLimits(0, 0);
    return body;
  }

  @override
  void update(double dt) {
    if (car.initiated) {
      var adjustDrive = 1.0;
      if (dt > 1 / 59) {
        adjustDrive = 20.0;
      }
      _updateTurn(adjustDrive > 1);
      _updateFriction();
      if (!game.isGameOver) {
        _updateDrive(adjustDrive);
      }
    }
  }

  @override
  void render(Canvas canvas) {
    canvas.drawRRect(_renderRect, _black);
  }

  void _updateFriction() {
    final impulse = _lateralVelocity
      ..scale(-_coefTireSquash)
      ..clampScalar(-_maxLateralImpulse, _maxLateralImpulse)
      ..scale(_currentTraction);
    body.applyLinearImpulse(impulse);
    body.applyAngularImpulse(
      0.01 * _currentTraction * body.getInertia() * -body.angularVelocity,
    );

    final currentForwardNormal = _forwardVelocity;
    final currentForwardSpeed = currentForwardNormal.length;
    currentForwardNormal.normalize();
    final dragForceMagnitude = -2 * currentForwardSpeed;
    body.applyForce(
      currentForwardNormal..scale(_currentTraction * dragForceMagnitude),
    );
  }

  void _updateDrive(double adjustDtForce) {
    var desiredSpeed = 0.0;
    var brake = false;

    if (controlsData != null && controlsData!.upValue > 0) {
      desiredSpeed = car.speed * controlsData!.upValue;
    }
    if (controlsData != null && controlsData!.downValue > 0) {
      desiredSpeed += _maxBackwardSpeed * controlsData!.downValue;
      brake = true;
    }

    if (pressedKeys.contains(Z1Control.run)) {
      desiredSpeed = car.speed;
    }
    if (pressedKeys.contains(Z1Control.stop)) {
      desiredSpeed += _maxBackwardSpeed;
      brake = true;
    }

    final currentForwardNormal = body.worldVector(Vector2(0, 1));
    currentSpeed = _forwardVelocity.dot(currentForwardNormal);

    var force = 0.0;
    var traction = _currentTraction;

    if (brake && desiredSpeed < currentSpeed) {
      force = -_maxDriveForce;
      if (desiredSpeed < 0) {
        traction = _currentTraction;
      } else {
        traction = _currentInertia;
      }
    } else if (!brake && desiredSpeed > currentSpeed) {
      force = _maxDriveForce;
      traction = _currentTraction;
    }

    if (force.abs() > 0) {
      body.applyForce(
        currentForwardNormal..scale(1 * traction * force * adjustDtForce),
      );
    }
  }

  void _updateTurn(bool disable) {
    var desiredAngle = 0.0;
    var isTurning = false;

    if (controlsData != null && controlsData!.leftValue > 0) {
      desiredAngle = -(_lockAngle * controlsData!.leftValue);
      isTurning = true;
    }
    if (controlsData != null && controlsData!.rightValue > 0) {
      desiredAngle += _lockAngle * controlsData!.rightValue;
      isTurning = true;
    }

    if (pressedKeys.contains(Z1Control.left)) {
      desiredAngle = -_lockAngle;
      isTurning = true;
    }
    if (pressedKeys.contains(Z1Control.right)) {
      desiredAngle += _lockAngle;
      isTurning = true;
    }
    if (isTurnableTire && isTurning && !disable) {
      final turnPerTimeStep = _turnSpeedPerSecond;
      final angleNow = joint.jointAngle();
      final angleToTurn =
          (desiredAngle - angleNow).clamp(-turnPerTimeStep, turnPerTimeStep);
      final angle = angleNow + angleToTurn;
      joint.setLimits(angle, angle);
    } else if (isTurnableTire &&
        (joint.lowerLimit != 0 || joint.upperLimit != 0)) {
      joint.setLimits(0, 0);
    }
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
