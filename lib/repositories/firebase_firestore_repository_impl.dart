import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:z1racing/base/exceptions/duplicated_name_exception.dart';
import 'package:z1racing/base/utils/zip_utils.dart';
import 'package:z1racing/extensions/z1useravatar_extension.dart';
import 'package:z1racing/models/z1car_shadow.dart';
import 'package:z1racing/models/z1track.dart';
import 'package:z1racing/models/z1user.dart';
import 'package:z1racing/models/z1user_race.dart';
import 'package:z1racing/models/z1version.dart';
import 'package:z1racing/repositories/firebase_firestore_repository.dart';
import 'package:z1racing/repositories/track_repository_impl.dart';

class FirebaseFirestoreRepositoryImpl implements FirebaseFirestoreRepository {
  static const String userCol = 'users';
  static const String racesCol = 'races';
  static const String shadowRacesCol = 'shadowRaces';
  static const String trackDataCollection = 'trackData';
  static const String versionDocument = 'settings/version';

  final _streamChangeController = StreamController<Z1User?>.broadcast();

  @override
  ValueNotifier<Z1User?> currentUserNotifier = ValueNotifier<Z1User?>(null);

  static final FirebaseFirestoreRepositoryImpl _instance =
      FirebaseFirestoreRepositoryImpl._internal();

  factory FirebaseFirestoreRepositoryImpl() {
    return _instance;
  }

  FirebaseFirestoreRepositoryImpl._internal() {
    currentUserNotifier.addListener(() {
      _streamChangeController.add(currentUserNotifier.value);
    });
  }

  late Z1Version _z1version;
  @override
  Z1Version get z1version => _z1version;

  @override
  Z1User? get currentUser {
    if (currentUserNotifier.value != null) {
      return currentUserNotifier.value;
    } else if (FirebaseAuth.instance.currentUser != null) {
      return Z1User.fromUser(FirebaseAuth.instance.currentUser!);
    }
    return null;
  }

  CollectionReference<Map<String, dynamic>> get usersCol =>
      FirebaseFirestore.instance.collection(userCol);
  DocumentReference<Map<String, dynamic>> get userDoc =>
      usersCol.doc(currentUser?.uid);
  DocumentReference<Map<String, dynamic>> get versionDoc =>
      FirebaseFirestore.instance.doc(versionDocument);
  CollectionReference<Map<String, dynamic>> get trackDataCol =>
      FirebaseFirestore.instance.collection(trackDataCollection);

  DocumentReference<Map<String, dynamic>> shadowDoc({
    required String raceId,
    required String trackId,
    required String shadowId,
  }) =>
      trackDataCol
          .doc(trackId)
          .collection(racesCol)
          .doc(raceId)
          .collection(shadowRacesCol)
          .doc(shadowId);

  Query<Map<String, dynamic>> get raceGroupCol =>
      FirebaseFirestore.instance.collectionGroup(racesCol);

  @override
  Future init() async {
    assert(currentUser != null);
    await _loadUser(baseUser: currentUser!);
    final z1user = currentUser!;
    _z1version = await getVersion();
    currentUserNotifier.value = z1user;
    return userDoc.set(z1user.toJson());
  }

  @override
  Future saveCompleteUserRace(
    Z1UserRace z1userRace,
    Z1CarShadow? z1carShadow,
  ) async {
    final raceDoc = trackDataCol
        .doc(z1userRace.trackId)
        .collection(racesCol)
        .doc(z1userRace.id);
    await raceDoc.set(z1userRace.toJson());

    if (z1carShadow != null) {
      final shadowJsonData = z1carShadow.toJson();
      final bytesSize = ZipUtils.jsonSizeInBytes(shadowJsonData);
      debugPrint('--> bytesSize $bytesSize');

      if (bytesSize < 1000000) {
        return shadowDoc(
          raceId: z1userRace.id,
          trackId: z1userRace.trackId,
          shadowId: z1userRace.id,
        ).set(z1carShadow.toJson());
      }
    }
  }

