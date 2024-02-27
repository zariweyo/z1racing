import 'dart:math';

import 'package:flame/components.dart';
import 'package:flutter/foundation.dart';
import 'package:z1racing/domain/entities/slot/slot_model.dart';
import 'package:z1racing/domain/entities/z1car_shadow.dart';
import 'package:z1racing/domain/entities/z1track.dart';
import 'package:z1racing/domain/entities/z1user.dart';
import 'package:z1racing/domain/entities/z1user_award.dart';
import 'package:z1racing/domain/entities/z1user_race.dart';
import 'package:z1racing/domain/repositories/firebase_firestore_repository.dart';
import 'package:z1racing/domain/repositories/game_repository.dart';
import 'package:z1racing/domain/repositories/track_repository.dart';
import 'package:z1racing/extensions/duration_extension.dart';

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
  ValueNotifier<List<Vector2>> tapNotifier = ValueNotifier<List<Vector2>>([]);
  GameStatus status = GameStatus.none;
  Z1Track currentTrack = Z1Track.empty();
  Z1UserRace? z1UserRace;
  Z1UserRace? z1UserRaceRef;
  Z1User? z1UserRef;
  Z1CarShadow? z1carShadow;
  Z1CarShadow? z1carShadowRef;
  CameraComponent? raceCamera;
  int _position = 1;

  Vector2 startPosition = Vector2(0, 0);
  double startAngle = 3.055;

  Vector2 get trackSize => Vector2(currentTrack.width, currentTrack.height);

  void initRaceData() {
    assert(FirebaseFirestoreRepository.instance.currentUser != null);
    FirebaseFirestoreRepository.instance.logEvent(
      name: 'race_init',
      parameters: {
        'trackId': currentTrack.trackId,
      },
    );
    z1UserRace = Z1UserRace.init(
      uid: FirebaseFirestoreRepository.instance.currentUser!.uid,
      trackId: currentTrack.trackId,
      numLaps: currentTrack.numLaps,
      displayName: FirebaseFirestoreRepository.instance.currentUser!.name,
    );
    z1carShadow = Z1CarShadow(
      id: z1UserRace!.id,
      uid: z1UserRace!.uid,
      trackId: z1UserRace!.trackId,
      z1UserRaceId: z1UserRace!.id,
      positions: [],
    );
    lapNotifier.removeListener(_onLapUpdate);
    lapNotifier.addListener(_onLapUpdate);
  }

  Future loadRefRace() async {
    assert(FirebaseFirestoreRepository.instance.currentUser != null);

    final currentZ1UserRaces = await TrackRepository.instance.getUserRaces(
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
        z1carShadowRef = await TrackRepository.instance.getUserShadow(
          uid: z1UserRaceRef!.uid,
          trackId: currentTrack.trackId,
        );

        z1UserRef = await FirebaseFirestoreRepository.instance
            .getUserByUid(uid: z1UserRaceRef!.uid);
      }
    }
  }

  @override
  void addNewShadowPosition(
    Vector2 position,
    double angle,
    SlotModelLevel level,
  ) {
    z1carShadow?.addPosition(
      Z1CarShadowPosition(
        time: Duration(milliseconds: (_time * 1000).toInt()),
        position: position.clone(),
        angle: angle,
        level: level,
      ),
    );
  }

  Future<void> _onLapUpdate() async {
    addLapTimeFromCurrent();
    if (raceIsEnd()) {
      FirebaseFirestoreRepository.instance.logEvent(
        name: 'race_complete',
        parameters: {
          'trackId': currentTrack.trackId,
          'millis': getTime().toInt(),
        },
      );
      z1UserRace = z1UserRace?.copyWith(
        position: (z1UserRace?.position ?? 0) + 1,
        time: Duration(milliseconds: getTime().toInt()),
      );

      saveRace();
    }
  }

  @override
  void addPosition() {
    if (!raceIsEnd()) {
      _position += 1;
    }
  }

  @override
  Duration getReferenceDelayLap({required int lap}) {
    if (z1UserRace == null ||
        z1UserRace!.lapTimes.length < lap ||
        z1UserRaceRef == null ||
        z1UserRaceRef!.lapTimes.length < lap ||
        z1UserRace!.lapTimes.isEmpty ||
        z1UserRaceRef!.lapTimes.isEmpty) {
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
  int getPosition() => _position;

  @override
  ValueNotifier<int> getLapNotifier() => lapNotifier;

  @override
  ValueNotifier<List<Vector2>> onDragFinished() => tapNotifier;

  void addLap() => lapNotifier.value++;

  set setTap(List<Vector2> v2) => tapNotifier.value = v2;

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
      await FirebaseFirestoreRepository.instance.addZ1UserAward(
        Z1UserAward(
          trackId: z1UserRace!.trackId,
          rating: max(4 - _position, 0),
          time: z1UserRace!.time,
          bestLap: z1UserRace!.bestLap,
        ),
      );
      z1UserRace = z1UserRace!.copyWith(position: _position);
      return FirebaseFirestoreRepository.instance
          .saveCompleteUserRace(z1UserRace!, null);
    }

    final bestPosition = min(currentUserRace.position, _position);
    final bestTime = min(
      currentUserRace.time.inMilliseconds,
      z1UserRace!.time.inMilliseconds,
    );
    final bestBestLap = min(
      currentUserRace.bestLap.inMilliseconds,
      z1UserRace!.bestLap.inMilliseconds,
    );
    z1UserRace = z1UserRace!.copyWith(position: bestPosition);
    await FirebaseFirestoreRepository.instance.addZ1UserAward(
      Z1UserAward(
        trackId: z1UserRace!.trackId,
        rating: max(4 - bestPosition, 0),
        time: DurationExtension.fromMap(bestTime),
        bestLap: DurationExtension.fromMap(bestBestLap),
      ),
    );

    final timeHasImproved =
        currentUserRace.time.compareTo(z1UserRace!.time) > 0;
    final bestLapHasImproved =
        currentUserRace.bestLap.compareTo(z1UserRace!.bestLap) > 0;

    if (timeHasImproved && bestLapHasImproved) {
      currentUserRace = currentUserRace.copyWith(
        time: z1UserRace!.time,
        bestLap: z1UserRace!.bestLap,
        lapTimes: z1UserRace!.lapTimes,
        position: bestPosition,
      );
      return FirebaseFirestoreRepository.instance
          .updateTimeAndBestLapUserRace(currentUserRace, null);
    }

    if (timeHasImproved) {
      currentUserRace = currentUserRace.copyWith(
        time: z1UserRace!.time,
        lapTimes: z1UserRace!.lapTimes,
        position: bestPosition,
      );
      return FirebaseFirestoreRepository.instance
          .updateTimeUserRace(currentUserRace, null);
    }

    if (bestLapHasImproved) {
      currentUserRace = currentUserRace.copyWith(
        bestLap: z1UserRace!.bestLap,
        position: bestPosition,
      );
      return FirebaseFirestoreRepository.instance
          .updateBestLapUserRace(currentUserRace);
    }
  }

  @override
  void reset() {
    FirebaseFirestoreRepository.instance.logEvent(
      name: 'race_end',
      parameters: {
        'trackId': currentTrack.trackId,
      },
    );
    lapNotifier.dispose();
    lapNotifier = ValueNotifier<int>(1);
    _position = 1;
    setTime(0);
    setStatus(GameStatus.gameover);
    initRaceData();
  }

  @override
  void restart() {
    FirebaseFirestoreRepository.instance.logEvent(
      name: 'race_restart',
      parameters: {
        'trackId': currentTrack.trackId,
      },
    );
    lapNotifier.value = 1;
    _position = 1;
    setTime(0);
    initRaceData();
  }
}
