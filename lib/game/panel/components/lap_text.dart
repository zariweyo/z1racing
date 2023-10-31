import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flutter/material.dart' hide Image, Gradient;
import 'package:google_fonts/google_fonts.dart';
import 'package:z1racing/extensions/duration_extension.dart';

import 'package:z1racing/game/car/components/car.dart';
import 'package:z1racing/game/repositories/game_repository_impl.dart';
import 'package:z1racing/game/z1racing_game.dart';

class LapText extends PositionComponent with HasGameRef<Z1RacingGame> {
  LapText({required this.car, required Vector2 position})
      : super(position: position);

  final Car car;
  late final ValueNotifier<int> lapNotifier =
      GameRepositoryImpl().getLapNotifier();
  late final TextComponent _timePassedComponent;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    final textStyle = GoogleFonts.rubikMonoOne(
      fontSize: 20,
      color: Color.fromARGB(235, 248, 248, 248),
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
      if (!GameRepositoryImpl().raceEnd()) {
        final prefix = lapNotifier.value < 10 ? '0' : '';
        lapCounter.text = '$prefix${lapNotifier.value}';
      } else {
        lapCounter.text = 'DONE';
      }
    }

    _timePassedComponent = TextComponent(
      position: Vector2(0, 70),
      anchor: Anchor.center,
      textRenderer: defaultRenderer,
    );
    add(_timePassedComponent);

    _backgroundPaint = Paint()
      ..color = Color.fromARGB(235, 248, 248, 248)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    lapNotifier.addListener(updateLapText);
    updateLapText();
  }

  @override
  void update(double dt) {
    if (gameRef.isGameOver) {
      return;
    }
    _timePassedComponent.text =
        Duration(milliseconds: GameRepositoryImpl().getTime().toInt())
            .toChronoString();
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
