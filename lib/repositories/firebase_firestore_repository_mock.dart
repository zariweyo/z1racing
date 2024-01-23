import 'dart:async';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:z1racing/models/z1car_shadow.dart';
import 'package:z1racing/models/z1track.dart';
import 'package:z1racing/models/z1user.dart';
import 'package:z1racing/models/z1user_race.dart';
import 'package:z1racing/models/z1version.dart';
import 'package:z1racing/repositories/firebase_firestore_repository.dart';
import 'package:z1racing/repositories/mock_data/data_repository_mock.dart';
import 'package:z1racing/repositories/track_repository_impl.dart';

class FirebaseFirestoreRepositoryMock implements FirebaseFirestoreRepository {
  List<Z1UserRace> dataMockUserRaces = [];
  List<Z1CarShadow> dataMockCarShadows = [];
  final _currentUserNotifier = ValueNotifier<Z1User?>(null);
  final _streamChangeController = StreamController<Z1User?>.broadcast();

  FirebaseFirestoreRepositoryMock() {
    loadUserRacesFromMock();
    _currentUserNotifier.addListener(() {
      _streamChangeController.add(_currentUserNotifier.value);
    });
  }

  void loadUserRacesFromMock() {
    dataMockUserRaces = DataRepositoryMock.getUserRaces();
  }

  Future<List<Z1UserRace>> _mockRaces() async {
    return dataMockUserRaces.sorted((a, b) => a.time.compareTo(b.time));
  }

  Z1User _currentUser = DataRepositoryMock.getUser();

  @override
  Z1User? get currentUser => _currentUser;

  @override
  Future<Z1Track> getTrackById({required String trackId}) {
    return DataRepositoryMock.getTrack(trackId);
  }

  @override
  Future<Z1Track?> getTrackByOrder({
    required int order,
    TrackRequestDirection direction = TrackRequestDirection.next,
  }) async {
    final tracks = (await DataRepositoryMock.getTracks())
        .sorted((a, b) => a.order.compareTo(b.order));
    if (tracks.isEmpty) {
      return null;
    }
    var index = tracks.indexWhere(
      (track) => track.order >= order,
    );
    if (direction == TrackRequestDirection.previous) {
      index--;
    } else {
      index++;
    }

    if (index <= 0) {
      return tracks.first;
    } else if (index >= tracks.length) {
      return tracks.last;
    }
    return tracks[index];
  }

  @override
  Future<Z1UserRace?> getUserRaceByTrackId({
    required String uid,
    required String trackId,
  }) async {
    return dataMockUserRaces
        .where((element) => element.uid == uid && element.trackId == trackId)
        .firstOrNull;
  }

  @override
  Future<Z1UserRace?> getUserRaceFromRemote(Z1UserRace z1userRace) async {
    return dataMockUserRaces
        .where(
          (element) =>
              element.uid == z1userRace.uid && element.id == z1userRace.id,
        )
        .firstOrNull;
  }

  @override
  Future<int> getUserRacePositionByTime({
    required String positionHash,
    required String trackId,
  }) async {
    return dataMockUserRaces
        .where((element) => element.positionHash.compareTo(positionHash) <= 0)
        .length;
  }

  @override
  Future<void> logEvent({
    required String name,
    Map<String, Object?>? parameters,
    AnalyticsCallOptions? callOptions,
  }) async {}

  @override
  Future<List<Z1UserRace>> getUserRacesByTime({
    required String positionHash,
    required String trackId,
    bool descending = false,
    int limit = 10,
  }) async {
    var list = (await _mockRaces())
        .where((element) => element.trackId == trackId)
        .sorted((a, b) => a.positionHash.compareTo(b.positionHash));
    if (descending) {
      list = list.reversed
          .where((element) => element.positionHash.compareTo(positionHash) < 0)
          .toList();
    } else {
      list = list
          .where((element) => element.positionHash.compareTo(positionHash) > 0)
          .toList();
    }

    await Future.delayed(const Duration(seconds: 1));

    return list.sublist(0, min(list.length, limit));
  }

  @override
  Future<Z1Version> getVersion() async {
    return Z1Version();
  }

  @override
  Future init() async {}

  @override
  Future saveCompleteUserRace(
    Z1UserRace z1userRace,
    Z1CarShadow? z1carShadow,
  ) async {
    dataMockUserRaces.add(z1userRace);
    if (z1carShadow != null) {
      dataMockCarShadows.add(z1carShadow);
    }
  }

  void _updateCarShadow(Z1CarShadow? z1carShadow) {
    if (z1carShadow != null) {
      final index = dataMockCarShadows.indexWhere(
        (element) =>
            element.id == z1carShadow.id &&
            element.z1UserRaceId == z1carShadow.z1UserRaceId,
      );
      if (index >= 0) {
        dataMockCarShadows[index] = z1carShadow;
      }
    }
  }

  @override
  Future<Z1CarShadow?> getCarShadowByTrackAndUid({
    required String uid,
    required String trackId,
  }) async {
    final z1UserRace = await getUserRaceByTrackId(uid: uid, trackId: trackId);
    if (z1UserRace == null) {
      return null;
    }
    return dataMockCarShadows.firstWhereOrNull(
      (element) => element.z1UserRaceId == z1UserRace.id,
    );
  }

  @override
  Future updateTimeAndBestLapUserRace(
    Z1UserRace z1userRace,
    Z1CarShadow? z1carShadow,
  ) async {
    final index = dataMockUserRaces.indexWhere(
      (element) =>
          element.id == z1userRace.id && element.trackId == z1userRace.trackId,
    );
    if (index >= 0) {
      dataMockUserRaces[index] = z1userRace;
      _updateCarShadow(z1carShadow);
    }
  }

  @override
  Future updateTimeUserRace(
    Z1UserRace z1userRace,
    Z1CarShadow? z1carShadow,
  ) async {
    final index = dataMockUserRaces.indexWhere(
      (element) =>
          element.id == z1userRace.id && element.trackId == z1userRace.trackId,
    );
    if (index >= 0) {
      dataMockUserRaces[index] = z1userRace;
      _updateCarShadow(z1carShadow);
    }
  }

  @override
  Future updateBestLapUserRace(Z1UserRace z1userRace) async {
    final index = dataMockUserRaces.indexWhere(
      (element) =>
          element.id == z1userRace.id && element.trackId == z1userRace.trackId,
    );
    if (index >= 0) {
      dataMockUserRaces[index] = z1userRace;
    }
  }

  @override
  Future<void> updateName(String newName) async {
    _currentUser = _currentUser.copyWith(name: newName);
    _currentUserNotifier.value = _currentUser;
  }

  @override
  Future<void> addZ1Coins(int z1Coins) async {
    _currentUser =
        _currentUser.copyWith(z1Coins: _currentUser.z1Coins + z1Coins);
    _currentUserNotifier.value = _currentUser;
  }

  @override
  Future<void> removeZ1Coins(int z1Coins) async {
    _currentUser =
        _currentUser.copyWith(z1Coins: max(_currentUser.z1Coins - z1Coins, 0));
    _currentUserNotifier.value = _currentUser;
  }

  @override
  Z1Version get z1version => Z1Version();

  @override
  Stream<Z1User?> get z1UserStream => _streamChangeController.stream;
}
