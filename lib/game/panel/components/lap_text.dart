import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flutter/material.dart' hide Image, Gradient;

import 'package:z1racing/game/car/components/car.dart';
import 'package:z1racing/game/z1racing_game.dart';

class LapText extends PositionComponent with HasGameRef<Z1RacingGame> {
  LapText({required this.car, required Vector2 position})
      : super(position: position);

  final Car car;
  late final ValueNotifier<int> lapNotifier = car.lapNotifier;
  late final TextComponent _timePassedComponent;
  List<Duration> lapTimes = [];

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    final textStyle = TextStyle(
      fontSize: 35,
      color: car.paint.color,
    );
    final defaultRenderer = TextPaint(style: textStyle);
    final lapCountRenderer = TextPaint(
      style: textStyle.copyWith(fontSize: 45, fontWeight: FontWeight.bold),
    );
    add(
      TextComponent(
        text: 'Lap',
        position: Vector2(0, -20),
        anchor: Anchor.center,
        textRenderer: defaultRenderer,
      ),
    );
    final lapCounter = TextComponent(
      position: Vector2(0, 20),
      anchor: Anchor.center,
      textRenderer: lapCountRenderer,
    );
    add(lapCounter);
    void updateLapText() {
      if (lapNotifier.value <= Z1RacingGame.numberOfLaps) {
        final prefix = lapNotifier.value < 10 ? '0' : '';
        lapCounter.text = '$prefix${lapNotifier.value}';
      } else {
        lapCounter.text = 'DONE';
      }
      if (lapNotifier.value > 1)
        _addTime(Duration(milliseconds: gameRef.seconds.toInt()));
    }

    _timePassedComponent = TextComponent(
      position: Vector2(0, 70),
      anchor: Anchor.center,
      textRenderer: defaultRenderer,
    );
    add(_timePassedComponent);

    _backgroundPaint = Paint()
      ..color = car.paint.color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    lapNotifier.addListener(updateLapText);
    updateLapText();
  }

  _addTime(Duration time) {
    Duration timeMod = time;
    if (!lapTimes.isEmpty) {
      timeMod = time - lapTimes.last;
    }
    lapTimes.add(time);

    final textStyle = TextStyle(
      fontSize: 20,
      color: car.paint.color,
    );
    final defaultRenderer = TextPaint(style: textStyle);
    final newTime = TextComponent(
      text:
          "${timeMod.inMinutes}:${timeMod.inSeconds % 60}:${timeMod.inMilliseconds % 1000}",
      position: Vector2(0, 70 + (lapTimes.length) * 22),
      anchor: Anchor.center,
      textRenderer: defaultRenderer,
    );
    add(newTime);
  }

  @override
  void update(double dt) {
    if (gameRef.isGameOver) {
      return;
    }
    _timePassedComponent.text = gameRef.timePassed;
  }

  final _backgroundRect = RRect.fromRectAndRadius(
    Rect.fromCircle(center: Offset.zero, radius: 50),
    const Radius.circular(10),
  );
  late final Paint _backgroundPaint;

  @override
  void render(Canvas canvas) {
    canvas.drawRRect(_backgroundRect, _backgroundPaint);
  }
}
