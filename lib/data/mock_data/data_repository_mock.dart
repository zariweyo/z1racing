import 'package:z1racing/data/mock_data/mock_track.dart';
import 'package:z1racing/domain/entities/z1season.dart';
import 'package:z1racing/domain/entities/z1track.dart';
import 'package:z1racing/domain/entities/z1user.dart';
import 'package:z1racing/domain/entities/z1user_award.dart';
import 'package:z1racing/domain/entities/z1user_race.dart';

class DataRepositoryMock {
  static List<Z1UserRace> getUserRaces() {
    final listMap = <Map<String, dynamic>>[
      {
        'uid': 'uid1',
        'trackId': 'rookie_1',
        'time': 101453,
        'bestLap': 17712,
        'lapTimes': [17467, 17467, 16812, 17467, 17467],
        'metadata': {'carId': '', 'displayName': 'player 1', 'numLaps': 5},
        'positionHash': '001014530001771201701020953',
        'updated': 1701020953,
      },
      {
        'uid': 'uid2',
        'trackId': 'rookie_1',
        'time': 86553,
        'bestLap': 16812,
        'lapTimes': [17467, 17467, 16812, 17467, 17467],
        'metadata': {'carId': '', 'displayName': 'player 2', 'numLaps': 5},
        'positionHash': '000865530001681201701021953',
        'updated': 1701021953,
      },
      {
        'uid': 'uid3',
        'trackId': 'rookie_1',
        'time': 89753,
        'bestLap': 16812,
        'lapTimes': [17467, 17467, 16812, 17467, 17467],
        'metadata': {'carId': '', 'displayName': 'player 3', 'numLaps': 5},
        'positionHash': '000897530001681201701022953',
        'updated': 1701022953,
      },
      {
        'uid': 'uid4',
        'trackId': 'rookie_1',
        'time': 87753,
        'bestLap': 16812,
        'lapTimes': [17467, 17467, 16812, 17467, 17467],
        'metadata': {'carId': '', 'displayName': 'player 4', 'numLaps': 5},
        'positionHash': '000877530001681201701023953',
        'updated': 1701023953,
      },
      {
        'uid': 'uid5',
        'trackId': 'rookie_1',
        'time': 89953,
        'bestLap': 16811,
        'lapTimes': [17467, 17467, 16812, 17467, 17467],
        'metadata': {'carId': '', 'displayName': 'player 5', 'numLaps': 5},
        'positionHash': '000899530001681101701024953',
        'updated': 1701024953,
      },
      {
        'uid': 'uid6',
        'trackId': 'rookie_1',
        'time': 89963,
        'bestLap': 16813,
        'lapTimes': [17467, 17467, 16812, 17467, 17467],
        'metadata': {'carId': '', 'displayName': 'player 6', 'numLaps': 5},
        'positionHash': '000899630001681301701025953',
        'updated': 1701025953,
      },
      {
        'uid': 'uid7',
        'trackId': 'rookie_1',
        'time': 90953,
        'bestLap': 16813,
        'lapTimes': [17467, 17467, 16812, 17467, 17467],
        'metadata': {'carId': '', 'displayName': 'player 7', 'numLaps': 5},
        'positionHash': '000909530001681301701024953',
        'updated': 1701024953,
      },
      {
        'uid': 'uid8',
        'trackId': 'rookie_1',
        'time': 91953,
        'bestLap': 16813,
        'lapTimes': [17467, 17467, 16812, 17467, 17467],
        'metadata': {'carId': '', 'displayName': 'player 8', 'numLaps': 5},
        'positionHash': '000919530001681301701025953',
        'updated': 1701025953,
      },
      {
        'uid': 'uid9',
        'trackId': 'rookie_1',
        'time': 92953,
        'bestLap': 16813,
        'lapTimes': [17467, 17467, 16812, 17467, 17467],
        'metadata': {'carId': '', 'displayName': 'player 9', 'numLaps': 5},
        'positionHash': '000929530001681301701025953',
        'updated': 1701025953,
      },
      {
        'uid': 'uid10',
        'trackId': 'rookie_1',
        'time': 93953,
        'bestLap': 16813,
        'lapTimes': [17467, 17467, 16812, 17467, 17467],
        'metadata': {'carId': '', 'displayName': 'player 10', 'numLaps': 5},
        'positionHash': '000939530001681301701025953',
        'updated': 1701025953,
      },
      {
        'uid': 'uid11',
        'trackId': 'rookie_1',
        'time': 94953,
        'bestLap': 16813,
        'lapTimes': [17467, 17467, 16812, 17467, 17467],
        'metadata': {'carId': '', 'displayName': 'player 11', 'numLaps': 5},
        'positionHash': '000949530001681301701025953',
        'updated': 1701025953,
      },
      {
        'uid': 'uid12',
        'trackId': 'rookie_1',
        'time': 95953,
        'bestLap': 16813,
        'lapTimes': [17467, 17467, 16812, 17467, 17467],
        'metadata': {'carId': '', 'displayName': 'player 12', 'numLaps': 5},
        'positionHash': '000959530001681301701025953',
        'updated': 1701025953,
      },
      {
        'uid': 'uid13',
        'trackId': 'rookie_1',
        'time': 96953,
        'bestLap': 16813,
        'lapTimes': [17467, 17467, 16812, 17467, 17467],
        'metadata': {'carId': '', 'displayName': 'player 13', 'numLaps': 5},
        'positionHash': '000969530001681301703025953',
        'updated': 1703025953,
      },
      {
        'uid': 'uid14',
        'trackId': 'rookie_1',
        'time': 97953,
        'bestLap': 16813,
        'lapTimes': [17467, 17467, 16812, 17467, 17467],
        'metadata': {'carId': '', 'displayName': 'player 14', 'numLaps': 5},
        'positionHash': '000979530001681301701025953',
        'updated': 1701025953,
      },
      {
        'uid': 'uid15',
        'trackId': 'rookie_1',
        'time': 98953,
        'bestLap': 16813,
        'lapTimes': [17467, 17467, 16812, 17467, 17467],
        'metadata': {'carId': '', 'displayName': 'player 15', 'numLaps': 5},
        'positionHash': '000989530001681301701025953',
        'updated': 1701025953,
      },
      {
        'uid': 'uid16',
        'trackId': 'rookie_1',
        'time': 99953,
        'bestLap': 16813,
        'lapTimes': [17467, 17467, 16812, 17467, 17467],
        'metadata': {'carId': '', 'displayName': 'player 16', 'numLaps': 5},
        'positionHash': '000999530001681301701025953',
        'updated': 1701025953,
      },
      {
        'uid': 'uid17',
        'trackId': 'rookie_1',
        'time': 100953,
        'bestLap': 16813,
        'lapTimes': [17467, 17467, 16812, 17467, 17467],
        'metadata': {'carId': '', 'displayName': 'player 17', 'numLaps': 5},
        'positionHash': '001009530001681301701025953',
        'updated': 1701025953,
      },
      {
        'uid': 'uid18',
        'trackId': 'rookie_1',
        'time': 101953,
        'bestLap': 16813,
        'lapTimes': [17467, 17467, 16812, 17467, 17467],
        'metadata': {'carId': '', 'displayName': 'player 18', 'numLaps': 5},
        'positionHash': '001019530001681301701025953',
        'updated': 1701025953,
      },
      {
        'uid': 'uid19',
        'trackId': 'rookie_1',
        'time': 102953,
        'bestLap': 16813,
        'lapTimes': [17467, 17467, 16812, 17467, 17467],
        'metadata': {'carId': '', 'displayName': 'player 19', 'numLaps': 5},
        'positionHash': '001029530001681301701025953',
        'updated': 1701025953,
      },
      {
        'uid': 'uid20',
        'trackId': 'rookie_1',
        'time': 103953,
        'bestLap': 16813,
        'lapTimes': [17467, 17467, 16812, 17467, 17467],
        'metadata': {'carId': '', 'displayName': 'player 20', 'numLaps': 5},
        'positionHash': '001039530001681301701025953',
        'updated': 1701025953,
      },
      {
        'uid': 'uid21',
        'trackId': 'rookie_1',
        'time': 104953,
        'bestLap': 16813,
        'lapTimes': [17467, 17467, 16812, 17467, 17467],
        'metadata': {'carId': '', 'displayName': 'player 21', 'numLaps': 5},
        'positionHash': '001049530001681301702025953',
        'updated': 1702025953,
      }
    ];
    return listMap.map(Z1UserRace.fromMap).toList();
  }

