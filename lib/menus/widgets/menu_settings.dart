import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:z1racing/base/components/common_textfield.dart';
import 'package:z1racing/base/exceptions/duplicated_name_exception.dart';
import 'package:z1racing/repositories/firebase_auth_repository.dart';
import 'package:z1racing/repositories/firebase_firestore_repository.dart';
import 'package:z1racing/repositories/game_repository_impl.dart';
import 'package:z1racing/repositories/preferences_repository.dart';

class MenuSettings extends StatefulWidget {
  const MenuSettings({super.key});

  static Future open({required BuildContext context}) {
    return showDialog(context: context, builder: (ctx) => const MenuSettings());
  }

  @override
  State<MenuSettings> createState() => _MenuSettingsState();
}

class _MenuSettingsState extends State<MenuSettings> {
  late String displayName;
  bool loading = false;
  String? errorText;
  bool enableMusic = false;

  @override
  void initState() {
    super.initState();
    displayName = FirebaseAuthRepository.instance.currentUser?.name ?? '';
    enableMusic = PreferencesRepository.instance.getEnableMusic();
  }

  Future<void> _nameUpdated(String newName) async {
    if (newName.length > 3 &&
        newName.length <= 15 &&
        FirebaseFirestoreRepository.instance.currentUser?.name != newName) {
      try {
        setState(() {
          loading = true;
        });
        await FirebaseFirestoreRepository.instance.updateName(newName);
        GameRepositoryImpl().reset();
      } on DuplicatedNameException catch (_) {
        setState(() {
          loading = false;
          errorText = AppLocalizations.of(context)!.errorDuplicateName;
        });
        return;
      } on Exception catch (exc) {
        debugPrint(exc.toString());
      }
      setState(() {
        loading = false;
        errorText = null;
      });
    } else {
      setState(() {
        loading = false;
        errorText = AppLocalizations.of(context)!.errorlengthName;
      });
    }
  }

  Widget _backButton(BuildContext context) {
    return Container(
      width: 100,
      child: ElevatedButton.icon(
        onPressed: () {
          if (!loading) {
            Navigator.of(context).pop();
          }
        },
        icon: Icon(
          Icons.arrow_back,
          color: loading ? Colors.white24 : Colors.white70,
        ),
        label: const Text(''),
      ),
    );
  }

  Widget _loadingWidget() {
    if (loading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    }

    return _version();
  }

  Widget _errorWidget() {
    if (errorText != null) {
      return Center(
        child: Text(
          errorText!,
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(color: Colors.redAccent),
          textAlign: TextAlign.center,
        ),
      );
    }

    return Container();
  }

  Widget _textfield() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.only(top: 17),
          width: 100,
          child: Text(
            '${AppLocalizations.of(context)!.nickName}: ',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        Expanded(
          child: CommonTextfield(
            initialText: displayName,
            onSubmitted: _nameUpdated,
            maxLength: 14,
          ),
        ),
      ],
    );
  }

  Widget _version() {
    final version = FirebaseAuthRepository.instance.packageInfo.version;
    return Container(
      width: MediaQuery.of(context).size.width,
      child: Text(
        AppLocalizations.of(context)!
            .version
            .replaceAll('%%VERSION%%', version),
        style: Theme.of(context)
            .textTheme
            .bodySmall
            ?.copyWith(color: Colors.white38),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _music() {
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

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black54,
      child: Container(
        margin: const EdgeInsets.all(10),
        width: MediaQuery.of(context).size.width,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _backButton(context),
            Expanded(
              child: ListView(
                children: [
                  _textfield(),
                  _errorWidget(),
                  _loadingWidget(),
                  _music(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
