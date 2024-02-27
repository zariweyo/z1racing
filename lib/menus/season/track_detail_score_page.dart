import 'package:flutter/material.dart';
import 'package:z1racing/domain/entities/z1track.dart';
import 'package:z1racing/menus/widgets/score/race_time_user_list.dart';

class TrackDetailScorePage extends StatefulWidget {
  final Z1Track track;

  const TrackDetailScorePage({required this.track, super.key});

  @override
  State<TrackDetailScorePage> createState() => _TrackDetailScorePageState();
}

class _TrackDetailScorePageState extends State<TrackDetailScorePage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return RaceTimeUserList(
      track: widget.track,
    );
  }
}
