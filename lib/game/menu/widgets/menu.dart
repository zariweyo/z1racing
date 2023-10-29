import 'package:flutter/material.dart' hide Image, Gradient;
import 'package:nakama/nakama.dart';
import 'package:z1racing/game/menu/widgets/menu_card.dart';
import 'package:z1racing/game/z1racing_game.dart';
import 'package:z1racing/repositories/nakama_repository.dart';

class Menu extends StatelessWidget {
  const Menu(this.game, {super.key});

  final Z1RacingGame game;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Material(
      color: Colors.transparent,
      child: Center(
        child: Wrap(
          children: [
            Column(
              children: [
                MenuCard(
                  children: [
                    Text(
                      'Z1 Racing',
                      style: textTheme.displayLarge,
                    ),
                    Text(
                      'First to 3 laps win',
                      style: textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      child: const Text('Play'),
                      onPressed: () {
                        game.prepareStart(numberOfPlayers: 1);
                      },
                    ),
                    Text(
                      'Arrow keys or Buttons',
                      style: textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      child: const Text('Connect Nakama'),
                      onPressed: () {
                        NakamaRepository.testCreate();
                      },
                    ),
                    ElevatedButton(
                      child: const Text('Join Nakama'),
                      onPressed: () {
                        NakamaRepository.testJoin();
                      },
                    ),
                    /* const SizedBox(height: 10),
                    ElevatedButton(
                      child: const Text('2 Players'),
                      onPressed: () {
                        game.prepareStart(numberOfPlayers: 2);
                      },
                    ),
                    Text(
                      'WASD',
                      style: textTheme.bodyMedium,
                    ), */
                  ],
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