  @override
  Future updateTimeAndBestLapUserRace(
    Z1UserRace z1userRace,
    Z1CarShadow? z1carShadow,
  ) async {
    final raceDoc = trackDataCol
        .doc(z1userRace.trackId)
        .collection(racesCol)
        .doc(z1userRace.id);

    await raceDoc.update(z1userRace.toUpdateTimeAndBestLapJson());

    if (z1carShadow != null) {
      final shadowJsonData = z1carShadow.toJson();
      final bytesSize = ZipUtils.jsonSizeInBytes(shadowJsonData);
      debugPrint('--> bytesSize $bytesSize');

      if (bytesSize < 1000000) {
        return shadowDoc(
          raceId: z1userRace.id,
          trackId: z1userRace.trackId,
          shadowId: z1userRace.id,
        ).set(z1carShadow.toJson());
      }
    }
  }

  @override
  Future updateTimeUserRace(
    Z1UserRace z1userRace,
    Z1CarShadow? z1carShadow,
  ) async {
    final raceDoc = trackDataCol
        .doc(z1userRace.trackId)
        .collection(racesCol)
        .doc(z1userRace.id);

    await raceDoc.update(z1userRace.toUpdateTimeJson());

    if (z1carShadow != null) {
      final shadowJsonData = z1carShadow.toJson();
      final bytesSize = ZipUtils.jsonSizeInBytes(shadowJsonData);
      debugPrint('--> bytesSize $bytesSize');

      if (bytesSize < 1000000) {
        return shadowDoc(
          raceId: z1userRace.id,
          trackId: z1userRace.trackId,
          shadowId: z1userRace.id,
        ).set(z1carShadow.toJson());
      }
    }
  }

  @override
  Future updateBestLapUserRace(Z1UserRace z1userRace) async {
    final raceDoc = trackDataCol
        .doc(z1userRace.trackId)
        .collection(racesCol)
        .doc(z1userRace.id);

    return raceDoc.update(z1userRace.toUpdateBestLapJson());
  }

  @override
  Future<Z1UserRace?> getUserRaceFromRemote(Z1UserRace z1userRace) async {
    final raceDoc = await trackDataCol
        .doc(z1userRace.trackId)
        .collection(racesCol)
        .doc(z1userRace.id)
        .get();
    if (!raceDoc.exists || raceDoc.data() == null) {
      return null;
    }
    return Z1UserRace.fromMap(raceDoc.data()!);
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

    final shadowDocSnap = await shadowDoc(
      raceId: z1UserRace.id,
      trackId: trackId,
      shadowId: z1UserRace.id,
    ).get();

    if (shadowDocSnap.exists && shadowDocSnap.data() != null) {
      return Z1CarShadow.fromMap(shadowDocSnap.data()!);
    }

    return null;
  }

  @override
  Future<Z1UserRace?> getUserRaceByTrackId({
    required String uid,
    required String trackId,
  }) async {
    if (trackId.isEmpty) {
      return null;
    }

    final raceDoc = trackDataCol
        .doc(trackId)
        .collection(racesCol)
        .where('uid', isEqualTo: uid)
        .limit(1);
    final qSnap = await raceDoc.get();
    if (qSnap.docs.isNotEmpty) {
      return Z1UserRace.fromMap(qSnap.docs.first.data());
    }

    return null;
  }

  @override
  Future<void> updateName(String newName) async {
    final query = await FirebaseFirestore.instance
        .collection(userCol)
        .where('name', isEqualTo: newName)
        .get();
    if (query.docs.isNotEmpty) {
      throw DuplicatedNameException();
    }

    final batch = FirebaseFirestore.instance.batch();
    batch.update(userDoc, {'name': newName});
    currentUserNotifier.value =
        currentUserNotifier.value?.copyWith(name: newName);
    (await raceGroupCol.where('uid', isEqualTo: currentUser?.uid).get())
        .docs
        .forEach((docSnap) {
      final userRace = Z1UserRace.fromMap(docSnap.data());
      userRace.metadata = userRace.metadata.copyWith(displayName: newName);
      batch.update(docSnap.reference, userRace.toUpdateMetadataJson());
    });
    await batch.commit();
    return FirebaseAuth.instance.currentUser?.updateDisplayName(newName);
  }

  @override
  Future<void> logEvent({
    required String name,
    Map<String, Object?>? parameters,
    AnalyticsCallOptions? callOptions,
  }) =>
      FirebaseAnalytics.instance.logEvent(
        name: name,
        parameters: parameters,
        callOptions: callOptions,
      );

