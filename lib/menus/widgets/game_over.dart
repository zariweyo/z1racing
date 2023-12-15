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
    final chronoLaptime = Duration(
      milliseconds: GameRepositoryImpl().getLapTimes().min.inMilliseconds,
    ).toChronoString();
    return Material(
      color: Colors.transparent,
      child: Center(
        child: Wrap(
          children: [
            MenuCard(
              children: [
                Text(
                  '${AppLocalizations.of(context)!.finish}!!!',
                  style: textTheme.displayLarge,
                ),
                const SizedBox(height: 10),
                Text(
                  '${AppLocalizations.of(context)!.time}: $chronoTime',
                  style: textTheme.bodyLarge,
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
