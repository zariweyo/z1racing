extension DurationExtension on Duration {
  String toChronoString() {
    String _minutes = inMinutes < 10 ? "0${inMinutes}" : "${inMinutes}";
    int _secondsD = inSeconds % 60;
    String _seconds = _secondsD < 10 ? "0${_secondsD}" : "${_secondsD}";
    int _millisD = inMilliseconds % 1000;
    String _milliseconds = _millisD < 10
        ? "00${_millisD}"
        : _millisD < 100
            ? "0${_millisD}"
            : "${_millisD}";
    return "${_minutes}:${_seconds}.${_milliseconds}";
  }
}
