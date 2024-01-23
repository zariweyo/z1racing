import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/extensions.dart';
import 'package:flutter/material.dart' hide Image, Gradient;
import 'package:google_fonts/google_fonts.dart';
import 'package:z1racing/extensions/duration_extension.dart';
import 'package:z1racing/game/z1racing_game.dart';
import 'package:z1racing/repositories/game_repository_impl.dart';

class LapText extends PositionComponent with HasGameRef<Z1RacingGame> {
  LapText() : super(position: Vector2(70, 50));
  late final ValueNotifier<int> lapNotifier =
      GameRepositoryImpl().getLapNotifier();
  late final TextComponent _timePassedComponent;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    final textStyle = GoogleFonts.rubikMonoOne(
      fontSize: 12,
      color: const Color.fromARGB(235, 248, 248, 248),
    );
    final defaultRenderer = TextPaint(style: textStyle);
    final lapCountRenderer = TextPaint(
      style: textStyle.copyWith(fontSize: 25, fontWeight: FontWeight.bold),
    );
    add(
      TextComponent(
        text: 'Lap',
        position: Vector2(0, -10),
        anchor: Anchor.center,
        textRenderer: defaultRenderer,
      ),
    );
    final lapCounter = TextComponent(
      position: Vector2(0, 10),
      anchor: Anchor.center,
      textRenderer: lapCountRenderer,
    );
    add(lapCounter);
    void updateLapText() {
      if (!GameRepositoryImpl().raceIsEnd()) {
        final lap =
            GameRepositoryImpl().currentTrack.numLaps - lapNotifier.value + 1;
        final prefix = lap < 10 ? '0' : '';
        lapCounter.text = '$prefix$lap';
      } else {
        lapCounter.text = 'DONE';
      }
    }

    _timePassedComponent = TextComponent(
      position: Vector2(0, 50),
      anchor: Anchor.center,
      textRenderer: defaultRenderer,
    );
    add(_timePassedComponent);

    _backgroundPaint = Paint()
      ..color = const Color.fromARGB(235, 248, 248, 248)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    lapNotifier.addListener(updateLapText);
    updateLapText();

    GameRepositoryImpl().getLapNotifier().addListener(() {
      if (GameRepositoryImpl().raceIsEnd()) {
        addAll([
          ScaleEffect.by(
            Vector2.all(1.5),
            EffectController(duration: 0.2, alternate: true, repeatCount: 3),
          ),
          RotateEffect.by(pi * 2, EffectController(duration: 0.5)),
        ]);
      } else {
        add(
          ScaleEffect.by(
            Vector2.all(1.5),
            EffectController(duration: 0.2, alternate: true),
          ),
        );
      }
    });
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
    Rect.fromCircle(center: Offset.zero, radius: 30),
    const Radius.circular(10),
  );
  late final Paint _backgroundPaint;

  @override
  void render(Canvas canvas) {
    canvas.drawRRect(_backgroundRect, _backgroundPaint);
  }
}
