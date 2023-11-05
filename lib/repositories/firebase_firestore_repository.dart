import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:z1racing/models/z1user.dart';
import 'package:z1racing/models/z1user_race.dart';
import 'package:z1racing/models/z1version.dart';

class FirebaseFirestoreRepository {
  static const String USERCOL = "users";
  static const String USERRACESCOL = "races";
  static const String VERSIONDOC = "settings/version";

  static final FirebaseFirestoreRepository _instance =
      FirebaseFirestoreRepository._internal();

  factory FirebaseFirestoreRepository() {
    return _instance;
  }

  FirebaseFirestoreRepository._internal();

  late Z1Version _z1version;
  Z1Version get z1version => _z1version;

  User? get currentUser => FirebaseAuth.instance.currentUser;

  CollectionReference get usersCol =>
      FirebaseFirestore.instance.collection(USERCOL);
  DocumentReference get userDoc => usersCol.doc(currentUser?.uid);
  DocumentReference get versionDoc =>
      FirebaseFirestore.instance.doc(VERSIONDOC);
  CollectionReference get userRaceCol => userDoc.collection(USERRACESCOL);

  Future init() async {
    assert(currentUser != null);

    Z1User z1user = Z1User.fromUser(currentUser!);
    _z1version = await getVersion();
    return userDoc.set(z1user.toJson());
  }

  Future saveUserRace(Z1UserRace z1userRace) async {
    DocumentReference raceDoc = userRaceCol.doc(z1userRace.id);
    DocumentSnapshot docSnap = await raceDoc.get();
    bool insert = true;
    bool updateBestLap = true;
    if (docSnap.exists) {
      Z1UserRace currentRace =
          Z1UserRace.fromMap(docSnap.data() as Map<String, dynamic>);
      if (currentRace.time < z1userRace.time) {
        insert = false;
      } else if (z1userRace.bestLapTime < currentRace.bestLapTime) {
        updateBestLap = true;
      }
    }

    if (insert) {
      return raceDoc.set(z1userRace.toJson());
    } else if (updateBestLap) {
      return raceDoc.update(z1userRace.toUpdateBestLapJson());
    }
  }

  Future<Z1UserRace?> getUserRaceByIds(
      {required String uid, required String raceId}) async {
    DocumentSnapshot snapDoc =
        await usersCol.doc(uid).collection(USERRACESCOL).doc(raceId).get();
    if (snapDoc.exists) {
      return Z1UserRace.fromMap(snapDoc.data() as Map<String, dynamic>);
    }

    return null;
  }

  Future<void> updateName(String newName) async {
    WriteBatch _batch = FirebaseFirestore.instance.batch();
    _batch.update(userDoc, {"name": newName});
    (await userRaceCol.get()).docs.forEach((qSnap) {
      Z1UserRace userRace =
          Z1UserRace.fromMap(qSnap.data() as Map<String, dynamic>);
      userRace.metadata = userRace.metadata.copyWith(displayName: newName);
      print(userRace.toJson());
      _batch.update(qSnap.reference, userRace.toUpdateMetadataJson());
    });
    await _batch.commit();
    return FirebaseAuth.instance.currentUser?.updateDisplayName(newName);
  }

  Future<int> getUserRacePositionByTime(
      {required Duration time, required String raceId}) async {
    AggregateQuery aggQuery = FirebaseFirestore.instance
        .collectionGroup(USERRACESCOL)
        .where("id", isEqualTo: raceId)
        .where("time", isLessThanOrEqualTo: time.inMilliseconds)
        .count();

    AggregateQuerySnapshot asnap = await aggQuery.get();

    return asnap.count;
  }

  Future<List<Z1UserRace>> getUserRacesByTime(
      {required Duration time,
      required String raceId,
      bool descending = false,
      int limit = 10}) async {
    try {
      Query query = FirebaseFirestore.instance
          .collectionGroup(USERRACESCOL)
          .where("id", isEqualTo: raceId)
          .orderBy("positionHash", descending: descending)
          .limit(limit);

      if (descending) {
        query = query.where("positionHash",
            isLessThanOrEqualTo: time.inMilliseconds);
      } else {
        query = query.where("positionHash", isGreaterThan: time.inMilliseconds);
      }

      QuerySnapshot qsnap = await query.get();
      return qsnap.docs
          .map((snapDoc) =>
              Z1UserRace.fromMap(snapDoc.data() as Map<String, dynamic>))
          .toList();
    } catch (ex) {
      throw ex;
    }
  }

  Future<List<Z1UserRace>> getUserRaces(
      {required String uid, required String raceId}) async {
    Duration time = Duration();
    Z1UserRace? z1userRace = await getUserRaceByIds(uid: uid, raceId: raceId);
    if (z1userRace != null) {
      time = z1userRace.time;
    }
    // int position = await getUserRacePositionByTime(time: time, raceId: raceId);
    List<Z1UserRace> z1userRacesResult = await getUserRacesByTime(
        time: time, raceId: raceId, descending: true, limit: 10);
    z1userRacesResult.addAll(await getUserRacesByTime(
        time: time,
        raceId: raceId,
        descending: false,
        limit: 20 - z1userRacesResult.length));

    return z1userRacesResult.sorted((a, b) => a.time.compareTo(b.time));
  }

  Future<Z1Version> getVersion() async {
    DocumentSnapshot docSnap = await versionDoc.get();
    if (!docSnap.exists) {
      return Z1Version();
    }

    return Z1Version.fromMap(docSnap.data() as Map<String, dynamic>);
  }
}
