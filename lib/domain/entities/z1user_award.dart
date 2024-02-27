import 'package:z1racing/extensions/duration_extension.dart';

class Z1UserAward {
  final String trackId;
  final Duration time;
  final Duration bestLap;
  final int rating;

  Z1UserAward({
    required this.trackId,
    required this.time,
    required this.bestLap,
    required this.rating,
  });

  Z1UserAward copyWith({
    String? trackId,
    Duration? time,
    Duration? bestLap,
    int? rating,
  }) {
    return Z1UserAward(
      trackId: trackId ?? this.trackId,
      time: time ?? this.time,
      bestLap: bestLap ?? this.bestLap,
      rating: rating ?? this.rating,
    );
  }

  factory Z1UserAward.fromMap(Map<String, dynamic> map) {
    return Z1UserAward(
      trackId: map['trackId']?.toString() ?? '',
      time: DurationExtension.fromMap(map['time']),
      bestLap: DurationExtension.fromMap(map['bestLap']),
      rating: int.parse(map['rating']?.toString() ?? '0'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'trackId': trackId,
      'time': time.toMap(),
      'bestLap': bestLap.toMap(),
      'rating': rating,
    };
  }
}
