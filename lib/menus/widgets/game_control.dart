import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:z1racing/game/z1racing_game.dart';

class GameControl extends StatelessWidget {
  final Z1RacingGame gameRef;
  final Function()? onRestart;
  final Function()? onReset;
  const GameControl({
    required this.gameRef,
    super.key,
    this.onRestart,
    this.onReset,
  });

  void _onPressed(BuildContext context) {
    gameRef.paused = !gameRef.paused;
    if (gameRef.paused) {
      _buildPopupDialog(context);
    }
  }

  Widget _menuItem(
    BuildContext context, {
    required String text,
    required Function() onTap,
  }) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      height: 50,
      child: ElevatedButton(
        onPressed: onTap,
        child: Text(
          text,
          style: textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  void _buildPopupDialog(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.menu),
        backgroundColor: Colors.black54,
        content: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: <Widget>[
              Text(
                AppLocalizations.of(context)!.menu.toUpperCase(),
                style: textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(
                height: 30,
              ),
              _menuItem(
                context,
                text: AppLocalizations.of(context)!.restart.toUpperCase(),
                onTap: () {
                  Navigator.of(context).pop();
                  onRestart?.call();
                },
              ),
              _menuItem(
                context,
                text: AppLocalizations.of(context)!.endRace.toUpperCase(),
                onTap: () {
                  Navigator.of(context).pop();
                  onReset?.call();
                },
              ),
              _menuItem(
                context,
                text: AppLocalizations.of(context)!.close.toUpperCase(),
                onTap: () {
                  Navigator.of(context).pop();
                  gameRef.paused = false;
                },
              ),
            ],
          ),
        ),
      ),
    ).then((value) => gameRef.paused = false);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: MediaQuery.of(context).size.width,
        child: Wrap(
          alignment: WrapAlignment.end,
          crossAxisAlignment: WrapCrossAlignment.end,
          children: [
            Container(
              margin: const EdgeInsets.all(10),
              width: 50,
              child: Row(
                children: [
                  IconButton(
                    highlightColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    splashColor: Colors.transparent,
                    onPressed: () => _onPressed(context),
                    icon: const Icon(
                      Icons.menu,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
