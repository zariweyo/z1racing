import 'package:vector_math/vector_math_64.dart';

extension Vector2Extension on Vector2 {
  static Vector2? fromMap(dynamic map) {
    if (map is! Map<String, dynamic> || map['x'] == null || map['y'] == null) {
      return null;
    }

    return Vector2(
      double.tryParse(
            map['x'].toString(),
          ) ??
          0,
      double.tryParse(
            map['y'].toString(),
          ) ??
          0,
    );
  }

  bool isEqual(Vector2 other) {
    if (other.x == x && other.y == y) {
      return true;
    }

    return false;
  }

  Map<String, dynamic> toMap() {
    return {
      'x': x,
      'y': y,
    };
  }
}
