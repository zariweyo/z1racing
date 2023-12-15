import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:z1racing/extensions/duration_extension.dart';
import 'package:z1racing/game/z1racing_game.dart';

class ReferenceTimeText extends PositionComponent
    with HasGameRef<Z1RacingGame> {
  late final TextComponent _timePassedComponent;
  final Duration duration;

  ReferenceTimeText({required this.duration});

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    position = Vector2(gameRef.size.x / 2, gameRef.size.y / 1.5);
    final textStyle = GoogleFonts.rubikMonoOne(
      fontSize: 15,
      color: const Color.fromARGB(235, 248, 248, 248),
    );
    final defaultRenderer = TextPaint(style: textStyle);

    _timePassedComponent = TextComponent(
      anchor: Anchor.center,
      textRenderer: defaultRenderer,
    );
    add(_timePassedComponent);

    var bgColor = const Color.fromARGB(72, 70, 232, 84);
    _timePassedComponent.text = duration.abs().toChronoString();
    if (duration.isNegative || duration.inMilliseconds == 0) {
      _timePassedComponent.text = '- ${_timePassedComponent.text}';
      bgColor = const Color.fromARGB(72, 70, 232, 84);
    } else {
      _timePassedComponent.text = '+ ${_timePassedComponent.text}';
      bgColor = const Color.fromARGB(71, 232, 70, 94);
    }

    _backgroundPaint = Paint()
      ..color = bgColor
      ..style = PaintingStyle.fill
      ..strokeWidth = 2;
    _backgroundRect =
        RRect.fromLTRBR(-80, -15, 80, 15, const Radius.circular(10));

    add(
      ScaleEffect.by(
        Vector2.all(1.2),
        EffectController(duration: 0.2, alternate: true),
        onComplete: () {},
      ),
    );
  }

  late final Paint _backgroundPaint;
  late final RRect _backgroundRect;
  @override
  void render(Canvas canvas) {
    canvas.drawRRect(_backgroundRect, _backgroundPaint);
  }
}
