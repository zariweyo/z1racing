import 'package:flutter/material.dart';
import 'package:z1racing/domain/entities/z1track.dart';
import 'package:z1racing/domain/entities/z1user_award.dart';
import 'package:z1racing/domain/repositories/firebase_firestore_repository.dart';
import 'package:z1racing/menus/season/track_card.dart';

class SeasonTracks extends StatefulWidget {
  final int season;
  const SeasonTracks({this.season = 1, super.key});

  @override
  State<SeasonTracks> createState() => _SeasonTracksState();
}

class _SeasonTracksState extends State<SeasonTracks>
    with AutomaticKeepAliveClientMixin {
  List<Z1Track> tracks = [];
  Map<String, Z1UserAward> awards = {};
  @override
  void initState() {
    awards = FirebaseFirestoreRepository.instance.currentUser?.awards ?? {};
    FirebaseFirestoreRepository.instance.getSeasons().then((seasons) {
      FirebaseFirestoreRepository.instance
          .getTracksByIds(
            trackIds: seasons.first.z1TrackIds,
          )
          .then(
            (value) => setState(() {
              tracks = value;
            }),
          );
    });
    FirebaseFirestoreRepository.instance.currentUserNotifier
        .addListener(userChange);
    super.initState();
  }

  @override
  void dispose() {
    FirebaseFirestoreRepository.instance.currentUserNotifier
        .removeListener(userChange);
    super.dispose();
  }

  void userChange() {
    awards = FirebaseFirestoreRepository.instance.currentUser?.awards ?? {};
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(5),
        margin: const EdgeInsets.symmetric(horizontal: 5),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
          ),
          itemCount: tracks.length,
          itemBuilder: (ctx, index) {
            return TrackCard(
              track: tracks[index],
              award: awards[tracks[index].trackId],
              enable: index == 0 ||
                  (awards[tracks[index - 1].trackId] != null &&
                      awards[tracks[index - 1].trackId]!.rating > 0),
            );
          },
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
