import 'package:z1racing/domain/entities/z1car_shadow.dart';
import 'package:z1racing/domain/entities/z1season.dart';
import 'package:z1racing/domain/entities/z1track.dart';
import 'package:z1racing/domain/entities/z1user_race.dart';
import 'package:z1racing/domain/repositories/firebase_firestore_repository.dart';
import 'package:z1racing/domain/repositories/track_repository.dart';
import 'package:z1racing/models/z1track_races.dart';

class TrackRepositoryImpl extends TrackRepository {
  static final TrackRepositoryImpl _instance = TrackRepositoryImpl._internal();

  factory TrackRepositoryImpl() {
    return _instance;
  }

  TrackRepositoryImpl._internal();

  @override
  Future<Z1Track?> getTrack({
    required String trackId,
  }) async {
    return FirebaseFirestoreRepository.instance.getTrackById(
      trackId: trackId,
    );
  }

  @override
  Future<Z1TrackRaces> getUserRaces({
    required String uid,
    required String trackId,
    int length = 10,
    UserRacesOptions userRacesOptions = UserRacesOptions.both,
  }) async {
    var positionHash = '';
    final z1userRace = await FirebaseFirestoreRepository.instance
        .getUserRaceByTrackId(uid: uid, trackId: trackId);
    if (z1userRace != null) {
      positionHash = z1userRace.positionHash;
    }
    var firstPosition =
        await FirebaseFirestoreRepository.instance.getUserRacePositionByTime(
      positionHash: positionHash,
      trackId: trackId,
    );

    if (firstPosition == 0) {
      firstPosition = 1;
    }
    final z1userRacesResult = <Z1UserRace>[];

    if ([UserRacesOptions.both, UserRacesOptions.descending]
        .contains(userRacesOptions)) {
      z1userRacesResult.addAll(
        await FirebaseFirestoreRepository.instance.getUserRacesByTime(
          positionHash: positionHash,
          trackId: trackId,
          descending: true,
          limit: length,
        ),
      );
      firstPosition = firstPosition - z1userRacesResult.length;
    }

    if ([UserRacesOptions.both, UserRacesOptions.ascending]
        .contains(userRacesOptions)) {
      z1userRacesResult.addAll(
        await FirebaseFirestoreRepository.instance.getUserRacesByTime(
          positionHash: positionHash,
          trackId: trackId,
          limit: length - z1userRacesResult.length,
        ),
      );
    }

    if (userRacesOptions == UserRacesOptions.both && z1userRace != null) {
      z1userRacesResult.add(z1userRace);
    }

    z1userRacesResult.sort((a, b) => a.positionHash.compareTo(b.positionHash));

    return Z1TrackRaces(races: z1userRacesResult, firstPosition: firstPosition);
  }

  @override
  Future<Z1CarShadow?> getUserShadow({
    required String uid,
    required String trackId,
  }) =>
      FirebaseFirestoreRepository.instance
          .getCarShadowByTrackAndUid(uid: uid, trackId: trackId);

  @override
  Future<List<Z1Season>> getSeasons() =>
      FirebaseFirestoreRepository.instance.getSeasons();
}
