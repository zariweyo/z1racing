import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:z1racing/ads/controller/admob_controller.dart';
import 'package:z1racing/base/components/button_action.dart';
import 'package:z1racing/models/z1user.dart';
import 'package:z1racing/repositories/firebase_firestore_repository.dart';
import 'package:z1racing/repositories/game_repository_impl.dart';

class MenuPlay extends StatefulWidget {
  final Function() onPressStart;

  const MenuPlay({required this.onPressStart, super.key});

  @override
  State<MenuPlay> createState() => _MenuPlayState();
}

class _MenuPlayState extends State<MenuPlay> {
  bool get canPlay => z1Coins > 0;
  int z1Coins = 0;
  bool loading = false;
  StreamSubscription<Z1User?>? streamSubscription;
  late bool enabled;

  @override
  void initState() {
    super.initState();
    enabled = GameRepositoryImpl().currentTrack.enabled;
    z1Coins = FirebaseFirestoreRepository.instance.currentUser?.z1Coins ?? 0;
    streamSubscription =
        FirebaseFirestoreRepository.instance.z1UserStream.listen((z1User) {
      z1Coins = z1User?.z1Coins ?? 0;
      loading = false;
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void didUpdateWidget(covariant MenuPlay oldWidget) {
    setState(() {
      enabled = GameRepositoryImpl().currentTrack.enabled;
    });
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    streamSubscription?.cancel();
    super.dispose();
  }

  Widget text() {
    final textTheme = Theme.of(context).textTheme;
    if (!canPlay) {
      return Container(
        width: 110,
        child: Row(
          children: [
            const Icon(
              Icons.monetization_on,
              size: 30,
              color: Colors.yellow,
            ),
            const SizedBox(
              width: 5,
            ),
            Text(
              AppLocalizations.of(context)!.play.toUpperCase(),
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
      );
    }
    return Text(
      AppLocalizations.of(context)!.play.toUpperCase(),
      style: textTheme.bodyLarge
          ?.copyWith(color: Colors.pink.shade50, fontWeight: FontWeight.bold),
    );
  }

  void onPress() {
    if (!canPlay) {
      setState(() {
        loading = true;
      });
      AdmobController.instance.showRewardedInterstitialAd().then((reward) {
        if (reward == null) {
          setState(() {
            loading = false;
            z1Coins += 1;
          });
        } else {
          FirebaseFirestoreRepository.instance
              .addZ1Coins(reward.amount.toInt());
        }
      });
    } else {
      FirebaseFirestoreRepository.instance.removeZ1Coins(1);
      widget.onPressStart();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!enabled) {
      return Container(
        padding: const EdgeInsets.all(8),
        child: Text(
          ' ${AppLocalizations.of(context)!.closed.toUpperCase()}',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontSize: 25,
                color: Colors.blue,
              ),
        ),
      );
    }

    if (loading) {
      return Container(
        padding: const EdgeInsets.all(8),
        child: const CircularProgressIndicator(
          color: Colors.blue,
        ),
      );
    }

    return ButtonActions(
      onTap: onPress,
      child: text(),
    );
  }
}
