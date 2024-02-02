import 'package:flutter/material.dart';
import 'package:z1racing/models/z1user.dart';

extension Z1UserAvatarExtension on Z1UserAvatar {
  String get _avatarPath => 'assets/images/avatars';
  String get avatarBasePath => '$_avatarPath/${name}_base.png';
  String get avatarWinPath => '$_avatarPath/${name}_win.png';
  String get avatarLostPath => '$_avatarPath/${name}_lost.png';
  MaterialColor get avatarBackgroundColor => switch (this) {
        Z1UserAvatar.girl_1 => Colors.pink,
        Z1UserAvatar.girl_2 => Colors.purple,
        Z1UserAvatar.boy_1 => Colors.green,
        Z1UserAvatar.boy_2 => Colors.blue,
      };
  String get avatarCar => switch (this) {
        Z1UserAvatar.girl_1 => 'pink_car.png',
        Z1UserAvatar.girl_2 => 'purple_car.png',
        Z1UserAvatar.boy_1 => 'green_car.png',
        Z1UserAvatar.boy_2 => 'blue_car.png',
      };
}
