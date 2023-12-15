import 'package:flutter/widgets.dart';
import 'package:z1racing/game/z1racing_map.dart';
import 'package:z1racing/menus/widgets/menu.dart';
import 'package:z1racing/menus/widgets/race_time_user_list.dart';
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
      _changeTrack(TrackRequestDirection.next);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Stack(
            alignment: AlignmentDirectional.center,
            children: [
              Z1RacingMap(
                key: GlobalKey(),
              ),
              RaceTimeUserList(changeTrack: _changeTrack),
            ],
          ),
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
    );
  }

  Future<void> _changeTrack(TrackRequestDirection direction) async {
    setState(() {
      loading = true;
    });
    final currentTrackDateTime =
        GameRepositoryImpl().currentTrack.initialDatetime;
    final track = await TrackRepositoryImpl()
        .getTrack(dateTime: currentTrackDateTime, direction: direction);
    if (track != null) {
      GameRepositoryImpl().currentTrack = track;
    }

    setState(() {
      loading = false;
    });
  }
}
