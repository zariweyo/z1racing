import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/extensions.dart';
import 'package:flutter/material.dart' hide Image, Gradient;
import 'package:google_fonts/google_fonts.dart';
import 'package:z1racing/game/z1racing_game.dart';
import 'package:z1racing/repositories/game_repository.dart';
import 'package:z1racing/repositories/game_repository_impl.dart';

class CountDownText extends PositionComponent with HasGameRef<Z1RacingGame> {
  CountDownText({this.seconds = 5}) : super();

  late final TextComponent _timePassedComponent;
  double totalTime = 0;
  final int seconds;
  int currentValue = 0;
  ValueNotifier<bool> onFinish = ValueNotifier<bool>(false);
  late final Paint _backgroundPaint;
  late final RRect _backgroundRect;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    position = Vector2(gameRef.size.x / 2, gameRef.size.y / 4);
    final textStyle = GoogleFonts.rubikMonoOne(
      fontSize: 70,
      color: const Color.fromARGB(235, 248, 248, 248),
    );
    final defaultRenderer = TextPaint(style: textStyle);

    _timePassedComponent = TextComponent(
      anchor: Anchor.center,
      textRenderer: defaultRenderer,
    );
    add(_timePassedComponent);

    _backgroundPaint = Paint()
      ..color = const Color.fromARGB(235, 248, 248, 248)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    _backgroundRect = RRect.fromRectAndRadius(
      Rect.fromCircle(center: Offset.zero, radius: 50),
      const Radius.circular(10),
    );
  }

  @override
  void update(double dt) {
    if (onFinish.value) {
      return;
    }
    totalTime += dt;
    final value = 5 - totalTime.toInt();
    if (currentValue != value) {
      currentValue = value;
      add(
        ScaleEffect.by(
          Vector2.all(2),
          EffectController(duration: 0.2, alternate: true),
        ),
      );
    }
    _timePassedComponent.text = value.toString();
    if (value == 0) {
      onFinish.value = true;
      GameRepositoryImpl().setStatus(GameStatus.start);
    }
  }

  @override
  void render(Canvas canvas) {
    canvas.drawRRect(_backgroundRect, _backgroundPaint);
  }
}
