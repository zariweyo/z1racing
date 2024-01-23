import 'package:flame/flame.dart';

class CacheRepository {
  Future<void> init() async {
    await Flame.images.loadAll(<String>[
      'trees_1.png',
      'trees_2.png',
    ]);
  }
}
