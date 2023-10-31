import 'package:flutter/foundation.dart';
import 'package:z1racing/game/repositories/game_repository.dart';

class GameRepositoryImpl extends GameRepository {
  static final GameRepositoryImpl _instance = GameRepositoryImpl._internal();

  factory GameRepositoryImpl() {
    return _instance;
  }

  GameRepositoryImpl._internal() {
    // initialization logic
  }

  static const int numberOfLaps = 5;
  double _time = 0;
  ValueNotifier<int> lapNotifier = ValueNotifier<int>(0);
  GameStatus status = GameStatus.none;
  List<Duration> lapTimes = [];

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

  bool raceEnd() => lapNotifier.value > numberOfLaps;

  int getTotalLaps() => numberOfLaps;

  GameStatus getStatus() => status;

  void setStatus(GameStatus _status) {
    status = _status;
  }

  void addLapTimeFromCurrent() {
    Duration timeMod = Duration(milliseconds: getTime().toInt());
    if (!lapTimes.isEmpty) {
      timeMod = timeMod - lapTimes.reduce((value, element) => value + element);
    }
    lapTimes.add(timeMod);
  }

  List<Duration> getLapTimes() => lapTimes;

  void reset() {
    lapNotifier.dispose();
    lapNotifier = ValueNotifier<int>(1);
    setTime(0);
    setStatus(GameStatus.gameover);
    lapTimes = [];
  }
}
