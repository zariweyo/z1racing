import 'package:flame/input.dart';

class ControlsData implements Comparable<ControlsData> {
  JoystickDirection _direction = JoystickDirection.idle;
  Vector2 _delta = Vector2.zero();
  final Vector2 size;
  ControlsData({
    required JoystickDirection direction,
    required Vector2 delta,
    required this.size,
  }) {
    _direction = direction;
    _delta = Vector2(delta.x / (size.x / 2), delta.y / (size.y / 2));
  }

  Vector2 get delta => _delta;
  JoystickDirection get direction => _direction;

  void updateBy(ControlsData other) {
    _direction = other.direction;
    _delta = other.delta.clone();
  }

  double get downValue => delta.y > 0 ? delta.y : 0;
  double get upValue => delta.y < 0 ? delta.y.abs() : 0;
  double get rightValue => delta.x > 0 ? delta.x : 0;
  double get leftValue => delta.x < 0 ? delta.x.abs() : 0;

  factory ControlsData.zero() {
    return ControlsData(
      direction: JoystickDirection.idle,
      delta: Vector2.zero(),
      size: Vector2(1, 1),
    );
  }

  bool hasChange(ControlsData other) {
    return compareTo(other) != 0;
  }

  bool hasHorizontal() {
    return delta.x != 0;
  }

  bool hasVertical() {
    return delta.y != 0;
  }

  @override
  int compareTo(ControlsData other) {
    return delta.y.compareTo(other.delta.y) * 1000 +
        delta.x.compareTo(other.delta.x);
  }

  ControlsData clone() {
    return ControlsData(
      direction: direction,
      delta: delta.clone(),
      size: Vector2(2, 2),
    );
  }

  @override
  String toString() {
    return '${direction.name} $delta';
  }
}
