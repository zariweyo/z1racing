import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:z1racing/extensions/duration_extension.dart';

import 'package:z1racing/repositories/game_repository_impl.dart';
import 'package:z1racing/game/z1racing_game.dart';

class SubLapList extends PositionComponent with HasGameRef<Z1RacingGame> {
  SubLapList() : super(position: Vector2(80, 80));

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
    List<Duration> lapTimes = GameRepositoryImpl().getLapTimes();

    removeAll(textComponents);
    textComponents.clear();

    lapTimes.forEachIndexed((index, lapTime) {
      bool isMin = lapTimes.min.inMilliseconds == lapTime.inMilliseconds;
      final textStyle = GoogleFonts.rubikMonoOne(
        fontSize: isMin ? 15 : 12,
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
