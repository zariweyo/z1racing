import 'package:flame/flame.dart';
import 'package:z1racing/domain/repositories/cache_repository.dart';

class CacheRepositoryImpl extends CacheRepository {
  static final CacheRepositoryImpl _instance = CacheRepositoryImpl._internal();

  factory CacheRepositoryImpl() {
    return _instance;
  }

  CacheRepositoryImpl._internal();

  @override
  Future<void> init() async {
    await Flame.images.loadAll(<String>[
      'trees_1.png',
      'trees_2.png',
    ]);
  }
}
