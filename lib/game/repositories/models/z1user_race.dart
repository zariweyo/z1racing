import 'package:collection/collection.dart';
import 'package:z1racing/extensions/duration_extension.dart';

class Z1UserRace {
  final String uid;
  final String trackId;
  final Duration time;
  final List<Duration> lapTimes;
  final DateTime updated;
  Z1UserRaceMetadata metadata;

  String get id => "${trackId}_${metadata.numLaps}";

  Z1UserRace(
      {required this.uid,
      required this.trackId,
      required this.time,
      required this.updated,
      required this.lapTimes,
      this.metadata = const Z1UserRaceMetadata()});

  Z1UserRace copyWith(
      {String? uid,
      String? trackId,
      Duration? time,
      List<Duration>? lapTimes,
      DateTime? updated}) {
    return Z1UserRace(
        uid: uid ?? this.uid,
        trackId: trackId ?? this.trackId,
        time: time ?? this.time,
        updated: updated ?? this.updated,
        lapTimes: lapTimes ?? this.lapTimes,
        metadata: this
            .metadata
            .copyWith(numLaps: (lapTimes ?? this.lapTimes).length));
  }

  addLaptime(Duration laptime) {
    lapTimes.add(laptime);
    metadata = metadata.copyWith(numLaps: lapTimes.length);
  }

  Duration get bestLapTime => lapTimes.min;

  factory Z1UserRace.init(
      {required String uid,
      required String trackId,
      required String displayName}) {
    return Z1UserRace(
        uid: uid,
        trackId: trackId,
        time: Duration(),
        updated: DateTime.now(),
        lapTimes: [],
        metadata: Z1UserRaceMetadata(displayName: displayName));
  }

  factory Z1UserRace.fromMap(Map<String, dynamic> map) {
    return Z1UserRace(
        uid: map['uid'] ?? "",
        trackId: map['trackId'] ?? "",
        time: DurationExtension.fromMap(map['time']),
        updated: map['updated'] != null
            ? DateTime.fromMillisecondsSinceEpoch(map['updated'], isUtc: true)
            : DateTime.now().toUtc(),
        lapTimes: DurationListExtension.fromMap(map['lapTimes']),
        metadata: map['metadata'] != null
            ? Z1UserRaceMetadata.fromMap(map['metadata'])
            : Z1UserRaceMetadata());
  }

  dynamic toJson() {
    return {
      "id": id,
      "uid": uid,
      "trackId": trackId,
      "time": time.toMap(),
      "lapTimes": lapTimes.toMap(),
      "updated": updated.millisecondsSinceEpoch,
      "metadata": metadata.toJson()
    };
  }
}

class Z1UserRaceMetadata {
  final int numLaps;
  final String displayName;
  final String carId;

  const Z1UserRaceMetadata(
      {this.numLaps = 0, this.displayName = "", this.carId = ""});

  factory Z1UserRaceMetadata.fromMap(Map<String, dynamic> map) {
    return Z1UserRaceMetadata(
        carId: map['carId'] ?? "",
        displayName: map['displayName'] ?? "",
        numLaps: map['numLaps'] ?? 0);
  }

  Z1UserRaceMetadata copyWith(
      {int? numLaps, String? carId, String? displayName}) {
    return Z1UserRaceMetadata(
      numLaps: numLaps ?? this.numLaps,
      carId: carId ?? this.carId,
      displayName: displayName ?? this.displayName,
    );
  }

  dynamic toJson() {
    return {
      "numLaps": numLaps,
      "carId": carId,
      "displayName": displayName,
    };
  }
}
