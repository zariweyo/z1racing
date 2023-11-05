import 'dart:math' as Math;

import 'package:collection/collection.dart';
import 'package:flame/components.dart';
import 'package:z1racing/models/z1track.dart';
import 'package:z1racing/game/track/components/lap_line.dart';
import 'package:z1racing/game/track/models/slot_model.dart';
import 'package:z1racing/game/track/components/track_slot.dart';

class Track {
  final Vector2 position;
  final double size;

  List<TrackSlot> _tracks = [];
  Z1Track z1track;

  Track({this.size = 40, required this.position, required this.z1track}) {
    compose();
  }

  compose() {
    Vector2 initPosition = position.clone()..add(Vector2(-160, -150));

    double currentAngle = z1track.slots.first.inputAngle - Math.pi;
    SlotModel currentTrack = z1track.slots.first;
    Vector2 currentPosition = initPosition;
    z1track.slots.forEachIndexed((index, trackModel) {
      if (index == 0) {
        _tracks.add(TrackSlot(
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
        _tracks.add(TrackSlot(
            position: nextPosition, slotModel: trackModel, angle: nextAngle));
        currentTrack = trackModel;
        currentAngle = nextAngle;
        currentPosition = nextPosition;
      }
    });
  }

  Iterable<Component> getComponents() {
    return [
      LapLine(1, Vector2(20, 50), Vector2(40, 1), isFinish: false),
      LapLine(2, Vector2(20, 70), Vector2(40, 1), isFinish: false),
      LapLine(3, Vector2(50, 25), Vector2(3, 40), isFinish: true, angle: -0.05),
      ..._tracks
    ];
  }
}
