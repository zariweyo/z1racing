import 'package:z1racing/domain/entities/z1track.dart';

abstract class MainServiceEvent {}

class MainServiceEventTrackSelected extends MainServiceEvent {
  final Z1Track track;

  MainServiceEventTrackSelected({required this.track});
}
