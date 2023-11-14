import 'package:z1racing/models/z1user_race.dart';

class Z1TrackRaces {
  final List<Z1UserRace> races;
  final int firstPosition;

  Z1TrackRaces({
    required this.races,
    required this.firstPosition,
  });

  factory Z1TrackRaces.empty() {
    return Z1TrackRaces(races: [], firstPosition: 0);
  }

  int get fisrtPositionHash => races.isNotEmpty ? races.first.positionHash : 0;
  int get lastPositionHash => races.isNotEmpty ? races.last.positionHash : 0;
}
