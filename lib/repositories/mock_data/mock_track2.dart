part of 'mock_track.dart';

class MockTrack2 extends MockTrack {
  @override
  Z1Track getTrack() {
    return Z1Track.fromMap({
      'slots': [
        {
          'type': 'rect',
          'size': {
            'x': 100.0,
            'y': 60.0,
          },
          'closedSide': 'left',
          'closedAdded': 'none',
        },
        {
          'type': 'rect',
          'size': {
            'x': 100.0,
            'y': 60.0,
          },
          'closedSide': 'left',
          'closedAdded': 'none',
          'sensor': 'finish',
        },
        {
          'type': 'rect',
          'size': {
            'x': 600.0,
            'y': 60.0,
          },
          'closedSide': 'left',
          'closedAdded': 'none',
        },
        {
          'type': 'curve',
          'angle': 90.0,
          'radius': 90.0,
          'added': true,
          'direction': 'left',
          'closedAdded': 'none',
        },
        {
          'type': 'curve',
          'angle': 90.0,
          'radius': 90.0,
          'added': true,
          'direction': 'left',
          'closedAdded': 'none',
        },
        {
          'type': 'rect',
          'size': {
            'x': 800.0,
            'y': 60.0,
          },
          'closedSide': 'left',
          'closedAdded': 'none',
        },
        {
          'type': 'curve',
          'angle': 90.0,
          'radius': 90.0,
          'added': true,
          'direction': 'left',
          'closedAdded': 'none',
        },
        {
          'type': 'curve',
          'angle': 90.0,
          'radius': 90.0,
          'added': true,
          'direction': 'left',
          'closedAdded': 'none',
        },
      ],
      'trackId': 'Mock2TrackId_b2',
      'name': 'The Mock 2 Track',
      'numLaps': 3,
      'initialDatetime': '2023-11-20T12:00:00Z',
      'version': 1,
    });
  }
}
