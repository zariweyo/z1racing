import 'package:flutter/widgets.dart';
import 'package:z1racing/menus/common/menu_header.dart';
import 'package:z1racing/menus/season/season_tracks.dart';
import 'package:z1racing/menus/widgets/menu.dart';

class Z1RacingHome extends StatefulWidget {
  const Z1RacingHome({super.key});

  @override
  State<Z1RacingHome> createState() => _Z1HomeState();
}

class _Z1HomeState extends State<Z1RacingHome> {
  bool loading = false;

  @override
  void initState() {
    /* if (GameRepositoryImpl().currentTrack.isEmpty) {
      _changeTrack(TrackRequestDirection.last);
    } */
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
/*         Expanded(
          flex: 5,
          child: Stack(
            alignment: AlignmentDirectional.center,
            children: [
              Z1RacingMap(
                z1track: GameRepositoryImpl().currentTrack,
                key: GlobalKey(),
              ),
              RaceTimeUserList(
                key: const ValueKey('RaceTimeUserList'),
                changeTrack: _changeTrack,
              ),
            ],
          ),
        ), */
        const Expanded(
          flex: 5,
          child: SeasonTracks(),
        ),
        Expanded(
          flex: 3,
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 20, right: 15),
                child: const MenuHeader(),
              ),
              Expanded(
                child: ListView(
                  children: const [
                    Menu(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
