import 'package:flame/game.dart';
import 'package:flutter/material.dart' hide Image, Gradient;
import 'package:google_fonts/google_fonts.dart';

import 'package:z1racing/game_over.dart';
import 'package:z1racing/menu.dart';
import 'package:z1racing/z1racing_game.dart';

class Z1RacingWidget extends StatelessWidget {
  const Z1RacingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = ThemeData(
      textTheme: TextTheme(
        displayLarge: GoogleFonts.vt323(
          fontSize: 35,
          color: Colors.white,
        ),
        labelLarge: GoogleFonts.vt323(
          fontSize: 30,
          fontWeight: FontWeight.w500,
        ),
        bodyLarge: GoogleFonts.vt323(
          fontSize: 28,
          color: Colors.grey,
        ),
        bodyMedium: GoogleFonts.vt323(
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

    return MaterialApp(
      title: 'Z1Racing',
      home: GameWidget<Z1RacingGame>(
        game: Z1RacingGame(),
        loadingBuilder: (context) => Center(
          child: Text(
            'Loading...',
            style: Theme.of(context).textTheme.displayLarge,
          ),
        ),
        overlayBuilderMap: {
          'menu': (_, game) => Menu(game),
          'game_over': (_, game) => GameOver(game),
        },
        initialActiveOverlays: const ['menu'],
      ),
      theme: theme,
    );
  }
}
