import 'package:flutter/widgets.dart';
import 'package:z1racing/game/z1racing_map.dart';
import 'package:z1racing/menus/widgets/menu.dart';
import 'package:z1racing/menus/widgets/menu_header.dart';
import 'package:z1racing/menus/widgets/score/race_time_user_list.dart';
import 'package:z1racing/repositories/game_repository_impl.dart';
import 'package:z1racing/repositories/track_repository_impl.dart';

class Z1RacingHome extends StatefulWidget {
  final void Function() onPressStart;
  const Z1RacingHome({required this.onPressStart, super.key});

  @override
  State<Z1RacingHome> createState() => _Z1HomeState();
}

class _Z1HomeState extends State<Z1RacingHome> {
  bool loading = false;

  @override
  void initState() {
    if (GameRepositoryImpl().currentTrack.isEmpty) {
      _changeTrack(TrackRequestDirection.last);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 5,
          child: Stack(
            alignment: AlignmentDirectional.center,
            children: [
              Z1RacingMap(
                key: GlobalKey(),
              ),
              RaceTimeUserList(
                key: const ValueKey('RaceTimeUserList'),
                changeTrack: _changeTrack,
              ),
            ],
          ),
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
                  children: [
                    Menu(
                      onPressStart: widget.onPressStart,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _changeTrack(TrackRequestDirection direction) async {
    setState(() {
      loading = true;
    });
    final vorder = GameRepositoryImpl().currentTrack.vorder;

    final track = await TrackRepositoryImpl()
        .getTrack(vorder: vorder, direction: direction);
    if (track != null) {
      GameRepositoryImpl().currentTrack = track;
    }

    setState(() {
      loading = false;
    });
  }
}
