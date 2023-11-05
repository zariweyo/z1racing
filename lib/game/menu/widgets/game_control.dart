import 'package:flutter/material.dart';
import 'package:z1racing/game/z1racing_game.dart';

class GameControl extends StatelessWidget {
  final Z1RacingGame gameRef;
  final Function()? onReset;
  GameControl({required this.gameRef, this.onReset});

  _onPressed(BuildContext context) {
    gameRef.paused = !gameRef.paused;
    if (gameRef.paused) {
      _buildPopupDialog(context);
    }
  }

  _menuItem(BuildContext context,
      {required String text, required Function() onTap}) {
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

  _buildPopupDialog(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    showDialog(
        context: context,
        builder: (BuildContext context) => new AlertDialog(
              title: const Text('Menu'),
              backgroundColor: Colors.black54,
              content: Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.white),
                      borderRadius: BorderRadius.circular(10)),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        'MENU',
                        style: textTheme.bodyLarge,
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      _menuItem(context, text: 'END RACE', onTap: () {
                        Navigator.of(context).pop();
                        onReset?.call();
                      }),
                      _menuItem(context, text: 'CLOSE', onTap: () {
                        Navigator.of(context).pop();
                        gameRef.paused = false;
                      }),
                    ],
                  )),
            )).then((value) => gameRef.paused = false);
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
                    margin: EdgeInsets.all(10),
                    width: 50,
                    child: Row(
                      children: [
                        IconButton(
                            highlightColor: Colors.transparent,
                            hoverColor: Colors.transparent,
                            splashColor: Colors.transparent,
                            onPressed: () => _onPressed(context),
                            icon: Icon(
                              Icons.menu,
                              color: Colors.white,
                            ))
                      ],
                    ),
                  )
                ])));
  }
}
