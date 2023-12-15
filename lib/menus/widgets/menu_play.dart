import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:z1racing/ads/controller/admob_controller.dart';
import 'package:z1racing/models/z1user.dart';
import 'package:z1racing/repositories/firebase_firestore_repository.dart';

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

  @override
  void initState() {
    super.initState();
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
  void dispose() {
    streamSubscription?.cancel();
    super.dispose();
  }

  Widget text() {
    final textTheme = Theme.of(context).textTheme;
    if (!canPlay) {
      return Text.rich(
        TextSpan(
          text: '',
          children: <InlineSpan>[
            const WidgetSpan(
              child: Icon(
                Icons.video_library_outlined,
                size: 30,
                color: Colors.red,
              ),
            ),
            TextSpan(
              text: ' ${AppLocalizations.of(context)!.notEnoghtCoinsToPlay}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 20,
                    color: Colors.blue,
                  ),
            ),
          ],
        ),
      );
    }
    return Text(
      AppLocalizations.of(context)!.play,
      style: textTheme.bodyLarge?.copyWith(color: Colors.white),
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
    if (loading) {
      return Container(
        padding: const EdgeInsets.all(8),
        child: const CircularProgressIndicator(
          color: Colors.blue,
        ),
      );
    }

    return ElevatedButton(
      autofocus: true,
      focusNode: FocusNode(
        onKey: (node, event) {
          switch (event.logicalKey) {
            case LogicalKeyboardKey.enter:
              node.unfocus();
              widget.onPressStart();
              break;
          }
          return KeyEventResult.ignored;
        },
      ),
      onPressed: onPress,
      child: text(),
    );
  }
}
