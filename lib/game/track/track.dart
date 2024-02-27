import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:z1racing/data/game_repository_impl.dart';
import 'package:z1racing/domain/entities/object/object_model.dart';
import 'package:z1racing/domain/entities/slot/slot_model.dart';
import 'package:z1racing/domain/entities/z1track.dart';
import 'package:z1racing/game/objects/tree_object.dart';
import 'package:z1racing/game/track/components/lap_line.dart';
import 'package:z1racing/game/track/components/level_change_line.dart';
import 'package:z1racing/game/track/components/track_slot.dart';
import 'package:z1racing/models/global_priorities.dart';

class Track {
  final Vector2 position;
  final double size;
  final bool ignoreObjects;
  final bool isMap;

  final List<Component> _slots = [];
  Z1Track z1track;
  Vector2 initPosition = Vector2.zero();
  final Color floorColor;
  final Color floorBridgeColor;
  final Color borderColor;
  final Color borderBridgeColor;
  Rect dimmension = Rect.zero;

  Track({
    required this.position,
    required this.z1track,
    this.ignoreObjects = true,
    this.isMap = false,
    this.size = 40,
    this.floorColor = const Color.fromARGB(255, 74, 59, 74),
    this.floorBridgeColor = const Color.fromARGB(255, 74, 59, 74),
    this.borderColor = const Color.fromARGB(255, 239, 235, 239),
    this.borderBridgeColor = const Color.fromARGB(255, 239, 235, 239),
  }) {
    compose();
  }

