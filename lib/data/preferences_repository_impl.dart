import 'package:shared_preferences/shared_preferences.dart';
import 'package:z1racing/domain/repositories/preferences_repository.dart';

class PreferencesRepositoryImpl extends PreferencesRepository {
  static final PreferencesRepositoryImpl _instance =
      PreferencesRepositoryImpl._internal();

  static PreferencesRepositoryImpl get instance => _instance;

  factory PreferencesRepositoryImpl() {
    return _instance;
  }

  PreferencesRepositoryImpl._internal();

  SharedPreferences? prefs;

  @override
  Future<void> init() async {
    prefs = await SharedPreferences.getInstance();
  }

  @override
  bool getEnableMusic() {
    return prefs?.getBool(enableMusicKey) ?? true;
  }

  @override
  Future<bool>? setEnableMusic({required bool enable}) {
    return prefs?.setBool(enableMusicKey, enable);
  }
}
