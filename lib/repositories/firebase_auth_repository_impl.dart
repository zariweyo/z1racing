import 'dart:async';
import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:z1racing/models/z1user.dart';
import 'package:z1racing/repositories/firebase_auth_repository.dart';

class FirebaseAuthRepositoryImpl implements FirebaseAuthRepository {
  static final FirebaseAuthRepositoryImpl _instance =
      FirebaseAuthRepositoryImpl._internal();

  factory FirebaseAuthRepositoryImpl() {
    return _instance;
  }

  FirebaseAuthRepositoryImpl._internal();

  late PackageInfo _packageInfo;
  @override
  Z1User? get currentUser => FirebaseAuth.instance.currentUser != null
      ? Z1User.fromUser(FirebaseAuth.instance.currentUser!)
      : null;
  @override
  PackageInfo get packageInfo => _packageInfo;
  @override
  ValueNotifier<Z1User?> currentUserNotifier = ValueNotifier<Z1User?>(null);

  @override
  Future init() async {
    changeUserSubscription =
        FirebaseAuth.instance.userChanges().listen(_userChange);
    if (currentUser == null) {
      await FirebaseAuth.instance.signInAnonymously();
    }
    if ((currentUser?.name ?? '').isEmpty) {
      await FirebaseAuth.instance.currentUser
          ?.updateDisplayName('USER_${Random().nextInt(100000000)}');
    }

    _packageInfo = await PackageInfo.fromPlatform();
  }

  StreamSubscription<User?>? changeUserSubscription;

  void dispose() {
    changeUserSubscription?.cancel();
  }

  void _userChange(User? userModified) {
    currentUserNotifier.value =
        userModified != null ? Z1User.fromUser(userModified) : null;
  }
}
