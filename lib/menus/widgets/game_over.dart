import 'package:collection/collection.dart';
import 'package:flutter/material.dart' hide Image, Gradient;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:z1racing/extensions/duration_extension.dart';
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
    final chronoTime =
        Duration(milliseconds: GameRepositoryImpl().getTime().toInt())
            .toChronoString();
    final z1UserRaceRef = GameRepositoryImpl().z1UserRaceRef;
    final z1UserRace = GameRepositoryImpl().z1UserRace;
    final chronoLaptime = Duration(
      milliseconds: GameRepositoryImpl().getLapTimes().min.inMilliseconds,
    ).toChronoString();

    var text1 = '';
    var text2 = '';
    String? textPlayerReference;
    if (z1UserRaceRef != null &&
        z1UserRaceRef.time.inMilliseconds > GameRepositoryImpl().getTime()) {
      // Congratulations
      text1 = AppLocalizations.of(context)!.winRace;
      text2 =
          '''${AppLocalizations.of(context)!.winRaceOvertaken} ${z1UserRaceRef.metadata.displayName}''';
      textPlayerReference =
          '''(${z1UserRaceRef.metadata.displayName}: ${z1UserRaceRef.time.toChronoString()})''';
    } else if (z1UserRaceRef != null) {
      // Sorry
      text1 = AppLocalizations.of(context)!.lostRace;
      text2 =
          '''${AppLocalizations.of(context)!.lostRaceOvertaken} ${z1UserRaceRef.metadata.displayName}''';
      textPlayerReference =
          '''(${z1UserRaceRef.metadata.displayName}: ${z1UserRaceRef.time.toChronoString()})''';
    } else {
      // First registry
      text1 = AppLocalizations.of(context)!.firstRace;
      text2 = AppLocalizations.of(context)!.firstRaceOvertaken;
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
                const SizedBox(height: 10),
                if (textPlayerReference != null)
                  Text(
                    textPlayerReference,
                    style: textTheme.bodyMedium,
                  )
                else
                  Container(),
                const SizedBox(height: 10),
                Text(
                  '${z1UserRace!.metadata.displayName}: $chronoTime',
                  style: textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  '${AppLocalizations.of(context)!.bestLap}: $chronoLaptime',
                  style: textTheme.bodyLarge,
                ),
                const SizedBox(height: 10),
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
