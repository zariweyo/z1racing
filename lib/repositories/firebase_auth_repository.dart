// ignore_for_file: prefer_constructors_over_static_methods

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:z1racing/models/z1user.dart';
import 'package:z1racing/repositories/firebase_auth_repository_impl.dart';
import 'package:z1racing/repositories/firebase_auth_repository_mock.dart';

abstract class FirebaseAuthRepository {
  static final FirebaseAuthRepository _instanceImpl =
      FirebaseAuthRepositoryImpl();
  static final FirebaseAuthRepository _instanceMock =
      FirebaseAuthRepositoryMock();

  static FirebaseAuthRepository? _instance;

  factory FirebaseAuthRepository._({bool useMock = false}) {
    if (useMock) {
      _instance = _instanceMock;
    } else {
      _instance = _instanceImpl;
    }

    return _instance!;
  }

  static FirebaseAuthRepository get instance =>
      _instance ?? FirebaseAuthRepository._();

  static FirebaseAuthRepository get initInMockMode =>
      _instance ?? FirebaseAuthRepository._(useMock: true);

  PackageInfo get packageInfo;
  Z1User? get currentUser;
  ValueNotifier<Z1User?> currentUserNotifier = ValueNotifier<Z1User?>(null);

  Future init();
}
