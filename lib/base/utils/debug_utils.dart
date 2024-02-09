import 'dart:io';

class DebugFps {
  Duration total = Duration.zero;
  int last = 0;
  final int secondsSteps;
  final int desiredFps;

  DebugFps({required this.desiredFps, required this.secondsSteps});

  void simulateDelayFps({
    required double dt,
  }) {
    total += Duration(milliseconds: (dt * 1000).toInt());

    if (total.inSeconds % secondsSteps == 0 && last != total.inSeconds) {
      last = total.inSeconds;
      const simulatedLoadTime = 50;
      final msPerFrame = (1000 / desiredFps).round();
      if (simulatedLoadTime > msPerFrame) {
        sleep(Duration(milliseconds: simulatedLoadTime - msPerFrame));
      }
    }
  }
}
