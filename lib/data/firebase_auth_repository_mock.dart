import 'dart:async';

import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:z1racing/data/mock_data/data_repository_mock.dart';
import 'package:z1racing/domain/entities/z1user.dart';
import 'package:z1racing/domain/repositories/firebase_auth_repository.dart';

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
  @override
  PackageInfo get packageInfo => _packageInfo;
  @override
  ValueNotifier<Z1User?> currentUserNotifier = ValueNotifier<Z1User?>(null);

  @override
  Future init() async {
    _packageInfo = await PackageInfo.fromPlatform();
  }
}
