import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:z1racing/ads/components/admob_reward_button.dart';
import 'package:z1racing/base/components/update_button.dart';
import 'package:z1racing/extensions/z1useravatar_extension.dart';
import 'package:z1racing/menus/widgets/menu_play.dart';
import 'package:z1racing/models/z1user.dart';
import 'package:z1racing/repositories/firebase_firestore_repository.dart';
import 'package:z1racing/repositories/game_repository_impl.dart';

class Menu extends StatefulWidget {
  final void Function() onPressStart;
  const Menu({required this.onPressStart, super.key});

  @override
  State<Menu> createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  bool initiated = false;
  late Z1User z1User;

  @override
  void initState() {
    z1User = FirebaseFirestoreRepository.instance.currentUser!;
    FirebaseFirestoreRepository.instance.currentUserNotifier
        .addListener(_currentUserModified);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    FirebaseFirestoreRepository.instance.currentUserNotifier
        .removeListener(_currentUserModified);
  }

  void _currentUserModified() {
    setState(() {
      z1User = FirebaseFirestoreRepository.instance.currentUser!;
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final numLaps = GameRepositoryImpl().currentTrack.numLaps;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(5),
          margin: const EdgeInsets.symmetric(horizontal: 5),
          decoration: BoxDecoration(
            color: Colors.black54,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Column(
                children: [
                  Image.asset(
                    'assets/images/logo_alpha.png',
                    height: 80,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 5),
                  MenuPlay(
                    onPressStart: widget.onPressStart,
                  ),
                  Text(
                    AppLocalizations.of(context)!
                        .numLaps
                        .replaceAll('%%LAPS%%', numLaps.toString()),
                    style: textTheme.bodyMedium,
                  ),
                  const AdmobRewardButton(),
                  const UpdateButton(),
                ],
              ),
              Column(
                children: [
                  Container(
                    height: 200,
                    child: Image.asset(z1User.z1UserAvatar.avatarBasePath),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
