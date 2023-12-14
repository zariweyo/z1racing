import 'dart:math' as Math;

import 'package:collection/collection.dart';
import 'package:flame/components.dart';
import 'package:z1racing/models/z1track.dart';
import 'package:z1racing/game/track/components/lap_line.dart';
import 'package:z1racing/game/track/models/slot_model.dart';
import 'package:z1racing/game/track/components/track_slot.dart';
import 'package:z1racing/repositories/game_repository_impl.dart';

class Track {
  final Vector2 position;
  final double size;

  List<Component> _slots = [];
  Z1Track z1track;
  Vector2 initPosition = Vector2.zero();

  Track({this.size = 40, required this.position, required this.z1track}) {
    compose();
  }

  compose() {
    initPosition = position.clone()..add(Vector2(-160, -150));

    double currentAngle = z1track.slots.first.inputAngle - Math.pi;
    SlotModel currentTrack = z1track.slots.first;
    Vector2 currentPosition = initPosition;
    bool startPositionSetted = false;
    z1track.slots.forEachIndexed((index, trackModel) {
      if (index == 0) {
        _slots.add(TrackSlot(
            position: initPosition.clone(),
            slotModel: trackModel,
            angle: currentAngle));
        currentTrack = trackModel;
      } else {
        double nextAngle =
            currentTrack.outputAngle - trackModel.inputAngle + currentAngle;
        Vector2 nextPosition = currentPosition +
            (currentTrack.masterPoints.last.clone()..rotate(currentAngle)) +
            ((-trackModel.masterPoints.first.clone())..rotate(nextAngle));

        _slots.add(TrackSlot(
            position: nextPosition, slotModel: trackModel, angle: nextAngle));

        if (trackModel.sensor == TrackModelSensor.finish) {
          _slots.add(LapLine(
              id: 1,
              position: nextPosition.clone(),
              size: Vector2(1, 40),
              angle: nextAngle,
              offsetPotition: Vector2(40, 25),
              isFinish: false));
          _slots.add(LapLine(
              id: 2,
              position: nextPosition.clone(),
              size: Vector2(1, 40),
              angle: nextAngle,
              offsetPotition: Vector2(60, 25),
              isFinish: false));
          _slots.add(LapLine(
              id: 3,
              position: nextPosition.clone(),
              size: Vector2(3, 40),
              angle: nextAngle,
              offsetPotition: Vector2(20, 25),
              isFinish: true));
          if (!startPositionSetted) {
            GameRepositoryImpl().startPosition = nextPosition.clone()
              ..add(Vector2(10, 25)..rotate(nextAngle));
            startPositionSetted = true;
          }
        }

        currentTrack = trackModel;
        currentAngle = nextAngle;
        currentPosition = nextPosition;
      }
    });
  }

  Iterable<Component> getComponents() {
    return _slots;
  }
}
