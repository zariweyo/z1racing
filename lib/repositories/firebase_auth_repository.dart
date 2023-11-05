import 'dart:async';
import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

class FirebaseAuthRepository {
  static final FirebaseAuthRepository _instance =
      FirebaseAuthRepository._internal();

  factory FirebaseAuthRepository() {
    return _instance;
  }

  FirebaseAuthRepository._internal();

  User? get currentUser => FirebaseAuth.instance.currentUser;
  late PackageInfo packageInfo;
  ValueNotifier<User?> currentUserNotifier = ValueNotifier<User?>(null);

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

    packageInfo = await PackageInfo.fromPlatform();
  }

  StreamSubscription<User?>? changeUserSubscription;

  void dispose() {
    changeUserSubscription?.cancel();
  }

  _userChange(User? userModified) {
    currentUserNotifier.value = userModified;
  }
}
