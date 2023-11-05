import 'package:flutter/foundation.dart';

enum GameStatus { none, gameover, start }

abstract class GameRepository {
  int getCurrentLap();
  int getTotalLaps();
  ValueNotifier<int> getLapNotifier();
  void setTime(double time);
  void addTime(double time);
  double getTime();
  bool raceIsEnd();
  GameStatus getStatus();
  void setStatus(GameStatus status);
  void reset();
  void addLapTimeFromCurrent();
  List<Duration> getLapTimes();
  Future<void> saveRace();
}
