import 'dart:math';
import 'package:flame_audio/flame_audio.dart';
import 'package:z1racing/domain/repositories/preferences_repository.dart';

class GameMusic {
  List<String> musics = [
    'race_background_1.mp3',
    'race_background_2.mp3',
    'race_background_3.mp3',
  ];

  GameMusic();

  Future<void> start() async {
    final audioEnabled = PreferencesRepository.instance.getEnableMusic();
    if (audioEnabled) {
      await FlameAudio.bgm.play(musics[Random().nextInt(musics.length)]);
    }
  }

  Future<void> stop() async {
    FlameAudio.bgm.stop();
  }
}
