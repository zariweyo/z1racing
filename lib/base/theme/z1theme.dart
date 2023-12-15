import 'package:flutter/material.dart';

class Z1Theme {
  ThemeData get themeData => ThemeData(
        textTheme: const TextTheme(
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
            bodySmall: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),),
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
}
