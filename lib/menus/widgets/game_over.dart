import 'package:collection/collection.dart';
import 'package:flutter/material.dart' hide Image, Gradient;
import 'package:z1racing/extensions/duration_extension.dart';
import 'package:z1racing/menus/widgets/menu_card.dart';
import 'package:z1racing/repositories/game_repository_impl.dart';
import 'package:z1racing/game/z1racing_game.dart';

class GameOver extends StatelessWidget {
  final Function()? onReset;
  const GameOver(this.game, {super.key, this.onReset});

  final Z1RacingGame game;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Material(
      color: Colors.transparent,
      child: Center(
        child: Wrap(
          children: [
            MenuCard(
              children: [
                Text(
                  'FINISH!!!',
                  style: textTheme.displayLarge,
                ),
                const SizedBox(height: 10),
                Text(
                  'Time: ${Duration(milliseconds: GameRepositoryImpl().getTime().toInt()).toChronoString()}',
                  style: textTheme.bodyLarge,
                ),
                Text(
                  'Best LAP: ${Duration(milliseconds: GameRepositoryImpl().getLapTimes().min.inMilliseconds).toChronoString()}',
                  style: textTheme.bodyLarge,
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: onReset,
                  child: const Text('Restart'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
