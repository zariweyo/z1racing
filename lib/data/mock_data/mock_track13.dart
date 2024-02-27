part of 'mock_track.dart';

class MockTrack13 extends MockTrack {
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
          'length': 340.0,
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
      'trackId': 'rookie_1',
      'name': 'Rookie I',
      'numLaps': 1,
      'version': 1,
      'enabled': true,
      'iaCars': [
        {
          'via': 1,
          'speed': 0.5,
          'avatar': 'girl_2',
          'delay': -1,
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
