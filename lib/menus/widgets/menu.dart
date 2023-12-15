import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:z1racing/base/components/update_button.dart';
import 'package:z1racing/game/z1racing_game.dart';
import 'package:z1racing/menus/widgets/menu_settings.dart';
import 'package:z1racing/repositories/firebase_auth_repository.dart';
import 'package:z1racing/repositories/firebase_firestore_repository.dart';
import 'package:z1racing/repositories/game_repository_impl.dart';

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
  void dispose() {
    super.dispose();
    FirebaseAuthRepository.instance.currentUserNotifier
        .removeListener(_currentUserModified);
  }

  void _currentUserModified() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final numLaps = GameRepositoryImpl().currentTrack.numLaps;
    final name = FirebaseFirestoreRepository.instance.currentUser?.name ?? '';
    return Material(
      color: Colors.transparent,
      child: Container(
        width: MediaQuery.of(context).size.width / 2,
        margin: EdgeInsets.only(
          right: 50,
          left: MediaQuery.of(context).size.width / 2,
        ),
        child: Wrap(
          alignment: WrapAlignment.end,
          crossAxisAlignment: WrapCrossAlignment.end,
          children: [
            Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  margin: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    border: Border.all(color: Colors.white38),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      Image.asset(
                        'assets/images/logo_alpha.png',
                        height: 50,
                        fit: BoxFit.contain,
                      ),
                      Text(
                        AppLocalizations.of(context)!
                            .homeHello
                            .replaceAll('%%USERNAME%%', name),
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
                                widget.game.prepareStart(numberOfPlayers: 1);
                                break;
                            }
                            return KeyEventResult.ignored;
                          },
                        ),
                        onPressed: () {
                          widget.game.prepareStart(numberOfPlayers: 1);
                        },
                        child: Text(
                          AppLocalizations.of(context)!.play,
                          style: textTheme.bodyLarge
                              ?.copyWith(color: Colors.white),
                        ),
                      ),
                      Text(
                        AppLocalizations.of(context)!
                            .numLaps
                            .replaceAll('%%LAPS%%', numLaps.toString()),
                        style: textTheme.bodySmall,
                      ),
                      Text(
                        AppLocalizations.of(context)!.infoControls,
                        style: textTheme.bodySmall,
                      ),
                      ElevatedButton(
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
                        onPressed: () {
                          MenuSettings.open(context: context);
                        },
                        child: Text(
                          AppLocalizations.of(context)!.settings,
                          style: textTheme.bodyLarge
                              ?.copyWith(color: Colors.white),
                        ),
                      ),
                      /* ElevatedButton(
                            child: const Text('Load Track'),
                            onPressed: () {
                              widget.changeTrack?.call();
                            },
                          ), */
                      const UpdateButton(),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
