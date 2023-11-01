import 'package:flutter/material.dart' hide Image, Gradient;
import 'package:z1racing/game/repositories/game_repository_impl.dart';
import 'package:z1racing/game/z1racing_game.dart';

class Menu extends StatefulWidget {
  const Menu(this.game, {super.key});

  final Z1RacingGame game;

  @override
  State<Menu> createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  bool initiated = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final numLaps = GameRepositoryImpl().currentTrack.numLaps;
    return Material(
      color: Colors.transparent,
      child: Container(
          width: MediaQuery.of(context).size.width,
          margin: EdgeInsets.all(50),
          child: Wrap(
            alignment: WrapAlignment.end,
            crossAxisAlignment: WrapCrossAlignment.end,
            children: [
              Column(
                children: [
                  Container(
                      padding: EdgeInsets.all(20),
                      margin: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                          color: Colors.black54,
                          border: Border.all(color: Colors.white38),
                          borderRadius: BorderRadius.circular(20)),
                      child: Column(
                        children: [
                          Text(
                            'Z1 Racing',
                            style: textTheme.displayLarge,
                          ),
                          Text(
                            'First to ${numLaps} laps win',
                            style: textTheme.bodyLarge,
                          ),
                          const SizedBox(height: 5),
                          ElevatedButton(
                            child: const Text('Play'),
                            onPressed: () {
                              widget.game.prepareStart(numberOfPlayers: 1);
                            },
                          ),
                          Text(
                            'Arrow keys or Buttons',
                            style: textTheme.bodyMedium,
                          )
                        ],
                      ))
                ],
              ),
            ],
          )),
    );
  }
}
