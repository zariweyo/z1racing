import 'dart:math' as math;

import 'package:collection/collection.dart';
import 'package:flame/components.dart';
import 'package:z1racing/game/track/components/lap_line.dart';
import 'package:z1racing/game/track/components/track_slot.dart';
import 'package:z1racing/game/track/models/slot_model.dart';
import 'package:z1racing/models/z1track.dart';
import 'package:z1racing/repositories/game_repository_impl.dart';

class Track {
  final Vector2 position;
  final double size;

  final List<Component> _slots = [];
  Z1Track z1track;
  Vector2 initPosition = Vector2.zero();

  Track({required this.position, required this.z1track, this.size = 40}) {
    compose();
  }

  void compose() {
    initPosition = position.clone()..add(Vector2(-160, -150));

    var currentAngle = z1track.slots.first.inputAngle - math.pi;
    var currentTrack = z1track.slots.first;
    var currentPosition = initPosition;
    var startPositionSetted = false;
    z1track.slots.forEachIndexed((index, trackModel) {
      if (index == 0) {
        _slots.add(
          TrackSlot(
            position: initPosition.clone(),
            slotModel: trackModel,
            angle: currentAngle,
          ),
        );
        currentTrack = trackModel;
      } else {
        final nextAngle =
            currentTrack.outputAngle - trackModel.inputAngle + currentAngle;
        final nextPosition = currentPosition +
            (currentTrack.masterPoints.last.clone()..rotate(currentAngle)) +
            ((-trackModel.masterPoints.first.clone())..rotate(nextAngle));

        _slots.add(
          TrackSlot(
            position: nextPosition,
            slotModel: trackModel,
            angle: nextAngle,
          ),
        );

        if (trackModel.sensor == TrackModelSensor.finish) {
          _slots.add(
            LapLine(
              id: 1,
              position: nextPosition.clone(),
              size: Vector2(1, 40),
              angle: nextAngle,
              offsetPotition: Vector2(40, 25),
              isFinish: false,
            ),
          );
          _slots.add(
            LapLine(
              id: 2,
              position: nextPosition.clone(),
              size: Vector2(1, 40),
              angle: nextAngle,
              offsetPotition: Vector2(60, 25),
              isFinish: false,
            ),
          );
          _slots.add(
            LapLine(
              id: 3,
              position: nextPosition.clone(),
              size: Vector2(3, 40),
              angle: nextAngle,
              offsetPotition: Vector2(20, 25),
              isFinish: true,
            ),
          );
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
