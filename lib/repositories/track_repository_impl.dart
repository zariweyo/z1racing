import 'package:z1racing/models/z1track.dart';
import 'package:z1racing/models/z1track_races.dart';
import 'package:z1racing/models/z1user_race.dart';
import 'package:z1racing/repositories/firebase_firestore_repository.dart';
import 'package:z1racing/repositories/track_repository.dart';

enum TrackRequestDirection { previous, next }

class TrackRepositoryImpl extends TrackRepository {
  @override
  Future<Z1Track?> getTrack(
      {DateTime? dateTime,
      TrackRequestDirection direction = TrackRequestDirection.next}) async {
    return FirebaseFirestoreRepository.instance.getTrackByActivedDate(
        dateTime: dateTime ?? DateTime.now().toUtc(), direction: direction);
  }

  Future<Z1TrackRaces> getUserRaces(
      {required String uid, required String trackId, int length = 10}) async {
    String positionHash = "";
    Z1UserRace? z1userRace = await FirebaseFirestoreRepository.instance
        .getUserRaceByTrackId(uid: uid, trackId: trackId);
    if (z1userRace != null) {
      positionHash = z1userRace.positionHash;
    }
    int firstPosition = await FirebaseFirestoreRepository.instance
        .getUserRacePositionByTime(
            positionHash: positionHash, trackId: trackId);
    List<Z1UserRace> z1userRacesResult =
        await FirebaseFirestoreRepository.instance.getUserRacesByTime(
            positionHash: positionHash,
            trackId: trackId,
            descending: true,
            limit: (length ~/ 2));
    firstPosition = firstPosition - z1userRacesResult.length + 1;
    z1userRacesResult.addAll(await FirebaseFirestoreRepository.instance
        .getUserRacesByTime(
            positionHash: positionHash,
            trackId: trackId,
            descending: false,
            limit: length - z1userRacesResult.length));

    z1userRacesResult.sort((a, b) => a.time.compareTo(b.time));

    return Z1TrackRaces(races: z1userRacesResult, firstPosition: firstPosition);
  }
}
