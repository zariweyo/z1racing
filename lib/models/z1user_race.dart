import 'package:collection/collection.dart';
import 'package:z1racing/extensions/duration_extension.dart';
import 'package:z1racing/extensions/string_extension.dart';

class Z1UserRace {
  final String uid;
  final String trackId;
  final Duration time;
  Duration bestLap;
  final List<Duration> lapTimes;
  final DateTime updated;
  Z1UserRaceMetadata metadata;

  String get id => "${trackId}_${uid}_${metadata.numLaps}";

  Z1UserRace(
      {required this.uid,
      required this.trackId,
      required this.time,
      required this.updated,
      required this.lapTimes,
      required this.bestLap,
      this.metadata = const Z1UserRaceMetadata()});

  Z1UserRace copyWith(
      {String? uid,
      String? trackId,
      Duration? time,
      Duration? bestLap,
      List<Duration>? lapTimes,
      DateTime? updated}) {
    return Z1UserRace(
        uid: uid ?? this.uid,
        trackId: trackId ?? this.trackId,
        time: time ?? this.time,
        bestLap: bestLap ?? this.bestLap,
        updated: updated ?? this.updated,
        lapTimes: lapTimes ?? this.lapTimes,
        metadata: this
            .metadata
            .copyWith(numLaps: (lapTimes ?? this.lapTimes).length));
  }

  addLaptime(Duration laptime) {
    if (lapTimes.isEmpty) {
      bestLap = laptime;
    } else {
      if (laptime < bestLap) {
        bestLap = laptime;
      }
    }

    lapTimes.add(laptime);
    metadata = metadata.copyWith(numLaps: lapTimes.length);
  }

  Duration get bestLapTime => bestLap != Duration.zero ? bestLap : lapTimes.min;

  int get secondsSinceEpoch => updated.millisecondsSinceEpoch;

  String get positionHash =>
      time.inMilliseconds.toString().toLimitHash(8) +
      bestLapTime.inMilliseconds.toString().toLimitHash(8) +
      secondsSinceEpoch.toString().toLimitHash(11);

  factory Z1UserRace.init(
      {required String uid,
      required String trackId,
      required String displayName}) {
    return Z1UserRace(
        uid: uid,
        trackId: trackId,
        time: Duration(),
        bestLap: Duration(),
        updated: DateTime.now(),
        lapTimes: [],
        metadata: Z1UserRaceMetadata(displayName: displayName));
  }

  factory Z1UserRace.fromMap(Map<String, dynamic> map) {
    return Z1UserRace(
        uid: map['uid'] ?? "",
        trackId: map['trackId'] ?? "",
        time: DurationExtension.fromMap(map['time']),
        bestLap: DurationExtension.fromMap(map['bestLap']),
        updated: map['updated'] != null
            ? DateTime.fromMillisecondsSinceEpoch(map['updated'], isUtc: true)
            : DateTime.now().toUtc(),
        lapTimes: DurationListExtension.fromMap(map['lapTimes']),
        metadata: map['metadata'] != null
            ? Z1UserRaceMetadata.fromMap(map['metadata'])
            : Z1UserRaceMetadata());
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "uid": uid,
      "trackId": trackId,
      "time": time.toMap(),
      "bestLap": bestLap.toMap(),
      "lapTimes": lapTimes.toMap(),
      "updated": updated.millisecondsSinceEpoch,
      "metadata": metadata.toJson(),
      "positionHash": positionHash
    };
  }

  Map<String, dynamic> toUpdateTimeAndBestLapJson() {
    return {
      "time": time.toMap(),
      "bestLap": bestLap.toMap(),
      "updated": updated.millisecondsSinceEpoch,
      "positionHash": positionHash
    };
  }

  Map<String, dynamic> toUpdateTimeJson() {
    return {
      "time": time.toMap(),
      "updated": updated.millisecondsSinceEpoch,
      "positionHash": positionHash
    };
  }

  Map<String, dynamic> toUpdateBestLapJson() {
    return {
      "bestLap": bestLap.toMap(),
      "updated": updated.millisecondsSinceEpoch,
      "positionHash": positionHash
    };
  }

  Map<String, dynamic> toUpdateMetadataJson() {
    return {
      "metadata": metadata.toJson(),
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
