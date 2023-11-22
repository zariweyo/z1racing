import 'dart:async';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:z1racing/models/z1user.dart';
import 'package:z1racing/repositories/mock_data/data_repository_mock.dart';
import 'package:z1racing/repositories/firebase_auth_repository.dart';

class FirebaseAuthRepositoryMock implements FirebaseAuthRepository {
  static final FirebaseAuthRepositoryMock _instance =
      FirebaseAuthRepositoryMock._internal();

  factory FirebaseAuthRepositoryMock() {
    return _instance;
  }

  FirebaseAuthRepositoryMock._internal();

  late PackageInfo _packageInfo;
  @override
  Z1User? get currentUser => DataRepositoryMock.getUser();
  PackageInfo get packageInfo => _packageInfo;
  ValueNotifier<Z1User?> currentUserNotifier = ValueNotifier<Z1User?>(null);

  Future init() async {
    _packageInfo = await PackageInfo.fromPlatform();
  }
}
