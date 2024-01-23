part of 'mock_track.dart';

class MockTrack5 extends MockTrack {
  @override
  Z1Track getTrack() {
    return Z1Track.fromMap({
      'slots': [
        {'type': 'rect', 'length': 80.0},
        {
          'type': 'curve',
          'angle': 90.0,
          'radius': 90.0,
          'added': false,
          'direction': 'left',
        },
        {
          'type': 'rect',
          'length': 130.0,
          'closedSide': 'right',
          'closedAdded': 'both',
        },
        {
          'type': 'curve',
          'angle': 90.0,
          'radius': 90.0,
          'added': false,
          'direction': 'left',
        },
        {'type': 'rect', 'length': 80.0, 'sensor': 'finish'},
        {'type': 'rect', 'length': 80.0},
        {
          'type': 'curve',
          'angle': 90.0,
          'radius': 90.0,
          'added': false,
          'direction': 'left',
        },
        {
          'type': 'rect',
          'length': 160.0,
          'closedSide': 'right',
          'closedAdded': 'both',
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
          'direction': 'right',
        },
        {
          'type': 'rect',
          'length': 140.0,
          'closedSide': 'left',
          'closedAdded': 'both',
        },
        {'type': 'rect', 'length': 70.0},
        {
          'type': 'curve',
          'angle': 90.0,
          'radius': 90.0,
          'added': false,
          'direction': 'right',
        },
        {
          'type': 'rect',
          'length': 100.0,
          'closedSide': 'left',
          'closedAdded': 'both',
        },
        {'type': 'rect', 'length': 300.0},
        {
          'type': 'curve',
          'angle': 90.0,
          'radius': 90.0,
          'added': false,
          'direction': 'right',
        },
        {
          'type': 'rect',
          'length': 100.0,
          'closedSide': 'left',
          'closedAdded': 'both',
        },
        {'type': 'rect', 'length': 250.0},
        {
          'type': 'curve',
          'angle': 90.0,
          'radius': 90.0,
          'added': false,
          'direction': 'right',
        },
        {'type': 'rect', 'length': 175.0},
        {
          'type': 'curve',
          'angle': 90.0,
          'radius': 90.0,
          'direction': 'right',
          'added': true,
          'closedAdded': 'start',
        },
        {
          'type': 'rect',
          'length': 30.0,
          'closedSide': 'right',
          'closedAdded': 'none',
        },
        {
          'type': 'curve',
          'angle': 90.0,
          'radius': 90.0,
          'direction': 'right',
          'added': true,
          'closedAdded': 'end',
        },
      ],
      'objects': [
        {
          'type': 'tree',
          'row': 1,
          'column': 1,
          'position': {
            'x': 150.0,
            'y': 50.0,
          },
        },
        {
          'type': 'tree',
          'row': 0,
          'column': 1,
          'position': {
            'x': 180.0,
            'y': 30.0,
          },
        },
        {
          'type': 'tree',
          'row': 0,
          'column': 2,
          'position': {
            'x': 140.0,
            'y': 40.0,
          },
        },
        {
          'type': 'tree',
          'row': 2,
          'column': 3,
          'position': {
            'x': 360.0,
            'y': 40.0,
          },
        },
        {
          'type': 'tree',
          'row': 2,
          'column': 3,
          'position': {
            'x': 360.0,
            'y': 100.0,
          },
        },
        {
          'type': 'tree',
          'row': 2,
          'column': 3,
          'position': {
            'x': 360.0,
            'y': 160.0,
          },
        },
        {
          'type': 'tree',
          'row': 2,
          'column': 2,
          'position': {
            'x': -120.0,
            'y': 40.0,
          },
        },
        {
          'type': 'tree',
          'row': 2,
          'column': 2,
          'position': {
            'x': -140.0,
            'y': 320.0,
          },
        },
        {
          'type': 'tree',
          'row': 2,
          'column': 2,
          'position': {
            'x': -80.0,
            'y': 320.0,
          },
        },
        {
          'type': 'tree',
          'row': 2,
          'column': 2,
          'position': {
            'x': -20.0,
            'y': 320.0,
          },
        }
      ],
      'trackId': 'Mock2TrackId_b5',
      'name': 'The Mock 5 Track',
      'numLaps': 3,
      'version': 1,
      'order': 5,
      'enabled': true,
      'carInitAngle': 3.055,
    });
  }
}
