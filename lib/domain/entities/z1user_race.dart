import 'package:collection/collection.dart';
import 'package:z1racing/extensions/duration_extension.dart';
import 'package:z1racing/extensions/string_extension.dart';

class Z1UserRace {
  final String uid;
  final String trackId;
  final int numLaps;
  final Duration time;
  Duration bestLap;
  final List<Duration> lapTimes;
  final DateTime updated;
  Z1UserRaceMetadata metadata;
  final int position;

  String get id => '${trackId}_${uid}_$numLaps';

  Z1UserRace({
    required this.uid,
    required this.trackId,
    required this.numLaps,
    required this.time,
    required this.updated,
    required this.lapTimes,
    required this.bestLap,
    required this.position,
    this.metadata = const Z1UserRaceMetadata(),
  });

  Z1UserRace copyWith({
    String? uid,
    String? trackId,
    int? numLaps,
    Duration? time,
    Duration? bestLap,
    List<Duration>? lapTimes,
    DateTime? updated,
    int? position,
  }) {
    return Z1UserRace(
      uid: uid ?? this.uid,
      trackId: trackId ?? this.trackId,
      numLaps: numLaps ?? this.numLaps,
      time: time ?? this.time,
      bestLap: bestLap ?? this.bestLap,
      updated: updated ?? this.updated,
      lapTimes: lapTimes ?? this.lapTimes,
      metadata: metadata.copyWith(numLaps: (lapTimes ?? this.lapTimes).length),
      position: position ?? this.position,
    );
  }

  void addLaptime(Duration laptime) {
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

  factory Z1UserRace.init({
    required String uid,
    required String trackId,
    required int numLaps,
    required String displayName,
  }) {
    return Z1UserRace(
      uid: uid,
      trackId: trackId,
      numLaps: numLaps,
      time: Duration.zero,
      bestLap: Duration.zero,
      updated: DateTime.now(),
      lapTimes: [],
      metadata: Z1UserRaceMetadata(displayName: displayName),
      position: 0,
    );
  }

  factory Z1UserRace.fromMap(Map<String, dynamic> map) {
    return Z1UserRace(
      uid: map['uid']?.toString() ?? '',
      trackId: map['trackId']?.toString() ?? '',
      position: int.parse(map['position']?.toString() ?? '0'),
      numLaps: map['lapTimes'] is List<dynamic>
          ? (map['lapTimes'] as List).length
          : 0,
      time: DurationExtension.fromMap(map['time']),
      bestLap: DurationExtension.fromMap(map['bestLap']),
      updated: map['updated'] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              int.tryParse(map['updated'].toString()) ?? 0,
              isUtc: true,
            )
          : DateTime.now().toUtc(),
      lapTimes: map['lapTimes'] is List<dynamic>
          ? DurationListExtension.fromMap(map['lapTimes'] as List<dynamic>)
          : [],
      metadata: map['metadata'] != null &&
              map['metadata'] is Map<String, dynamic>
          ? Z1UserRaceMetadata.fromMap(map['metadata'] as Map<String, dynamic>)
          : const Z1UserRaceMetadata(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'uid': uid,
      'trackId': trackId,
      'numLaps': numLaps,
      'time': time.toMap(),
      'bestLap': bestLap.toMap(),
      'lapTimes': lapTimes.toMap(),
      'updated': updated.millisecondsSinceEpoch,
      'metadata': metadata.toJson(),
      'positionHash': positionHash,
      'position': position,
    };
  }

  Map<String, dynamic> toUpdateTimeAndBestLapJson() {
    return {
      'time': time.toMap(),
      'lapTimes': lapTimes.toMap(),
      'bestLap': bestLap.toMap(),
      'updated': updated.millisecondsSinceEpoch,
      'positionHash': positionHash,
      'position': position,
    };
  }

  Map<String, dynamic> toUpdateTimeJson() {
    return {
      'time': time.toMap(),
      'lapTimes': lapTimes.toMap(),
      'updated': updated.millisecondsSinceEpoch,
      'positionHash': positionHash,
      'position': position,
    };
  }

  Map<String, dynamic> toUpdateBestLapJson() {
    return {
      'bestLap': bestLap.toMap(),
      'updated': updated.millisecondsSinceEpoch,
      'positionHash': positionHash,
      'position': position,
    };
  }

  Map<String, dynamic> toUpdateMetadataJson() {
    return {
      'metadata': metadata.toJson(),
    };
  }
}

class Z1UserRaceMetadata {
  final int numLaps;
  final String displayName;
  final String carId;

  const Z1UserRaceMetadata({
    this.numLaps = 0,
    this.displayName = '',
    this.carId = '',
  });

  factory Z1UserRaceMetadata.fromMap(Map<String, dynamic> map) {
    return Z1UserRaceMetadata(
      carId: map['carId']?.toString() ?? '',
      displayName: map['displayName']?.toString() ?? '',
      numLaps: int.tryParse(map['numLaps']?.toString() ?? '0') ?? 0,
    );
  }

  Z1UserRaceMetadata copyWith({
    int? numLaps,
    String? carId,
    String? displayName,
  }) {
    return Z1UserRaceMetadata(
      numLaps: numLaps ?? this.numLaps,
      carId: carId ?? this.carId,
      displayName: displayName ?? this.displayName,
    );
  }

  dynamic toJson() {
    return {
      'numLaps': numLaps,
      'carId': carId,
      'displayName': displayName,
    };
  }
}
