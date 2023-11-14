import 'package:z1racing/models/z1track.dart';
import 'package:z1racing/repositories/track_repository.dart';

class TrackRepositoryMock extends TrackRepository {
  @override
  Future<Z1Track> getTrack() async {
    Map<String, dynamic> map = {
      "slots": [
        {
          "type": "rect",
          "size": {
            "x": 60.0,
            "y": 60.0,
          },
          "closedSide": "left",
          "closedAdded": "start",
          "sensor": "finish_"
        },
        {
          "type": "curve",
          "angle": 70.0,
          "radius": 90.0,
          "added": true,
          "direction": "left",
          "closedAdded": "none"
        },
        {
          "type": "rect",
          "size": {
            "x": 60.0,
            "y": 60.0,
          },
          "closedSide": "left",
          "closedAdded": "end",
          "sensor": "finish_"
        },
        {
          "type": "curve",
          "angle": 30.0,
          "added": true,
          "radius": 60.0,
          "direction": "right",
          "closedAdded": "start"
        },
        {
          "type": "curve",
          "added": true,
          "radius": 100.0,
          "direction": "right",
          "closedAdded": "end",
          "sensor": "sensor"
        },
        {
          "type": "curve",
          "added": true,
          "radius": 100.0,
          "direction": "left",
          "closedAdded": "start",
          "sensor": "sensor"
        },
        {
          "type": "curve",
          "angle": 40.0,
          "added": true,
          "radius": 60.0,
          "direction": "left",
          "closedAdded": "none"
        },
        {
          "type": "rect",
          "size": {
            "x": 50.0,
            "y": 120.0,
          },
          "sensor": "sensor",
          "closedSide": "left",
          "closedAdded": "end"
        },
        {
          "type": "rect",
          "size": {
            "x": 250.0,
            "y": 120.0,
          },
          "sensor": "finish_"
        },
        {
          "type": "curve",
          "angle": 90.0,
          "added": true,
          "radius": 170.0,
          "direction": "left",
          "closedAdded": "both"
        },
        {
          "type": "rect",
          "size": {
            "x": 150.0,
            "y": 60.0,
          },
        },
        {
          "type": "rect",
          "size": {
            "x": 50.0,
            "y": 60.0,
          },
          "closedSide": "left",
          "closedAdded": "start",
        },
        {
          "type": "curve",
          "added": true,
          "radius": 90.0,
          "angle": 70.0,
          "direction": "left",
          "closedAdded": "none"
        },
        {
          "type": "rect",
          "size": {
            "x": 82.0,
            "y": 60.0,
          },
          "closedSide": "left",
          "closedAdded": "end",
        },
        {
          "type": "rect",
          "size": {
            "x": 150.0,
            "y": 60.0,
          },
          "sensor": "finish"
        },
        {
          "type": "rect",
          "size": {
            "x": 50.0,
            "y": 60.0,
          },
          "closedSide": "left",
          "closedAdded": "start",
        },
        {
          "type": "curve",
          "added": true,
          "radius": 50.0,
          "angle": 120.0,
          "direction": "left",
          "closedAdded": "none"
        },
        {
          "type": "rect",
          "size": {
            "x": 65.5,
            "y": 60.0,
          },
          "closedSide": "left",
          "closedAdded": "end",
        },
        {
          "type": "rect",
          "size": {
            "x": 253.80,
            "y": 60.0,
          }
        },
        {
          "type": "curve",
          "radius": 90.0,
          "direction": "left",
          "closedAdded": "both"
        },
        {
          "type": "rect",
          "size": {
            "x": 23.0,
            "y": 60.0,
          }
        },
      ],
      "trackId": "Mock2TrackId_b1",
      "name": "The Mock 2 Track",
      "numLaps": 5,
    };
    return Z1Track.fromMap(map);
  }
}
