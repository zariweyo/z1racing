extension DurationExtension on Duration {
  String toChronoString() {
    return '${minutesString()}:${secondsString()}.${millisString()}';
  }

  String minutesString() {
    final minutes = inMinutes < 10 ? '0$inMinutes' : '$inMinutes';
    return minutes;
  }

  String secondsString() {
    final secondsD = inSeconds % 60;
    final seconds = secondsD < 10 ? '0$secondsD' : '$secondsD';
    return seconds;
  }

  String millisString() {
    final millisD = inMilliseconds % 1000;
    final milliseconds = millisD < 10
        ? '00$millisD'
        : millisD < 100
            ? '0$millisD'
            : '$millisD';
    return milliseconds;
  }

  static Duration fromMap(dynamic millis) {
    final value = int.tryParse(millis.toString());
    if (value == null) {
      return Duration.zero;
    }

    return Duration(milliseconds: value);
  }

  int toMap() {
    return inMilliseconds;
  }
}

extension DurationListExtension on List<Duration> {
  static List<Duration> fromMap(List<dynamic> millis) {
    return millis.map(DurationExtension.fromMap).toList();
  }

  List<int> toMap() {
    return map((e) => e.toMap()).toList();
  }
}
