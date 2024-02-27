// ignore_for_file: prefer_constructors_over_static_methods

import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:z1racing/data/firebase_firestore_repository_impl.dart';
import 'package:z1racing/data/firebase_firestore_repository_mock.dart';
import 'package:z1racing/domain/entities/z1car_shadow.dart';
import 'package:z1racing/domain/entities/z1season.dart';
import 'package:z1racing/domain/entities/z1track.dart';
import 'package:z1racing/domain/entities/z1user.dart';
import 'package:z1racing/domain/entities/z1user_award.dart';
import 'package:z1racing/domain/entities/z1user_race.dart';
import 'package:z1racing/domain/entities/z1version.dart';
import 'package:z1racing/extensions/z1useravatar_extension.dart';

abstract class FirebaseFirestoreRepository {
  static final FirebaseFirestoreRepository _instanceImpl =
      FirebaseFirestoreRepositoryImpl();
  static final FirebaseFirestoreRepository _instanceMock =
      FirebaseFirestoreRepositoryMock();

  static FirebaseFirestoreRepository? _instance;

  factory FirebaseFirestoreRepository._({bool useMock = false}) {
    if (useMock) {
      _instance = _instanceMock;
    } else {
      _instance = _instanceImpl;
    }

    return _instance!;
  }

  static FirebaseFirestoreRepository get instance =>
      _instance ?? FirebaseFirestoreRepository._();

  static FirebaseFirestoreRepository get initInMockMode =>
      _instance ?? FirebaseFirestoreRepository._(useMock: true);

  Future init();
  Future saveCompleteUserRace(Z1UserRace z1userRace, Z1CarShadow? z1carShadow);
  Future updateTimeAndBestLapUserRace(
    Z1UserRace z1userRace,
    Z1CarShadow? z1carShadow,
  );
  Future updateTimeUserRace(Z1UserRace z1userRace, Z1CarShadow? z1carShadow);
  Future updateBestLapUserRace(Z1UserRace z1userRace);
  Future<Z1UserRace?> getUserRaceFromRemote(Z1UserRace z1userRace);
  Future<Z1UserRace?> getUserRaceByTrackId({
    required String uid,
    required String trackId,
  });
  Future<Z1User?> getUserByUid({required String uid});
  Future<void> updateName(String newName);
  Future<void> updateAvatar(Z1UserAvatar avatar);
  Future<void> addZ1Coins(int z1Coins);
  Future<void> addZ1UserAward(Z1UserAward z1UserAward);
  Future<void> removeZ1Coins(int z1Coins);
  Future<int> getUserRacePositionByTime({
    required String positionHash,
    required String trackId,
  });
  Future<Z1Track> getTrackById({required String trackId});
  Future<List<Z1Season>> getSeasons();
  Future<Z1CarShadow?> getCarShadowByTrackAndUid({
    required String uid,
    required String trackId,
  });
  Future<List<Z1Track>> getTracksByIds({required List<String> trackIds});
  Future<List<Z1UserRace>> getUserRacesByTime({
    required String positionHash,
    required String trackId,
    bool descending = false,
    int limit = 10,
  });
  Future<void> logEvent({
    required String name,
    Map<String, Object?>? parameters,
    AnalyticsCallOptions? callOptions,
  });
  Future<Z1Version> getVersion();
  Z1Version get z1version;
  Z1User? get currentUser;
  ValueNotifier<Z1User?> currentUserNotifier = ValueNotifier<Z1User?>(null);
  MaterialColor get avatarColor =>
      Z1UserAvatar.values.first.avatarBackgroundColor;
  String get avatarCar => Z1UserAvatar.values.first.avatarCar;
}
