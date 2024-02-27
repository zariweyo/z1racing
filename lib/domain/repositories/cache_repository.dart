import 'package:z1racing/data/cache_repository_impl.dart';

abstract class CacheRepository {
  static CacheRepository get instance => CacheRepositoryImpl();

  Future<void> init();
}
