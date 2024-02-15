part of 'mock_track.dart';

class MockTrack1 extends MockTrack {
  @override
  Z1Track getTrack() {
    return Z1Track.fromMap({
      'slots': [
        {
          'type': 'rect',
          'size': {
            'x': 60.0,
            'y': 60.0,
          },
          'closedSide': 'left',
          'closedAdded': 'start',
          'sensor': 'finish_',
        },
        {
          'type': 'curve',
          'angle': 70.0,
          'radius': 90.0,
          'added': true,
          'direction': 'left',
          'closedAdded': 'none',
        },
        {
          'type': 'rect',
          'size': {
            'x': 60.0,
            'y': 60.0,
          },
          'closedSide': 'left',
          'closedAdded': 'end',
          'sensor': 'finish_',
        },
        {
          'type': 'curve',
          'angle': 30.0,
          'added': true,
          'radius': 60.0,
          'direction': 'right',
          'closedAdded': 'start',
        },
        {
          'type': 'curve',
          'added': true,
          'radius': 100.0,
          'direction': 'right',
          'closedAdded': 'end',
          'sensor': 'sensor',
        },
        {
          'type': 'curve',
          'added': true,
          'radius': 100.0,
          'direction': 'left',
          'closedAdded': 'start',
          'sensor': 'sensor',
        },
        {
          'type': 'curve',
          'angle': 40.0,
          'added': true,
          'radius': 60.0,
          'direction': 'left',
          'closedAdded': 'none',
        },
        {
          'type': 'rect',
          'size': {
            'x': 50.0,
            'y': 120.0,
          },
          'sensor': 'sensor',
          'closedSide': 'left',
          'closedAdded': 'end',
        },
        {
          'type': 'rect',
          'size': {
            'x': 250.0,
            'y': 120.0,
          },
          'sensor': 'finish_',
        },
        {
          'type': 'curve',
          'angle': 90.0,
          'added': true,
          'radius': 170.0,
          'direction': 'left',
          'closedAdded': 'both',
        },
        {
          'type': 'rect',
          'size': {
            'x': 150.0,
            'y': 60.0,
          },
        },
        {
          'type': 'rect',
          'size': {
            'x': 50.0,
            'y': 60.0,
          },
          'closedSide': 'left',
          'closedAdded': 'start',
        },
        {
          'type': 'curve',
          'added': true,
          'radius': 90.0,
          'angle': 70.0,
          'direction': 'left',
          'closedAdded': 'none',
        },
        {
          'type': 'rect',
          'size': {
            'x': 82.0,
            'y': 60.0,
          },
          'closedSide': 'left',
          'closedAdded': 'end',
        },
        {
          'type': 'rect',
          'size': {
            'x': 150.0,
            'y': 60.0,
          },
          'sensor': 'finish',
        },
        {
          'type': 'rect',
          'size': {
            'x': 50.0,
            'y': 60.0,
          },
          'closedSide': 'left',
          'closedAdded': 'start',
        },
        {
          'type': 'curve',
          'added': true,
          'radius': 50.0,
          'angle': 120.0,
          'direction': 'left',
          'closedAdded': 'none',
        },
        {
          'type': 'rect',
          'size': {
            'x': 65.5,
            'y': 60.0,
          },
          'closedSide': 'left',
          'closedAdded': 'end',
        },
        {
          'type': 'rect',
          'size': {
            'x': 253.80,
            'y': 60.0,
          },
        },
        {
          'type': 'curve',
          'radius': 90.0,
          'direction': 'left',
          'closedAdded': 'both',
        },
        {
          'type': 'rect',
          'size': {
            'x': 23.0,
            'y': 60.0,
          },
        },
      ],
      'trackId': 'Mock2TrackId_b1',
      'name': 'The Mock 1 Track',
      'numLaps': 5,
      'initialDatetime': '2023-11-23T12:00:00Z',
      'carInitAngle': 2.83,
      'version': 1,
      'vorder': 1,
      'enabled': true,
    });
  }
}
