import 'dart:async';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:z1racing/models/z1track.dart';
import 'package:z1racing/models/z1user.dart';
import 'package:z1racing/models/z1user_race.dart';
import 'package:z1racing/models/z1version.dart';
import 'package:z1racing/repositories/firebase_firestore_repository.dart';
import 'package:z1racing/repositories/mock_data/data_repository_mock.dart';
import 'package:z1racing/repositories/track_repository_impl.dart';

class FirebaseFirestoreRepositoryMock implements FirebaseFirestoreRepository {
  List<Z1UserRace> dataMockUserRaces = [];
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
  Future<Z1Track?> getTrackByActivedDate({
    required DateTime dateTime,
    TrackRequestDirection direction = TrackRequestDirection.next,
  }) async {
    final tracks = (await DataRepositoryMock.getTracks())
        .sorted((a, b) => a.initialDatetime.compareTo(b.initialDatetime));
    if (tracks.isEmpty) {
      return null;
    }
    var index = tracks.indexWhere(
      (track) => track.initialDatetime.difference(dateTime).inSeconds >= 0,
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
          .where((element) => element.positionHash.compareTo(positionHash) <= 0)
          .toList();
    } else {
      list = list
          .where((element) => element.positionHash.compareTo(positionHash) > 0)
          .toList();
    }

    return list.sublist(0, min(list.length, limit));
  }

  @override
  Future<Z1Version> getVersion() async {
    return Z1Version();
  }

  @override
  Future init() async {}

  @override
  Future saveCompleteUserRace(Z1UserRace z1userRace) async {
    dataMockUserRaces.add(z1userRace);
  }

  @override
  Future updateTimeAndBestLapUserRace(Z1UserRace z1userRace) async {
    final index = dataMockUserRaces.indexWhere(
      (element) =>
          element.id == z1userRace.id && element.trackId == z1userRace.trackId,
    );
    if (index >= 0) {
      dataMockUserRaces[index] = z1userRace;
    }
  }

  @override
  Future updateTimeUserRace(Z1UserRace z1userRace) async {
    final index = dataMockUserRaces.indexWhere(
      (element) =>
          element.id == z1userRace.id && element.trackId == z1userRace.trackId,
    );
    if (index >= 0) {
      dataMockUserRaces[index] = z1userRace;
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
