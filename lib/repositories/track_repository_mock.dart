import 'package:z1racing/models/z1track.dart';
import 'package:z1racing/repositories/track_repository.dart';
import 'package:z1racing/game/track/models/slot_model.dart';

class TrackRepositoryMock extends TrackRepository {
  @override
  Future<Z1Track> getTrack() async {
    List<Map<String, dynamic>> slots = [
      {
        "type": "rect",
        "size": {
          "x": 60.0,
          "y": 60.0,
        },
        "sensor": "finish"
      },
      {
        "type": "curve",
        "angle": 70.0,
        "radius": 90.0,
        "added": true,
        "direction": "left",
        "closedAdded": "both"
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
        "closedAdded": "end"
      },
      {
        "type": "rect",
        "size": {
          "x": 300.0,
          "y": 120.0,
        },
        "sensor": "sensor"
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
          "x": 200.0,
          "y": 60.0,
        },
        "sensor": "sensor"
      },
      {
        "type": "curve",
        "added": true,
        "radius": 90.0,
        "angle": 70.0,
        "direction": "left",
        "closedAdded": "both"
      },
      {
        "type": "rect",
        "size": {
          "x": 282.0,
          "y": 60.0,
        }
      },
      {
        "type": "curve",
        "added": true,
        "radius": 90.0,
        "angle": 140.0,
        "direction": "left",
        "closedAdded": "both"
      },
      {
        "type": "rect",
        "size": {
          "x": 325.5,
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
          "x": 35.0,
          "y": 60.0,
        }
      },
    ];
    await Future.delayed(Duration(seconds: 3));
    return Z1Track(
        trackId: "Mock2TrackId",
        name: "The Mock 2 Track",
        numLaps: 5,
        slots: slots.map((e) => SlotModel.fromMap(e)).toList());
  }
}
