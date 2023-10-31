import 'package:flame/game.dart';
import 'package:flutter/material.dart' hide Image, Gradient;
import 'package:flutter/services.dart';

import 'package:z1racing/game/menu/widgets/game_over.dart';
import 'package:z1racing/game/menu/widgets/menu.dart';
import 'package:z1racing/game/repositories/game_repository_impl.dart';
import 'package:z1racing/game/z1racing_game.dart';

class Z1RacingWidget extends StatefulWidget {
  const Z1RacingWidget({super.key});

  @override
  State<Z1RacingWidget> createState() => _Z1RacingWidgetState();
}

class _Z1RacingWidgetState extends State<Z1RacingWidget> {
  late GlobalKey key;

  @override
  void initState() {
    key = GlobalKey();
    GameRepositoryImpl();
    super.initState();
  }

  _reset() {
    setState(() {
      GameRepositoryImpl().reset();
      key = GlobalKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = ThemeData(
      textTheme: TextTheme(
        displayLarge: TextStyle(
          fontSize: 35,
          color: Colors.white,
        ),
        labelLarge: TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.w500,
        ),
        bodyLarge: TextStyle(
          fontSize: 28,
          color: Colors.grey,
        ),
        bodyMedium: TextStyle(
          fontSize: 18,
          color: Colors.grey,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          minimumSize: const Size(150, 50),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        hoverColor: Colors.red.shade700,
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
        border: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
        errorBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: Colors.red.shade700,
          ),
        ),
      ),
    );

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    return MaterialApp(
      title: 'Z1Racing',
      home: GameWidget<Z1RacingGame>(
        key: key,
        game: Z1RacingGame(),
        loadingBuilder: (context) => Center(
          child: Text(
            'Loading...',
            style: Theme.of(context).textTheme.displayLarge,
          ),
        ),
        overlayBuilderMap: {
          'menu': (_, game) => Menu(game),
          'game_over': (_, game) => GameOver(game, onReset: _reset),
        },
        initialActiveOverlays: const ['menu'],
      ),
      theme: theme,
    );
  }
}
