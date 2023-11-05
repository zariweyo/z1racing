import 'package:z1racing/models/z1track.dart';

abstract class TrackRepository {
  Future<Z1Track> getTrack();
}
