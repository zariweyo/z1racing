import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:z1racing/domain/repositories/preferences_repository.dart';

class SettingsMusic extends StatefulWidget {
  const SettingsMusic({super.key});

  @override
  State<SettingsMusic> createState() => _SettingsMusicState();
}

class _SettingsMusicState extends State<SettingsMusic> {
  bool enableMusic = false;

  @override
  void initState() {
    super.initState();
    enableMusic = PreferencesRepository.instance.getEnableMusic();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: Row(
        children: [
          Text(
            AppLocalizations.of(context)!.enabledMusic,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.left,
          ),
          Switch(
            value: enableMusic,
            activeColor: Colors.greenAccent,
            onChanged: (newVal) {
              PreferencesRepository.instance.setEnableMusic(enable: newVal);
              if (newVal) {
                FlameAudio.bgm.resume();
              } else {
                FlameAudio.bgm.stop();
              }
              setState(() {
                enableMusic = newVal;
              });
            },
          ),
        ],
      ),
    );
  }
}
