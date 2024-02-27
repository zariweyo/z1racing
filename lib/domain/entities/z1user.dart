import 'package:collection/collection.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:z1racing/domain/entities/z1user_award.dart';

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
  final Map<String, Z1UserAward> awards;

  Z1User({
    required this.uid,
    required this.name,
    this.z1Coins = 0,
    this.z1UserAvatar = Z1UserAvatar.girl_1,
    this.awards = const {},
  });

  Z1User copyWith({
    String? uid,
    String? name,
    int? z1Coins,
    Z1UserAvatar? z1UserAvatar,
    Map<String, Z1UserAward>? awards,
  }) {
    return Z1User(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      z1Coins: z1Coins ?? this.z1Coins,
      z1UserAvatar: z1UserAvatar ?? this.z1UserAvatar,
      awards: awards ?? this.awards,
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
      awards: map['awards'] != null
          ? (map['awards'] as Map<String, dynamic>).map(
              (key, value) => MapEntry<String, Z1UserAward>(
                key,
                Z1UserAward.fromMap(value as Map<String, dynamic>),
              ),
            )
          : {},
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
      'awards': awards
          .map((key, value) => MapEntry<String, dynamic>(key, value.toJson())),
    };
  }
}