  void compose() {
    final objetcOffset = Vector2.zero();
    if (z1track.slots.isEmpty) {
      return;
    }
    initPosition = position.clone()..add(Vector2(-160, -150));

    var currentAngle = -z1track.slots.first.inputAngle;
    var currentTrack = z1track.slots.first;
    var currentPosition = initPosition;
    var startPositionSetted = false;
    var currentLevel = SlotModelLevel.floor;

    z1track.slots.forEachIndexed((index, trackModel) {
      final baseFloorColor = trackModel.level == SlotModelLevel.bridge
          ? floorBridgeColor
          : floorColor;
      final baseBorderColor = trackModel.level == SlotModelLevel.bridge
          ? borderBridgeColor
          : borderColor;
      if (index == 0) {
        _slots.add(
          TrackSlot(
            index: index,
            position: initPosition.clone(),
            slotModel: trackModel,
            angle: currentAngle,
            floorColor: baseFloorColor,
            borderColor: baseBorderColor,
            trackSlotPosition: z1track.numLaps <= 1
                ? TrackSlotPosition.first
                : TrackSlotPosition.normal,
            priority: isMap ? -1 : GlobalPriorities.slotFloor,
          ),
        );
        currentTrack = trackModel;
      } else {
        final isLast = index == z1track.slots.length - 2;
        final nextAngle =
            currentTrack.outputAngle - trackModel.inputAngle + currentAngle;
        final nextPosition = currentPosition +
            (currentTrack.masterPoints.last.clone()..rotate(currentAngle)) +
            ((-trackModel.masterPoints.first.clone())..rotate(nextAngle));

        if (!isMap &&
            trackModel.level != currentLevel &&
            trackModel.level == SlotModelLevel.bridge) {
          _slots.add(
            LevelChangeLine(
              id: 5,
              position: nextPosition.clone(),
              size: Vector2(1, 40),
              angle: nextAngle,
              offsetPotition: Vector2(-20, 25),
              level: SlotModelLevel.floor,
            ),
          );
          _slots.add(
            LevelChangeLine(
              id: 5,
              position: nextPosition.clone(),
              size: Vector2(1, 40),
              angle: nextAngle,
              offsetPotition: Vector2(0, 25),
              level: SlotModelLevel.both,
            ),
          );
          _slots.add(
            LevelChangeLine(
              id: 5,
              position: nextPosition.clone(),
              size: Vector2(1, 40),
              angle: nextAngle,
              offsetPotition: Vector2(20, 25),
              level: SlotModelLevel.bridge,
            ),
          );
          currentLevel = trackModel.level;
        } else if (!isMap &&
            trackModel.level != currentLevel &&
            trackModel.level == SlotModelLevel.floor) {
          _slots.add(
            LevelChangeLine(
              id: 6,
              position: nextPosition.clone(),
              size: Vector2(1, 40),
              angle: nextAngle,
              offsetPotition: Vector2(-20, 25),
              level: SlotModelLevel.bridge,
            ),
          );
          _slots.add(
            LevelChangeLine(
              id: 5,
              position: nextPosition.clone(),
              size: Vector2(1, 40),
              angle: nextAngle,
              offsetPotition: Vector2(0, 25),
              level: SlotModelLevel.both,
            ),
          );
          _slots.add(
            LevelChangeLine(
              id: 6,
              position: nextPosition.clone(),
              size: Vector2(1, 40),
              angle: nextAngle,
              offsetPotition: Vector2(20, 25),
              level: SlotModelLevel.floor,
            ),
          );
          currentLevel = trackModel.level;
        }

        var trackPriority = GlobalPriorities.slotFloor;
        if (isMap) {
          trackPriority = -1;
        } else if (trackModel.level == SlotModelLevel.bridge &&
            z1track.slots[index - 1].level == SlotModelLevel.floor) {
          trackPriority = GlobalPriorities.slotFloor;
        } else if (trackModel.level == SlotModelLevel.bridge &&
            !isLast &&
            z1track.slots[index + 1].level == SlotModelLevel.floor) {
          trackPriority = GlobalPriorities.slotFloor;
        } else if (trackModel.level == SlotModelLevel.bridge) {
          trackPriority = GlobalPriorities.slotBridge;
        }
        _slots.add(
          TrackSlot(
            index: index,
            position: nextPosition,
            slotModel: trackModel,
            angle: nextAngle,
            floorColor: baseFloorColor,
            borderColor: baseBorderColor,
            priority: trackPriority,
          ),
        );

        if (!isMap &&
            (trackModel.sensor == TrackModelSensor.finish ||
                trackModel.sensor == TrackModelSensor.start)) {
          _slots.add(
            LapLine(
              id: 1,
              position: nextPosition.clone(),
              size: Vector2(1, 40),
              angle: nextAngle,
              offsetPotition: Vector2(40, 25),
              type: LapLineType.control,
            ),
          );
          _slots.add(
            LapLine(
              id: 2,
              position: nextPosition.clone(),
              size: Vector2(1, 40),
              angle: nextAngle,
              offsetPotition: Vector2(60, 25),
              type: LapLineType.control,
            ),
          );
          _slots.add(
            LapLine(
              id: 3,
              position: nextPosition.clone(),
              size: Vector2(3, 40),
              angle: nextAngle,
              offsetPotition: Vector2(20, 25),
              type: trackModel.sensor == TrackModelSensor.finish
                  ? LapLineType.finish
                  : LapLineType.start,
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
        dimmension = Rect.fromLTRB(
          min(currentPosition.x, dimmension.left),
          min(currentPosition.y, dimmension.top),
          max(currentPosition.x, dimmension.right),
          max(currentPosition.y, dimmension.bottom),
        );
      }
    });

    if (!isMap && !ignoreObjects) {
      z1track.objects.forEachIndexed((index, objectModel) {
        switch (objectModel.type) {
          case ObjectModelType.none:
            break;
          case ObjectModelType.tree1:
            _slots.add(
              Tree1Object(
                position: objectModel.position.clone()..add(objetcOffset),
                row: objectModel.row,
                column: objectModel.column,
              ),
            );
            break;
          case ObjectModelType.tree2:
            _slots.add(
              Tree2Object(
                position: objectModel.position.clone()..add(objetcOffset),
                row: objectModel.row,
                column: objectModel.column,
              ),
            );
            break;
        }
      });
    }
  }

  Iterable<Component> get getComponents => _slots;
}
