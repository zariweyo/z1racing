import 'package:flutter/material.dart';
import 'package:z1racing/base/components/button_action.dart';
import 'package:z1racing/domain/repositories/firebase_firestore_repository.dart';
import 'package:z1racing/menus/widgets/settings/settings_avatar.dart';
import 'package:z1racing/menus/widgets/settings/settings_music.dart';
import 'package:z1racing/menus/widgets/settings/settings_nickname.dart';
import 'package:z1racing/menus/widgets/settings/settings_version.dart';

class MenuSettings extends StatefulWidget {
  const MenuSettings({super.key});

  static Future open({required BuildContext context}) {
    return showDialog(context: context, builder: (ctx) => const MenuSettings());
  }

  @override
  State<MenuSettings> createState() => _MenuSettingsState();
}

class _MenuSettingsState extends State<MenuSettings> {
  bool loading = false;

  @override
  void initState() {
    super.initState();
    FirebaseFirestoreRepository.instance.currentUserNotifier
        .addListener(onUserChange);
  }

  @override
  void dispose() {
    FirebaseFirestoreRepository.instance.currentUserNotifier
        .removeListener(onUserChange);
    super.dispose();
  }

  void onUserChange() {
    setState(() {});
  }

  Widget _backButton(BuildContext context) {
    return ButtonActions(
      onTap: () {
        if (!loading) {
          Navigator.of(context).pop();
        }
      },
      child: Icon(
        Icons.arrow_back,
        color: loading ? Colors.white24 : Colors.white70,
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

    return Container();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black,
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
                  SettingsNickname(
                    onLoading: (isLoading) {
                      setState(() {
                        loading = isLoading;
                      });
                    },
                  ),
                  _loadingWidget(),
                  const SettingsMusic(),
                  const SettingsAvatar(),
                  const SettingsVersion(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
