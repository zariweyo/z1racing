import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:z1racing/models/z1track.dart';
import 'package:z1racing/models/z1user.dart';
import 'package:z1racing/models/z1user_race.dart';
import 'package:z1racing/models/z1version.dart';
import 'package:z1racing/repositories/firebase_firestore_repository.dart';
import 'package:z1racing/repositories/track_repository_impl.dart';

class FirebaseFirestoreRepositoryImpl implements FirebaseFirestoreRepository {
  static const String USERCOL = "users";
  static const String RACESCOL = "races";
  static const String TRACKDATACOL = "trackData";
  static const String VERSIONDOC = "settings/version";

  static final FirebaseFirestoreRepositoryImpl _instance =
      FirebaseFirestoreRepositoryImpl._internal();

  factory FirebaseFirestoreRepositoryImpl() {
    return _instance;
  }

  FirebaseFirestoreRepositoryImpl._internal();

  late Z1Version _z1version;
  Z1Version get z1version => _z1version;

  @override
  Z1User? get currentUser => FirebaseAuth.instance.currentUser != null
      ? Z1User.fromUser(FirebaseAuth.instance.currentUser!)
      : null;

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

    Z1User z1user = currentUser!;
    _z1version = await getVersion();
    return userDoc.set(z1user.toJson());
  }

  Future saveCompleteUserRace(Z1UserRace z1userRace) async {
    DocumentReference<Map<String, dynamic>> raceDoc = trackDataCol
        .doc(z1userRace.trackId)
        .collection(RACESCOL)
        .doc(z1userRace.id);
    return raceDoc.set(z1userRace.toJson());
  }

  @override
  Future updateTimeAndBestLapUserRace(Z1UserRace z1userRace) async {
    DocumentReference<Map<String, dynamic>> raceDoc = trackDataCol
        .doc(z1userRace.trackId)
        .collection(RACESCOL)
        .doc(z1userRace.id);

    return raceDoc.update(z1userRace.toUpdateTimeAndBestLapJson());
  }

  Future updateTimeUserRace(Z1UserRace z1userRace) async {
    DocumentReference<Map<String, dynamic>> raceDoc = trackDataCol
        .doc(z1userRace.trackId)
        .collection(RACESCOL)
        .doc(z1userRace.id);

    return raceDoc.update(z1userRace.toUpdateTimeJson());
  }

  Future updateBestLapUserRace(Z1UserRace z1userRace) async {
    DocumentReference<Map<String, dynamic>> raceDoc = trackDataCol
        .doc(z1userRace.trackId)
        .collection(RACESCOL)
        .doc(z1userRace.id);

    return raceDoc.update(z1userRace.toUpdateBestLapJson());
  }

  @override
  Future<Z1UserRace?> getUserRaceFromRemote(Z1UserRace z1userRace) async {
    DocumentSnapshot<Map<String, dynamic>> raceDoc = await trackDataCol
        .doc(z1userRace.trackId)
        .collection(RACESCOL)
        .doc(z1userRace.id)
        .get();
    if (!raceDoc.exists || raceDoc.data() == null) {
      return null;
    }
    return Z1UserRace.fromMap(raceDoc.data()!);
  }

  Future<Z1UserRace?> getUserRaceByTrackId(
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
      {required String positionHash, required String trackId}) async {
    CollectionReference raceCol =
        trackDataCol.doc(trackId).collection(RACESCOL);
    AggregateQuery aggQuery = raceCol
        .where("positionHash", isLessThanOrEqualTo: positionHash)
        .count();

    AggregateQuerySnapshot asnap = await aggQuery.get();

    return asnap.count;
  }

  Future<Z1Track> getTrackById({required String trackId}) async {
    DocumentSnapshot<Map<String, dynamic>> docSnap =
        await trackDataCol.doc(trackId).get();

    if (!docSnap.exists || docSnap.data() == null) {
      return Z1Track.empty();
    }
    return Z1Track.fromMap(docSnap.data()!);
  }

  Future<Z1Track?> getTrackByActivedDate(
      {required DateTime dateTime,
      TrackRequestDirection direction = TrackRequestDirection.next}) async {
    Query<Map<String, dynamic>> query = trackDataCol.orderBy("initialDatetime",
        descending: direction == TrackRequestDirection.previous);

    switch (direction) {
      case TrackRequestDirection.previous:
        query = query.where("initialDatetime",
            isLessThanOrEqualTo: dateTime.toIso8601String());
        break;
      case TrackRequestDirection.next:
        query = query.where("initialDatetime",
            isGreaterThanOrEqualTo:
                dateTime.add(Duration(minutes: 1)).toIso8601String());
        break;
    }

    QuerySnapshot<Map<String, dynamic>> qSnap = await query.limit(1).get();
    if (qSnap.docs.isNotEmpty) {
      return Z1Track.fromMap(qSnap.docs.first.data());
    }
    return null;
  }

  Future<List<Z1UserRace>> getUserRacesByTime(
      {required String positionHash,
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

  Future<Z1Version> getVersion() async {
    DocumentSnapshot<Map<String, dynamic>> docSnap = await versionDoc.get();
    if (!docSnap.exists) {
      return Z1Version();
    }

    return Z1Version.fromMap(docSnap.data() ?? {});
  }
}
