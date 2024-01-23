import 'package:z1racing/models/z1car_shadow.dart';
import 'package:z1racing/models/z1track.dart';
import 'package:z1racing/models/z1track_races.dart';
import 'package:z1racing/models/z1user_race.dart';
import 'package:z1racing/repositories/firebase_firestore_repository.dart';
import 'package:z1racing/repositories/track_repository.dart';

enum TrackRequestDirection { previous, next, last }

enum UserRacesOptions { both, descending, ascending }

class TrackRepositoryImpl extends TrackRepository {
  @override
  Future<Z1Track?> getTrack({
    int order = 0,
    TrackRequestDirection direction = TrackRequestDirection.next,
  }) async {
    return FirebaseFirestoreRepository.instance.getTrackByOrder(
      order: order,
      direction: direction,
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
  }) async {
    return FirebaseFirestoreRepository.instance
        .getCarShadowByTrackAndUid(uid: uid, trackId: trackId);
  }
}
