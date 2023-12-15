import 'package:flame/game.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart' hide Image, Gradient;
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:z1racing/base/components/loading_widget.dart';
import 'package:z1racing/base/theme/z1theme.dart';
import 'package:z1racing/game/z1racing_game.dart';
import 'package:z1racing/home/z1racing_home.dart';
import 'package:z1racing/menus/widgets/alert_update_forced.dart';
import 'package:z1racing/menus/widgets/game_control.dart';
import 'package:z1racing/menus/widgets/game_over.dart';
import 'package:z1racing/models/z1version.dart';
import 'package:z1racing/repositories/firebase_auth_repository.dart';
import 'package:z1racing/repositories/firebase_firestore_repository.dart';
import 'package:z1racing/repositories/game_repository_impl.dart';

class Z1RacingWidget extends StatefulWidget {
  const Z1RacingWidget({super.key});

  @override
  State<Z1RacingWidget> createState() => _Z1RacingWidgetState();
}

enum _Z1RacingWidgetStateHome { home, race, loading, update }

class _Z1RacingWidgetState extends State<Z1RacingWidget> {
  late GlobalKey key;
  _Z1RacingWidgetStateHome stateHome = _Z1RacingWidgetStateHome.loading;

  @override
  void initState() {
    key = GlobalKey();
    FirebaseAuthRepository.instance.init().then((_) async {
      await FirebaseFirestoreRepository.instance.init();
      final z1versionState = FirebaseFirestoreRepository.instance.z1version
          .check(FirebaseAuthRepository.instance.packageInfo);
      switch (z1versionState) {
        case Z1VersionState.none:
        case Z1VersionState.updateAvailable:
          setState(() {
            stateHome = _Z1RacingWidgetStateHome.home;
          });
          break;
        case Z1VersionState.updateForced:
          setState(() {
            stateHome = _Z1RacingWidgetStateHome.update;
          });
          break;
      }
    });

    startBgmMusic();

    super.initState();
  }

  @override
  void dispose() {
    FlameAudio.bgm.dispose();
    super.dispose();
  }

  void _reset() {
    setState(() {
      GameRepositoryImpl().reset();
      key = GlobalKey();
      game = null;
      stateHome = _Z1RacingWidgetStateHome.home;
    });
  }

  void _restart() {
    setState(() {
      GameRepositoryImpl().restart();
      game = null;
      key = GlobalKey();
    });
  }

  Future<void> startBgmMusic() async {
    try {
      if (!FlameAudio.bgm.isPlaying) {
        FlameAudio.bgm.initialize();
        FlameAudio.bgm.play('race_background_4.mp3');
      }
    } on Exception catch (_) {
      //
    }
  }

  Future<void> onPressStart() async {
    setState(() {
      stateHome = _Z1RacingWidgetStateHome.loading;
    });

    await GameRepositoryImpl().loadRefRace();

    setState(() {
      stateHome = _Z1RacingWidgetStateHome.race;
    });
  }

  Widget _getHome() {
    switch (stateHome) {
      case _Z1RacingWidgetStateHome.home:
        FlameAudio.bgm.resume();
        return Z1RacingHome(
          onPressStart: onPressStart,
        );
      case _Z1RacingWidgetStateHome.race:
        FlameAudio.bgm.stop();
        return gameWidget();
      case _Z1RacingWidgetStateHome.loading:
        FlameAudio.bgm.stop();
        return const LoadingWidget();
      case _Z1RacingWidgetStateHome.update:
        FlameAudio.bgm.stop();
        return const AlertUpdateForced();
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
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      debugShowCheckedModeBanner: false,
      home: _getHome(),
      theme: theme,
    );
  }

  GameWidget<Z1RacingGame>? game;

  Widget gameWidget() {
    game ??= GameWidget<Z1RacingGame>(
      key: key,
      game: Z1RacingGame(),
      loadingBuilder: (context) =>
          const LoadingWidget(key: ValueKey('InitialLoadingWidget')),
      overlayBuilderMap: {
        'game_over': (_, game) => GameOver(game, onReset: _reset),
        'game_control': (_, game) => GameControl(
              gameRef: game,
              onReset: _reset,
              onRestart: _restart,
            ),
      },
      initialActiveOverlays: const [],
    );

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
      child: game!,
    );
  }
}
