part of 'mock_track.dart';

class MockTrack6 extends MockTrack {
  @override
  Z1Track getTrack() {
    return Z1Track.fromMap({
      'slots': [
        {'type': 'rect', 'length': 180.0},
        {
          'type': 'curve',
          'angle': 90.0,
          'radius': 90.0,
          'added': true,
          'closedAdded': 'start',
          'direction': 'left',
        },
        {
          'type': 'curve',
          'angle': 45.0,
          'radius': 90.0,
          'added': true,
          'closedAdded': 'end',
          'direction': 'left',
        },
        {
          'type': 'curve',
          'angle': 45.0,
          'radius': 90.0,
          'added': true,
          'closedAdded': 'start',
          'direction': 'right',
        },
        {
          'type': 'curve',
          'angle': 90.0,
          'radius': 90.0,
          'added': true,
          'closedAdded': 'end',
          'direction': 'right',
        },
        {
          'type': 'curve',
          'angle': 90.0,
          'radius': 90.0,
          'added': true,
          'closedAdded': 'start',
          'direction': 'left',
        },
        {
          'type': 'curve',
          'angle': 90.0,
          'radius': 90.0,
          'added': true,
          'closedAdded': 'end',
          'direction': 'left',
        },
        {
          'type': 'rect',
          'length': 50.0,
          'closedSide': 'right',
          'closedAdded': 'start',
        },
        {
          'type': 'rect',
          'length': 50.0,
          'sensor': 'finish',
          'closedSide': 'right',
          'closedAdded': 'end',
        },
        {
          'type': 'curve',
          'angle': 45.0,
          'radius': 90.0,
          'added': false,
          'direction': 'left',
        },
        {'type': 'rect', 'length': 100.0},
        {
          'type': 'curve',
          'angle': 45.0,
          'radius': 90.0,
          'added': false,
          'direction': 'left',
        },
        {
          'type': 'curve',
          'angle': 90.0,
          'radius': 90.0,
          'added': true,
          'closedAdded': 'start',
          'direction': 'right',
        },
        {
          'type': 'curve',
          'angle': 90.0,
          'radius': 90.0,
          'added': true,
          'closedAdded': 'end',
          'direction': 'right',
        },
        {
          'type': 'rect',
          'length': 100.0,
          'closedSide': 'left',
          'closedAdded': 'both',
        },
        {
          'type': 'curve',
          'angle': 90.0,
          'radius': 90.0,
          'added': false,
          'direction': 'right',
        },
        {'type': 'rect', 'length': 100.0},
        {
          'type': 'curve',
          'angle': 90.0,
          'radius': 90.0,
          'added': true,
          'closedAdded': 'start',
          'direction': 'left',
        },
        {
          'type': 'curve',
          'angle': 90.0,
          'radius': 90.0,
          'added': true,
          'closedAdded': 'end',
          'direction': 'left',
        },
        {
          'type': 'rect',
          'length': 100.0,
          'closedSide': 'right',
          'closedAdded': 'both',
        },
        {'type': 'rect', 'length': 100.0},
        {
          'type': 'curve',
          'angle': 90.0,
          'radius': 90.0,
          'added': false,
          'direction': 'left',
        },
        {'type': 'rect', 'length': 272.0},
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
          'added': true,
          'closedAdded': 'both',
          'direction': 'right',
        },
        {
          'type': 'curve',
          'angle': 90.0,
          'radius': 90.0,
          'added': true,
          'closedAdded': 'both',
          'direction': 'left',
        },
      ],
      'objects': [
        {
          'type': 'tree1',
          'row': 1,
          'column': 1,
          'position': {
            'x': 430.0,
            'y': 250.0,
          },
        },
        {
          'type': 'tree1',
          'row': 0,
          'column': 1,
          'position': {
            'x': 430.0,
            'y': 280.0,
          },
        },
        {
          'type': 'tree1',
          'row': 0,
          'column': 2,
          'position': {
            'x': 340.0,
            'y': 250.0,
          },
        },
        {
          'type': 'tree1',
          'row': 0,
          'column': 2,
          'position': {
            'x': 340.0,
            'y': 280.0,
          },
        },
        {
          'type': 'tree1',
          'row': 1,
          'column': 2,
          'position': {
            'x': 590.0,
            'y': -10.0,
          },
        },
        {
          'type': 'tree1',
          'row': 1,
          'column': 2,
          'position': {
            'x': 590.0,
            'y': -50.0,
          },
        },
        {
          'type': 'tree1',
          'row': 1,
          'column': 2,
          'position': {
            'x': 590.0,
            'y': 110.0,
          },
        },
        {
          'type': 'tree1',
          'row': 1,
          'column': 2,
          'position': {
            'x': 80.0,
            'y': 240.0,
          },
        },
        {
          'type': 'tree1',
          'row': 1,
          'column': 2,
          'position': {
            'x': 60.0,
            'y': -70.0,
          },
        },
        {
          'type': 'tree1',
          'row': 1,
          'column': 0,
          'position': {
            'x': 250.0,
            'y': -110.0,
          },
        },
        {
          'type': 'tree1',
          'row': 1,
          'column': 0,
          'position': {
            'x': 300.0,
            'y': -110.0,
          },
        },
        {
          'type': 'tree2',
          'row': 0,
          'column': 0,
          'position': {
            'x': 40.0,
            'y': 110.0,
          },
        },
        {
          'type': 'tree2',
          'row': 0,
          'column': 0,
          'position': {
            'x': 40.0,
            'y': 140.0,
          },
        },
        {
          'type': 'tree2',
          'row': 0,
          'column': 0,
          'position': {
            'x': 40.0,
            'y': 170.0,
          },
        },
        {
          'type': 'tree2',
          'row': 0,
          'column': 0,
          'position': {
            'x': 40.0,
            'y': 200.0,
          },
        }
      ],
      'trackId': 'Mock2TrackId_b6',
      'name': 'The Mock 6 Track',
      'numLaps': 3,
      'version': 1,
      'order': 6,
      'enabled': true,
      'carInitAngle': 3.055,
    });
  }
}
