import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:z1racing/ads/components/admob_reward_button.dart';
import 'package:z1racing/base/components/update_button.dart';
import 'package:z1racing/menus/widgets/menu_play.dart';
import 'package:z1racing/menus/widgets/menu_settings.dart';
import 'package:z1racing/repositories/firebase_auth_repository.dart';
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

  @override
  void initState() {
    FirebaseAuthRepository.instance.currentUserNotifier
        .addListener(_currentUserModified);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    FirebaseAuthRepository.instance.currentUserNotifier
        .removeListener(_currentUserModified);
  }

  void _currentUserModified() {
    setState(() {});
  }

  Widget titleName() {
    final textTheme = Theme.of(context).textTheme;
    final name = FirebaseFirestoreRepository.instance.currentUser?.name ?? '';
    return Container(
      margin: const EdgeInsets.all(10),
      child: Text(
        AppLocalizations.of(context)!
            .homeHello
            .replaceAll('%%USERNAME%%', name.toUpperCase()),
        style: textTheme.bodyLarge
            ?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final numLaps = GameRepositoryImpl().currentTrack.numLaps;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(5),
          margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 20),
          decoration: BoxDecoration(
            color: Colors.black54,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              titleName(),
              Row(
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
                      GestureDetector(
                        onTap: () {
                          MenuSettings.open(context: context);
                        },
                        child: Text(
                          AppLocalizations.of(context)!.settings,
                          style: textTheme.bodyLarge
                              ?.copyWith(color: Colors.white),
                        ),
                      ),
                      const AdmobRewardButton(),
                      const UpdateButton(),
                    ],
                  ),
                  Column(
                    children: [
                      Container(
                        height: 200,
                        child: Image.asset('assets/images/woman_racer_1.png'),
                      ),
                    ],
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
