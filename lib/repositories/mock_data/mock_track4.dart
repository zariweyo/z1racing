part of 'mock_track.dart';

class MockTrack4 extends MockTrack {
  Z1Track getTrack() {
    return Z1Track.fromMap({
      "slots": [
        {"type": "rect", "length": 50.0},
        {"type": "rect", "length": 50.0, "sensor": "finish"},
        {
          "type": "curve",
          "angle": 90.0,
          "radius": 90.0,
          "added": false,
          "direction": "left"
        },
        {"type": "rect", "length": 100.0},
        {
          "type": "curve",
          "angle": 90.0,
          "radius": 90.0,
          "added": false,
          "direction": "left"
        },
        {"type": "rect", "length": 100.0},
        {
          "type": "curve",
          "angle": 90.0,
          "radius": 90.0,
          "added": false,
          "direction": "left"
        },
        {"type": "rect", "length": 100.0},
        {
          "type": "curve",
          "angle": 90.0,
          "radius": 90.0,
          "added": false,
          "direction": "left"
        },
      ],
      "trackId": "Mock2TrackId_b4",
      "name": "The Mock 4 Track",
      "numLaps": 2,
      "initialDatetime": "2023-11-10T12:00:00Z",
      "version": 1
    });
  }
}
