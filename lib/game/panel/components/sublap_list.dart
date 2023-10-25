import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flutter/material.dart' hide Image, Gradient;
import 'package:google_fonts/google_fonts.dart';
import 'package:z1racing/extensions/duration_extension.dart';

import 'package:z1racing/game/car/components/car.dart';
import 'package:z1racing/game/z1racing_game.dart';

class SubLapList extends PositionComponent with HasGameRef<Z1RacingGame> {
  SubLapList({required this.car, required Vector2 position})
      : super(position: position);

  final Car car;
  late final ValueNotifier<int> lapNotifier = car.lapNotifier;
  List<Duration> lapTimes = [];

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    void updateLapText() {
      if (lapNotifier.value > 1)
        _addTime(Duration(milliseconds: gameRef.seconds.toInt()));
    }

    lapNotifier.addListener(updateLapText);
  }

  _addTime(Duration time) {
    Duration timeMod = time;
    if (!lapTimes.isEmpty) {
      timeMod = time - lapTimes.last;
    }
    lapTimes.add(time);

    final textStyle = GoogleFonts.rubikMonoOne(
      fontSize: 15,
      color: Color.fromARGB(232, 240, 234, 234),
    );
    final defaultRenderer = TextPaint(style: textStyle);
    final newTime = TextComponent(
      text: timeMod.toChronoString(),
      position: Vector2(0, 70 + (lapTimes.length) * 22),
      anchor: Anchor.center,
      textRenderer: defaultRenderer,
    );
    add(newTime);
  }
}
