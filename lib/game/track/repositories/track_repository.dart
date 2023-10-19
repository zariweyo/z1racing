import 'package:z1racing/game/track/models/track_model.dart';

class TrackRepository {
  List<TrackModel> getTrack() {
    List<Map<String, dynamic>> data = [
      {
        "type": "rect",
        "size": {
          "x": 60.0,
          "y": 60.0,
        }
      },
      {
        "type": "curve",
        "size": {
          "x": 90.0,
          "y": 90.0,
        },
        "radius": 90.0,
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
        "size": {
          "x": 60.0,
          "y": 60.0,
        },
        "radius": 60.0,
        "direction": "right",
        "closedAdded": "start"
      },
      {
        "type": "curve",
        "size": {
          "x": 100.0,
          "y": 100.0,
        },
        "radius": 100.0,
        "direction": "right",
        "closedAdded": "end"
      },
      {
        "type": "curve",
        "size": {
          "x": 100.0,
          "y": 100.0,
        },
        "radius": 100.0,
        "direction": "left",
        "closedAdded": "start"
      },
      {
        "type": "curve",
        "size": {
          "x": 60.0,
          "y": 60.0,
        },
        "radius": 60.0,
        "direction": "left",
        "closedAdded": "end"
      },
      {
        "type": "rect",
        "size": {
          "x": 300.0,
          "y": 120.0,
        }
      },
      {
        "type": "curve",
        "size": {
          "x": 120.0,
          "y": 120.0,
        },
        "radius": 150.0,
        "direction": "left",
        "closedAdded": "start"
      },
      {
        "type": "curve",
        "size": {
          "x": 120.0,
          "y": 120.0,
        },
        "radius": 120.0,
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
        "size": {
          "x": 60.0,
          "y": 60.0,
        },
        "radius": 73.0,
        "direction": "left",
        "closedAdded": "both"
      },
      {
        "type": "rect",
        "size": {
          "x": 129.5,
          "y": 60.0,
        }
      },
      {
        "type": "curve",
        "size": {
          "x": 50.0,
          "y": 50.0,
        },
        "radius": 50.0,
        "direction": "left",
        "closedAdded": "both"
      }
    ];
    return data.map((e) => TrackModel.fromMap(e)).toList();
  }
}
