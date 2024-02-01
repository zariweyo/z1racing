import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:z1racing/menus/widgets/score/score_user_column_title.dart';
import 'package:z1racing/menus/widgets/score/score_user_row.dart';
import 'package:z1racing/menus/widgets/score/score_user_title.dart';
import 'package:z1racing/models/z1track.dart';
import 'package:z1racing/models/z1user_race.dart';
import 'package:z1racing/repositories/firebase_auth_repository.dart';
import 'package:z1racing/repositories/game_repository_impl.dart';
import 'package:z1racing/repositories/track_repository_impl.dart';

class RaceTimeUserList extends StatefulWidget {
  final Function(TrackRequestDirection)? changeTrack;
  const RaceTimeUserList({super.key, this.changeTrack});

  @override
  State<RaceTimeUserList> createState() => _RaceTimeUserListState();
}

class _RaceTimeUserListState extends State<RaceTimeUserList> {
  Map<String, List<Z1UserRace>> currentZ1UserRaces = {};
  int firstPosition = 0;
  bool initiated = false;
  late Z1Track currentTrack;
  bool loadingTop = false;
  bool loadingBottom = false;
  ScrollController controller = ScrollController();
  bool endComplete = false;

  @override
  void initState() {
    currentTrack = GameRepositoryImpl().currentTrack;
    controller.addListener(_scrollListener);
    currentZ1UserRaces[currentTrack.trackId] = [];
    FirebaseAuthRepository.instance.currentUserNotifier.addListener(renameUser);
    initUpdate();
    super.initState();
  }

  @override
  void didUpdateWidget(covariant RaceTimeUserList oldWidget) {
    if (currentTrack != GameRepositoryImpl().currentTrack) {
      setState(() {
        currentTrack = GameRepositoryImpl().currentTrack;
        loadingTop = true;
        endComplete = false;
        currentZ1UserRaces[currentTrack.trackId] = [];
        initUpdate();
      });
    }
    super.didUpdateWidget(oldWidget);
  }

  void initUpdate() {
    _update(FirebaseAuthRepository.instance.currentUser!.uid).then((_) {
      if (currentZ1UserRaces[currentTrack.trackId]?.isNotEmpty ?? false) {
        final index = currentZ1UserRaces[currentTrack.trackId]?.indexWhere(
              (element) =>
                  element.uid ==
                  FirebaseAuthRepository.instance.currentUser!.uid,
            ) ??
            -1;
        if (index > 0) {
          controller.jumpTo(index * 40 + 1);
        }
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    FirebaseAuthRepository.instance.currentUserNotifier
        .removeListener(renameUser);
    controller.removeListener(_scrollListener);
  }

  void renameUser() {
    final index = currentZ1UserRaces[currentTrack.trackId]?.indexWhere(
          (element) =>
              element.uid == FirebaseAuthRepository.instance.currentUser?.uid,
        ) ??
        -1;
    if (index >= 0) {
      setState(() {
        currentZ1UserRaces[currentTrack.trackId]![index].metadata =
            currentZ1UserRaces[currentTrack.trackId]![index].metadata.copyWith(
                  displayName:
                      FirebaseAuthRepository.instance.currentUser?.name,
                );
      });
    }
  }

  Future<void> _scrollListener() async {
    if (currentZ1UserRaces[currentTrack.trackId] == null) {
      return;
    }
    if (controller.position.atEdge) {
      final isTop = controller.position.pixels == 0;
      if (isTop && !loadingTop) {
        if (firstPosition <= 1) {
          return;
        }
        if (currentZ1UserRaces[currentTrack.trackId]!.isNotEmpty) {
          final init = currentZ1UserRaces[currentTrack.trackId]!.length;
          await _update(
            currentZ1UserRaces[currentTrack.trackId]!.first.uid,
            userRacesOptions: UserRacesOptions.descending,
          );
          final res = currentZ1UserRaces[currentTrack.trackId]!.length - init;
          controller.jumpTo(res * 40 - 10);
        }
      } else if (!loadingBottom) {
        if (!endComplete &&
            currentZ1UserRaces[currentTrack.trackId]!.isNotEmpty) {
          final init = currentZ1UserRaces[currentTrack.trackId]!.length;
          await _update(
            currentZ1UserRaces[currentTrack.trackId]!.last.uid,
            userRacesOptions: UserRacesOptions.ascending,
          );
          controller.jumpTo(controller.position.pixels + 10);
          if (currentZ1UserRaces[currentTrack.trackId]!.length - init == 0) {
            endComplete = true;
          }
        }
      }
    }
  }

  Future<void> _update(
    String uid, {
    UserRacesOptions userRacesOptions = UserRacesOptions.both,
  }) {
    final completer = Completer();
    if (currentZ1UserRaces[currentTrack.trackId] == null) {
      completer.complete();
      return completer.future;
    }

    setState(() {
      if ([UserRacesOptions.both, UserRacesOptions.descending]
          .contains(userRacesOptions)) {
        loadingTop = true;
      } else {
        loadingBottom = true;
      }
    });
    TrackRepositoryImpl()
        .getUserRaces(
      uid: uid,
      trackId: currentTrack.trackId,
      userRacesOptions: userRacesOptions,
    )
        .then((trackRace) {
      if (mounted) {
        setState(() {
          initiated = true;
          currentZ1UserRaces[currentTrack.trackId]!
            ..addAll(
              trackRace.races.where(
                (element) =>
                    element.trackId == currentTrack.trackId &&
                    !currentZ1UserRaces[currentTrack.trackId]!
                        .contains(element),
              ),
            )
            ..sort((a, b) => a.positionHash.compareTo(b.positionHash));
          if ([UserRacesOptions.both, UserRacesOptions.descending]
              .contains(userRacesOptions)) {
            firstPosition = trackRace.firstPosition;
          }

          loadingTop = false;
          loadingBottom = false;
        });
      }
      completer.complete();
    });
    return completer.future;
  }

  Widget showLoading() {
    return LinearProgressIndicator(
      valueColor: AlwaysStoppedAnimation<Color>(Colors.pink.shade50),
      backgroundColor: Colors.transparent,
      minHeight: 1,
    );
  }

  Widget showList() {
    return ListView(
      controller: controller,
      children: currentZ1UserRaces[currentTrack.trackId]
              ?.mapIndexed(
                (index, z1Race) => ScoreUserRow(
                  position: firstPosition + index,
                  race: z1Race,
                ),
              )
              .toList() ??
          [],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height - 50,
      //width: MediaQuery.of(context).size.width / 2,
      padding: const EdgeInsets.all(5),
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black54,
        //border: Border.all(color: Colors.white38),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ScoreUserTitle(
            currentTrack: currentTrack,
            changeTrack: widget.changeTrack,
          ),
          const ScoreUserColumnsTitle(),
          if (loadingTop) showLoading(),
          Expanded(child: showList()),
          if (loadingBottom) showLoading(),
        ],
      ),
    );
  }
}
