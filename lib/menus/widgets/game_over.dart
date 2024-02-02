import 'package:flutter/material.dart' hide Image, Gradient;
import 'package:flutter/widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:z1racing/base/components/button_action.dart';
import 'package:z1racing/extensions/z1useravatar_extension.dart';
import 'package:z1racing/game/z1racing_game.dart';
import 'package:z1racing/menus/widgets/menu_card.dart';
import 'package:z1racing/repositories/firebase_firestore_repository.dart';
import 'package:z1racing/repositories/game_repository_impl.dart';

class GameOver extends StatelessWidget {
  final Function()? onReset;
  final Function()? onRestart;
  const GameOver(this.game, {super.key, this.onReset, this.onRestart});

  final Z1RacingGame game;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final z1UserRaceRef = GameRepositoryImpl().z1UserRaceRef;
    final currentUser = FirebaseFirestoreRepository.instance.currentUser!;
    final color = FirebaseFirestoreRepository.instance.avatarColor;

    var text1 = '';
    var text2 = '';
    var image = '';

    if (z1UserRaceRef != null &&
        z1UserRaceRef.time.inMilliseconds > GameRepositoryImpl().getTime()) {
      // Congratulations
      text1 = AppLocalizations.of(context)!.winRace;
      text2 =
          '''${AppLocalizations.of(context)!.winRaceOvertaken} ${z1UserRaceRef.metadata.displayName}''';
      image = currentUser.z1UserAvatar.avatarWinPath;
    } else if (z1UserRaceRef != null) {
      // Sorry
      text1 = AppLocalizations.of(context)!.lostRace;
      text2 =
          '''${AppLocalizations.of(context)!.lostRaceOvertaken} ${z1UserRaceRef.metadata.displayName}''';
      image = currentUser.z1UserAvatar.avatarLostPath;
    } else {
      // First registry
      text1 = AppLocalizations.of(context)!.firstRace;
      text2 = AppLocalizations.of(context)!.firstRaceOvertaken;
      image = currentUser.z1UserAvatar.avatarWinPath;
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
                ),
                Text(
                  text2,
                  style: textTheme.bodyLarge,
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
