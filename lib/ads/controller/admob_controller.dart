// ignore_for_file: prefer_constructors_over_static_methods
import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdmobController {
  static AdmobController get instance {
    return _instance ?? AdmobController._internal();
  }

  static AdmobController? _instance;

  AdmobController({bool useMock = false}) {
    debugPrint('--> ADS INITIATED useMock: $useMock');
    final testDeviceIds =
        useMock ? <String>['8E1D5DFBC285B35C41A53D17D86CFEE3'] : <String>[];
    MobileAds.instance.updateRequestConfiguration(
      RequestConfiguration(testDeviceIds: testDeviceIds),
    );

    _createRewardedInterstitialAd();
  }

  factory AdmobController._internal({bool useMock = false}) {
    _instance = AdmobController(useMock: useMock);
    return _instance!;
  }

  static AdmobController get initInMockMode =>
      _instance ?? AdmobController._internal(useMock: true);

  static AdmobController get initInProdMode =>
      _instance ?? AdmobController._internal();

  InterstitialAd? _interstitialAd;

  RewardedAd? _rewardedAd;

  RewardedInterstitialAd? _rewardedInterstitialAd;

  final int maxFailedLoadAttempts = 3;

  static const AdRequest request = AdRequest(
    keywords: <String>['race', 'car', 'game'],
    nonPersonalizedAds: true,
    httpTimeoutMillis: 5,
  );

  Future<bool> _createRewardedInterstitialAd() {
    final completer = Completer<bool>();
    RewardedInterstitialAd.load(
      adUnitId: Platform.isAndroid
          ? 'ca-app-pub-6257464910095828/4693751411'
          : 'ca-app-pub-6257464910095828/2674733362',
      request: request,
      rewardedInterstitialAdLoadCallback: RewardedInterstitialAdLoadCallback(
        onAdLoaded: (RewardedInterstitialAd ad) {
          debugPrint('--> $ad loaded.');
          _rewardedInterstitialAd = ad;
          completer.complete(true);
        },
        onAdFailedToLoad: (LoadAdError error) async {
          debugPrint('--> RewardedInterstitialAd failed to load: $error');
          _rewardedInterstitialAd = null;
          completer.complete(false);
        },
      ),
    );
    return completer.future;
  }

  Future<RewardItem?> showRewardedInterstitialAd() async {
    final completer = Completer<RewardItem?>();
    FlameAudio.bgm.pause();
    final createdReward = await _createRewardedInterstitialAd();
    if (!createdReward) {
      completer.complete(null);
      return null;
    }
    if (_rewardedInterstitialAd == null) {
      debugPrint(
        '--> Warning: attempt to show rewarded interstitial before loaded.',
      );
      FlameAudio.bgm.resume();
      completer.complete(null);
    }
    _rewardedInterstitialAd!.fullScreenContentCallback =
        FullScreenContentCallback(
      onAdShowedFullScreenContent: (RewardedInterstitialAd ad) =>
          debugPrint('--> $ad onAdShowedFullScreenContent.'),
      onAdDismissedFullScreenContent: (RewardedInterstitialAd ad) {
        debugPrint('--> $ad onAdDismissedFullScreenContent.');
        ad.dispose();
        completer.complete(null);
      },
      onAdFailedToShowFullScreenContent:
          (RewardedInterstitialAd ad, AdError error) {
        debugPrint('--> $ad onAdFailedToShowFullScreenContent: $error');
        ad.dispose();
        FlameAudio.bgm.resume();
        completer.complete(null);
      },
    );

    _rewardedInterstitialAd!.setImmersiveMode(true);
    _rewardedInterstitialAd!.show(
      onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
        debugPrint(
          '--> $ad with reward $RewardItem(${reward.amount}, ${reward.type})',
        );
        if (!completer.isCompleted) {
          completer.complete(reward);
        }
      },
    );
    _rewardedInterstitialAd = null;

    return completer.future;
  }

  void openAdInspector() {
    MobileAds.instance.openAdInspector(
      (error) => log(
        'AdInspec ${error == null ? 'OPEN' : 'error: ${error.message ?? ''}'}',
      ),
    );
  }

  void dispose() {
    _interstitialAd?.dispose();
    _rewardedAd?.dispose();
    _rewardedInterstitialAd?.dispose();
  }
}
