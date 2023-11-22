import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:z1racing/base/components/update_button.dart';
import 'package:z1racing/repositories/firebase_auth_repository.dart';
import 'package:z1racing/repositories/firebase_firestore_repository.dart';
import 'package:z1racing/repositories/game_repository_impl.dart';
import 'package:z1racing/menus/widgets/menu_settings.dart';
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
    FirebaseAuthRepository.instance.currentUserNotifier
        .addListener(_currentUserModified);
    super.initState();
  }

  @override
  dispose() {
    super.dispose();
    FirebaseAuthRepository.instance.currentUserNotifier
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
        FirebaseFirestoreRepository.instance.currentUser?.name ?? "";
    return Material(
      color: Colors.transparent,
      child: Container(
          width: MediaQuery.of(context).size.width / 2,
          margin: EdgeInsets.only(
              top: 0, right: 50, left: MediaQuery.of(context).size.width / 2),
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
                            autofocus: true,
                            focusNode: FocusNode(
                              onKey: (node, event) {
                                switch (event.logicalKey) {
                                  case LogicalKeyboardKey.enter:
                                    node.unfocus();
                                    widget.game
                                        .prepareStart(numberOfPlayers: 1);
                                    break;
                                }
                                return KeyEventResult.ignored;
                              },
                            ),
                            child: Text(
                              'Play',
                              style: textTheme.bodyLarge
                                  ?.copyWith(color: Colors.white),
                            ),
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
                            autofocus: false,
                            focusNode: FocusNode(
                              onKey: (node, event) {
                                switch (event.logicalKey) {
                                  case LogicalKeyboardKey.enter:
                                    node.unfocus();
                                    MenuSettings.open(context: context);
                                    break;
                                }
                                return KeyEventResult.ignored;
                              },
                            ),
                            child: Text(
                              'Settings',
                              style: textTheme.bodyLarge
                                  ?.copyWith(color: Colors.white),
                            ),
                            onPressed: () {
                              MenuSettings.open(context: context);
                            },
                          ),
                          /* ElevatedButton(
                            child: const Text('Load Track'),
                            onPressed: () {
                              widget.changeTrack?.call();
                            },
                          ), */
                          UpdateButton()
                        ],
                      ))
                ],
              ),
            ],
          )),
    );
  }
}
