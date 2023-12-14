import 'package:collection/collection.dart';
import 'package:flame/input.dart';
import 'package:flutter/foundation.dart';
import 'package:z1racing/models/z1track_races.dart';
import 'package:z1racing/repositories/firebase_auth_repository.dart';
import 'package:z1racing/repositories/firebase_firestore_repository.dart';
import 'package:z1racing/repositories/game_repository.dart';
import 'package:z1racing/models/z1track.dart';
import 'package:z1racing/models/z1user_race.dart';
import 'package:z1racing/repositories/track_repository_impl.dart';

class GameRepositoryImpl extends GameRepository {
  static final GameRepositoryImpl _instance = GameRepositoryImpl._internal();

  factory GameRepositoryImpl() {
    return _instance;
  }

  GameRepositoryImpl._internal() {
    // initialization logic
  }

  double _time = 0;
  ValueNotifier<int> lapNotifier = ValueNotifier<int>(0);
  GameStatus status = GameStatus.none;
  Z1Track currentTrack = Z1Track.empty();
  Z1UserRace? z1UserRace;
  Z1TrackRaces currentZ1UserRaces = Z1TrackRaces.empty();
  Z1UserRace? get currentZ1UserRace =>
      currentZ1UserRaces.races.firstWhereOrNull(
        (element) =>
            element.uid == FirebaseAuthRepository.instance.currentUser?.uid,
      );

  Vector2 startPosition = Vector2(0, 0);

  Vector2 get trackSize {
    List<Vector2> points =
        currentTrack.slots.map((slot) => slot.points1).flattened.toList();

    double width =
        (points.map((e) => e.x).max - points.map((e) => e.x).min).abs();
    double height =
        (points.map((e) => e.y).max - points.map((e) => e.y).min).abs();

    return Vector2(width * 4, height * 6);
  }

  loadTrack({required Z1Track track}) {
    currentTrack = track;
  }

  resetUserRace() {
    assert(FirebaseAuthRepository.instance.currentUser != null);
    z1UserRace = Z1UserRace.init(
        uid: FirebaseAuthRepository.instance.currentUser!.uid,
        trackId: currentTrack.trackId,
        displayName: FirebaseAuthRepository.instance.currentUser!.name);
    lapNotifier.removeListener(_onLapUpdate);
    lapNotifier.addListener(_onLapUpdate);
  }

  Future loadCurrentRace() async {
    assert(FirebaseAuthRepository.instance.currentUser != null);
    currentZ1UserRaces = await TrackRepositoryImpl().getUserRaces(
        uid: FirebaseAuthRepository.instance.currentUser!.uid,
        trackId: currentTrack.trackId);
  }

  _onLapUpdate() async {
    addLapTimeFromCurrent();
    if (raceIsEnd()) {
      z1UserRace =
          z1UserRace?.copyWith(time: Duration(milliseconds: getTime().toInt()));
      saveRace();
    }
  }

  void setTime(double time) {
    _time = time;
  }

  void addTime(double time) {
    _time += time;
  }

  double getTime() => _time * 1000;

  ValueNotifier<int> getLapNotifier() => lapNotifier;

  void addLap() => lapNotifier.value++;

  int getCurrentLap() => lapNotifier.value;

  bool raceIsEnd() => lapNotifier.value > currentTrack.numLaps;

  int getTotalLaps() => currentTrack.numLaps;

  GameStatus getStatus() => status;

  void setStatus(GameStatus _status) {
    status = _status;
  }

  void addLapTimeFromCurrent() {
    assert(z1UserRace != null);
    Duration timeMod = Duration(milliseconds: getTime().toInt());
    if (!z1UserRace!.lapTimes.isEmpty) {
      timeMod = timeMod -
          z1UserRace!.lapTimes.reduce((value, element) => value + element);
    }
    z1UserRace!.addLaptime(timeMod);
  }

  List<Duration> getLapTimes() => z1UserRace?.lapTimes ?? [];

  Future saveRace() async {
    if (z1UserRace == null) {
      return;
    }
    Z1UserRace? currentUserRace = await FirebaseFirestoreRepository.instance
        .getUserRaceFromRemote(z1UserRace!);

    if (currentUserRace == null) {
      return FirebaseFirestoreRepository.instance
          .saveCompleteUserRace(z1UserRace!);
    }

    bool timeHasImproved = currentUserRace.time.compareTo(z1UserRace!.time) > 0;
    bool bestLapHasImproved =
        currentUserRace.bestLap.compareTo(z1UserRace!.bestLap) > 0;

    if (timeHasImproved && bestLapHasImproved) {
      currentUserRace = currentUserRace.copyWith(
          time: z1UserRace!.time, bestLap: z1UserRace!.bestLap);
      return FirebaseFirestoreRepository.instance
          .updateTimeAndBestLapUserRace(currentUserRace);
    }

    if (timeHasImproved) {
      currentUserRace = currentUserRace.copyWith(time: z1UserRace!.time);
      return FirebaseFirestoreRepository.instance
          .updateTimeUserRace(currentUserRace);
    }

    if (bestLapHasImproved) {
      currentUserRace = currentUserRace.copyWith(bestLap: z1UserRace!.bestLap);
      return FirebaseFirestoreRepository.instance
          .updateBestLapUserRace(currentUserRace);
    }
  }

  void reset() {
    lapNotifier.dispose();
    lapNotifier = ValueNotifier<int>(1);
    setTime(0);
    setStatus(GameStatus.gameover);
    resetUserRace();
  }
}
