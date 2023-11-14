import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:z1racing/models/z1track_races.dart';
import 'package:z1racing/models/z1user.dart';
import 'package:z1racing/models/z1user_race.dart';
import 'package:z1racing/models/z1version.dart';

class FirebaseFirestoreRepository {
  static const String USERCOL = "users";
  static const String RACESCOL = "races";
  static const String TRACKDATACOL = "trackData";
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

  CollectionReference<Map<String, dynamic>> get usersCol =>
      FirebaseFirestore.instance.collection(USERCOL);
  DocumentReference<Map<String, dynamic>> get userDoc =>
      usersCol.doc(currentUser?.uid);
  DocumentReference<Map<String, dynamic>> get versionDoc =>
      FirebaseFirestore.instance.doc(VERSIONDOC);
  CollectionReference<Map<String, dynamic>> get trackDataCol =>
      FirebaseFirestore.instance.collection(TRACKDATACOL);

  Query<Map<String, dynamic>> get raceGroupCol =>
      FirebaseFirestore.instance.collectionGroup(RACESCOL);

  Future init() async {
    assert(currentUser != null);

    Z1User z1user = Z1User.fromUser(currentUser!);
    _z1version = await getVersion();
    return userDoc.set(z1user.toJson());
  }

  Future saveUserRace(Z1UserRace z1userRace) async {
    DocumentReference<Map<String, dynamic>> raceDoc = trackDataCol
        .doc(z1userRace.trackId)
        .collection(RACESCOL)
        .doc(z1userRace.id);
    DocumentSnapshot<Map<String, dynamic>> docSnap = await raceDoc.get();
    bool insert = true;
    bool updateBestLap = false;
    if (docSnap.exists) {
      Z1UserRace currentRace = Z1UserRace.fromMap(docSnap.data() ?? {});

      if (currentRace.time < z1userRace.time) {
        currentRace = currentRace.copyWith(
            bestLap: z1userRace.bestLapTime < currentRace.bestLapTime
                ? z1userRace.bestLapTime
                : currentRace.bestLapTime);
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
      {required String uid, required String trackId}) async {
    Query<Map<String, dynamic>> raceDoc = trackDataCol
        .doc(trackId)
        .collection(RACESCOL)
        .where("uid", isEqualTo: uid)
        .limit(1);
    QuerySnapshot<Map<String, dynamic>> qSnap = await raceDoc.get();
    if (qSnap.docs.length > 0) {
      return Z1UserRace.fromMap(qSnap.docs.first.data());
    }

    return null;
  }

  Future<void> updateName(String newName) async {
    WriteBatch _batch = FirebaseFirestore.instance.batch();
    _batch.update(userDoc, {"name": newName});
    (await raceGroupCol.where("uid", isEqualTo: currentUser?.uid).get())
        .docs
        .forEach((docSnap) {
      Z1UserRace userRace = Z1UserRace.fromMap(docSnap.data());
      userRace.metadata = userRace.metadata.copyWith(displayName: newName);
      _batch.update(docSnap.reference, userRace.toUpdateMetadataJson());
    });
    await _batch.commit();
    return FirebaseAuth.instance.currentUser?.updateDisplayName(newName);
  }

  Future<int> getUserRacePositionByTime(
      {required int positionHash, required String trackId}) async {
    CollectionReference raceCol =
        trackDataCol.doc(trackId).collection(RACESCOL);
    AggregateQuery aggQuery = raceCol
        .where("positionHash", isLessThanOrEqualTo: positionHash)
        .count();

    AggregateQuerySnapshot asnap = await aggQuery.get();

    return asnap.count;
  }

  Future<List<Z1UserRace>> getUserRacesByTime(
      {required int positionHash,
      required String trackId,
      bool descending = false,
      int limit = 10}) async {
    try {
      CollectionReference<Map<String, dynamic>> raceCol =
          trackDataCol.doc(trackId).collection(RACESCOL);
      Query<Map<String, dynamic>> query =
          raceCol.orderBy("positionHash", descending: descending).limit(limit);

      if (descending) {
        query = query.where("positionHash", isLessThanOrEqualTo: positionHash);
      } else {
        query = query.where("positionHash", isGreaterThan: positionHash);
      }

      QuerySnapshot<Map<String, dynamic>> qsnap = await query.get();
      return qsnap.docs
          .map((snapDoc) => Z1UserRace.fromMap(snapDoc.data()))
          .toList();
    } catch (ex) {
      throw ex;
    }
  }

  Future<Z1TrackRaces> getUserRaces(
      {required String uid, required String trackId}) async {
    int positionHash = 0;
    Z1UserRace? z1userRace = await getUserRaceByIds(uid: uid, trackId: trackId);
    if (z1userRace != null) {
      positionHash = z1userRace.positionHash;
    }
    int firstPosition = await getUserRacePositionByTime(
        positionHash: positionHash, trackId: trackId);
    List<Z1UserRace> z1userRacesResult = await getUserRacesByTime(
        positionHash: positionHash,
        trackId: trackId,
        descending: true,
        limit: 10);
    firstPosition = firstPosition - z1userRacesResult.length + 1;
    z1userRacesResult.addAll(await getUserRacesByTime(
        positionHash: positionHash,
        trackId: trackId,
        descending: false,
        limit: 20 - z1userRacesResult.length));

    z1userRacesResult.sort((a, b) => a.time.compareTo(b.time));

    return Z1TrackRaces(races: z1userRacesResult, firstPosition: firstPosition);
  }

  Future<Z1Version> getVersion() async {
    DocumentSnapshot<Map<String, dynamic>> docSnap = await versionDoc.get();
    if (!docSnap.exists) {
      return Z1Version();
    }

    return Z1Version.fromMap(docSnap.data() ?? {});
  }
}
