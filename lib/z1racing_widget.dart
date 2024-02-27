import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flame/game.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart' hide Image, Gradient;
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:z1racing/base/components/loading_widget.dart';
import 'package:z1racing/base/theme/z1theme.dart';
import 'package:z1racing/data/game_repository_impl.dart';
import 'package:z1racing/domain/entities/z1version.dart';
import 'package:z1racing/domain/repositories/firebase_auth_repository.dart';
import 'package:z1racing/domain/repositories/firebase_firestore_repository.dart';
import 'package:z1racing/domain/repositories/preferences_repository.dart';
import 'package:z1racing/game/z1racing_game.dart';
import 'package:z1racing/home/z1racing_home.dart';
import 'package:z1racing/menus/common/alert_update_forced.dart';
import 'package:z1racing/menus/common/game_control.dart';
import 'package:z1racing/menus/common/game_over.dart';
import 'package:z1racing/services/main_service/main_service_bloc.dart';
import 'package:z1racing/services/main_service/main_service_states.dart';

class Z1RacingWidget extends StatefulWidget {
  const Z1RacingWidget({super.key});

  @override
  State<Z1RacingWidget> createState() => _Z1RacingWidgetState();
}

class _Z1RacingWidgetState extends State<Z1RacingWidget> {
  late GlobalKey key;
  MainServiceStateHome stateHome = MainServiceStateHome.loading;
  Color currentBackgroundColor = Colors.black;

  @override
  void initState() {
    key = GlobalKey();
    FirebaseAuthRepository.instance.init().then((_) async {
      await FirebaseFirestoreRepository.instance.init();
      currentUserChange();
      final z1versionState = FirebaseFirestoreRepository.instance.z1version
          .check(FirebaseAuthRepository.instance.packageInfo);
      switch (z1versionState) {
        case Z1VersionState.none:
        case Z1VersionState.updateAvailable:
          setState(() {
            stateHome = MainServiceStateHome.home;
          });
          break;
        case Z1VersionState.updateForced:
          setState(() {
            stateHome = MainServiceStateHome.update;
          });
          break;
      }
    });

    FirebaseFirestoreRepository.instance.currentUserNotifier
        .addListener(currentUserChange);

    startBgmMusic();

    super.initState();
  }

  @override
  void dispose() {
    FlameAudio.bgm.dispose();
    FirebaseFirestoreRepository.instance.currentUserNotifier
        .removeListener(currentUserChange);
    super.dispose();
  }

  void currentUserChange() {
    if (FirebaseFirestoreRepository.instance.avatarColor !=
        currentBackgroundColor) {
      setState(() {
        currentBackgroundColor =
            FirebaseFirestoreRepository.instance.avatarColor;
      });
    }
  }

  void _reset() {
    setState(() {
      GameRepositoryImpl().reset();
      key = GlobalKey();
      game = null;
      stateHome = MainServiceStateHome.home;
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
        await FlameAudio.bgm.play('race_background_4.mp3');
        final audioEnabled = PreferencesRepository.instance.getEnableMusic();
        if (!audioEnabled) {
          _stopAudio();
        }
      }
    } on Exception catch (_) {
      //
    }
  }

  Future<void> _resumeAudio() async {
    final audioEnabled = PreferencesRepository.instance.getEnableMusic();
    if (audioEnabled) {
      await FlameAudio.bgm.play('race_background_4.mp3');
      FlameAudio.bgm.resume();
    }
  }

  void _stopAudio() {
    FlameAudio.bgm.stop();
  }

  Widget _getHome() {
    FirebaseAnalytics.instance.logScreenView(screenName: stateHome.name);
    switch (stateHome) {
      case MainServiceStateHome.home:
        _resumeAudio();
        return const Z1RacingHome();
      case MainServiceStateHome.race:
        _stopAudio();
        return gameWidget();
      case MainServiceStateHome.loading:
        _stopAudio();
        return const LoadingWidget();
      case MainServiceStateHome.update:
        _stopAudio();
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
      title: 'Z1 Rally',
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      debugShowCheckedModeBanner: false,
      home: BlocProvider(
        create: (context) => MainServiceBloc(),
        child: BlocListener<MainServiceBloc, MainServiceState>(
          listener: listener,
          child: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                opacity: 0.2,
                colorFilter: ColorFilter.mode(
                  currentBackgroundColor,
                  BlendMode.modulate,
                ),
                image: const AssetImage(
                  'assets/images/background.png',
                ), // Especifica la ruta de tu imagen
                fit: BoxFit.none,
                repeat: ImageRepeat.repeat, // Esto hará que tu imagen se repita
              ),
            ),
            child: _getHome(),
          ),
        ),
      ),
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
        'game_over': (_, game) => GameOver(
              game,
              onReset: _reset,
              onRestart: _restart,
            ),
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

  void listener(BuildContext context, MainServiceState state) {
    if (state is MainServiceStatePage) {
      setState(() {
        stateHome = state.stateHome;
      });
    }
  }
}
