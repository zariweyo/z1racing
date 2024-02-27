part of 'mock_track.dart';

class MockTrack11 extends MockTrack {
  @override
  Z1Track getTrack() {
    return Z1Track.fromMap({
      'slots': [
        {'type': 'rect', 'length': 40.0},
        {'type': 'rect', 'length': 80.0, 'sensor': 'start'},
        {
          'type': 'curve',
          'angle': 60.0,
          'radius': 50.0,
          'added': false,
          'direction': 'left',
        },
        {'type': 'rect', 'length': 20.0},
        {
          'type': 'curve',
          'angle': 40.0,
          'radius': 50.0,
          'added': false,
          'direction': 'right',
        },
        {'type': 'rect', 'length': 40.0},
        {
          'type': 'curve',
          'angle': 90.0,
          'radius': 150.0,
          'added': false,
          'direction': 'right',
        },
        {
          'type': 'curve',
          'angle': 90.0,
          'radius': 90.0,
          'added': false,
          'direction': 'left',
        },
        {
          'type': 'curve',
          'angle': 90.0,
          'radius': 60.0,
          'added': false,
          'direction': 'left',
        },
        {
          'type': 'curve',
          'angle': 90.0,
          'radius': 90.0,
          'added': false,
          'direction': 'left',
        },
        {'type': 'rect', 'length': 80.0},
        {
          'type': 'curve',
          'angle': 90.0,
          'radius': 90.0,
          'added': false,
          'direction': 'right',
        },
        {'type': 'rect', 'length': 30.0},
        {
          'type': 'curve',
          'angle': 90.0,
          'radius': 90.0,
          'added': false,
          'direction': 'left',
        },
        {'type': 'rect', 'length': 80.0},
        {'type': 'rect', 'length': 80.0, 'sensor': 'finish'},
      ],
      'trackId': 'Mock2TrackId_b11',
      'name': 'The Mock 11 Track',
      'numLaps': 1,
      'initialDatetime': '2023-11-10T12:00:00Z',
      'version': 1,
      'season': 1,
      'chapter': 2,
      'enabled': true,
      'settings': {'dark': 0.6},
      'iaCars': [
        {
          'via': 2,
          'speed': 0.8,
          'avatar': 'girl_2',
          'delay': 4,
        },
        {
          'via': 5,
          'speed': 0.6,
          'avatar': 'girl_1',
          'delay': 3,
        },
        {
          'via': 4,
          'speed': 0.75,
          'avatar': 'girl_1',
          'delay': 4,
        }
      ],
    });
  }
}
