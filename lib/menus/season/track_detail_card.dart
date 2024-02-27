import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:z1racing/base/components/button_action.dart';
import 'package:z1racing/domain/entities/z1track.dart';
import 'package:z1racing/domain/entities/z1user_award.dart';
import 'package:z1racing/menus/season/track_detail_tab.dart';
import 'package:z1racing/menus/season/track_params.dart';
import 'package:z1racing/services/main_service/main_service_bloc.dart';
import 'package:z1racing/services/main_service/main_service_events.dart';

class TrackDetailCard extends StatelessWidget {
  static Future open({
    required Z1Track track,
    required BuildContext context,
    Z1UserAward? award,
  }) {
    return showDialog(
      context: context,
      builder: (ctx) => TrackDetailCard(track: track, award: award),
    ).then((value) {
      if (value is TrackDetailCardReason) {
        switch (value) {
          case TrackDetailCardReason.play:
            BlocProvider.of<MainServiceBloc>(context)
                .add(MainServiceEventTrackSelected(track: track));
            break;
          case TrackDetailCardReason.none:
        }
      }
    });
  }

  final Z1Track track;
  final Z1UserAward? award;
  const TrackDetailCard({
    required this.track,
    this.award,
    super.key,
  });

  Widget _backButton(BuildContext context) {
    return ButtonActions(
      onTap: () {
        Navigator.of(context).pop(TrackDetailCardReason.none);
      },
      child: const Icon(
        Icons.arrow_back,
        color: Colors.white70,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        margin: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                children: [
                  _backButton(context),
                  TrackParams(
                    track: track,
                    scale: 1.5,
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 5,
              child: TrackDetailTab(
                track: track,
                award: award,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
