import 'package:z1racing/data/preferences_repository_impl.dart';

abstract class PreferencesRepository {
  String get enableMusicKey => 'ENABLE_MUSIC';

  static PreferencesRepository get instance => PreferencesRepositoryImpl();

  Future<void> init();

  bool getEnableMusic();

  Future<bool>? setEnableMusic({required bool enable});
}