  static Future<Z1UserRace?> getUserRace() async {
    final map = <String, dynamic>{};
    return Z1UserRace.fromMap(map);
  }

  static Z1User getUser() => Z1User(
        uid: 'uid1',
        name: 'player 1',
        z1Coins: 100,
        awards: {
          'rookie_1': Z1UserAward(
            trackId: 'rookie_1',
            rating: 1,
            bestLap: const Duration(milliseconds: 6300),
            time: const Duration(milliseconds: 6300),
          ),
          'rookie_2': Z1UserAward(
            trackId: 'rookie_2',
            rating: 1,
            bestLap: const Duration(milliseconds: 6300),
            time: const Duration(milliseconds: 6300),
          ),
        },
      );

  static List<Z1User> getUsers() => [
        getUser(),
        Z1User(uid: 'uid2', name: 'player 2', z1Coins: 100),
        Z1User(uid: 'uid3', name: 'player 3', z1Coins: 100),
        Z1User(uid: 'uid4', name: 'player 4', z1Coins: 100),
        Z1User(uid: 'uid5', name: 'player 5', z1Coins: 100),
        Z1User(uid: 'uid6', name: 'player 6', z1Coins: 100),
        Z1User(uid: 'uid7', name: 'player 7', z1Coins: 100),
        Z1User(uid: 'uid8', name: 'player 8', z1Coins: 100),
        Z1User(uid: 'uid9', name: 'player 9', z1Coins: 100),
        Z1User(uid: 'uid10', name: 'player 10', z1Coins: 100),
        Z1User(uid: 'uid11', name: 'player 11', z1Coins: 100),
        Z1User(uid: 'uid12', name: 'player 12', z1Coins: 100),
        Z1User(uid: 'uid13', name: 'player 13', z1Coins: 100),
        Z1User(uid: 'uid14', name: 'player 14', z1Coins: 100),
        Z1User(uid: 'uid15', name: 'player 15', z1Coins: 100),
        Z1User(uid: 'uid16', name: 'player 16', z1Coins: 100),
        Z1User(uid: 'uid17', name: 'player 17', z1Coins: 100),
        Z1User(uid: 'uid18', name: 'player 18', z1Coins: 100),
        Z1User(uid: 'uid19', name: 'player 19', z1Coins: 100),
        Z1User(uid: 'uid20', name: 'player 20', z1Coins: 100),
      ];

