import 'dart:math';

import 'package:z1racing/domain/entities/slot/slot_model.dart';

class CollisionCategorie {
  static int floor = pow(2, 1).toInt();
  static int bridge = pow(2, 2).toInt();
  static int carFightFloor = pow(2, 1).toInt();
  static int carFightBridge = pow(2, 2).toInt();
  static List<int> carVias = [
    pow(2, 10).toInt(),
    pow(2, 11).toInt(),
    pow(2, 12).toInt(),
    pow(2, 13).toInt(),
    pow(2, 14).toInt(),
    pow(2, 15).toInt(),
    pow(2, 16).toInt(),
  ];

  static List<int> carViasBridge = [
    pow(2, 20).toInt(),
    pow(2, 21).toInt(),
    pow(2, 22).toInt(),
    pow(2, 23).toInt(),
    pow(2, 24).toInt(),
    pow(2, 25).toInt(),
    pow(2, 26).toInt(),
  ];

  static int getViaCollisionFromSlotModelLevel(SlotModelLevel level, int via) {
    if (level == SlotModelLevel.bridge) {
      return carViasBridge[via];
    }

    return carVias[via];
  }

  static int getTrackCollisionFromSlotModelLevel(SlotModelLevel level) {
    if (level == SlotModelLevel.bridge) {
      return bridge;
    }

    return floor;
  }

  static int getCollisionFromCarLevel(SlotModelLevel level) {
    if (level == SlotModelLevel.bridge) {
      return bridge;
    } else if (level == SlotModelLevel.both) {
      return bridge + floor;
    }

    return floor;
  }

  static int getCollisionFromCarFightLevel(SlotModelLevel level) {
    if (level == SlotModelLevel.bridge) {
      return carFightBridge;
    } else if (level == SlotModelLevel.both) {
      return carFightBridge + carFightFloor;
    }

    return carFightFloor;
  }

  static SlotModelLevel getSlotModelLevelFromCollision(int collision) {
    if (collision == bridge) {
      return SlotModelLevel.bridge;
    }

    return SlotModelLevel.floor;
  }
}
