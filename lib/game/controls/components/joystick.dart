import 'dart:async';

import 'package:flame/cache.dart';
import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/material.dart';
import 'package:z1racing/game/controls/models/jcontrols_data.dart';

class Joystick extends JoystickComponent {
  static Future<Joystick> create(
      {required Images images, EdgeInsets? margin}) async {
    final image = await images.load('joystick.png');
    final sheet = SpriteSheet.fromColumnsAndRows(
      image: image,
      columns: 2,
      rows: 1,
    );

    return Joystick(
        knob: SpriteComponent(
          sprite: sheet.getSpriteById(0),
          size: Vector2.all(100),
        ),
        background: SpriteComponent(
          sprite: sheet.getSpriteById(1),
          size: Vector2.all(100),
        ));
  }

  StreamSubscription? _valueChangeSubscription;
  var _streamChangeController = StreamController<ControlsData>.broadcast();
  final _notifier = ValueNotifier<ControlsData>(ControlsData.zero());
  Joystick(
      {super.knob,
      super.background,
      super.margin = const EdgeInsets.only(right: 40, bottom: 40)}) {
    this._notifier.addListener(_listener);
  }

  Stream<ControlsData> get stream => _streamChangeController.stream;

  _listener() {
    _streamChangeController.add(_notifier.value);
  }

  void dispose() {
    _valueChangeSubscription?.cancel();
    this._notifier.removeListener(_listener);
  }

  @override
  void update(double dt) {
    ControlsData current =
        ControlsData(direction: direction, delta: delta, size: size);
    if (_notifier.value.hasChange(current)) {
      _notifier.value = current.clone();
    }
    super.update(dt);
  }
}
