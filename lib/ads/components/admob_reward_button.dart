import 'package:flutter/material.dart';
import 'package:z1racing/ads/controller/admob_controller.dart';
import 'package:z1racing/domain/repositories/firebase_firestore_repository.dart';

class AdmobRewardButton extends StatefulWidget {
  const AdmobRewardButton({super.key});

  @override
  State<AdmobRewardButton> createState() => _AdmobRewardButtonState();
}

class _AdmobRewardButtonState extends State<AdmobRewardButton> {
  bool loading = false;
  int z1Coins = 0;

  @override
  void initState() {
    super.initState();
    z1Coins = FirebaseFirestoreRepository.instance.currentUser?.z1Coins ?? 0;
    FirebaseFirestoreRepository.instance.currentUserNotifier
        .addListener(addReward);
  }

  @override
  void dispose() {
    FirebaseFirestoreRepository.instance.currentUserNotifier
        .removeListener(addReward);
    super.dispose();
  }

  void addReward() {
    if (mounted) {
      setState(() {
        loading = false;
        z1Coins =
            FirebaseFirestoreRepository.instance.currentUser?.z1Coins ?? 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Container(
        padding: const EdgeInsets.all(8),
        child: const CircularProgressIndicator(
          color: Colors.yellow,
        ),
      );
    }

    return ElevatedButton(
      onPressed: () {
        setState(() {
          loading = true;
        });
        AdmobController.instance.showRewardedInterstitialAd().then((reward) {
          if (reward == null) {
            setState(() {
              loading = false;
            });
          } else {
            FirebaseFirestoreRepository.instance
                .addZ1Coins(reward.amount.toInt());
          }
        });
      },
      child: Text.rich(
        TextSpan(
          text: '',
          children: <InlineSpan>[
            const WidgetSpan(
              child: Icon(
                Icons.monetization_on,
                size: 30,
                color: Colors.yellow,
              ),
            ),
            TextSpan(
              text: ' x ',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 14,
                    color: Colors.yellow,
                  ),
            ),
            TextSpan(
              text: '$z1Coins',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.yellow,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
