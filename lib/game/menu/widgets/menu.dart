import 'package:flutter/material.dart';
import 'package:z1racing/game/repositories/firebase_auth_repository.dart';
import 'package:z1racing/game/repositories/firebase_firestore_repository.dart';
import 'package:z1racing/game/repositories/game_repository_impl.dart';
import 'package:z1racing/game/menu/widgets/menu_settings.dart';
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
    FirebaseAuthRepository()
        .currentUserNotifier
        .addListener(_currentUserModified);
    super.initState();
  }

  @override
  dispose() {
    super.dispose();
    FirebaseAuthRepository()
        .currentUserNotifier
        .removeListener(_currentUserModified);
  }

  _currentUserModified() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final numLaps = GameRepositoryImpl().currentTrack.numLaps;
    final String name =
        FirebaseFirestoreRepository().currentUser?.displayName ?? "";
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
                          Image.asset(
                            "assets/images/logo_alpha.png",
                            height: 50,
                            fit: BoxFit.contain,
                          ),
                          Text(
                            'Hello ${name}',
                            style: textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 5),
                          ElevatedButton(
                            child: const Text('Play'),
                            onPressed: () {
                              widget.game.prepareStart(numberOfPlayers: 1);
                            },
                          ),
                          Text(
                            '${numLaps} laps',
                            style: textTheme.bodySmall,
                          ),
                          Text(
                            'Arrow keys or Buttons',
                            style: textTheme.bodySmall,
                          ),
                          ElevatedButton(
                            child: const Text('Settings'),
                            onPressed: () {
                              MenuSettings.open(context: context);
                            },
                          ),
                        ],
                      ))
                ],
              ),
            ],
          )),
    );
  }
}
