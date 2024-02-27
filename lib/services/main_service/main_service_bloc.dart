import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:z1racing/ads/controller/admob_controller.dart';
import 'package:z1racing/data/game_repository_impl.dart';
import 'package:z1racing/domain/repositories/firebase_firestore_repository.dart';
import 'package:z1racing/services/main_service/main_service_events.dart';
import 'package:z1racing/services/main_service/main_service_states.dart';

enum TrackDetailCardReason { none, play }

class MainServiceBloc extends Bloc<MainServiceEvent, MainServiceState> {
  MainServiceBloc() : super(MainServiceStateInitial()) {
    on<MainServiceEventTrackSelected>(_mainServiceEventTrackSelected);
  }

  FutureOr<void> _mainServiceEventTrackSelected(
    MainServiceEventTrackSelected event,
    Emitter<MainServiceState> emit,
  ) async {
    final z1Coins =
        FirebaseFirestoreRepository.instance.currentUser?.z1Coins ?? 0;
    if (z1Coins == 0) {
      final reward =
          await AdmobController.instance.showRewardedInterstitialAd();
      if (reward != null) {
        FirebaseFirestoreRepository.instance.addZ1Coins(reward.amount.toInt());
      }
    } else {
      FirebaseFirestoreRepository.instance.removeZ1Coins(1);
    }

    GameRepositoryImpl().currentTrack = event.track;

    emit(MainServiceStatePage(stateHome: MainServiceStateHome.loading));

    await GameRepositoryImpl().loadRefRace();

    emit(MainServiceStatePage(stateHome: MainServiceStateHome.race));
  }
}
