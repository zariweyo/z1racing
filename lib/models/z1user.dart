import 'package:firebase_auth/firebase_auth.dart';

class Z1User {
  final String uid;
  final String name;
  final int z1Coins;

  Z1User({required this.uid, required this.name, this.z1Coins = 0});

  Z1User copyWith({String? uid, String? name, int? z1Coins}) {
    return Z1User(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      z1Coins: z1Coins ?? this.z1Coins,
    );
  }

  factory Z1User.fromMap(Map<String, dynamic> map) {
    return Z1User(
      uid: map['uid']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      z1Coins: int.parse(map['z1Coins']?.toString() ?? '0'),
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
    };
  }
}
