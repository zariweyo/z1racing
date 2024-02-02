import 'package:collection/collection.dart';
import 'package:firebase_auth/firebase_auth.dart';

enum Z1UserAvatar {
  girl_1,
  girl_2,
  boy_1,
  boy_2,
}

class Z1User {
  final String uid;
  final String name;
  final Z1UserAvatar z1UserAvatar;
  final int z1Coins;

  Z1User({
    required this.uid,
    required this.name,
    this.z1Coins = 0,
    this.z1UserAvatar = Z1UserAvatar.girl_1,
  });

  Z1User copyWith({
    String? uid,
    String? name,
    int? z1Coins,
    Z1UserAvatar? z1UserAvatar,
  }) {
    return Z1User(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      z1Coins: z1Coins ?? this.z1Coins,
      z1UserAvatar: z1UserAvatar ?? this.z1UserAvatar,
    );
  }

  factory Z1User.fromMap(Map<String, dynamic> map) {
    return Z1User(
      uid: map['uid']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      z1Coins: int.parse(map['z1Coins']?.toString() ?? '0'),
      z1UserAvatar: Z1UserAvatar.values.firstWhereOrNull(
            (element) => element.name == (map['z1UserAvatar'] ?? ''),
          ) ??
          Z1UserAvatar.girl_1,
    );
  }

  factory Z1User.fromUser(User user) {
    return Z1User(uid: user.uid, name: user.displayName ?? '');
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': name,
      'z1Coins': z1Coins,
      'z1UserAvatar': z1UserAvatar.name,
    };
  }
}
