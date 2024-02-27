import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:z1racing/base/components/rate_in_stars.dart';
import 'package:z1racing/domain/entities/z1track.dart';
import 'package:z1racing/domain/entities/z1user_award.dart';
import 'package:z1racing/game/z1racing_map.dart';
import 'package:z1racing/menus/common/menu_play.dart';
import 'package:z1racing/services/main_service/main_service_bloc.dart';

class TrackDetailPlayPage extends StatelessWidget {
  final Z1Track track;
  final Z1UserAward? award;

  const TrackDetailPlayPage({
    required this.track,
    required this.award,
    super.key,
  });

  void onPlay(BuildContext context) {
    Navigator.of(context).pop(TrackDetailCardReason.play);
  }

  Widget get title => Container(
        margin: const EdgeInsets.all(5),
        child: Text(
          track.name,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 21),
        ),
      );

  Widget goal(String text, double pos) {
    return Row(
      children: [
        RatingStars(
          rating: pos,
          iconSize: 25,
        ),
        Text(text),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          flex: 4,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              title,
              Expanded(
                child: Z1RacingMap(
                  z1track: track,
                  size: const Offset(200, 140),
                  key: GlobalKey(),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          flex: 4,
          child: Column(
            children: [
              RatingStars(
                rating: (award?.rating ?? 0).toDouble(),
                iconSize: 50,
              ),
              goal(AppLocalizations.of(context)!.goal1, 3),
              goal(AppLocalizations.of(context)!.goal2, 2),
              goal(AppLocalizations.of(context)!.goal3, 1),
              MenuPlay(
                onPressStart: () => onPlay(context),
                track: track,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
