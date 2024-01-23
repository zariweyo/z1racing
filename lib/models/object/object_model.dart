import 'package:collection/collection.dart';
import 'package:vector_math/vector_math_64.dart';

enum ObjectModelType { none, tree }

class ObjectModel {
  final ObjectModelType type;
  final int row;
  final int column;
  final Vector2 position;

  ObjectModel({
    required this.type,
    required this.row,
    required this.column,
    required this.position,
  });

  factory ObjectModel.fromMap(dynamic mapDyn) {
    final map = mapDyn as Map<String, dynamic>;
    return ObjectModel(
      type: ObjectModelType.values
              .firstWhereOrNull((element) => element.name == map['type']) ??
          ObjectModelType.none,
      row: map['row'] is int ? map['row'] as int : 0,
      column: map['column'] is int ? map['column'] as int : 0,
      position: Vector2(
        double.tryParse(
              (map['position'] as Map<String, dynamic>)['x'].toString(),
            ) ??
            0,
        double.tryParse(
              (map['position'] as Map<String, dynamic>)['y'].toString(),
            ) ??
            0,
      ),
    );
  }
}
