// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:z1racing/data/firebase_firestore_repository_mock.dart';
import 'package:z1racing/data/game_repository_impl.dart';
import 'package:z1racing/data/mock_data/data_repository_mock.dart';
import 'package:z1racing/domain/entities/z1car_shadow.dart';
import 'package:z1racing/domain/entities/z1track.dart';
import 'package:z1racing/domain/entities/z1user.dart';
import 'package:z1racing/domain/entities/z1user_race.dart';
import 'package:z1racing/domain/repositories/firebase_auth_repository.dart';
import 'package:z1racing/domain/repositories/firebase_firestore_repository.dart';
import 'package:z1racing/domain/repositories/track_repository.dart';
import 'package:z1racing/extensions/duration_extension.dart';
import 'package:z1racing/extensions/string_extension.dart';
import 'package:z1racing/menus/widgets/score/race_time_user_list.dart';

void main() {
  Z1User? currentAuthUser;
  late Z1Track track;

  setUp(() async {
    FirebaseAuthRepository.initInMockMode;
    FirebaseFirestoreRepository.initInMockMode;
    currentAuthUser = FirebaseFirestoreRepository.instance.currentUser;

    track = (await DataRepositoryMock.getTracks())
        .where((element) => element.trackId == 'rookie_1')
        .first;
    GameRepositoryImpl().currentTrack = track;
  });

  void resetMockRaces() {
    (FirebaseFirestoreRepository.initInMockMode
            as FirebaseFirestoreRepositoryMock)
        .loadFromMock();
  }

  testWidgets('Widget LeaderBoard TEST', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MaterialApp(
        home: RaceTimeUserList(
          track: track,
        ),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: const <Locale>[Locale('en')],
      ),
    );

    await tester.pump(const Duration(seconds: 3));

    expect(find.text('${track.name} (${track.numLaps} laps)'), findsOneWidget);
    expect(find.text(currentAuthUser?.name ?? '--'), findsOneWidget);
  });

  test('Test Mock User', () {
    final currentFirestoreUser =
        FirebaseFirestoreRepository.instance.currentUser;
    expect(currentAuthUser?.name, 'player 1');
    expect(currentAuthUser?.name, currentFirestoreUser?.name);
  });

  test('Test Get next and before tracks', () {
    final currentFirestoreUser =
        FirebaseFirestoreRepository.instance.currentUser;
    expect(currentAuthUser?.name, 'player 1');
    expect(currentAuthUser?.name, currentFirestoreUser?.name);
  });

  test('Update race time', () async {
    resetMockRaces();
    Future<Z1UserRace?> getCurrentUserRace() async {
      const uidCheck = 'uid2';
      final trackRaces = await TrackRepository.instance
          .getUserRaces(uid: uidCheck, trackId: track.trackId);

      return trackRaces.races
          .where((element) => element.uid == uidCheck)
          .firstOrNull;
    }

    Future<Z1UserRace?> updateRace(Z1UserRace newRace) async {
      GameRepositoryImpl().initRaceData();
      GameRepositoryImpl().z1UserRace = newRace;
      GameRepositoryImpl().saveRace();
      return getCurrentUserRace();
    }

    var userRaceInit = await getCurrentUserRace();

    expect(userRaceInit == null, false);

    final userRaceTimeImproved1 = await updateRace(
      userRaceInit!.copyWith(
        time: const Duration(seconds: 10),
      ),
    );
    expect(userRaceInit.time > userRaceTimeImproved1!.time, true);
    expect(userRaceInit.bestLap == userRaceTimeImproved1.bestLap, true);
    expect(
      userRaceInit.positionHash.compareTo(userRaceTimeImproved1.positionHash) >
          0,
      true,
    );

    userRaceInit = userRaceTimeImproved1;
    final userRaceTimeImproved2 = await updateRace(
      userRaceInit.copyWith(bestLap: const Duration(seconds: 9)),
    );
    expect(userRaceInit.time == userRaceTimeImproved2!.time, true);
    expect(userRaceInit.bestLap > userRaceTimeImproved2.bestLap, true);
    expect(
      userRaceInit.positionHash.compareTo(userRaceTimeImproved2.positionHash) >
          0,
      true,
    );

    userRaceInit = userRaceTimeImproved2;
    final userRaceTimeImproved3 = await updateRace(
      userRaceInit.copyWith(bestLap: const Duration(minutes: 100)),
    );
    expect(userRaceInit.time == userRaceTimeImproved3!.time, true);
    expect(userRaceInit.bestLap == userRaceTimeImproved3.bestLap, true);
    expect(
      userRaceInit.positionHash.compareTo(userRaceTimeImproved3.positionHash) ==
          0,
      true,
    );

    userRaceInit = userRaceTimeImproved3;
    final userRaceTimeImproved4 = await updateRace(
      userRaceInit.copyWith(
        time: const Duration(minutes: 100),
        bestLap: const Duration(minutes: 100),
      ),
    );
    expect(userRaceInit.time == userRaceTimeImproved4!.time, true);
    expect(userRaceInit.bestLap == userRaceTimeImproved4.bestLap, true);
    expect(
      userRaceInit.positionHash.compareTo(userRaceTimeImproved4.positionHash) ==
          0,
      true,
    );

    userRaceInit = userRaceTimeImproved4;
    final userRaceTimeImproved5 = await updateRace(
      userRaceInit.copyWith(
        time: const Duration(seconds: 1),
        bestLap: const Duration(seconds: 1),
      ),
    );
    expect(userRaceInit.time > userRaceTimeImproved5!.time, true);
    expect(userRaceInit.bestLap > userRaceTimeImproved5.bestLap, true);
    expect(
      userRaceInit.positionHash.compareTo(userRaceTimeImproved5.positionHash) >
          0,
      true,
    );
  });

  test('Test Mock LeaderBoard list', () async {
    resetMockRaces();
    const uidCheck = 'uid2';
    final trackRaces = await TrackRepository.instance
        .getUserRaces(uid: uidCheck, trackId: track.trackId);
    debugPrint(
      trackRaces.races
          .mapIndexed(
            (index, e) => "${e.uid == uidCheck ? '-->' : ''}  "
                '${index + trackRaces.firstPosition + 1} '
                '${e.metadata.displayName} '
                '${e.time.toChronoString()} '
                '${e.bestLap.toChronoString()} '
                '${e.positionHash} ',
          )
          .join('\n'),
    );
    expect(trackRaces.firstPosition >= 0, true);
    expect(trackRaces.races.isNotEmpty, true);
    expect(
      trackRaces.races
          .sorted((a, b) => a.positionHash.compareTo(b.positionHash))
          .map((e) => e.uid)
          .join(','),
      trackRaces.races.map((e) => e.uid).join(','),
    );
    expect(
      trackRaces.races.map((e) => e.uid).toSet().join(','),
      trackRaces.races.map((e) => e.uid).join(','),
    );
  });

  test('Mapping Z1CArShadow empty', () {
    final map = {
      'id': 'idShadow1',
      'z1UserRaceId': 'raceId1',
      'positions': [],
    };

    final z1CarShadowResult = Z1CarShadow.fromMap(map);

    expect(z1CarShadowResult.id, map['id']);
    expect(z1CarShadowResult.positions.length, 0);
  });

  test('Mapping Z1CArShadow 1 reg', () {
    final map = {
      'id': 'idShadow1',
      'z1UserRaceId': 'raceId1',
      'positions': [
        {
          'time': 63123,
          'position': {'x': 20, 'y': 30},
        },
      ],
    };

    final z1CarShadowResult = Z1CarShadow.fromMap(map);

    expect(z1CarShadowResult.id, map['id']);
    expect(z1CarShadowResult.positions.first.time.inSeconds, 63);
    expect(z1CarShadowResult.positions.first.position.y, 30);
  });

  test('Test Hash', () {
    expect('12'.toLimitHash(4), '0012');
    expect('12'.toLimitHash(2), '12');
    expect(''.toLimitHash(2), '00');
    expect('123456'.toLimitHash(3), '123');
    expect('123456'.toLimitHash(9), '000123456');
  });
}
