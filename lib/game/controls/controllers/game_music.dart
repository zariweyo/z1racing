import 'dart:math';
import 'package:flame_audio/flame_audio.dart';

class GameMusic {
  AudioPlayer? player;
  List<String> musics = [
    'race_background_1.mp3',
    'race_background_2.mp3',
    'race_background_3.mp3',
  ];

  GameMusic();

  Future<void> start() async {
    player =
        await FlameAudio.loopLongAudio(musics[Random().nextInt(musics.length)]);
  }

  Future<void> stop() async {
    player?.dispose();
  }
}
