import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseAuthRepository {
  static final FirebaseAuthRepository _instance =
      FirebaseAuthRepository._internal();

  factory FirebaseAuthRepository() {
    return _instance;
  }

  FirebaseAuthRepository._internal() {
    init();
  }

  init() async {
    User? user = FirebaseAuth.instance.currentUser;
    changeUserSubscription =
        FirebaseAuth.instance.userChanges().listen(_userChange);
    if (user == null) {
      FirebaseAuth.instance.signInAnonymously();
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
