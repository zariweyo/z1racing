import 'package:firebase_auth/firebase_auth.dart';

class Z1User {
  final String uid;
  final String name;

  Z1User({required this.uid, required this.name});

  Z1User copyWith(String? uid, String? name) {
    return Z1User(
      uid: uid ?? this.uid,
      name: name ?? this.name,
    );
  }

  factory Z1User.fromMap(Map<String, dynamic> map) {
    return Z1User(
      uid: map['uid'] ?? "",
      name: map['name'] ?? "",
    );
  }

  factory Z1User.fromUser(User user) {
    return Z1User(
      uid: user.uid,
      name: user.displayName ?? "",
    );
  }

  dynamic toJson() {
    return {
      "uid": uid,
      "name": name,
    };
  }
}
