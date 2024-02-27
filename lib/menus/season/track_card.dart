import 'package:flame/extensions.dart';
import 'package:flutter/material.dart';
import 'package:z1racing/base/components/duration_widget.dart';
import 'package:z1racing/base/components/rate_in_stars.dart';
import 'package:z1racing/domain/entities/z1track.dart';
import 'package:z1racing/domain/entities/z1user_award.dart';
import 'package:z1racing/domain/repositories/firebase_firestore_repository.dart';
import 'package:z1racing/extensions/z1useravatar_extension.dart';
import 'package:z1racing/game/z1racing_map.dart';
import 'package:z1racing/menus/season/track_detail_card.dart';
import 'package:z1racing/menus/season/track_params.dart';

class TrackCard extends StatelessWidget {
  final Z1Track track;
  final Z1UserAward? award;
  final bool enable;

  const TrackCard({
    required this.track,
    required this.enable,
    this.award,
    super.key,
  });

  Color get avatarColor =>
      FirebaseFirestoreRepository
          .instance.currentUser?.z1UserAvatar.avatarBackgroundColor ??
      Colors.grey;

  Widget get title => Container(
        margin: const EdgeInsets.all(5),
        child: Text(
          track.name,
          textAlign: TextAlign.center,
        ),
      );

  void onTap(BuildContext context) {
    if (enable) {
      TrackDetailCard.open(track: track, award: award, context: context);
    }
  }

  Widget _showKey() {
    if (enable) {
      return Container();
    }
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Icon(
        Icons.lock,
        color: Colors.white,
        size: 60,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap(context),
      child: Stack(
        alignment: AlignmentDirectional.center,
        children: [
          Container(
            height: 300,
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(20),
            ),
            margin: const EdgeInsets.all(10),
            child: Column(
              children: [
                title,
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TrackParams(
                      track: track,
                    ),
                    Expanded(
                      child: Z1RacingMap(
                        z1track: track,
                        size: const Offset(100, 100),
                        key: GlobalKey(),
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    DurationWidget(
                      duration: award?.time ?? Duration.zero,
                      color: award == null
                          ? Colors.grey
                          : avatarColor.brighten(0.4),
                      size: 25,
                      fontWeight: FontWeight.bold,
                    ),
                    RatingStars(
                      rating: award?.rating.toDouble() ?? 0,
                      iconSize: 25,
                    ),
                  ],
                ),
              ],
            ),
          ),
          _showKey(),
        ],
      ),
    );
  }
}