  Future<void> _loadUser({required Z1User baseUser}) async {
    final docSnap = await userDoc.get();
    if (docSnap.exists) {
      currentUserNotifier.value = Z1User.fromMap(docSnap.data()!);
    } else {
      currentUserNotifier.value = baseUser.copyWith(z1Coins: 5);
    }
  }

  @override
  Future<void> addZ1Coins(int z1Coins) async {
    currentUserNotifier.value = currentUserNotifier.value?.copyWith(
      z1Coins: (currentUserNotifier.value?.z1Coins ?? 0) + z1Coins,
    );
    return userDoc.update({'z1Coins': currentUserNotifier.value?.z1Coins ?? 0});
  }

  @override
  Future<void> removeZ1Coins(int z1Coins) async {
    currentUserNotifier.value = currentUserNotifier.value?.copyWith(
      z1Coins: max((currentUserNotifier.value?.z1Coins ?? 0) - z1Coins, 0),
    );
    return userDoc.update({'z1Coins': currentUserNotifier.value?.z1Coins ?? 0});
  }

  @override
  Future<int> getUserRacePositionByTime({
    required String positionHash,
    required String trackId,
  }) async {
    if (trackId.isEmpty) {
      return 0;
    }
    final CollectionReference raceCol =
        trackDataCol.doc(trackId).collection(racesCol);
    final aggQuery = raceCol
        .where('positionHash', isLessThanOrEqualTo: positionHash)
        .count();

    final asnap = await aggQuery.get();

    return asnap.count;
  }

  @override
  Future<Z1Track> getTrackById({required String trackId}) async {
    final docSnap = await trackDataCol.doc(trackId).get();

    if (!docSnap.exists || docSnap.data() == null) {
      return Z1Track.empty();
    }
    return Z1Track.fromMap(docSnap.data()!);
  }

  @override
  Future<Z1User?> getUserByUid({required String uid}) async {
    final userSnap = await usersCol.doc(uid).get();
    if (userSnap.exists) {
      return Z1User.fromMap(userSnap.data()!);
    }

    return null;
  }

  @override
  Future<Z1Track?> getTrackByOrder({
    required int vorder,
    required List<int> acceptedVersions,
    TrackRequestDirection direction = TrackRequestDirection.next,
  }) async {
    var query =
        trackDataCol.where('version', whereIn: acceptedVersions).orderBy(
              'vorder',
              descending: [
                TrackRequestDirection.previous,
                TrackRequestDirection.last,
              ].contains(direction),
            );

    switch (direction) {
      case TrackRequestDirection.last:
        break;
      case TrackRequestDirection.previous:
        query = query.where(
          'vorder',
          isLessThan: vorder,
        );
        break;
      case TrackRequestDirection.next:
        query = query.where(
          'vorder',
          isGreaterThan: vorder,
        );
        break;
    }

    final qSnap = await query.limit(1).get();
    if (qSnap.docs.isNotEmpty) {
      return Z1Track.fromMap(qSnap.docs.first.data());
    }
    return null;
  }

  @override
  Future<List<Z1UserRace>> getUserRacesByTime({
    required String positionHash,
    required String trackId,
    bool descending = false,
    int limit = 10,
  }) async {
    if (trackId.isEmpty) {
      return [];
    }
    try {
      if (limit == 0) {
        return [];
      }
      final raceCol = trackDataCol.doc(trackId).collection(racesCol);
      var query =
          raceCol.orderBy('positionHash', descending: descending).limit(limit);

      if (descending) {
        query = query.where('positionHash', isLessThan: positionHash);
      } else {
        query = query.where('positionHash', isGreaterThan: positionHash);
      }

      final qsnap = await query.get();
      return qsnap.docs
          .map((snapDoc) => Z1UserRace.fromMap(snapDoc.data()))
          .toList();
    } on Exception catch (_) {
      rethrow;
    }
  }

  @override
  Future<Z1Version> getVersion() async {
    final docSnap = await versionDoc.get();
    if (!docSnap.exists) {
      return Z1Version();
    }

    return Z1Version.fromMap(docSnap.data() ?? {});
  }

  @override
  Future<void> updateAvatar(Z1UserAvatar avatar) async {
    userDoc.update({'z1UserAvatar': avatar.name});
    currentUserNotifier.value =
        currentUserNotifier.value?.copyWith(z1UserAvatar: avatar);
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
