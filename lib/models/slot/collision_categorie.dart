import 'package:z1racing/models/slot/slot_model.dart';

class CollisionCategorie {
  static const int floor = 0x0001;
  static const int bridge = 0x0002;

  static int getCollisionFromSlotModelLevel(SlotModelLevel level) {
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

  static SlotModelLevel getSlotModelLevelFromCollision(int collision) {
    if (collision == bridge) {
      return SlotModelLevel.bridge;
    }

    return SlotModelLevel.floor;
  }
}
