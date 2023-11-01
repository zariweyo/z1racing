import 'package:z1racing/game/repositories/models/z1track.dart';

abstract class TrackRepository {
  Future<Z1Track> getTrack();
}
