import 'package:flutter/material.dart';
import 'package:z1racing/domain/entities/z1track.dart';
import 'package:z1racing/domain/entities/z1user_award.dart';
import 'package:z1racing/domain/repositories/firebase_firestore_repository.dart';
import 'package:z1racing/menus/season/track_detail_play_page.dart';
import 'package:z1racing/menus/season/track_detail_score_page.dart';

class TrackDetailTab extends StatelessWidget {
  final Z1Track track;
  final Z1UserAward? award;

  const TrackDetailTab({required this.track, this.award, super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          TabBar(
            indicatorColor:
                FirebaseFirestoreRepository.instance.avatarColor.shade300,
            dividerColor: Colors.transparent,
            tabs: [
              tab(iconData: Icons.games),
              tab(iconData: Icons.scoreboard),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                TrackDetailPlayPage(track: track, award: award),
                TrackDetailScorePage(
                  track: track,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Tab tab({required IconData iconData}) {
    return Tab(
      icon: Icon(
        iconData,
        size: 30,
        color: FirebaseFirestoreRepository.instance.avatarColor.shade300,
      ),
    );
  }
}
