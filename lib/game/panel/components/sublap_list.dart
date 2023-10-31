import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:z1racing/extensions/duration_extension.dart';

import 'package:z1racing/game/car/components/car.dart';
import 'package:z1racing/game/repositories/game_repository_impl.dart';
import 'package:z1racing/game/z1racing_game.dart';

class SubLapList extends PositionComponent with HasGameRef<Z1RacingGame> {
  SubLapList({required this.car, required Vector2 position})
      : super(position: position);

  final Car car;
  List<TextComponent> textComponents = [];

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    void updateLapText() {
      if (GameRepositoryImpl().getCurrentLap() > 0) _addTime();
    }

    GameRepositoryImpl().getLapNotifier().addListener(updateLapText);
  }

  _addTime() {
    GameRepositoryImpl().addLapTimeFromCurrent();
    List<Duration> lapTimes = GameRepositoryImpl().getLapTimes();

    removeAll(textComponents);
    textComponents.clear();

    lapTimes.forEachIndexed((index, lapTime) {
      bool isMin = lapTimes.min.inMilliseconds == lapTime.inMilliseconds;
      final textStyle = GoogleFonts.rubikMonoOne(
        fontSize: isMin ? 20 : 15,
        fontWeight: isMin ? FontWeight.bold : FontWeight.w300,
        color: Color.fromARGB(232, 240, 234, 234),
      );
      final defaultRenderer = TextPaint(style: textStyle);
      final newTime = TextComponent(
        text: lapTime.toChronoString(),
        position: Vector2(0, 50 + index * 22),
        anchor: Anchor.center,
        textRenderer: defaultRenderer,
      );
      textComponents.add(newTime);
    });

    addAll(textComponents);
  }
}
