import 'package:flutter/services.dart';
import 'package:z1racing/models/z1control.dart';

extension LogicalKeyboardKeyExtension on LogicalKeyboardKey {
  Z1Control toZ1Control() {
    switch (this) {
      case LogicalKeyboardKey.arrowUp:
        return Z1Control.run;
      case LogicalKeyboardKey.arrowDown:
        return Z1Control.stop;
      case LogicalKeyboardKey.arrowLeft:
        return Z1Control.left;
      case LogicalKeyboardKey.arrowRight:
        return Z1Control.right;
      default:
        return Z1Control.none;
    }
  }
}
