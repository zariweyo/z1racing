import 'package:shared_preferences/shared_preferences.dart';

class PreferencesRepository {
  String get enableMusicKey => 'ENABLE_MUSIC';

  static final PreferencesRepository _instance =
      PreferencesRepository._internal();

  static PreferencesRepository get instance => _instance;

  factory PreferencesRepository() {
    return _instance;
  }

  PreferencesRepository._internal() {
    // Initiated
  }

  SharedPreferences? prefs;

  Future<void> init() async {
    prefs = await SharedPreferences.getInstance();
  }

  bool getEnableMusic() {
    return prefs?.getBool(enableMusicKey) ?? true;
  }

  Future<bool>? setEnableMusic({required bool enable}) {
    return prefs?.setBool(enableMusicKey, enable);
  }
}
