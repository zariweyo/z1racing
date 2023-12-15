// ignore_for_file: prefer_constructors_over_static_methods

import 'dart:async';

import 'package:z1racing/models/z1track.dart';
import 'package:z1racing/models/z1user.dart';
import 'package:z1racing/models/z1user_race.dart';
import 'package:z1racing/models/z1version.dart';
import 'package:z1racing/repositories/firebase_firestore_repository_impl.dart';
import 'package:z1racing/repositories/firebase_firestore_repository_mock.dart';
import 'package:z1racing/repositories/track_repository_impl.dart';

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
  Future saveCompleteUserRace(Z1UserRace z1userRace);
  Future updateTimeAndBestLapUserRace(Z1UserRace z1userRace);
  Future updateTimeUserRace(Z1UserRace z1userRace);
  Future updateBestLapUserRace(Z1UserRace z1userRace);
  Future<Z1UserRace?> getUserRaceFromRemote(Z1UserRace z1userRace);
  Future<Z1UserRace?> getUserRaceByTrackId({
    required String uid,
    required String trackId,
  });
  Future<void> updateName(String newName);
  Future<void> addZ1Coins(int z1Coins);
  Future<void> removeZ1Coins(int z1Coins);
  Future<int> getUserRacePositionByTime({
    required String positionHash,
    required String trackId,
  });
  Future<Z1Track> getTrackById({required String trackId});
  Future<Z1Track?> getTrackByActivedDate({
    required DateTime dateTime,
    TrackRequestDirection direction = TrackRequestDirection.next,
  });
  Future<List<Z1UserRace>> getUserRacesByTime({
    required String positionHash,
    required String trackId,
    bool descending = false,
    int limit = 10,
  });
  Future<Z1Version> getVersion();
  Z1Version get z1version;
  Z1User? get currentUser;
  Stream<Z1User?> get z1UserStream;
}
