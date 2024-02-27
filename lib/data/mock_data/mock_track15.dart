part of 'mock_track.dart';

class MockTrack15 extends MockTrack {
  @override
  Z1Track getTrack() {
    return Z1Track.fromMap({
      'slots': [
        {
          'type': 'rect',
          'length': 20.0,
          'closedSide': 'none',
          'closedAdded': 'none',
        },
        {
          'type': 'rect',
          'length': 50.0,
          'closedSide': 'none',
          'closedAdded': 'none',
          'sensor': 'start',
        },
        {
          'type': 'rect',
          'length': 50.0,
          'closedSide': 'none',
          'closedAdded': 'none',
        },
        {
          'type': 'rect',
          'length': 170.0,
          'closedSide': 'none',
          'closedAdded': 'none',
        },
        {
          'type': 'curve',
          'angle': 90.0,
          'radius': 90.0,
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
          'radius': 90.0,
          'added': false,
          'direction': 'left',
        },
        {
          'type': 'rect',
          'length': 140.0,
          'closedSide': 'none',
          'closedAdded': 'none',
        },
        {
          'type': 'rect',
          'length': 50.0,
          'closedSide': 'none',
          'closedAdded': 'none',
          'sensor': 'finish',
        },
      ],
      'objects': [],
      'trackId': 'rookie_rain',
      'name': 'Rookie Rain',
      'numLaps': 1,
      'version': 1,
      'enabled': true,
      'settings': {'slide': 2, 'rain': 1.5},
      'iaCars': [
        {
          'via': 1,
          'speed': 0.5,
          'avatar': 'girl_2',
          'delay': -1,
        },
        {
          'via': 3,
          'speed': 0.4,
          'avatar': 'boy_1',
          'delay': 2,
        },
        {
          'via': 6,
          'speed': 0.3,
          'avatar': 'girl_1',
          'delay': -1,
        }
      ],
    });
  }
}
