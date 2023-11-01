import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:z1racing/game/repositories/models/z1user.dart';
import 'package:z1racing/game/repositories/models/z1user_race.dart';

class FirebaseFirestoreRepository {
  static const String USERCOL = "users";
  static const String USERRACESCOL = "races";

  static final FirebaseFirestoreRepository _instance =
      FirebaseFirestoreRepository._internal();

  factory FirebaseFirestoreRepository() {
    return _instance;
  }

  FirebaseFirestoreRepository._internal();

  User? get currentUser => FirebaseAuth.instance.currentUser;

  CollectionReference get usersCol =>
      FirebaseFirestore.instance.collection(USERCOL);
  DocumentReference get userDoc => usersCol.doc(currentUser?.uid);
  CollectionReference get userRaceCol => userDoc.collection(USERRACESCOL);

  Future init() async {
    assert(currentUser != null);

    Z1User z1user = Z1User.fromUser(currentUser!);
    return userDoc.set(z1user.toJson());
  }

  Future saveUserRace(Z1UserRace z1userRace) async {
    DocumentReference raceDoc = userRaceCol.doc(z1userRace.id);
    DocumentSnapshot docSnap = await raceDoc.get();
    bool insert = true;
    if (docSnap.exists) {
      Z1UserRace currentRace =
          Z1UserRace.fromMap(docSnap.data() as Map<String, dynamic>);
      if (currentRace.time < z1userRace.time) {
        insert = false;
      }
    }

    if (insert) {
      return raceDoc.set(z1userRace.toJson());
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
          .orderBy("time", descending: descending)
          .limit(limit);

      if (descending) {
        query = query.where("time", isLessThanOrEqualTo: time.inMilliseconds);
      } else {
        query = query.where("time", isGreaterThan: time.inMilliseconds);
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
    int position = await getUserRacePositionByTime(time: time, raceId: raceId);
    List<Z1UserRace> z1userRacesResult = await getUserRacesByTime(
        time: time, raceId: raceId, descending: true, limit: 5);
    z1userRacesResult.addAll(await getUserRacesByTime(
        time: time,
        raceId: raceId,
        descending: false,
        limit: 10 - z1userRacesResult.length));

    return z1userRacesResult.sorted((a, b) => a.time.compareTo(b.time));
  }
}
