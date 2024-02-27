import 'package:flutter/material.dart' hide Image, Gradient;
import 'package:flutter/widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:z1racing/base/components/button_action.dart';
import 'package:z1racing/data/game_repository_impl.dart';
import 'package:z1racing/domain/repositories/firebase_firestore_repository.dart';
import 'package:z1racing/extensions/z1useravatar_extension.dart';
import 'package:z1racing/game/z1racing_game.dart';
import 'package:z1racing/menus/common/menu_card.dart';

class GameOver extends StatelessWidget {
  final Function()? onReset;
  final Function()? onRestart;
  const GameOver(this.game, {super.key, this.onReset, this.onRestart});

  final Z1RacingGame game;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final currentUser = FirebaseFirestoreRepository.instance.currentUser!;
    final color = FirebaseFirestoreRepository.instance.avatarColor;

    var text1 = '';
    var image = '';
    var hasWon = false;

    if (GameRepositoryImpl().getPosition() == 1) {
      // Congratulations
      text1 = AppLocalizations.of(context)!.goalPodium1;
      image = currentUser.z1UserAvatar.avatarWinPath;
      hasWon = true;
    } else if (GameRepositoryImpl().getPosition() == 2) {
      // Congratulations
      text1 = AppLocalizations.of(context)!.goalPodium2;
      image = currentUser.z1UserAvatar.avatarBasePath;
      hasWon = false;
    } else if (GameRepositoryImpl().getPosition() == 3) {
      // Congratulations
      text1 = AppLocalizations.of(context)!.goalPodium3;
      image = currentUser.z1UserAvatar.avatarBasePath;
      hasWon = false;
    } else {
      // Sorry
      text1 = AppLocalizations.of(context)!.lostRace;
      image = currentUser.z1UserAvatar.avatarLostPath;
    }

    return Material(
      color: Colors.transparent,
      child: Center(
        child: Wrap(
          children: [
            MenuCard(
              children: [
                Text(
                  text1,
                  style: textTheme.displayLarge,
                  textAlign: TextAlign.center,
                ),
                Container(
                  height: 200,
                  child: Image.asset(image),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ButtonActions(
                      onTap: onReset,
                      child: Text(
                        AppLocalizations.of(context)!.endRace,
                        style: textTheme.bodyLarge?.copyWith(
                          color: color.shade50,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (!hasWon)
                      ButtonActions(
                        onTap: onRestart,
                        child: Text(
                          AppLocalizations.of(context)!.restart,
                          style: textTheme.bodyLarge?.copyWith(
                            color: color.shade50,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
