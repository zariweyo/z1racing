import 'package:flutter/foundation.dart';
import 'package:vector_math/vector_math_64.dart';
import 'package:z1racing/domain/entities/slot/slot_model.dart';

enum GameStatus { none, gameover, start }

abstract class GameRepository {
  int getCurrentLap();
  int getTotalLaps();
  ValueNotifier<int> getLapNotifier();
  ValueNotifier<List<Vector2>> onDragFinished();
  void setTime(double time);
  void addTime(double time);
  void addNewShadowPosition(
    Vector2 position,
    double angle,
    SlotModelLevel level,
  );
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
  void addPosition();
  int getPosition();
}
