import 'package:flutter/material.dart' hide Image, Gradient;
import 'package:flutter/widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:z1racing/game/z1racing_game.dart';
import 'package:z1racing/menus/widgets/menu_card.dart';
import 'package:z1racing/repositories/game_repository_impl.dart';

class GameOver extends StatelessWidget {
  final Function()? onReset;
  const GameOver(this.game, {super.key, this.onReset});

  final Z1RacingGame game;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final z1UserRaceRef = GameRepositoryImpl().z1UserRaceRef;

    var text1 = '';
    var text2 = '';
    var image = '';

    if (z1UserRaceRef != null &&
        z1UserRaceRef.time.inMilliseconds > GameRepositoryImpl().getTime()) {
      // Congratulations
      text1 = AppLocalizations.of(context)!.winRace;
      text2 =
          '''${AppLocalizations.of(context)!.winRaceOvertaken} ${z1UserRaceRef.metadata.displayName}''';
      image = 'assets/images/woman_racer_2.png';
    } else if (z1UserRaceRef != null) {
      // Sorry
      text1 = AppLocalizations.of(context)!.lostRace;
      text2 =
          '''${AppLocalizations.of(context)!.lostRaceOvertaken} ${z1UserRaceRef.metadata.displayName}''';
      image = 'assets/images/woman_racer_3.png';
    } else {
      // First registry
      text1 = AppLocalizations.of(context)!.firstRace;
      text2 = AppLocalizations.of(context)!.firstRaceOvertaken;
      image = 'assets/images/woman_racer_2.png';
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
                ElevatedButton(
                  onPressed: onReset,
                  child: Text(AppLocalizations.of(context)!.close),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
