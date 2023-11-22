part of 'mock_track.dart';

class MockTrack3 extends MockTrack {
  Z1Track getTrack() {
    return Z1Track.fromMap({
      "slots": [
        {
          "type": "rect",
          "size": {
            "x": 60.0,
            "y": 60.0,
          },
          "closedSide": "right",
          "closedAdded": "none"
        },
        {
          "type": "rect",
          "size": {
            "x": 60.0,
            "y": 60.0,
          },
          "sensor": "finish",
          "closedSide": "right",
          "closedAdded": "end"
        },
        {
          "type": "rect",
          "size": {
            "x": 187.0,
            "y": 60.0,
          },
        },
        {
          "type": "rect",
          "size": {
            "x": 60.0,
            "y": 60.0,
          }
        },
        {
          "type": "curve",
          "angle": 70.0,
          "radius": 90.0,
          "added": true,
          "direction": "left",
          "closedAdded": "start"
        },
        {
          "type": "rect",
          "size": {
            "x": 60.0,
            "y": 60.0,
          },
          "closedSide": "left",
          "closedAdded": "none"
        },
        {
          "type": "curve",
          "angle": 70.0,
          "radius": 90.0,
          "added": true,
          "direction": "left",
          "closedAdded": "end"
        },
        {
          "type": "rect",
          "size": {
            "x": 360.0,
            "y": 60.0,
          }
        },
        {
          "type": "curve",
          "angle": 90.0,
          "radius": 100.0,
          "added": true,
          "direction": "left",
          "closedAdded": "start"
        },
        {
          "type": "curve",
          "angle": 90.0,
          "radius": 90.0,
          "added": true,
          "direction": "left",
          "closedAdded": "none"
        },
        {
          "type": "curve",
          "angle": 60.0,
          "radius": 60.0,
          "added": true,
          "direction": "left",
          "closedAdded": "end"
        },
        {
          "type": "curve",
          "angle": 90.0,
          "radius": 90.0,
          "added": true,
          "direction": "right",
          "closedAdded": "start"
        },
        {
          "type": "curve",
          "angle": 75.0,
          "radius": 75.0,
          "added": true,
          "direction": "right",
          "closedAdded": "end"
        },
        {
          "type": "rect",
          "size": {
            "x": 58.0,
            "y": 60.0,
          }
        },
        {
          "type": "curve",
          "angle": 70.0,
          "radius": 90.0,
          "added": false,
          "direction": "right",
          "closedAdded": "none"
        },
        {
          "type": "curve",
          "angle": 90.0,
          "radius": 90.0,
          "added": true,
          "direction": "left",
          "closedAdded": "start"
        },
        {
          "type": "curve",
          "angle": 90.0,
          "radius": 90.0,
          "added": true,
          "direction": "left",
          "closedAdded": "none"
        },
        {
          "type": "curve",
          "angle": 60.0,
          "radius": 60.0,
          "added": true,
          "direction": "left",
          "closedAdded": "none"
        },
        {
          "type": "rect",
          "size": {
            "x": 90.0,
            "y": 60.0,
          },
          "closedSide": "right",
          "closedAdded": "start"
        },
      ],
      "trackId": "Mock2TrackId_b3",
      "name": "The Mock 3 Track",
      "numLaps": 5,
      "initialDatetime": "2023-12-12T12:00:00Z",
      "version": 1
    });
  }
}
