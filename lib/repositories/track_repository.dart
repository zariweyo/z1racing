import 'package:z1racing/models/z1track.dart';
import 'package:z1racing/models/z1track_races.dart';

abstract class TrackRepository {
  Future<Z1Track?> getTrack();
  Future<Z1TrackRaces> getUserRaces(
      {required String uid, required String trackId,});
}
