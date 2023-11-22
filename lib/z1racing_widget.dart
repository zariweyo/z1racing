import 'package:flame/game.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart' hide Image, Gradient;
import 'package:flutter/services.dart';
import 'package:z1racing/base/components/loading_widget.dart';
import 'package:z1racing/base/theme/z1theme.dart';
import 'package:z1racing/menus/widgets/alert_update_forced.dart';
import 'package:z1racing/menus/widgets/game_control.dart';

import 'package:z1racing/menus/widgets/game_over.dart';
import 'package:z1racing/menus/widgets/menu.dart';
import 'package:z1racing/menus/widgets/race_time_user_list.dart';
import 'package:z1racing/models/z1version.dart';
import 'package:z1racing/repositories/firebase_auth_repository.dart';
import 'package:z1racing/repositories/firebase_firestore_repository.dart';
import 'package:z1racing/repositories/game_repository_impl.dart';
import 'package:z1racing/models/z1track.dart';
import 'package:z1racing/repositories/track_repository_impl.dart';
import 'package:z1racing/game/z1racing_game.dart';

class Z1RacingWidget extends StatefulWidget {
  const Z1RacingWidget({super.key});

  @override
  State<Z1RacingWidget> createState() => _Z1RacingWidgetState();
}

enum _Z1RacingWidgetStateHome { normal, loading, update }

class _Z1RacingWidgetState extends State<Z1RacingWidget> {
  late GlobalKey key;
  _Z1RacingWidgetStateHome stateHome = _Z1RacingWidgetStateHome.loading;

  @override
  void initState() {
    key = GlobalKey();
    FirebaseAuthRepository.instance.init().then((_) async {
      await FirebaseFirestoreRepository.instance.init();
      Z1VersionState z1versionState = FirebaseFirestoreRepository
          .instance.z1version
          .check(FirebaseAuthRepository.instance.packageInfo);
      switch (z1versionState) {
        case Z1VersionState.none:
        case Z1VersionState.updateAvailable:
          await _changeTrack(TrackRequestDirection.next);
          break;
        case Z1VersionState.updateForced:
          setState(() {
            stateHome = _Z1RacingWidgetStateHome.update;
          });
          break;
      }
    });

    super.initState();
  }

  @override
  dispose() {
    FlameAudio.bgm.dispose();
    super.dispose();
  }

  _changeTrack(TrackRequestDirection direction) async {
    setState(() {
      stateHome = _Z1RacingWidgetStateHome.loading;
    });
    DateTime currentTrackDateTime =
        GameRepositoryImpl().currentTrack.initialDatetime;
    Z1Track? track = await TrackRepositoryImpl()
        .getTrack(dateTime: currentTrackDateTime, direction: direction);
    if (track != null) {
      GameRepositoryImpl().loadTrack(track: track);
    }
    setState(() {
      stateHome = _Z1RacingWidgetStateHome.normal;
      key = GlobalKey();
      game = null;
    });
  }

  _reset() {
    setState(() {
      GameRepositoryImpl().reset();
      key = GlobalKey();
      game = null;
    });
  }

  _getHome() {
    switch (stateHome) {
      case _Z1RacingWidgetStateHome.normal:
        return gameWidget();
      case _Z1RacingWidgetStateHome.loading:
        return LoadingWidget();
      case _Z1RacingWidgetStateHome.update:
        return AlertUpdateForced();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Z1Theme().themeData;

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    return MaterialApp(
      title: 'Z1 Racing',
      debugShowCheckedModeBanner: false,
      home: _getHome(),
      theme: theme,
    );
  }

  GameWidget<Z1RacingGame>? game;

  Widget gameWidget() {
    if (game == null) {
      game = GameWidget<Z1RacingGame>(
        key: key,
        game: Z1RacingGame(),
        loadingBuilder: (context) =>
            LoadingWidget(key: ValueKey("InitialLoadingWidget")),
        overlayBuilderMap: {
          'menu': (_, game) => Menu(game),
          'timeList': (_, game) => RaceTimeUserList(changeTrack: _changeTrack),
          'game_over': (_, game) => GameOver(game, onReset: _reset),
          'game_control': (_, game) =>
              GameControl(gameRef: game, onReset: _reset),
        },
        initialActiveOverlays: const ['menu'],
      );
    }

    return FocusScope(
        onKeyEvent: (node, event) {
          if (event is KeyDownEvent) {
            switch (event.logicalKey) {
              case LogicalKeyboardKey.arrowUp:
                FocusManager.instance.primaryFocus?.previousFocus();
                break;
              case LogicalKeyboardKey.arrowDown:
                FocusManager.instance.primaryFocus?.nextFocus();
                break;
            }
          }
          return KeyEventResult.handled;
        },
        child: game!);
  }
}
