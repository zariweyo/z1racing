import 'dart:async';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:z1racing/base/utils/zip_utils.dart';
import 'package:z1racing/data/mock_data/data_repository_mock.dart';
import 'package:z1racing/domain/entities/z1car_shadow.dart';
import 'package:z1racing/domain/entities/z1season.dart';
import 'package:z1racing/domain/entities/z1track.dart';
import 'package:z1racing/domain/entities/z1user.dart';
import 'package:z1racing/domain/entities/z1user_award.dart';
import 'package:z1racing/domain/entities/z1user_race.dart';
import 'package:z1racing/domain/entities/z1version.dart';
import 'package:z1racing/domain/repositories/firebase_firestore_repository.dart';
import 'package:z1racing/extensions/z1useravatar_extension.dart';

class FirebaseFirestoreRepositoryMock implements FirebaseFirestoreRepository {
  List<Z1UserRace> dataMockUserRaces = [];
  List<Map<String, dynamic>> dataMockCarShadows = [];
  final _streamChangeController = StreamController<Z1User?>.broadcast();
  late List<Z1User> userList;

  Map<String, Z1Season> cacheSeasons = {};
  Map<String, Z1Track> cacheTracks = {};

  @override
  ValueNotifier<Z1User?> currentUserNotifier = ValueNotifier<Z1User?>(null);

  FirebaseFirestoreRepositoryMock() {
    loadFromMock();
    currentUserNotifier.addListener(() {
      _streamChangeController.add(currentUserNotifier.value);
    });
  }

  void loadFromMock() {
    dataMockUserRaces = DataRepositoryMock.getUserRaces();
    userList = DataRepositoryMock.getUsers();
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
  Future<Z1User?> getUserByUid({required String uid}) async {
    return userList.firstWhereOrNull((element) => element.uid == uid);
  }

  @override
  Future<List<Z1Track>> getTracksByIds({required List<String> trackIds}) async {
    if (trackIds.every((elemento) => cacheTracks.keys.contains(elemento))) {
      return cacheTracks.values
          .where((element) => trackIds.contains(element.trackId))
          .toList();
    }
    final tracks = (await DataRepositoryMock.getTracks())
        .where((element) => trackIds.contains(element.trackId))
        .sorted(
          (a, b) => trackIds.indexOf(a.trackId).compareTo(
                trackIds.indexOf(b.trackId),
              ),
        );
    cacheTracks.addAll({for (final item in tracks) item.trackId: item});

    return tracks;
  }

  @override
  Future<List<Z1Season>> getSeasons() async {
    if (cacheSeasons.isNotEmpty) {
      return cacheSeasons.values.toList();
    }
    final seasons = await DataRepositoryMock.getSeasons();

    cacheSeasons = {for (final item in seasons) item.id: item};
    return seasons;
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
      final shadowJsonData = z1carShadow.toJson();
      final bytesSize = ZipUtils.jsonSizeInBytes(shadowJsonData);
      debugPrint('--> Shadow $bytesSize');
      dataMockCarShadows.add(z1carShadow.toJson());
    }
  }

  void _updateCarShadow(Z1CarShadow? z1carShadow) {
    if (z1carShadow != null) {
      final index =
          dataMockCarShadows.map(Z1CarShadow.fromMap).toList().indexWhere(
                (element) =>
                    element.id == z1carShadow.id &&
                    element.z1UserRaceId == z1carShadow.z1UserRaceId,
              );
      if (index >= 0) {
        dataMockCarShadows[index] = z1carShadow.toJson();
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
    return dataMockCarShadows
        .map(Z1CarShadow.fromMap)
        .toList()
        .firstWhereOrNull(
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
    currentUserNotifier.value = _currentUser;
  }

  @override
  Future<void> addZ1UserAward(Z1UserAward z1UserAward) async {
    _currentUser.awards[z1UserAward.trackId] = z1UserAward;
    _currentUser = _currentUser.copyWith(awards: _currentUser.awards);
    currentUserNotifier.value = _currentUser;
  }

  @override
  Future<void> addZ1Coins(int z1Coins) async {
    _currentUser =
        _currentUser.copyWith(z1Coins: _currentUser.z1Coins + z1Coins);
    currentUserNotifier.value = _currentUser;
  }

  @override
  Future<void> removeZ1Coins(int z1Coins) async {
    _currentUser =
        _currentUser.copyWith(z1Coins: max(_currentUser.z1Coins - z1Coins, 0));
    currentUserNotifier.value = _currentUser;
  }

  @override
  Z1Version get z1version => Z1Version();

  @override
  Future<void> updateAvatar(Z1UserAvatar avatar) async {
    _currentUser = _currentUser.copyWith(z1UserAvatar: avatar);
    final index =
        userList.indexWhere((element) => element.uid == _currentUser.uid);
    if (index >= 0) {
      userList[index] = _currentUser;
    }
    currentUserNotifier.value = _currentUser;
  }

  @override
  MaterialColor get avatarColor =>
      currentUser?.z1UserAvatar.avatarBackgroundColor ??
      Z1UserAvatar.values.first.avatarBackgroundColor;

  @override
  String get avatarCar =>
      currentUser?.z1UserAvatar.avatarCar ??
      Z1UserAvatar.values.first.avatarCar;
}
