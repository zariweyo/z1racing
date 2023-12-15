import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:z1racing/base/components/duration_widget.dart';
import 'package:z1racing/models/z1track.dart';
import 'package:z1racing/models/z1user_race.dart';
import 'package:z1racing/repositories/firebase_auth_repository.dart';
import 'package:z1racing/repositories/game_repository_impl.dart';
import 'package:z1racing/repositories/track_repository_impl.dart';

class RaceTimeUserList extends StatefulWidget {
  final Function(TrackRequestDirection)? changeTrack;
  const RaceTimeUserList({super.key, this.changeTrack});

  @override
  State<RaceTimeUserList> createState() => _RaceTimeUserListState();
}

class _RaceTimeUserListState extends State<RaceTimeUserList> {
  List<Z1UserRace> currentZ1UserRaces = [];
  int firstPosition = 0;
  bool initiated = false;
  late Z1Track currentTrack;

  @override
  void initState() {
    currentTrack = GameRepositoryImpl().currentTrack;
    FirebaseAuthRepository.instance.currentUserNotifier.addListener(_update);
    _update();
    super.initState();
  }

  @override
  void didUpdateWidget(covariant RaceTimeUserList oldWidget) {
    setState(() {
      currentTrack = GameRepositoryImpl().currentTrack;
      _update();
    });
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    super.dispose();
    FirebaseAuthRepository.instance.currentUserNotifier.removeListener(_update);
  }

  void _update() {
    TrackRepositoryImpl()
        .getUserRaces(
      uid: FirebaseAuthRepository.instance.currentUser!.uid,
      trackId: currentTrack.trackId,
    )
        .then((trackRace) {
      if (mounted) {
        setState(() {
          initiated = true;
          currentZ1UserRaces = trackRace.races;
          firstPosition = trackRace.firstPosition;
        });
      }
    });
  }

  Widget dataRow(int index, Z1UserRace race) {
    final textTheme = Theme.of(context).textTheme;
    Color? color;
    if (FirebaseAuthRepository.instance.currentUser?.uid == race.uid) {
      color = Colors.green;
    }
    final bodyMedium =
        textTheme.bodyMedium?.copyWith(fontSize: 12, color: color);
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(1),
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              color: color ?? Colors.white70,
              border: Border.all(),
              borderRadius: const BorderRadius.all(Radius.circular(5)),
            ),
            child: Text(
              (firstPosition + index).toString(),
              style: bodyMedium?.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        Expanded(
          flex: 5,
          child: Text(
            race.metadata.displayName,
            style: bodyMedium?.copyWith(fontSize: 16),
            textAlign: TextAlign.start,
          ),
        ),
        Expanded(
          flex: 3,
          child: DurationWidget(
            duration: race.time,
            color: color,
            size: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        Expanded(
          flex: 3,
          child: DurationWidget(
            duration: race.bestLapTime,
            color: color,
            size: 24,
          ),
        ),
      ],
    );
  }

  Widget dataRowTitle() {
    final textTheme = Theme.of(context).textTheme;
    final bodyMedium =
        textTheme.bodyMedium?.copyWith(fontSize: 12, color: Colors.white);
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Expanded(
          child: Container(),
        ),
        Expanded(
          flex: 5,
          child: Text(
            AppLocalizations.of(context)!.name.toUpperCase(),
            style: bodyMedium?.copyWith(fontSize: 14),
            textAlign: TextAlign.start,
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            AppLocalizations.of(context)!.time.toUpperCase(),
            style: bodyMedium?.copyWith(fontSize: 14),
            textAlign: TextAlign.start,
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            AppLocalizations.of(context)!.fastLap.toUpperCase(),
            style: bodyMedium?.copyWith(fontSize: 14),
            textAlign: TextAlign.start,
          ),
        ),
      ],
    );
  }

  Widget title() {
    final textTheme = Theme.of(context).textTheme;
    final bodyMedium = textTheme.bodyMedium
        ?.copyWith(fontSize: 14, fontWeight: FontWeight.bold);
    final numLaps = AppLocalizations.of(context)!
        .numLaps
        .replaceAll('%%LAPS%%', currentTrack.numLaps.toString());
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Flexible(
            child: ElevatedButton.icon(
              onPressed: () =>
                  widget.changeTrack?.call(TrackRequestDirection.previous),
              icon: Icon(
                Icons.fast_rewind,
                color: textTheme.bodyMedium?.color ?? Colors.white54,
              ),
              label: const Text(''),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              '${currentTrack.name} ($numLaps)',
              style: bodyMedium,
              textAlign: TextAlign.center,
            ),
          ),
          Flexible(
            child: ElevatedButton.icon(
              onPressed: () =>
                  widget.changeTrack?.call(TrackRequestDirection.next),
              icon: Icon(
                Icons.fast_forward,
                color: textTheme.bodyMedium?.color ?? Colors.white54,
              ),
              label: const Text(''),
            ),
          ),
        ],
      ),
    );
  }

  Widget showLoading() {
    return const Center(
      child: CircularProgressIndicator(
        color: Colors.white54,
      ),
    );
  }

  Widget showList() {
    return ListView(
      children: currentZ1UserRaces.mapIndexed(dataRow).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height - 50,
      width: MediaQuery.of(context).size.width / 2.2,
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black54,
        border: Border.all(color: Colors.white38),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          title(),
          dataRowTitle(),
          Expanded(child: initiated ? showList() : showLoading()),
        ],
      ),
    );
  }
}
