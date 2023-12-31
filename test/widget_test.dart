// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:z1racing/extensions/duration_extension.dart';
import 'package:z1racing/extensions/string_extension.dart';
import 'package:z1racing/menus/widgets/race_time_user_list.dart';
import 'package:z1racing/models/z1track.dart';
import 'package:z1racing/models/z1track_races.dart';
import 'package:z1racing/models/z1user.dart';
import 'package:z1racing/models/z1user_race.dart';
import 'package:z1racing/repositories/firebase_firestore_repository_mock.dart';
import 'package:z1racing/repositories/mock_data/data_repository_mock.dart';
import 'package:z1racing/repositories/firebase_auth_repository.dart';
import 'package:z1racing/repositories/firebase_firestore_repository.dart';
import 'package:z1racing/repositories/game_repository_impl.dart';
import 'package:z1racing/repositories/track_repository_impl.dart';

void main() {
  Z1User? currentAuthUser;
  late Z1Track track;

  setUp(() async {
    FirebaseAuthRepository.initInMockMode;
    FirebaseFirestoreRepository.initInMockMode;
    currentAuthUser = FirebaseAuthRepository.instance.currentUser;

    track = (await DataRepositoryMock.getTracks())
        .where((element) => element.trackId == "Mock2TrackId_b1")
        .first;
    GameRepositoryImpl().loadTrack(track: track);
  });

  _resetMockRaces() {
    (FirebaseFirestoreRepository.initInMockMode
            as FirebaseFirestoreRepositoryMock)
        .loadUserRacesFromMock();
  }

  testWidgets('Widget LeaderBoard TEST', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(MaterialApp(home: RaceTimeUserList()));

    await tester.pump(Duration(seconds: 1));

    expect(find.text("${track.name} (${track.numLaps} laps)"), findsOneWidget);
    expect(find.text(currentAuthUser?.name ?? "--"), findsOneWidget);
  });

  test("Test Mock User", () {
    Z1User? currentFirestoreUser =
        FirebaseFirestoreRepository.instance.currentUser;
    expect(currentAuthUser?.name, 'player 1');
    expect(currentAuthUser?.name, currentFirestoreUser?.name);
  });

  test("Test Get next and before tracks", () {
    Z1User? currentFirestoreUser =
        FirebaseFirestoreRepository.instance.currentUser;
    expect(currentAuthUser?.name, 'player 1');
    expect(currentAuthUser?.name, currentFirestoreUser?.name);
  });

  test("Test Mock Track", () async {
    List<Z1Track> tracks = (await DataRepositoryMock.getTracks())
        .sorted((a, b) => a.initialDatetime.compareTo(b.initialDatetime));
    expect(tracks.length >= 3, true);

    Z1Track? currentTrack = tracks.first;

    doOper(
        {required TrackRequestDirection direction,
        required int indexExpected}) async {
      currentTrack = await FirebaseFirestoreRepository.instance
          .getTrackByActivedDate(
              dateTime: currentTrack!.initialDatetime, direction: direction);
      expect(currentTrack != null, true);
      expect(currentTrack!.id, tracks[indexExpected].id);
    }

    await doOper(direction: TrackRequestDirection.next, indexExpected: 1);
    await doOper(direction: TrackRequestDirection.next, indexExpected: 2);
    await doOper(direction: TrackRequestDirection.next, indexExpected: 3);
    await doOper(direction: TrackRequestDirection.previous, indexExpected: 2);
    await doOper(direction: TrackRequestDirection.previous, indexExpected: 1);
    await doOper(direction: TrackRequestDirection.previous, indexExpected: 0);
    await doOper(direction: TrackRequestDirection.next, indexExpected: 1);
    await doOper(direction: TrackRequestDirection.previous, indexExpected: 0);
  });

  test("Update race time", () async {
    _resetMockRaces();
    Future<Z1UserRace?> getCurrentUserRace() async {
      const uidCheck = "uid2";
      Z1TrackRaces trackRaces = await TrackRepositoryImpl()
          .getUserRaces(uid: uidCheck, trackId: track.trackId);

      return trackRaces.races
          .where((element) => element.uid == uidCheck)
          .firstOrNull;
    }

    Future<Z1UserRace?> updateRace(Z1UserRace newRace) async {
      GameRepositoryImpl().resetUserRace();
      GameRepositoryImpl().z1UserRace = newRace;
      GameRepositoryImpl().saveRace();
      return getCurrentUserRace();
    }

    Z1UserRace? userRaceInit = await getCurrentUserRace();

    expect(userRaceInit == null, false);

    Z1UserRace? userRaceTimeImproved1 =
        await updateRace(userRaceInit!.copyWith(time: Duration(seconds: 10)));
    expect(userRaceInit.time > userRaceTimeImproved1!.time, true);
    expect(userRaceInit.bestLap == userRaceTimeImproved1.bestLap, true);
    expect(
        userRaceInit.positionHash
                .compareTo(userRaceTimeImproved1.positionHash) >
            0,
        true);

    userRaceInit = userRaceTimeImproved1;
    Z1UserRace? userRaceTimeImproved2 =
        await updateRace(userRaceInit.copyWith(bestLap: Duration(seconds: 9)));
    expect(userRaceInit.time == userRaceTimeImproved2!.time, true);
    expect(userRaceInit.bestLap > userRaceTimeImproved2.bestLap, true);
    expect(
        userRaceInit.positionHash
                .compareTo(userRaceTimeImproved2.positionHash) >
            0,
        true);

    userRaceInit = userRaceTimeImproved2;
    Z1UserRace? userRaceTimeImproved3 = await updateRace(
        userRaceInit.copyWith(bestLap: Duration(minutes: 100)));
    expect(userRaceInit.time == userRaceTimeImproved3!.time, true);
    expect(userRaceInit.bestLap == userRaceTimeImproved3.bestLap, true);
    expect(
        userRaceInit.positionHash
                .compareTo(userRaceTimeImproved3.positionHash) ==
            0,
        true);

    userRaceInit = userRaceTimeImproved3;
    Z1UserRace? userRaceTimeImproved4 = await updateRace(userRaceInit.copyWith(
        time: Duration(minutes: 100), bestLap: Duration(minutes: 100)));
    expect(userRaceInit.time == userRaceTimeImproved4!.time, true);
    expect(userRaceInit.bestLap == userRaceTimeImproved4.bestLap, true);
    expect(
        userRaceInit.positionHash
                .compareTo(userRaceTimeImproved4.positionHash) ==
            0,
        true);

    userRaceInit = userRaceTimeImproved4;
    Z1UserRace? userRaceTimeImproved5 = await updateRace(userRaceInit.copyWith(
        time: Duration(seconds: 1), bestLap: Duration(seconds: 1)));
    expect(userRaceInit.time > userRaceTimeImproved5!.time, true);
    expect(userRaceInit.bestLap > userRaceTimeImproved5.bestLap, true);
    expect(
        userRaceInit.positionHash
                .compareTo(userRaceTimeImproved5.positionHash) >
            0,
        true);
  });

  test("Test Mock LeaderBoard list", () async {
    _resetMockRaces();
    const uidCheck = "uid2";
    Z1TrackRaces trackRaces = await TrackRepositoryImpl()
        .getUserRaces(uid: uidCheck, trackId: track.trackId);
    print(trackRaces.races
        .mapIndexed((index, e) =>
            "${e.uid == uidCheck ? '-->' : ''}  " +
            "${index + trackRaces.firstPosition + 1} " +
            "${e.metadata.displayName} " +
            "${e.time.toChronoString()} " +
            "${e.bestLap.toChronoString()} " +
            "${e.positionHash.toString()} " +
            "(${e.time.inMilliseconds} ${e.bestLapTime.inMilliseconds} ${e.secondsSinceEpoch} )")
        .join("\n"));
    expect(trackRaces.firstPosition >= 0, true);
    expect(trackRaces.races.isNotEmpty, true);
    expect(
        trackRaces.races
            .sorted((a, b) => a.positionHash.compareTo(b.positionHash))
            .map((e) => e.uid)
            .join(","),
        trackRaces.races.map((e) => e.uid).join(","));
    expect(trackRaces.races.map((e) => e.uid).toSet().join(","),
        trackRaces.races.map((e) => e.uid).join(","));
  });

  test("Test Hash", () {
    expect("12".toLimitHash(4), "0012");
    expect("12".toLimitHash(2), "12");
    expect("".toLimitHash(2), "00");
    expect("123456".toLimitHash(3), "123");
    expect("123456".toLimitHash(9), "000123456");
  });
}
