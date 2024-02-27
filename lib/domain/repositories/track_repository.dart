// ignore_for_file: prefer_constructors_over_static_methods

import 'package:z1racing/data/track_repository_impl.dart';
import 'package:z1racing/domain/entities/z1car_shadow.dart';
import 'package:z1racing/domain/entities/z1season.dart';
import 'package:z1racing/domain/entities/z1track.dart';
import 'package:z1racing/models/z1track_races.dart';

enum TrackRequestDirection { previous, next, last }

enum UserRacesOptions { both, descending, ascending }

abstract class TrackRepository {
  static TrackRepository get instance => TrackRepositoryImpl();

  Future<Z1Track?> getTrack({
    required String trackId,
  });
  Future<List<Z1Season>> getSeasons();
  Future<Z1TrackRaces> getUserRaces({
    required String uid,
    required String trackId,
    int length = 10,
    UserRacesOptions userRacesOptions = UserRacesOptions.both,
  });
  Future<Z1CarShadow?> getUserShadow({
    required String uid,
    required String trackId,
  });
}
