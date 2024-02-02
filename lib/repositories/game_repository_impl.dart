import 'package:flame/components.dart';
import 'package:flutter/foundation.dart';
import 'package:z1racing/models/z1car_shadow.dart';
import 'package:z1racing/models/z1track.dart';
import 'package:z1racing/models/z1user.dart';
import 'package:z1racing/models/z1user_race.dart';
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
  Z1User? z1UserRef;
  Z1CarShadow? z1carShadow;
  Z1CarShadow? z1carShadowRef;
  CameraComponent? raceCamera;

  Vector2 startPosition = Vector2(0, 0);

  Vector2 get trackSize => Vector2(currentTrack.width, currentTrack.height);

  void initRaceData() {
    assert(FirebaseFirestoreRepository.instance.currentUser != null);
    FirebaseFirestoreRepository.instance.logEvent(name: 'race_init');
    z1UserRace = Z1UserRace.init(
      uid: FirebaseFirestoreRepository.instance.currentUser!.uid,
      trackId: currentTrack.trackId,
      numLaps: currentTrack.numLaps,
      displayName: FirebaseFirestoreRepository.instance.currentUser!.name,
    );
    z1carShadow = Z1CarShadow(
      id: z1UserRace!.id,
      uid: z1UserRace!.uid,
      z1UserRaceId: z1UserRace!.id,
      positions: [],
    );
    lapNotifier.removeListener(_onLapUpdate);
    lapNotifier.addListener(_onLapUpdate);
  }

  Future loadRefRace() async {
    assert(FirebaseFirestoreRepository.instance.currentUser != null);

    final currentZ1UserRaces = await TrackRepositoryImpl().getUserRaces(
      uid: FirebaseFirestoreRepository.instance.currentUser!.uid,
      trackId: currentTrack.trackId,
    );

    z1UserRaceRef = null;
    z1carShadowRef = null;

    if (currentZ1UserRaces.races.isNotEmpty) {
      final userPos = currentZ1UserRaces.races.indexWhere(
        (race) =>
            race.uid == FirebaseFirestoreRepository.instance.currentUser!.uid,
      );
      if (userPos <= 0) {
        z1UserRaceRef = currentZ1UserRaces.races.first;
      } else {
        z1UserRaceRef = currentZ1UserRaces.races[userPos - 1];
      }

      if (z1UserRaceRef != null) {
        z1carShadowRef = await TrackRepositoryImpl().getUserShadow(
          uid: z1UserRaceRef!.uid,
          trackId: currentTrack.trackId,
        );

        z1UserRef = await FirebaseFirestoreRepository.instance
            .getUserByUid(uid: z1UserRaceRef!.uid);
      }
    }
  }

  @override
  void addNewShadowPosition(Vector2 position, double angle) {
    z1carShadow?.addPosition(
      Z1CarShadowPosition(
        time: Duration(milliseconds: (_time * 1000).toInt()),
        position: position.clone(),
        angle: angle,
      ),
    );
  }

  Future<void> _onLapUpdate() async {
    addLapTimeFromCurrent();
    if (raceIsEnd()) {
      FirebaseFirestoreRepository.instance.logEvent(name: 'race_complete');
      z1UserRace =
          z1UserRace?.copyWith(time: Duration(milliseconds: getTime().toInt()));
      saveRace();
    }
  }

  @override
  Duration getReferenceDelayLap({required int lap}) {
    if (z1UserRace == null ||
        z1UserRace!.lapTimes.length < lap ||
        z1UserRaceRef == null ||
        z1UserRaceRef!.lapTimes.length < lap) {
      return Duration.zero;
    }

    final lastLapDuration = z1UserRace!.lapTimes
        .sublist(0, lap)
        .reduce((value, element) => value + element);
    final lastRefLapDuration = z1UserRaceRef!.lapTimes
        .sublist(0, lap)
        .reduce((value, element) => value + element);

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
    FirebaseFirestoreRepository.instance.logEvent(name: 'race_save');
    var currentUserRace = await FirebaseFirestoreRepository.instance
        .getUserRaceFromRemote(z1UserRace!);

    if (currentUserRace == null) {
      return FirebaseFirestoreRepository.instance
          .saveCompleteUserRace(z1UserRace!, z1carShadow);
    }

    final timeHasImproved =
        currentUserRace.time.compareTo(z1UserRace!.time) > 0;
    final bestLapHasImproved =
        currentUserRace.bestLap.compareTo(z1UserRace!.bestLap) > 0;

    if (timeHasImproved && bestLapHasImproved) {
      currentUserRace = currentUserRace.copyWith(
        time: z1UserRace!.time,
        bestLap: z1UserRace!.bestLap,
        lapTimes: z1UserRace!.lapTimes,
      );
      return FirebaseFirestoreRepository.instance
          .updateTimeAndBestLapUserRace(currentUserRace, z1carShadow);
    }

    if (timeHasImproved) {
      currentUserRace = currentUserRace.copyWith(
        time: z1UserRace!.time,
        lapTimes: z1UserRace!.lapTimes,
      );
      return FirebaseFirestoreRepository.instance
          .updateTimeUserRace(currentUserRace, z1carShadow);
    }

    if (bestLapHasImproved) {
      currentUserRace = currentUserRace.copyWith(bestLap: z1UserRace!.bestLap);
      return FirebaseFirestoreRepository.instance
          .updateBestLapUserRace(currentUserRace);
    }
  }

  @override
  void reset() {
    FirebaseFirestoreRepository.instance.logEvent(name: 'race_reset');
    lapNotifier.dispose();
    lapNotifier = ValueNotifier<int>(1);
    setTime(0);
    setStatus(GameStatus.gameover);
    initRaceData();
  }

  @override
  void restart() {
    FirebaseFirestoreRepository.instance.logEvent(name: 'race_restart');
    lapNotifier.value = 1;
    setTime(0);
    initRaceData();
  }
}
