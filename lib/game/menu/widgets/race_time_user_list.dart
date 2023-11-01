import 'package:flutter/material.dart';
import 'package:z1racing/extensions/duration_extension.dart';
import 'package:z1racing/game/repositories/firebase_auth_repository.dart';
import 'package:z1racing/game/repositories/firebase_firestore_repository.dart';
import 'package:z1racing/game/repositories/game_repository_impl.dart';
import 'package:z1racing/game/repositories/models/z1track.dart';
import 'package:z1racing/game/repositories/models/z1user_race.dart';

class RaceTimeUserList extends StatefulWidget {
  RaceTimeUserList();

  @override
  State<RaceTimeUserList> createState() => _RaceTimeUserListState();
}

class _RaceTimeUserListState extends State<RaceTimeUserList> {
  List<Z1UserRace> currentZ1UserRaces = [];
  bool initiated = false;
  late Z1Track currentTrack;

  @override
  void initState() {
    currentTrack = GameRepositoryImpl().currentTrack;
    FirebaseFirestoreRepository()
        .getUserRaces(
            uid: FirebaseAuthRepository().currentUser!.uid,
            raceId: currentTrack.id)
        .then((raceList) {
      if (mounted)
        setState(() {
          initiated = true;
          currentZ1UserRaces = raceList;
        });
    });
    super.initState();
  }

  Widget dataRow(Z1UserRace race) {
    final textTheme = Theme.of(context).textTheme;
    Color? color;
    if (FirebaseAuthRepository().currentUser?.uid == race.uid) {
      color = Colors.green;
    }
    TextStyle? bodyMedium =
        textTheme.bodyMedium?.copyWith(fontSize: 12, color: color);
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Expanded(
            flex: 3,
            child: Text(
              race.metadata.displayName,
              style: bodyMedium,
              textAlign: TextAlign.start,
            )),
        Expanded(
            flex: 2,
            child: Text(
              race.time.toChronoString(),
              style: bodyMedium,
              textAlign: TextAlign.end,
            )),
        Expanded(
            flex: 2,
            child: Text(
              race.bestLapTime.toChronoString(),
              style: bodyMedium,
              textAlign: TextAlign.end,
            )),
      ],
    );
  }

  Widget title() {
    final textTheme = Theme.of(context).textTheme;
    TextStyle? bodyMedium = textTheme.bodyMedium
        ?.copyWith(fontSize: 14, fontWeight: FontWeight.bold);
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.only(bottom: 10),
      child: Text(
        currentTrack.name,
        style: bodyMedium,
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget showLoading() {
    return Center(
        child: CircularProgressIndicator(
      color: Colors.white54,
    ));
  }

  Widget showList() {
    return ListView(
      children: currentZ1UserRaces.map((e) => dataRow(e)).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
        color: Colors.transparent,
        child: Container(
          height: MediaQuery.of(context).size.height - 50,
          width: MediaQuery.of(context).size.width / 2.5,
          padding: EdgeInsets.all(20),
          margin: EdgeInsets.all(20),
          decoration: BoxDecoration(
              color: Colors.black54,
              border: Border.all(color: Colors.white38),
              borderRadius: BorderRadius.circular(20)),
          child: Column(children: [
            title(),
            Expanded(child: initiated ? showList() : showLoading())
          ]),
        ));
  }
}
