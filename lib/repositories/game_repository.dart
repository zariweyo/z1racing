import 'package:flutter/foundation.dart';
import 'package:vector_math/vector_math_64.dart';

enum GameStatus { none, gameover, start }

abstract class GameRepository {
  int getCurrentLap();
  int getTotalLaps();
  ValueNotifier<int> getLapNotifier();
  void setTime(double time);
  void addTime(double time);
  void addNewShadowPosition(Vector2 position, double angle);
  double getTime();
  bool raceIsEnd();
  GameStatus getStatus();
  void setStatus(GameStatus status);
  void reset();
  void restart();
  Duration getReferenceDelayLap({required int lap});
  Duration getReferenceDelayRace();
  void addLapTimeFromCurrent();
  List<Duration> getLapTimes();
  Future<void> saveRace();
}
