import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/cache.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/extensions.dart';
import 'package:flame/input.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:z1racing/game/controls/models/jcontrols_data.dart';
import 'package:z1racing/game/z1racing_game.dart';

enum ButtonGameType { left, right, up, down }

class ButtonsGame extends PositionComponent with DragCallbacks {
  static Future<ButtonsGame> create({
    required Z1RacingGame game,
    required Images images,
  }) async {
    return ButtonsGame(game: game, images: images);
  }

  StreamSubscription? _valueChangeSubscription;
  final _streamChangeController = StreamController<ControlsData>.broadcast();
  final _notifier = ValueNotifier<ControlsData>(ControlsData.zero());
  final Images images;

  ButtonsGame({required Z1RacingGame game, required this.images}) {
    position = Vector2(0, 100);
    size = game.size;
    _notifier.addListener(_listener);
  }

  Stream<ControlsData> get stream => _streamChangeController.stream;

  void _listener() {
    _streamChangeController.add(_notifier.value);
  }

  void dispose() {
    _valueChangeSubscription?.cancel();
    _notifier.removeListener(_listener);
  }

  final Map<ButtonGameType, Vector2> _currentPressed = {};
  final Map<int, ButtonGameType> _currentDragged = {};
  ButtonGameType? buttonCancelled;

  void _updatePressed() {
    const gearStep = 0.02;
    const movementStep = 0.06;
    _currentPressed.forEach((type, value) {
      switch (type) {
        case ButtonGameType.left:
          if (_currentPressed[type]!.x > -1) {
            _currentPressed[type]!.x -= gearStep;
          }
          break;
        case ButtonGameType.right:
          if (_currentPressed[type]!.x < 1) {
            _currentPressed[type]!.x += gearStep;
          }
          break;
        case ButtonGameType.down:
          if (_currentPressed[type]!.y < 1) {
            _currentPressed[type]!.y += movementStep;
          }
          break;
        case ButtonGameType.up:
          if (_currentPressed[type]!.y > -1) {
            _currentPressed[type]!.y -= movementStep;
          }
          break;
      }
    });
  }

  void _onPressed(ButtonGameType type) {
    if (_currentPressed[type] == null) {
      _currentPressed[type] = Vector2.zero();
    }
  }

  void _onReleased(ButtonGameType type) {
    _currentPressed.remove(type);
  }

  @override
  void onDragStart(DragStartEvent event) {
    if (buttonCancelled != null) {
      _currentDragged[event.pointerId] = buttonCancelled!;
    }
    super.onDragStart(event);
  }

  @override
  void onDragEnd(DragEndEvent event) {
    if (_currentDragged[event.pointerId] != null) {
      _currentPressed.remove(_currentDragged[event.pointerId]);
      _currentDragged.remove(event.pointerId);
    }
    super.onDragEnd(event);
  }

  JoystickDirection get direction {
    if (_currentPressed.keys.contains(ButtonGameType.up)) {
      if (_currentPressed.keys.contains(ButtonGameType.left)) {
        return JoystickDirection.upLeft;
      } else if (_currentPressed.keys.contains(ButtonGameType.right)) {
        return JoystickDirection.upRight;
      }
      return JoystickDirection.up;
    } else if (_currentPressed.keys.contains(ButtonGameType.down)) {
      if (_currentPressed.keys.contains(ButtonGameType.down)) {
        return JoystickDirection.downLeft;
      } else if (_currentPressed.keys.contains(ButtonGameType.right)) {
        return JoystickDirection.downRight;
      }
      return JoystickDirection.down;
    }
    return JoystickDirection.idle;
  }

  Vector2 get delta => _currentPressed.isEmpty
      ? Vector2.zero()
      : _currentPressed.values.reduce((value, element) => value + element);

  HudButtonComponent _createButton({
    required Image image,
    required ButtonGameType type,
    double radius = 40,
    EdgeInsets? margin,
  }) {
    return HudButtonComponent(
      button: ActionButton(
        image: image,
        radius: radius,
        rotate: type == ButtonGameType.left ? 0 : math.pi / 2,
      ),
      buttonDown: ActionButton(image: image, radius: radius - 10, move: 10),
      margin: margin,
      onPressed: () => _onPressed(type),
      onReleased: () => _onReleased(type),
      onCancelled: () => buttonCancelled = type,
    );
  }

  @override
  Future<void> onLoad() async {
    super.onLoad();
    final image = await images.load('arrow.png');

    final bottonLeft = _createButton(
      image: image,
      margin: const EdgeInsets.only(left: 10, bottom: 120),
      radius: 60,
      type: ButtonGameType.left,
    );
    final bottonRight = _createButton(
      image: image,
      margin: const EdgeInsets.only(left: 170, bottom: 120),
      radius: 60,
      type: ButtonGameType.right,
    );
    final bottonUp = _createButton(
      image: image,
      margin: const EdgeInsets.only(right: 10, bottom: 270),
      type: ButtonGameType.up,
    );
    final bottonDown = _createButton(
      image: image,
      margin: const EdgeInsets.only(right: 10, bottom: 120),
      type: ButtonGameType.down,
    );

    add(bottonLeft);
    add(bottonRight);
    add(bottonUp);
    add(bottonDown);
  }

  @override
  void update(double dt) {
    super.update(dt);
    _updatePressed();
    final current =
        ControlsData(direction: direction, delta: delta, size: Vector2(2, 2));
    if (_notifier.value.hasChange(current)) {
      _notifier.value = current.clone();
    }
  }
}

class ActionButton extends PositionComponent {
  final Image image;
  final double rotate;
  ActionButton({
    required this.image,
    double radius = 50,
    double move = 0,
    this.rotate = 0,
  })  : _radius = radius,
        _paint = Paint()
          ..color = const Color(0x5580C080)
          ..style = PaintingStyle.fill
          ..strokeWidth = 5,
        super(
          position: Vector2(move, move),
          size: Vector2.all(2 * radius),
          anchor: Anchor.center,
        );

  final double _radius;
  final Paint _paint;

  late final RRect _renderRect = RRect.fromRectAndCorners(
    Rect.fromCircle(center: Offset(_radius * 2, _radius * 2), radius: _radius),
    topLeft: const Radius.circular(20),
    topRight: const Radius.circular(20),
    bottomLeft: const Radius.circular(20),
    bottomRight: const Radius.circular(20),
  );

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    canvas.drawRRect(_renderRect, _paint);
  }
}
