import 'dart:async';
import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseAuthRepository {
  static final FirebaseAuthRepository _instance =
      FirebaseAuthRepository._internal();

  factory FirebaseAuthRepository() {
    return _instance;
  }

  FirebaseAuthRepository._internal();

  User? get currentUser => FirebaseAuth.instance.currentUser;

  Future init() async {
    changeUserSubscription =
        FirebaseAuth.instance.userChanges().listen(_userChange);
    if (currentUser == null) {
      await FirebaseAuth.instance.signInAnonymously();
    }
    if ((currentUser?.displayName ?? "").isEmpty) {
      await FirebaseAuth.instance.currentUser
          ?.updateDisplayName("USER_" + Random().nextInt(100000000).toString());
    }
  }

  StreamSubscription<User?>? changeUserSubscription;

  void dispose() {
    changeUserSubscription?.cancel();
  }

  _userChange(event) {
    print(event);
  }
}
