import 'package:flutter/material.dart' hide Image, Gradient;
import 'package:z1racing/game/menu/widgets/menu_card.dart';
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
                  'Player ${game.winner!.playerNumber + 1} wins!',
                  style: textTheme.displayLarge,
                ),
                const SizedBox(height: 10),
                Text(
                  'Time: ${game.timePassed}',
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