  static Future<Z1Track> getTrack(String trackId) async {
    return (await getTracks())
        .where((element) => element.trackId == trackId)
        .first;
  }

  static Future<List<Z1Track>> getTracks() async {
    final tracks = <Z1Track>[];

    // tracks.add(MockTrack2().getTrack());
    tracks.add(MockTrack3().getTrack());
    tracks.add(MockTrack4().getTrack());
    tracks.add(MockTrack5().getTrack());
    tracks.add(MockTrack6().getTrack());
    tracks.add(MockTrack11().getTrack());
    tracks.add(MockTrack12().getTrack());
    tracks.add(MockTrack2().getTrack());
    tracks.add(MockTrack7().getTrack());
    tracks.add(MockTrack8().getTrack());
    tracks.add(MockTrack9().getTrack());
    tracks.add(MockTrack10().getTrack());
    tracks.add(MockTrack13().getTrack());
    tracks.add(MockTrack14().getTrack());
    tracks.add(MockTrack15().getTrack());
    return tracks;
  }

  static Future<List<Z1Season>> getSeasons() async {
    return [
      Z1Season.fromMap(
        {
          'id': 'idSeason1',
          'name': 'Season 1',
          'version': '0',
          'z1TrackIds': [
            MockTrack13().getTrack().trackId,
            MockTrack14().getTrack().trackId,
            MockTrack15().getTrack().trackId,
            MockTrack11().getTrack().trackId,
            MockTrack12().getTrack().trackId,
          ],
        },
      ),
    ];
  }
}
