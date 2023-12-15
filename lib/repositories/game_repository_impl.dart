import 'package:flame/input.dart';
import 'package:flutter/foundation.dart';
import 'package:z1racing/models/z1track.dart';
import 'package:z1racing/models/z1user_race.dart';
import 'package:z1racing/repositories/firebase_auth_repository.dart';
import 'package:z1racing/repositories/firebase_firestore_repository.dart';
import 'package:z1racing/repositories/game_repository.dart';
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
  Z1UserRace? z1UserRaceRef;

  Vector2 startPosition = Vector2(0, 0);

  Vector2 get trackSize => Vector2(currentTrack.width, currentTrack.height);

  void initRaceData() {
    assert(FirebaseAuthRepository.instance.currentUser != null);
    z1UserRace = Z1UserRace.init(
      uid: FirebaseAuthRepository.instance.currentUser!.uid,
      trackId: currentTrack.trackId,
      displayName: FirebaseAuthRepository.instance.currentUser!.name,
    );
    lapNotifier.removeListener(_onLapUpdate);
    lapNotifier.addListener(_onLapUpdate);
  }

  Future loadRefRace() async {
    assert(FirebaseAuthRepository.instance.currentUser != null);

    final currentZ1UserRaces = await TrackRepositoryImpl().getUserRaces(
      uid: FirebaseAuthRepository.instance.currentUser!.uid,
      trackId: currentTrack.trackId,
    );

    if (currentZ1UserRaces.races.isNotEmpty) {
      final userPos = currentZ1UserRaces.races.indexWhere(
        (race) => race.uid == FirebaseAuthRepository.instance.currentUser!.uid,
      );
      if (userPos <= 0) {
        z1UserRaceRef = currentZ1UserRaces.races.first;
      } else {
        z1UserRaceRef = currentZ1UserRaces.races[userPos - 1];
      }
    }
  }

  Future<void> _onLapUpdate() async {
    addLapTimeFromCurrent();
    if (raceIsEnd()) {
      z1UserRace =
          z1UserRace?.copyWith(time: Duration(milliseconds: getTime().toInt()));
      saveRace();
    }
  }

  @override
  Duration getReferenceDelayLap({required int lap}) {
    final index = lap - 1;
    if (z1UserRace == null ||
        z1UserRace!.lapTimes.length < lap ||
        z1UserRaceRef == null ||
        z1UserRaceRef!.lapTimes.length < lap) {
      return Duration.zero;
    }

    final lastLapDuration = z1UserRace!.lapTimes[index];
    final lastRefLapDuration = z1UserRaceRef!.lapTimes[index];

    final result = Duration(
      milliseconds:
          lastLapDuration.inMilliseconds - lastRefLapDuration.inMilliseconds,
    );
    return result;
  }

  @override
  Duration getReferenceDelayRace() {
    if (z1UserRace == null || z1UserRaceRef == null) {
      return Duration.zero;
    }
    final timeDuration = z1UserRace!.time;
    final refTimeDuration = z1UserRaceRef!.time;

    return Duration(
      milliseconds:
          timeDuration.inMilliseconds - refTimeDuration.inMilliseconds,
    );
  }

  @override
  void setTime(double time) {
    _time = time;
  }

  @override
  void addTime(double time) {
    _time += time;
  }

  @override
  double getTime() => _time * 1000;

  @override
  ValueNotifier<int> getLapNotifier() => lapNotifier;

  void addLap() => lapNotifier.value++;

  @override
  int getCurrentLap() => lapNotifier.value;

  @override
  bool raceIsEnd() => lapNotifier.value > currentTrack.numLaps;

  @override
  int getTotalLaps() => currentTrack.numLaps;

  @override
  GameStatus getStatus() => status;

  @override
  void setStatus(GameStatus status) {
    this.status = status;
  }

  @override
  void addLapTimeFromCurrent() {
    assert(z1UserRace != null);
    var timeMod = Duration(milliseconds: getTime().toInt());
    if (z1UserRace!.lapTimes.isNotEmpty) {
      timeMod = timeMod -
          z1UserRace!.lapTimes.reduce((value, element) => value + element);
    }
    z1UserRace!.addLaptime(timeMod);
  }

  @override
  List<Duration> getLapTimes() => z1UserRace?.lapTimes ?? [];

  @override
  Future saveRace() async {
    if (z1UserRace == null) {
      return;
    }
    var currentUserRace = await FirebaseFirestoreRepository.instance
        .getUserRaceFromRemote(z1UserRace!);

    if (currentUserRace == null) {
      return FirebaseFirestoreRepository.instance
          .saveCompleteUserRace(z1UserRace!);
    }

    final timeHasImproved =
        currentUserRace.time.compareTo(z1UserRace!.time) > 0;
    final bestLapHasImproved =
        currentUserRace.bestLap.compareTo(z1UserRace!.bestLap) > 0;

    if (timeHasImproved && bestLapHasImproved) {
      currentUserRace = currentUserRace.copyWith(
        time: z1UserRace!.time,
        bestLap: z1UserRace!.bestLap,
      );
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

  @override
  void reset() {
    lapNotifier.dispose();
    lapNotifier = ValueNotifier<int>(1);
    setTime(0);
    setStatus(GameStatus.gameover);
    initRaceData();
  }

  @override
  void restart() {
    lapNotifier.value = 1;
    setTime(0);
    initRaceData();
  }
}
